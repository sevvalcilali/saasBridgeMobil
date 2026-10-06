import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'sse.dart';

/// Sunucunun reddi: 4xx + `{ok:false, hata}` — `hata` kullanıcıya gösterilir (sözleşme).
class SunucuHatasi implements Exception {
  const SunucuHatasi(this.metin);

  final String metin;

  @override
  String toString() => metin;
}

/// Canlı akıştan gelen olay (`SunucuIstemcisi.olaylar`).
sealed class SunucuOlayi {
  const SunucuOlayi();
}

/// Akış açıldı; sunucu yayınlıyor.
class Baglandi extends SunucuOlayi {
  const Baglandi();
}

/// Yeni anlık durum (`/state` ile aynı JSON).
class DurumGeldi extends SunucuOlayi {
  const DurumGeldi(this.durum);

  final Map<String, dynamic> durum;
}

/// Akış koptu ya da açılamadı; istemci bekleyip yeniden dener.
class Koptu extends SunucuOlayi {
  const Koptu();
}

/// Sunucuyla konuşan TEK yer (web `src/api/client.js` ile aynı davranış): açılışta `/state`,
/// sonra `/events` canlı akışı; kopunca geri çekmeli bekleyip yeniden bağlanır; ~2 Hz
/// yayında `sessizlik` boyunca hiç mesaj gelmezse soket ölmüş sayılır. Paket yok: `dart:io`.
class SunucuIstemcisi {
  SunucuIstemcisi(
    String adres, {
    HttpClient? istemci,
    Duration Function(int deneme)? bekleme,
    this.sessizlik = const Duration(seconds: 6),
  }) : adres = adres.replaceAll(RegExp(r'/+$'), ''),
       _istemci = (istemci ?? HttpClient())..connectionTimeout = _baglantiSuresi,
       _bekleme = bekleme ?? _geriCekme;

  final String adres;
  final Duration sessizlik;
  final HttpClient _istemci;
  final Duration Function(int deneme) _bekleme;
  bool _acik = true;

  /// Her `olaylar()` çağrısı yeni bir nesil; `akisiKes` nesli ilerletir, eski döngü bekleme süresinden
  /// uyanınca kendi neslinin geçtiğini görüp biter (ikinci akış açmaz, soket sızmaz).
  int _nesil = 0;
  HttpClientRequest? _akisIstegi;
  StreamIterator<String>? _akisOkuyucu;

  /// Sinyal grafiğinin verisi (history) telefona gelmez: Wi-Fi ve sunucu yükü düşer.
  static const String _sorgu = '?grafik=0';
  static const Duration _ilkBekleme = Duration(milliseconds: 500);
  static const Duration _enUzunBekleme = Duration(seconds: 10);
  static const Duration _istekSuresi = Duration(seconds: 8);

  /// TCP bağlanma sınırı: paketler düşerse (uyuyan laptop, ağ değişti) işletim sisteminin ~75 sn'si beklenmez.
  static const Duration _baglantiSuresi = Duration(seconds: 5);

  static Duration _geriCekme(int deneme) {
    final ms = _ilkBekleme.inMilliseconds * (1 << deneme.clamp(0, 10));
    return Duration(milliseconds: ms.clamp(0, _enUzunBekleme.inMilliseconds));
  }

  Future<Map<String, dynamic>> durumAl() async =>
      (await _json(await _istek('GET', '/state$_sorgu'))) as Map<String, dynamic>;

  /// Kayıtlı kişiler (`/api/people`): kartı olmayanlar da burada (Kart Ver 1. adım).
  Future<List<Map<String, dynamic>>> kisiler() async =>
      ((await _json(await _istek('GET', '/api/people'))) as List).cast<Map<String, dynamic>>();

  /// Alıcının duyduğu kartlar (`/api/cards`): pil, boştaki kartlar.
  Future<List<Map<String, dynamic>>> kartlar() async =>
      ((await _json(await _istek('GET', '/api/cards'))) as List).cast<Map<String, dynamic>>();

  /// Kişi ekler (`POST /api/people`); sunucu reddederse [SunucuHatasi] (hata metniyle).
  Future<Map<String, dynamic>> kisiEkle(Map<String, Object?> govde) async =>
      (await _jsonYaz('POST', '/api/people', govde)) as Map<String, dynamic>;

  /// Yalnız değişen alanlar (`PATCH /api/people/{kisiId}`).
  Future<Map<String, dynamic>> kisiGuncelle(String kisiId, Map<String, Object?> govde) async =>
      (await _jsonYaz('PATCH', '/api/people/${Uri.encodeComponent(kisiId)}', govde)) as Map<String, dynamic>;

  Future<bool> esikGonder(int dbm) => _komut({'cmd': 'threshold', 'value': dbm});

