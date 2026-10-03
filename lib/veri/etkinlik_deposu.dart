import 'dart:async';

import 'package:flutter/foundation.dart';

import '../mantik/bicim.dart';
import '../mantik/kurulum.dart';
import 'modeller.dart';
import 'sahte_veri.dart';

/// Ekranların veriye TEK erişim noktası. Bugün gömülü sahte veriyi verir ve
/// saati kendi yürütür; gerçek sunucuya geçiş ileride yalnız bu katmanı değiştirir.
class EtkinlikDeposu extends ChangeNotifier {
  /// `aliciBagli` verilmezse derleme değişkeni okunur:
  /// `flutter run --dart-define=ALICI_BAGLI=false` kopuk durumu gösterir.
  /// `bildirimler` yalnız testlerde (boş durum) verilir.
  EtkinlikDeposu({bool? aliciBagli, List<Bildirim>? bildirimler})
    : aliciBagli = aliciBagli ?? const bool.fromEnvironment('ALICI_BAGLI', defaultValue: true),
      bildirimler = bildirimler ?? SahteVeri.bildirimler;

  final bool aliciBagli;
  final List<Bildirim> bildirimler;

  String get etkinlikAdi => SahteVeri.etkinlikAdi;
  String get tarihMekan => SahteVeri.tarihMekan;
  String get raporTarihi => SahteVeri.raporTarihi;
  String get cizelgeBaslangici => SahteVeri.cizelgeBaslangici;
  int get duyulanKartSayisi => SahteVeri.duyulanKartSayisi;
  int get kayitliKatilimci => SahteVeri.kayitliKatilimci;
  List<Kisi> get kisiler => SahteVeri.kisiler;
  List<Cift> get ciftler => SahteVeri.ciftler;
  List<KisiRengi> get seriRenkleri => SahteVeri.seriRenkleri;
  List<AcikKart> get acikKartlar => SahteVeri.acikKartlar;

  int _tick = 0;
  int _saatSn = SahteVeri.baslangicSaatSn;
  int _esik = SahteVeri.baslangicEsik;
  Timer? _zamanlayici;

  /// Sıfırla'dan bu yana geçen saniye; "birlikte" süreleri bununla akar.
  int get tick => _tick;

  /// Günün saniyesi.
  int get saatSn => _saatSn;
  String get saat => saatYazisi(_saatSn);
  String get saatKisa => kisaSaatYazisi(_saatSn);

  /// "Birlikte" sayılmak için gereken en düşük sinyal gücü (dBm).
  int get esik => _esik;

  Kisi bul(String id) => kisiler.firstWhere((k) => k.id == id);

  /// Saati başlatır (saniyede bir `ilerlet`). Yeniden çağırmak etkisizdir.
  void baslat() {
    _zamanlayici ??= Timer.periodic(const Duration(seconds: 1), (_) => ilerlet());
  }

  /// Bir saniye ilerletir. Zamanlayıcı bunu çağırır; testler doğrudan çağırır.
  void ilerlet() {
    _tick++;
    _saatSn++;
    notifyListeners();
  }

  /// Süre sayacını sıfırlar. Saat akmaya devam eder.
  void sifirla() {
    _tick = 0;
    notifyListeners();
  }

  void esikAyarla(int deger) {
    final yeni = esikSinirla(deger);
    if (yeni == _esik) return;
    _esik = yeni;
    notifyListeners();
  }

  void esikArtir() => esikAyarla(_esik + 1);

  void esikAzalt() => esikAyarla(_esik - 1);

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }
}
