import 'dart:async';
import 'dart:convert';

import '../mantik/bicim.dart';
import '../mantik/gruplar.dart';
import '../mantik/kural.dart';
import '../mantik/rapor_hesap.dart';
import '../mantik/kurulum.dart';
import 'etkinlik_deposu.dart';
import 'modeller.dart';
import 'sunucu_durumu.dart';
import 'sunucu_istemcisi.dart';

/// Gerçek sunucuya bağlı depo. Açılışta `/state`, sonra `/events` canlı akışı (~2 Hz): süreler ve saat
/// sunucudan gelir, yerel sayaç yoktur. Kopunca son veri kalır, `sunucuBagli` false olur; istemci
/// kendiliğinden yeniden bağlanır. Kartlar (son duyulma, boştakiler) ve kayıtlı kişi sayısı `/api/cards` ve
/// `/api/people`'dan seyrek yoklanır.
class SunucuDeposu extends EtkinlikDeposu {
  SunucuDeposu(
    this._istemci, {
    this.yoklamaAraligi = const Duration(seconds: 2),
    this.grafikAraligi = const Duration(seconds: 4),
  }) : super.temel();

  final SunucuIstemcisi _istemci;

  /// Kartlar ve kayıtlı kişiler bu sıklıkla yoklanır (masadaki açık kartlar ve kart sağlığı tazelensin).
  final Duration yoklamaAraligi;

  /// Kurulum grafiği geçmişi bu sıklıkla istenir (büyük yanıt; 90 sn'lik pencerede 4 sn yeterli).
  final Duration grafikAraligi;

  /// Depo kapatıldı: yolda kalan yanıtlar bildirim göndermez.
  bool _kapandi = false;

  SunucuDurumu? _durum;
  bool _bagli = false;
  Map<String, dynamic>? _hamDurum;
  List<Map<String, dynamic>> _kartlar = const [];
  List<Katilimci> _katilimcilar = const [];
  int? _esikYerel; // kaydırıcı bırakılınca hemen görünsün; sunucu doğrulayınca kalkar
  StreamSubscription<SunucuOlayi>? _abonelik;
  Timer? _yoklama;
  Timer? _grafikYoklama;
  bool _grafikIsteniyor = false;
  Map<String, List<(int, double)>> _gecmis = const {};
  int _grafikSaniyesi = 90;
  bool _yoklaniyor = false;
  int _yoklamaSayaci = 0;
  String _kartlarImzasi = '';
  String _kisilerImzasi = '';
  DateTime _sonBildirim = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _ertelenenBildirim;

  /// Kayıtlı kişiler kartlardan seyrek değişir: her N. yoklamada istenir.
  static const int _kisiYoklamaKati = 5;

  /// Ekran saniyede en çok bir kez yeniden çizilir (sakin ekran; akış 2 Hz).
  static const Duration _enSikBildirim = Duration(seconds: 1);

  /// Dinleyicileri saniyede en çok bir kez uyandırır; arada gelen güncellemeler birleşir (sonuncusu kalır).
  void _bildir() {
    if (_kapandi) return;
    final gecen = DateTime.now().difference(_sonBildirim);
    if (gecen >= _enSikBildirim) {
      _ertelenenBildirim?.cancel();
      _ertelenenBildirim = null;
      _sonBildirim = DateTime.now();
      notifyListeners();
      return;
    }
    _ertelenenBildirim ??= Timer(_enSikBildirim - gecen, () {
      _ertelenenBildirim = null;
      if (_kapandi) return;
      _sonBildirim = DateTime.now();
      notifyListeners();
    });
  }

  @override
  bool get sunucuBagli => _bagli;
  @override
  bool get aliciBagli => _durum?.aliciBagli ?? false;
  @override
  List<Bildirim> get bildirimler => _durum?.bildirimler ?? const [];
  @override
  String get etkinlikAdi => _durum?.etkinlikAdi ?? '';
  @override
  String get tarihMekan => _durum?.tarihMekan ?? '';
  @override
  String get raporTarihi {
    final s = DateTime.now();
    return '${s.day.toString().padLeft(2, '0')}.${s.month.toString().padLeft(2, '0')}.${s.year}';
  }

  /// Etkinliğin başı = sunucu saati − geçen süre (`elapsed`).
  @override
  String get cizelgeBaslangici {
    final d = _durum;
    if (d == null) return '—';
    final gecen = ((_hamDurum?['elapsed'] as num?) ?? 0).round();
    return kisaSaatYazisi((d.saatSn - gecen).clamp(0, 24 * 3600 - 1));
  }

  /// Son 30 sn içinde duyulan kişi kartları (sessiz ve kayıp olanlar sayılmaz).
  @override
  int get duyulanKartSayisi => tumKartlar.where((k) => k.seenAgo <= sessizSn).length;
  @override
  int get kayitliKatilimci => _katilimcilar.where((k) => !k.ayrildi).length;
  @override
  List<Katilimci> get katilimcilar => _katilimcilar;
  @override
  bool get demo => false;
  @override
  List<Kisi> get kisiler => _durum?.kisiler ?? const [];
  @override
  List<CanliCift> get canliCiftler => _durum?.canliCiftler ?? const [];
  @override
  List<Cift> get ciftler => _durum?.ciftler ?? const [];

