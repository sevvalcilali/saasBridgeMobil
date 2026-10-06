import 'package:flutter/foundation.dart';

import '../mantik/bicim.dart';
import 'modeller.dart';
import 'sahte_depo.dart';

/// Ekranların veriye TEK erişim noktası. İki gerçekleme: [SahteDepo] (gömülü sahte veri, saati
/// kendi yürütür; testler ve sunucusuz deneme) ve [SunucuDeposu] (gerçek sunucu: `/state` + `/events`).
/// Ekranlar hangisi olduğunu bilmez.
abstract class EtkinlikDeposu extends ChangeNotifier {
  EtkinlikDeposu.temel();

  /// Varsayılan: sahte veri. `aliciBagli` verilmezse derleme değişkeni okunur
  /// (`--dart-define=ALICI_BAGLI=false` kopuk durumu gösterir); `bildirimler` yalnız testlerde.
  factory EtkinlikDeposu({bool? aliciBagli, List<Bildirim>? bildirimler}) = SahteDepo;

  /// Sunucuyla bağlantı var mı (sahte veride hep var). Yoksa üstte bant çıkar, son veri kalır.
  bool get sunucuBagli;

  /// Alıcı (USB) sunucuya bağlı ve duyuyor mu.
  bool get aliciBagli;
  List<Bildirim> get bildirimler;
  String get etkinlikAdi;
  String get tarihMekan;
  String get raporTarihi;

  /// Görüşme zaman çizelgesinin başı (etkinliğin başladığı saat).
  String get cizelgeBaslangici;
  int get duyulanKartSayisi;
  int get kayitliKatilimci;
  List<Kisi> get kisiler;
  List<Cift> get ciftler;
  List<KisiRengi> get seriRenkleri;
  List<AcikKart> get acikKartlar;

  /// Sıfırla'dan bu yana geçen saniye; "birlikte" süreleri bununla akar (sunucuda hep 0: süre sunucudan gelir).
  int get tick;

  /// Günün saniyesi.
  int get saatSn;
  String get saat => saatYazisi(saatSn);
  String get saatKisa => kisaSaatYazisi(saatSn);

  /// "Birlikte" sayılmak için gereken en düşük sinyal gücü (dBm).
  int get esik;

  Kisi bul(String id);

  /// Veri akışını başlatır (saat ya da sunucu bağlantısı). Yeniden çağırmak etkisizdir.
  void baslat();

  /// Akışı durdurur (uygulama arka plana geçince). `baslat` kaldığı yerden sürdürür.
  void durdur();

  /// Bir saniye ilerletir; yalnız sahte veride anlamlı (testler doğrudan çağırır).
  void ilerlet() {}

  /// Süreleri/geçmişi/bildirimleri sıfırlar — çağıran onay almış olmalı.
  Future<void> sifirla();

  void esikAyarla(int deger);

  void esikArtir() => esikAyarla(esik + 1);

  void esikAzalt() => esikAyarla(esik - 1);
}
