import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../mantik/kart_no.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

enum KartVerModu { ver, iade }

enum KartSecimModu { yaklastir, numara }

/// Son yapılan atama (bantta gösterilir).
typedef SonAtama = ({String ad, String kart});

/// Kart Ver / Kart İadesi ekranının durumu. İşlemler sahte veriyi değiştirmez;
/// yalnız bant ve bilgi metni üretir (şartname §2). Sekme değişse de korunur.
class KartVerDurumu extends ChangeNotifier {
  KartVerDurumu(
    this._depo, {
    this.demoGecikmesi = const Duration(milliseconds: 1400),
    this.demoKarti = '88',
  }) {
    aramaDenetleyici.addListener(notifyListeners);
    numaraDenetleyici.addListener(notifyListeners);
  }

  final EtkinlikDeposu _depo;

  /// "Demo: kartı yaklaştır"dan sonra kartın bulunma süresi.
  final Duration demoGecikmesi;

  /// Demo yaklaştırmada bulunan kart.
  final String demoKarti;

  /// Adım 1 ve Kart İadesi aramasının ortak metni.
  final TextEditingController aramaDenetleyici = TextEditingController();

  /// "Numarayı yaz" alanının metni.
  final TextEditingController numaraDenetleyici = TextEditingController();

  KartVerModu _mod = KartVerModu.ver;
  int _adim = 1;
  String? _seciliKisi;
  String? _seciliKart;
  KartSecimModu _kartModu = KartSecimModu.yaklastir;
  String? _bulundu;
  SonAtama? _sonAtama;
  String? _bilgi;
  String? _iadeSecili;
  Timer? _demo;

  KartVerModu get mod => _mod;

  /// Sihirbaz adımı: 1 Kişi, 2 Kart, 3 Onay.
  int get adim => _adim;

  /// Kart verilecek kişi.
  Kisi? get kisi => _kisiBul(_seciliKisi);
  String? get seciliKart => _seciliKart;
  KartSecimModu get kartModu => _kartModu;

  /// "Yaklaştır ve tanı" ile bulunan kart.
  String? get bulundu => _bulundu;
  SonAtama? get sonAtama => _sonAtama;

  /// Geri alma ya da iade sonrası gösterilen bilgi metni.
  String? get bilgi => _bilgi;

  /// İadesi onaylanmayı bekleyen kişi.
  Kisi? get iadeKisisi => _kisiBul(_iadeSecili);
  String get arama => aramaDenetleyici.text;

  /// Yazılan numara; rakam dışı her şey atılmıştır.
  String get numara => yalnizRakam(numaraDenetleyici.text);
  bool get numaraSecilebilir => numaraGecerli(numara);

  Kisi? _kisiBul(String? id) => id == null ? null : _depo.bul(id);

  /// Bekleyen demo yaklaştırmayı iptal eder: adım ya da kişi değişince eski
  /// "Kart 88 bulundu" sonradan belirmesin.
  void _demoIptal() {
    _demo?.cancel();
    _demo = null;
  }

  void kisiSec(String id) {
    _demoIptal();
    _seciliKisi = id;
    _adim = 2;
    _bulundu = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  void kartModuSec(KartSecimModu mod) {
    if (_kartModu == mod) return;
    _demoIptal();
    _kartModu = mod;
    notifyListeners();
  }

  /// Donanım olmadan yaklaştırmayı taklit eder.
  void demoYaklastir() {
    _demoIptal();
    _demo = Timer(demoGecikmesi, () {
      _demo = null;
      _bulundu = demoKarti;
      notifyListeners();
    });
  }

  void bulunanSec() {
    final kart = _bulundu;
    if (kart == null) return;
    _seciliKart = kart;
    _adim = 3;
    notifyListeners();
  }

  void numaraSec() {
    if (!numaraSecilebilir) return;
    _seciliKart = numaraTemizle(numara);
    _adim = 3;
    notifyListeners();
  }

  void acikKartSec(String no) {
    _seciliKart = no;
    _adim = 3;
    notifyListeners();
  }

  void kisiAdiminaDon() {
    _demoIptal();
    _adim = 1;
    _bulundu = null;
    notifyListeners();
  }

  void kartAdiminaDon() {
    _demoIptal();
    _adim = 2;
    _bulundu = null;
    notifyListeners();
  }

  void onayla() {
    final k = kisi;
    final kart = _seciliKart;
    if (k == null || kart == null) return;
    _demoIptal();
    _sonAtama = (ad: gorunenAd(k), kart: kart);
    _bilgi = null;
    _adim = 1;
    _seciliKisi = null;
    _seciliKart = null;
    _bulundu = null;
    numaraDenetleyici.clear();
    aramaDenetleyici.clear();
    notifyListeners();
  }

  void geriAl() {
    final atama = _sonAtama;
    if (atama == null) return;
    _bilgi = '↶ Geri alındı: ${atama.ad} → Kart ${atama.kart} ataması kaldırıldı, kart boşta.';
    _sonAtama = null;
    notifyListeners();
  }

  void modVer() {
    _mod = KartVerModu.ver;
    _iadeSecili = null;
    notifyListeners();
  }

  void modIade() {
    _demoIptal();
    _mod = KartVerModu.iade;
    notifyListeners();
  }

  void iadeSec(String id) {
    _iadeSecili = id;
    notifyListeners();
  }

  void iadeVazgec() {
    _iadeSecili = null;
    notifyListeners();
  }

  void iadeOnayla() {
    final k = iadeKisisi;
    if (k == null) return;
    _iadeSecili = null;
    _bilgi = '✓ Kart ${k.id} iade alındı. ${gorunenAd(k)} panodan düştü; süreleri raporda kalır.';
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı değiştir": Kart ver modu, adım 2, kişi seçili.
  void kartDegistirBaslat(String id) {
    _demoIptal();
    _mod = KartVerModu.ver;
    _seciliKisi = id;
    _adim = 2;
    _bulundu = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı iade al": Kart iadesi modu, kişi seçili.
  void iadeBaslat(String id) {
    _mod = KartVerModu.iade;
    _iadeSecili = id;
    notifyListeners();
  }

  @override
  void dispose() {
    _demoIptal();
    aramaDenetleyici.dispose();
    numaraDenetleyici.dispose();
    super.dispose();
  }
}