  /// Grafikteki en güçlü çiftlerin rengi: çiftin ilk kişisinin rengi.
  @override
  List<KisiRengi> get seriRenkleri {
    final renk = {for (final k in kisiler) k.id: k.renk};
    final sirali = [...ciftler]..sort((a, b) => b.rssi.compareTo(a.rssi));
    return [for (final c in sirali.take(6)) renk[c.a] ?? KisiRengi.gri];
  }

  /// Alıcının şu an duyduğu kartlar (≤ 8 sn), sinyal gücüyle.
  @override
  List<AcikKart> get acikKartlar => [for (final k in tumKartlar) if (k.seenAgo <= 8) k];

  /// `/api/cards`'taki tüm kişi kartları; 100+ dinleyici cihazlar kart değildir.
  @override
  List<AcikKart> get tumKartlar => [
    for (final k in _kartlar)
      if (SunucuDurumu.kisiKartiMi(k['kart'] as String))
        AcikKart(
          k['kart'] as String,
          atanmis: k['atanan'] != null,
          seenAgo: ((k['seenAgo'] as num?) ?? 999).toDouble(),
        ),
  ];

  @override
  Map<String, List<(int, double)>> get gecmis => _gecmis;
  @override
  int get grafikSaniyesi => _grafikSaniyesi;

  /// Testler için: grafik geçmişi isteniyor mu.
  bool get grafikIsteniyor => _grafikIsteniyor;

  /// Kurulum açıkken: `/state?grafik=1` yoklanır (akış grafiksiz kalır; geçmiş durumun ~%60'ı).
  @override
  void grafikIste(bool iste) {
    if (_grafikIsteniyor == iste) return;
    _grafikIsteniyor = iste;
    _grafikZamanlayicisiniKur();
  }

  /// İstek varsa ve akış açıksa yoklamayı başlatır; yoksa durdurur. `durdur` isteği unutmaz (arka plandan dönünce
  /// `baslat` yeniden kurar).
  void _grafikZamanlayicisiniKur() {
    _grafikYoklama?.cancel();
    _grafikYoklama = null;
    if (!_grafikIsteniyor || _abonelik == null || _kapandi) return;
    _grafikYokla();
    _grafikYoklama = Timer.periodic(grafikAraligi, (_) => _grafikYokla());
  }

  bool _grafikYoklaniyor = false;
  Future<void> _grafikYokla() async {
    if (_grafikYoklaniyor || _abonelik == null) return;
    _grafikYoklaniyor = true;
    try {
      final g = await _istemci.grafikGecmisi();
      if (_kapandi || _abonelik == null || !_grafikIsteniyor) return; // bu arada durduruldu ya da kapandı
      _gecmis = g.gecmis;
      _grafikSaniyesi = g.saniye;
      _bildir();
    } catch (_) {
      /* sonraki yoklamada */
    } finally {
      _grafikYoklaniyor = false;
    }
  }

  @override
  int get tick => 0;
  @override
  int get saatSn => _durum?.saatSn ?? 0;
  @override
  int get esik => _esikYerel ?? _durum?.esik ?? -72;

  @override
  Kisi bul(String id) => kisiler.firstWhere(
    (k) => k.id == id,
    orElse: () => Kisi(id: id, rol: Rol.misafir, renk: KisiRengi.gri),
  );

  @override
  List<({Kisi kisi, int sn})> gunBoyu(String id) {
    final liste = [
      for (final c in _durum?.gunBoyu ?? const <GunBoyuCift>[])
        if (c.a == id) (kisi: bul(c.b), sn: c.sn) else if (c.b == id) (kisi: bul(c.a), sn: c.sn),
    ]..sort((x, y) => y.sn.compareTo(x.sn));
    return liste;
  }

  @override
  void baslat() {
    if (_abonelik != null) return;
    _istemci.durumAl().then(_durumAyarla, onError: (_) {});
    _abonelik = _istemci.olaylar().listen((olay) {
      switch (olay) {
        case Baglandi():
          _bagli = true;
          _bildir();
        case DurumGeldi(:final durum):
          _durumAyarla(durum);
        case Koptu():
          if (!_bagli) return;
          _bagli = false;
          _bildir();
      }
    });
    _yokla();
    _yoklama = Timer.periodic(yoklamaAraligi, (_) => _yokla());
    _grafikZamanlayicisiniKur(); // arka plandan dönüş: Kurulum açıksa grafik sürer
  }

  @override
  void durdur() {
    _abonelik?.cancel();
    _abonelik = null;
    _yoklama?.cancel();
    _yoklama = null;
    _grafikYoklama?.cancel();
    _grafikYoklama = null;
    _ertelenenBildirim?.cancel();
    _ertelenenBildirim = null;
    _istemci.akisiKes();
    if (_bagli) {
      _bagli = false;
      notifyListeners();
    }
  }

