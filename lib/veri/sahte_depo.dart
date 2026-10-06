import 'dart:async';

import '../mantik/gruplar.dart';
import '../mantik/kural.dart';
import '../mantik/kurulum.dart';
import '../mantik/rapor_hesap.dart';
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
  Map<String, List<(int, double)>> get gecmis => const {};
  @override
  int get grafikSaniyesi => 90;
  @override
  List<AcikKart> get acikKartlar => SahteVeri.acikKartlar;
  @override
  List<AcikKart> get tumKartlar => SahteVeri.tumKartlar;
  @override
  List<Katilimci> get katilimcilar => SahteVeri.katilimcilar;
  @override
  bool get demo => true;

  /// Sahte veri değişmez; işlem başarılı sayılır (yalnız bant gösterilir).
  @override
  Future<String?> kartAta(String kisiId, String kart) async => null;
  @override
  Future<String?> kartIadeAl(String kart, {bool ayrildi = true}) async => null;
  @override
  Future<String?> kisiEkle(Map<String, Object?> govde) async => null;
  @override
  Future<String?> kisiGuncelle(String kisiId, Map<String, Object?> govde) async => null;

  /// Sahte etkinlik 1 saat önce başlamış sayılır; süreler tick ile akar.
  @override
  double get gecenSn => (3600 + _tick).toDouble();

  /// Her birlikte çift için sürmekte olan bir görüşme (kisiId = "k" + kart no).
  @override
  Future<List<Oturum>> oturumlar() async => [
    for (final k in kisiler)
      if (k.ile != null && _noSirasi(k.id, k.ile!) < 0) Oturum('k${k.id}', 'k${k.ile}', 3600.0 - k.sn, null),
  ];

  // Kurallar bellekte (arayüz sunucusuz denenebilsin); sunucuyla aynı doğrulama ve ad üretimi.
  final List<Kural> _kurallar = [];
  int _kuralSayac = 0;

  @override
  Future<List<Kural>> kurallar() async => List.unmodifiable(_kurallar);

  @override
  Future<String?> kuralEkle(Map<String, Object?> govde) async {
    final sonuc = kuralCoz({...govde, 'kuralId': 'r${_kuralSayac + 1}'}, katilimcilar);
    if (sonuc is String) return sonuc;
    _kuralSayac++;
    _kurallar.add(sonuc as Kural);
    return null;
  }

  @override
  Future<String?> kuralGuncelle(String kuralId, Map<String, Object?> govde) async {
    final i = _kurallar.indexWhere((k) => k.kuralId == kuralId);
    if (i < 0) return 'kural yok';
    final sonuc = kuralCoz({..._kurallar[i].govde(), ...govde, 'kuralId': kuralId}, katilimcilar);
    if (sonuc is String) return sonuc;
    _kurallar[i] = sonuc as Kural;
    return null;
  }

  @override
  Future<String?> kuralSil(String kuralId) async {
    _kurallar.removeWhere((k) => k.kuralId == kuralId);
    return null;
  }

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

  /// Sahte veride yalnız şu anki eş bilinir.
  @override
  List<({Kisi kisi, int sn})> gunBoyu(String id) {
    final k = bul(id);
    final ile = k.ile;
    return ile == null ? const [] : [(kisi: bul(ile), sn: k.sn + _tick)];
  }

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