  /// Tüm süreleri/geçmişi/bildirimleri sıfırlar — çağıran onay almış olmalı.
  Future<bool> sifirla() => _komut({'cmd': 'reset'});

  Future<bool> kartAta(String kisiId, String kart) => _tamam('/api/assign', {'kisiId': kisiId, 'kart': kart});

  /// `ayrildi: false` = "Geri al" (kişi ayrılmadı, hâlâ kart bekliyor).
  Future<bool> kartIadeAl(String kart, {bool ayrildi = true}) =>
      _tamam('/api/unassign', {'kart': kart, 'ayrildi': ayrildi});

  Future<bool> _komut(Map<String, Object?> govde) => _tamam('/control', govde);

  Future<bool> _tamam(String yol, Map<String, Object?> govde) async {
    try {
      final yanit = await _istek('POST', yol, govde: govde);
      await yanit.drain<void>();
      return yanit.statusCode >= 200 && yanit.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Canlı akış: dinlendiği sürece bağlı kalmaya çalışır; `akisiKes` / `kapat` ile biter.
  Stream<SunucuOlayi> olaylar() async* {
    var deneme = 0;
    final nesil = ++_nesil;
    bool canli() => _acik && nesil == _nesil;
    while (canli()) {
      var basarili = false;
      HttpClientRequest? istek;
      try {
        istek = await _istemci.getUrl(Uri.parse('$adres/events$_sorgu')).timeout(_istekSuresi);
        if (!canli()) return;
        istek.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
        _akisIstegi = istek;
        final yanit = await istek.close().timeout(_istekSuresi);
        if (yanit.statusCode != 200) throw HttpException('akış açılamadı: ${yanit.statusCode}');
        basarili = true;
        yield const Baglandi();
        // Sessizlik gözcüsü: mesaj gelmeyen akış timeout ile düşer, dış döngü yeniden bağlanır.
        // Okuyucu saklanır: `akisiKes` sokette bekleyen okumayı iptal eder (yoksa üretici asılı kalır).
        final okuyucu = StreamIterator(sseVerileri(yanit).timeout(sessizlik));
        _akisOkuyucu = okuyucu;
        while (await okuyucu.moveNext()) {
          if (!canli()) return;
          final cozulen = jsonDecode(okuyucu.current);
          if (cozulen is Map<String, dynamic>) yield DurumGeldi(cozulen);
        }
        throw const HttpException('akış kapandı');
      } catch (_) {
        if (!canli()) return;
        yield const Koptu();
        if (basarili) deneme = 0;
        await Future<void>.delayed(_bekleme(deneme++));
      } finally {
        istek?.abort();
        if (identical(_akisIstegi, istek)) _akisIstegi = null;
      }
    }
  }

  void _okuyucuyuKapat() {
    final okuyucu = _akisOkuyucu;
    _akisOkuyucu = null;
    // Kesilen soketin hatası beklenen durumdur; sessizce yutulur.
    if (okuyucu != null) unawaited(okuyucu.cancel().then((_) {}, onError: (_) {}));
  }

  /// Yalnız canlı akışı keser (arka plana geçince); komutlar ve yeni `olaylar()` çalışmaya devam eder.
  void akisiKes() {
    _nesil++;
    _okuyucuyuKapat();
    _akisIstegi?.abort();
    _akisIstegi = null;
  }

  void kapat() {
    _acik = false;
    akisiKes();
    _istemci.close(force: true);
  }

  Future<HttpClientResponse> _istek(String yontem, String yol, {Map<String, Object?>? govde}) async {
    final istek = await _istemci.openUrl(yontem, Uri.parse('$adres$yol')).timeout(_istekSuresi);
    if (govde != null) {
      istek.headers.contentType = ContentType.json;
      istek.write(jsonEncode(govde));
    }
    return istek.close().timeout(_istekSuresi);
  }

  /// Yazma isteği: 2xx → JSON; 4xx `{ok:false, hata}` → [SunucuHatasi]; başka → HttpException.
  Future<Object?> _jsonYaz(String yontem, String yol, Map<String, Object?> govde) async {
    final yanit = await _istek(yontem, yol, govde: govde);
    final metin = await utf8.decoder.bind(yanit).join();
    if (yanit.statusCode >= 200 && yanit.statusCode < 300) return jsonDecode(metin);
    try {
      final cozulen = jsonDecode(metin);
      if (cozulen is Map && cozulen['hata'] is String) throw SunucuHatasi(cozulen['hata'] as String);
    } on FormatException {
      // JSON değil: aşağıdaki genel hata
    }
    throw HttpException('${yanit.statusCode}: $metin');
  }

  Future<Object?> _json(HttpClientResponse yanit) async {
    final metin = await utf8.decoder.bind(yanit).join();
    if (yanit.statusCode != 200) throw HttpException('${yanit.statusCode}: $metin');
    return jsonDecode(metin);
  }
}