  void _durumAyarla(Map<String, dynamic> ham) {
    _hamDurum = ham;
    _durum = SunucuDurumu.ayristir(ham);
    if (_esikYerel != null && _durum!.esik == _esikYerel) _esikYerel = null;
    _bagli = true;
    _bildir();
  }

  /// Kartları (her seferinde) ve kayıtlı kişileri (seyrek) yoklar; önceki yoklama bitmeden yenisi başlamaz,
  /// veri değişmediyse ekran uyandırılmaz.
  Future<void> _yokla() async {
    if (_yoklaniyor) return;
    _yoklaniyor = true;
    try {
      var degisti = false;
      final kartlar = await _istemci.kartlar();
      final kartImza = jsonEncode(kartlar);
      if (kartImza != _kartlarImzasi) {
        _kartlarImzasi = kartImza;
        _kartlar = kartlar;
        degisti = true;
      }
      if (_yoklamaSayaci++ % _kisiYoklamaKati == 0) {
        final kisiler = await _istemci.kisiler();
        final kisiImza = jsonEncode(kisiler);
        if (kisiImza != _kisilerImzasi) {
          _kisilerImzasi = kisiImza;
          _katilimcilar = [for (final k in kisiler) katilimciAyristir(k)];
          degisti = true;
        }
      }
      if (!degisti || _kapandi) return;
      final ham = _hamDurum;
      if (ham != null) _durum = SunucuDurumu.ayristir(ham);
      _bildir();
    } catch (_) {
      /* sonraki yoklamada yeniden denenir; bant akışa bağlıdır */
    } finally {
      _yoklaniyor = false;
    }
  }

  /// Yazma sonrası listeler hemen tazelensin (sayaç sıfırlanır: kişiler de istenir).
  Future<void> _hemenYokla() async {
    _yoklamaSayaci = 0;
    await _yokla();
  }

  @override
  Future<String?> kartAta(String kisiId, String kart) async {
    final oldu = await _istemci.kartAta(kisiId, kart);
    if (!oldu) return 'Kart verilemedi: sunucu kabul etmedi ya da ulaşılamıyor.';
    await _hemenYokla(); // liste ve kartlar hemen tazelensin
    return null;
  }

  @override
  Future<String?> kartIadeAl(String kart, {bool ayrildi = true}) async {
    final oldu = await _istemci.kartIadeAl(kart, ayrildi: ayrildi);
    if (!oldu) return 'İade alınamadı: sunucu kabul etmedi ya da ulaşılamıyor.';
    await _hemenYokla();
    return null;
  }

  @override
  Future<String?> kisiEkle(Map<String, Object?> govde) => _yaz(() => _istemci.kisiEkle(govde), 'Kişi eklenemedi');

  @override
  Future<String?> kisiGuncelle(String kisiId, Map<String, Object?> govde) =>
      _yaz(() => _istemci.kisiGuncelle(kisiId, govde), 'Kişi güncellenemedi');

  @override
  double get gecenSn => ((_hamDurum?['elapsed'] as num?) ?? 0).toDouble();

  @override
  Future<List<Oturum>> oturumlar() async => [for (final o in await _istemci.oturumlar()) Oturum.ayristir(o)];

  @override
  Future<List<Kural>> kurallar() async => [for (final k in await _istemci.kurallar()) Kural.ayristir(k)];

  @override
  Future<String?> kuralEkle(Map<String, Object?> govde) => _yaz(() => _istemci.kuralEkle(govde), 'Kural eklenemedi', yokla: false);

  @override
  Future<String?> kuralGuncelle(String kuralId, Map<String, Object?> govde) =>
      _yaz(() => _istemci.kuralGuncelle(kuralId, govde), 'Kural güncellenemedi', yokla: false);

  @override
  Future<String?> kuralSil(String kuralId) => _yaz(() => _istemci.kuralSil(kuralId), 'Kural silinemedi', yokla: false);

  /// Yazma: sunucunun hata metni varsa o, yoksa genel metin; başarıda listeler hemen tazelenir.
  Future<String?> _yaz(Future<Object?> Function() istek, String genelHata, {bool yokla = true}) async {
    try {
      await istek();
    } on SunucuHatasi catch (h) {
      return h.metin;
    } catch (_) {
      return '$genelHata: sunucuya ulaşılamıyor.';
    }
    if (yokla) await _hemenYokla();
    return null;
  }

  @override
  Future<void> sifirla() async {
    await _istemci.sifirla();
  }

  @override
  void esikAyarla(int deger) {
    final yeni = esikSinirla(deger);
    if (yeni == esik) return;
    _esikYerel = yeni;
    notifyListeners();
    _istemci.esikGonder(yeni).then((oldu) {
      // Sunucu almadıysa ekran eski değere döner (sözleşme §5).
      if (!oldu && _esikYerel == yeni) {
        _esikYerel = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _kapandi = true;
    durdur();
    _istemci.kapat();
    super.dispose();
  }
}
