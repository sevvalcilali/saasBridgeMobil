import 'package:flutter/foundation.dart';

import '../mantik/bicim.dart';
import '../mantik/gruplar.dart';
import '../mantik/kural.dart';
import '../mantik/rapor_hesap.dart';
import 'modeller.dart';
import 'sahte_depo.dart';

/// Ekranların veriye TEK erişim noktası. İki gerçekleme: [SahteDepo] (gömülü sahte veri, saati
/// kendi yürütür; testler ve sunucusuz deneme) ve [SunucuDeposu] (gerçek sunucu: `/state` + `/events`).
/// Ekranlar hangisi olduğunu bilmez.
abstract class EtkinlikDeposu extends ChangeNotifier {
  EtkinlikDeposu.temel();

  /// Varsayılan: sahte veri. `aliciBagli` verilmezse derleme değişkeni okunur
  /// (`--dart-define=ALICI_BAGLI=false` kopuk durumu gösterir); `bildirimler` yalnız testlerde.
  factory EtkinlikDeposu({bool? aliciBagli, bool sunucuBagli, List<Bildirim>? bildirimler}) = SahteDepo;

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

  /// Şu an birlikte olan kart çiftleri (salon görünümü kümeleri bundan çıkar).
  List<CanliCift> get canliCiftler;
  List<Cift> get ciftler;
  List<KisiRengi> get seriRenkleri;

  /// Sinyal geçmişi: "a-b" → [(saniye önce, dBm)]; sunucuda yalnız `grafikIste(true)` iken dolar.
  Map<String, List<(int, double)>> get gecmis;
  int get grafikSaniyesi;

  /// Kurulum açıkken true: sunucudan grafik geçmişi istenir (büyük veri, yalnız gerekince).
  void grafikIste(bool iste) {}
  List<AcikKart> get acikKartlar;

  /// Kayıtlı kişiler (kartı olsun olmasın): Kart Ver ve İade.
  List<Katilimci> get katilimcilar;

  /// Sahte veriyle mi çalışıyor (Kart Ver'de "Demo: kartı yaklaştır" düğmesi yalnız o zaman).
  bool get demo;

  /// Sıfırla'dan bu yana geçen saniye; "birlikte" süreleri bununla akar (sunucuda hep 0: süre sunucudan gelir).
  int get tick;

  /// Günün saniyesi.
  int get saatSn;
  String get saat => saatYazisi(saatSn);
  String get saatKisa => kisaSaatYazisi(saatSn);

  /// "Birlikte" sayılmak için gereken en düşük sinyal gücü (dBm).
  int get esik;

  Kisi bul(String id);

  /// Kişinin bugün görüştükleri ve toplam süreleri, en uzun önce (kişi detayı "Bugün kiminle").
  List<({Kisi kisi, int sn})> gunBoyu(String id);

  /// Veri akışını başlatır (saat ya da sunucu bağlantısı). Yeniden çağırmak etkisizdir.
  void baslat();

  /// Akışı durdurur (uygulama arka plana geçince). `baslat` kaldığı yerden sürdürür.
  void durdur();

  /// Bir saniye ilerletir; yalnız sahte veride anlamlı (testler doğrudan çağırır).
  void ilerlet() {}

  /// Süreleri/geçmişi/bildirimleri sıfırlar — çağıran onay almış olmalı.
  Future<void> sifirla();

  void esikAyarla(int deger);

  /// Kişiye kart verir (kart değişimi dahil). Başarısızsa kullanıcıya gösterilecek hata metni.
  Future<String?> kartAta(String kisiId, String kart);

  /// Kartı iade alır; `ayrildi: false` = "Geri al" (kişi ayrılmadı, hâlâ kart bekliyor).
  Future<String?> kartIadeAl(String kart, {bool ayrildi = true});

  /// Yeni kayıtlı kişi (`POST /api/people` gövdesi). Hata metni ya da null.
  Future<String?> kisiEkle(Map<String, Object?> govde);

  /// Kişiyi günceller; `govde` yalnız değişen alanlar. Hata metni ya da null.
  Future<String?> kisiGuncelle(String kisiId, Map<String, Object?> govde);

  /// Görüşme kayıtları (`/api/sessions`; rapor açılışta ve "Yenile" ile ister).
  Future<List<Oturum>> oturumlar();

  /// Etkinliğin başından geçen saniye (`/state.elapsed`): oturum sürelerinin "şimdi"si.
  double get gecenSn;

  /// Uyarı kuralları (sözleşme §10): sunucuda tutulur, her açılışta istenir (önbellek yok).
  Future<List<Kural>> kurallar();
  Future<String?> kuralEkle(Map<String, Object?> govde);
  Future<String?> kuralGuncelle(String kuralId, Map<String, Object?> govde);
  Future<String?> kuralSil(String kuralId);

  void esikArtir() => esikAyarla(esik + 1);

  void esikAzalt() => esikAyarla(esik - 1);
}
