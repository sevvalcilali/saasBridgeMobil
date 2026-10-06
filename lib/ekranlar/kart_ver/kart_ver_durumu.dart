import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../mantik/kart_no.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

enum KartVerModu { ver, iade }

enum KartSecimModu { yaklastir, numara }

/// Son yapılan atama (bantta gösterilir).
typedef SonAtama = ({String ad, String kart});

/// Kart Ver / Kart İadesi ekranının durumu. Onayla, Geri al ve İade al depoya gider (gerçek sunucuda
/// `/api/assign` ve `/api/unassign`; sahte veride yalnız bant). Kişiler kayıtlı kişilerdir (`Katilimci`,
/// kartı olmayanlar dahil). "Yaklaştır ve tanı" gerçek sunucuda alıcının duyduğu kartlardan bulur;
/// sahte veride demo düğmesiyle. Sekme değişse de korunur.
class KartVerDurumu extends ChangeNotifier {
  KartVerDurumu(
    this._depo, {
    this.demoGecikmesi = const Duration(milliseconds: 1400),
    this.demoKarti = '88',
  }) {
    aramaDenetleyici.addListener(notifyListeners);
    numaraDenetleyici.addListener(notifyListeners);
    _depo.addListener(_depoDegisti);
  }

  final EtkinlikDeposu _depo;

  /// "Demo: kartı yaklaştır"dan sonra kartın bulunma süresi (yalnız sahte veri).
  final Duration demoGecikmesi;

  /// Demo yaklaştırmada bulunan kart.
  final String demoKarti;

  /// Adım 1 ve Kart İadesi aramasının ortak metni.
  final TextEditingController aramaDenetleyici = TextEditingController();

  /// "Numarayı yaz" alanının metni.
  final TextEditingController numaraDenetleyici = TextEditingController();

  KartVerModu _mod = KartVerModu.ver;
  int _adim = 1;
  String? _seciliKisi; // kisiId
  String? _seciliKart;
  KartSecimModu _kartModu = KartSecimModu.yaklastir;
  String? _demoBulundu;
  SonAtama? _sonAtama;
  String? _bilgi;
  String? _hata;
  bool _gonderiliyor = false;
  bool _yalnizBekleyen = false;
  bool _sahipOnayi = false;
  String? _iadeSecili; // kisiId
  Timer? _demo;

  KartVerModu get mod => _mod;

  /// Sihirbaz adımı: 1 Kişi, 2 Kart, 3 Onay.
  int get adim => _adim;

  /// Kart verilecek kişi.
  Katilimci? get kisi => _katilimciBul(_seciliKisi);
  String? get seciliKart => _seciliKart;

  /// Seçili kart başka birindeyse o kişi (sözleşme §2: masa "Bu kart X'te. Geri alındı mı?" diye sorar).
  Katilimci? get kartinSahibi {
    final kart = _seciliKart;
    if (kart == null) return null;
    final sahip = _karttakiKisi(kart);
    return sahip != null && sahip.kisiId != _seciliKisi ? sahip : null;
  }

  /// "Geri alındı" onayı verildi mi (yalnız başkasının kartı için gerekir).
  bool get sahipOnayi => _sahipOnayi;
  KartSecimModu get kartModu => _kartModu;

  /// "Yaklaştır ve tanı" ile bulunan kart: gerçek sunucuda alıcının −55 dBm'den güçlü duyduğu tek boş
  /// kart; sahte veride demo.
  String? get bulundu => _depo.demo ? _demoBulundu : yaklastirilanKart(_depo.acikKartlar).kart;

  /// Birden çok kart yakınsa uyarı.
  String? get yaklastirmaUyarisi => _depo.demo ? null : yaklastirilanKart(_depo.acikKartlar).uyari;
  SonAtama? get sonAtama => _sonAtama;

  /// Geri alma ya da iade sonrası gösterilen bilgi metni.
  String? get bilgi => _bilgi;

  /// Sunucu kabul etmeyince gösterilen hata.
  String? get hata => _hata;
  bool get gonderiliyor => _gonderiliyor;

  /// Adım 1: yalnız kart bekleyenler.
  bool get yalnizBekleyen => _yalnizBekleyen;

  /// İadesi onaylanmayı bekleyen kişi.
  Katilimci? get iadeKisisi => _katilimciBul(_iadeSecili);
  String get arama => aramaDenetleyici.text;

  /// Yazılan numara; rakam dışı her şey atılmıştır.
  String get numara => yalnizRakam(numaraDenetleyici.text);
  bool get numaraSecilebilir => numaraGecerli(numara);

  Katilimci? _katilimciBul(String? kisiId) {
    if (kisiId == null) return null;
    for (final k in _depo.katilimcilar) {
      if (k.kisiId == kisiId) return k;
    }
    return null;
  }

  Katilimci? _karttakiKisi(String kart) {
    for (final k in _depo.katilimcilar) {
      if (k.atananKart == kart) return k;
    }
    return null;
  }

  /// Depo değişince (kartlar, kişiler) ekran tazelenir: "yaklaştır" kartı bulsun.
  void _depoDegisti() => notifyListeners();

  /// Bekleyen demo yaklaştırmayı iptal eder: adım ya da kişi değişince eski
  /// "Kart 88 bulundu" sonradan belirmesin.
  void _demoIptal() {
    _demo?.cancel();
    _demo = null;
  }

