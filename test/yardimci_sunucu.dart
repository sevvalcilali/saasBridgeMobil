import 'dart:convert';
import 'dart:io';

/// Testlerin kendi küçük sunucusu: /state, /events (SSE), /control, /api/*.
/// `flutter_test` her HttpClient'ı 400 döndüren sahteyle değiştirir (ağ yasak); buna bağlanan
/// testler `HttpOverrides.global = null` der.
class SahteSunucu {
  SahteSunucu(this.sunucu, {String? durum}) : durum = durum ?? varsayilanDurum {
    sunucu.listen(_isle);
  }

  static const varsayilanDurum =
      '{"clock":"10:00:00","people":[],"live":[],"alerts":[],"event":{"name":"E","date":"d"},"threshold":-70,"receiverAge":0.5}';

  final HttpServer sunucu;

  /// `/state` ve (akış mesajı verilmezse) `/events` yanıtı.
  String durum;
  final istekler = <String>[];
  final govdeler = <String>[];
  int akisAcilis = 0;

  /// Her akış açılışında yollanacak mesajlar; sonra bağlantı kapanır. `null` = `durum` bir kez, sonra açık kalır.
  List<String>? akisMesajlari = ['{"n":1}', '{"n":2}'];
  bool akisHatali = false;
  String kisilerYaniti = '[{"kisiId":"k1"}]';
  String kartlarYaniti = '[]';
  String kurallarYaniti = '[]';
  String oturumlarYaniti = '[]';

  /// Verilirse sonraki yazma isteği bu kodla `{ok:false, hata}` döner (sözleşmedeki hata biçimi).
  (int, String)? hata;
  final _acikAkislar = <HttpResponse>[];

  String get adres => 'http://127.0.0.1:${sunucu.port}';

  static Future<SahteSunucu> ac({String? durum}) async =>
      SahteSunucu(await HttpServer.bind('127.0.0.1', 0), durum: durum);

  /// Açık akışlara bir mesaj yollar (akisMesajlari null iken).
  Future<void> yayinla(String mesaj) async {
    for (final r in _acikAkislar) {
      r.write('data: $mesaj\r\n\r\n');
      await r.flush();
    }
  }

  /// Açık akışları keser (sunucu çöktü gibi).
  Future<void> akislariKes() async {
    for (final r in _acikAkislar) {
      await r.close();
    }
    _acikAkislar.clear();
  }

  Future<void> _isle(HttpRequest r) async {
    istekler.add('${r.method} ${r.uri}');
    final yol = r.uri.path;
    if (yol == '/state') {
      r.response.headers.contentType = ContentType.json;
      r.response.write(durum);
    } else if (yol == '/events') {
      akisAcilis++;
      if (akisHatali) {
        r.response.statusCode = 500;
      } else {
        r.response.headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
        r.response.bufferOutput = false;
        final mesajlar = akisMesajlari;
        if (mesajlar == null) {
          _acikAkislar.add(r.response);
          r.response.write('data: $durum\r\n\r\n');
          await r.response.flush();
          return; // açık kalır
        }
        for (final m in mesajlar) {
          r.response.write('data: $m\r\n\r\n');
          await r.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }
    } else if (yol == '/control' || yol.startsWith('/api/')) {
      govdeler.add(await utf8.decoder.bind(r).join());
      r.response.headers.contentType = ContentType.json;
      final yazma = r.method != 'GET';
      final bekleyenHata = yazma ? hata : null;
      if (bekleyenHata != null) {
        hata = null;
        r.response.statusCode = bekleyenHata.$1;
        r.response.write(jsonEncode({'ok': false, 'hata': bekleyenHata.$2}));
      } else {
        r.response.write(switch ((yol, yazma)) {
          ('/api/people', false) => kisilerYaniti,
          ('/api/people', true) => '{"kisiId":"k9","ad":"Yeni"}',
          ('/api/cards', _) => kartlarYaniti,
          ('/api/rules', false) => kurallarYaniti,
          ('/api/sessions', false) => oturumlarYaniti,
          ('/api/rules', true) => '{"kuralId":"r9","ad":"Yeni","kim":{"rol":"herkes","enAzYildiz":0},"kiminle":{"rol":"herkes","enAzYildiz":0},"dakika":0,"acik":true}',
          _ => yol.startsWith('/api/people/')
              ? '{"kisiId":"k1"}'
              : yol.startsWith('/api/rules/') && r.method == 'PATCH'
              ? '{"kuralId":"r1","ad":"A","kim":{"rol":"herkes","enAzYildiz":0},"kiminle":{"rol":"herkes","enAzYildiz":0},"dakika":0,"acik":false}'
              : '{"ok":true}',
        });
      }
    } else {
      r.response.statusCode = 404;
    }
    await r.response.close();
  }

  Future<void> kapat() => sunucu.close(force: true);
}

/// Koşul sağlanana ya da süre dolana dek bekler.
Future<void> bekle(bool Function() kosul, {Duration sure = const Duration(seconds: 5)}) async {
  final son = DateTime.now().add(sure);
  while (!kosul() && DateTime.now().isBefore(son)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
