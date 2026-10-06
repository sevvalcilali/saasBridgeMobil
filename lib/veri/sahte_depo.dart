import 'dart:async';

import '../mantik/gruplar.dart';
import '../mantik/kurulum.dart';
import 'etkinlik_deposu.dart';
import 'modeller.dart';
import 'sahte_veri.dart';

/// Gömülü sahte veriyle çalışan depo: saati kendi yürütür, işlemler veriyi değiştirmez.
/// Sunucusuz deneme ve testler için; `EtkinlikDeposu()` bunu kurar.
class SahteDepo extends EtkinlikDeposu {
  SahteDepo({bool? aliciBagli, this.sunucuBagli = true, List<Bildirim>? bildirimler})
    : aliciBagli = aliciBagli ?? const bool.fromEnvironment('ALICI_BAGLI', defaultValue: true),
      bildirimler = bildirimler ?? SahteVeri.bildirimler,
      super.temel();

  /// Testlerde kopuk bandını göstermek için false verilir.
  @override
  final bool sunucuBagli;
  @override
  final bool aliciBagli;
  @override
  final List<Bildirim> bildirimler;

  @override
  String get etkinlikAdi => SahteVeri.etkinlikAdi;
  @override
  String get tarihMekan => SahteVeri.tarihMekan;
  @override
  String get raporTarihi => SahteVeri.raporTarihi;
  @override
  String get cizelgeBaslangici => SahteVeri.cizelgeBaslangici;
  @override
  int get duyulanKartSayisi => SahteVeri.duyulanKartSayisi;
  @override
  int get kayitliKatilimci => SahteVeri.kayitliKatilimci;
  @override
  List<Kisi> get kisiler => SahteVeri.kisiler;
  /// Sahte veride çiftler kişinin `ile` alanından türer (her çift bir kez).
  @override
  List<CanliCift> get canliCiftler => [
    for (final k in kisiler)
      if (k.ile != null && _noSirasi(k.id, k.ile!) < 0) CanliCift(k.id, k.ile!),
  ];
  static int _noSirasi(String a, String b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0);
  @override
  List<Cift> get ciftler => SahteVeri.ciftler;
  @override
  List<KisiRengi> get seriRenkleri => SahteVeri.seriRenkleri;
  @override
  List<AcikKart> get acikKartlar => SahteVeri.acikKartlar;

  int _tick = 0;
  int _saatSn = SahteVeri.baslangicSaatSn;
  int _esik = SahteVeri.baslangicEsik;
  Timer? _zamanlayici;

  @override
  int get tick => _tick;
  @override
  int get saatSn => _saatSn;
  @override
  int get esik => _esik;

  @override
  Kisi bul(String id) => kisiler.firstWhere((k) => k.id == id);

  @override
  void baslat() {
    _zamanlayici ??= Timer.periodic(const Duration(seconds: 1), (_) => ilerlet());
  }

  /// Aradaki süre telafi edilmez (şartname §10).
  @override
  void durdur() {
    _zamanlayici?.cancel();
    _zamanlayici = null;
  }

  @override
  void ilerlet() {
    _tick++;
    _saatSn++;
    notifyListeners();
  }

  /// Süre sayacını sıfırlar. Saat akmaya devam eder.
  @override
  Future<void> sifirla() async {
    _tick = 0;
    notifyListeners();
  }

  @override
  void esikAyarla(int deger) {
    final yeni = esikSinirla(deger);
    if (yeni == _esik) return;
    _esik = yeni;
    notifyListeners();
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }
}