  void kisiSec(String kisiId) {
    _demoIptal();
    _seciliKisi = kisiId;
    _adim = 2;
    _demoBulundu = null;
    _hata = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  void bekleyenSuzgeci(bool deger) {
    if (_yalnizBekleyen == deger) return;
    _yalnizBekleyen = deger;
    notifyListeners();
  }

  void kartModuSec(KartSecimModu mod) {
    if (_kartModu == mod) return;
    _demoIptal();
    _kartModu = mod;
    notifyListeners();
  }

  /// Donanım olmadan yaklaştırmayı taklit eder (yalnız sahte veri).
  void demoYaklastir() {
    _demoIptal();
    _demo = Timer(demoGecikmesi, () {
      _demo = null;
      _demoBulundu = demoKarti;
      notifyListeners();
    });
  }

  void _kartSec(String kart) {
    _seciliKart = kart;
    _sahipOnayi = false; // her yeni kart için yeniden sorulur
    _adim = 3;
    notifyListeners();
  }

  void bulunanSec() {
    final kart = bulundu;
    if (kart == null) return;
    _kartSec(kart);
  }

  void numaraSec() {
    if (!numaraSecilebilir) return;
    _kartSec(numaraTemizle(numara));
  }

  void acikKartSec(String no) => _kartSec(no);

  void sahipOnayla(bool deger) {
    if (_sahipOnayi == deger) return;
    _sahipOnayi = deger;
    notifyListeners();
  }

  void kisiAdiminaDon() {
    _demoIptal();
    _adim = 1;
    _demoBulundu = null;
    notifyListeners();
  }

  void kartAdiminaDon() {
    _demoIptal();
    _adim = 2;
    _demoBulundu = null;
    notifyListeners();
  }

  /// Onayla: kart kişiye verilir (sunucu). Başarılıysa bant + adım 1; değilse hata, sihirbaz kalır.
  Future<void> onayla() async {
    final k = kisi;
    final kart = _seciliKart;
    if (k == null || kart == null || _gonderiliyor) return;
    if (kartinSahibi != null && !_sahipOnayi) return; // başkasının kartı: önce "geri alındı" onayı
    _demoIptal();
    _gonderiliyor = true;
    _hata = null;
    notifyListeners();
    final hata = await _depo.kartAta(k.kisiId, kart);
    _gonderiliyor = false;
    if (hata != null) {
      _hata = hata;
      notifyListeners();
      return;
    }
    _sonAtama = (ad: k.ad, kart: kart);
    _bilgi = null;
    // Gönderim sürerken görevli başka seçim yaptıysa o seçim korunur; yalnız bu atama temizlenir.
    if (_seciliKisi == k.kisiId && _seciliKart == kart) {
      _adim = 1;
      _seciliKisi = null;
      _seciliKart = null;
      _sahipOnayi = false;
      _demoBulundu = null;
      numaraDenetleyici.clear();
      aramaDenetleyici.clear();
    }
    notifyListeners();
  }

  /// Geri al: son atama kaldırılır, kişi ayrılmış sayılmaz (`ayrildi: false`).
  Future<void> geriAl() async {
    final atama = _sonAtama;
    if (atama == null || _gonderiliyor) return;
    _gonderiliyor = true;
    _hata = null;
    notifyListeners();
    final hata = await _depo.kartIadeAl(atama.kart, ayrildi: false);
    _gonderiliyor = false;
    if (hata != null) {
      _hata = hata;
      notifyListeners();
      return;
    }
    _bilgi = '↶ Geri alındı: ${atama.ad} → Kart ${atama.kart} ataması kaldırıldı, kart boşta.';
    _sonAtama = null;
    notifyListeners();
  }

  void modVer() {
    _mod = KartVerModu.ver;
    _iadeSecili = null;
    _hata = null;
    notifyListeners();
  }

  void modIade() {
    _demoIptal();
    _mod = KartVerModu.iade;
    _hata = null;
    notifyListeners();
  }

  void iadeSec(String kisiId) {
    _iadeSecili = kisiId;
    notifyListeners();
  }

  void iadeVazgec() {
    _iadeSecili = null;
    notifyListeners();
  }

  /// İade al: kart masaya döner, kişi "ayrıldı" olur; süreleri raporda kalır.
  Future<void> iadeOnayla() async {
    final k = iadeKisisi;
    final kart = k?.atananKart;
    if (k == null || kart == null || _gonderiliyor) return;
    _gonderiliyor = true;
    _hata = null;
    notifyListeners();
    final hata = await _depo.kartIadeAl(kart);
    _gonderiliyor = false;
    if (hata != null) {
      _hata = hata;
      notifyListeners();
      return;
    }
    if (_iadeSecili == k.kisiId) _iadeSecili = null; // bu arada başka kişi seçildiyse o kalır
    _bilgi = '✓ Kart $kart iade alındı. ${k.ad} panodan düştü; süreleri raporda kalır.';
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı değiştir": Kart ver modu, adım 2, o kartın kişisi seçili.
  void kartDegistirBaslat(String kart) {
    final k = _karttakiKisi(kart);
    if (k == null) return;
    _demoIptal();
    _mod = KartVerModu.ver;
    _seciliKisi = k.kisiId;
    _adim = 2;
    _demoBulundu = null;
    _hata = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı iade al": Kart iadesi modu, o kartın kişisi seçili.
  void iadeBaslat(String kart) {
    final k = _karttakiKisi(kart);
    if (k == null) return;
    _mod = KartVerModu.iade;
    _iadeSecili = k.kisiId;
    _hata = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _demoIptal();
    _depo.removeListener(_depoDegisti);
    aramaDenetleyici.dispose();
    numaraDenetleyici.dispose();
    super.dispose();
  }
}
