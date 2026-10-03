import '../veri/modeller.dart';
import 'bicim.dart';

// Kişiden türetilen ad, durum ve süre yazıları.

/// Kayıtsız kart "Kart 14" diye gösterilir.
String gorunenAd(Kisi k) => k.ad ?? 'Kart ${k.id}';

/// Liste satırının kalın başlığı: kurum varsa kurum, yoksa ad.
String baslik(Kisi k) => k.kurum ?? gorunenAd(k);

/// Başlığın yanındaki ikincil yazı: "· Cem Erdem" ya da "· ★★★★".
String altAd(Kisi k) {
  if (k.kurum != null) return '· ${gorunenAd(k)}';
  return k.yildiz > 0 ? '· ${yildizlar(k.yildiz)}' : '';
}

/// "Nova Robotik · Cem Erdem" (kurum yoksa yalnız ad).
String tamAd(Kisi k) => k.kurum != null ? '${k.kurum} · ${gorunenAd(k)}' : gorunenAd(k);

String rolAdi(Rol rol) => switch (rol) {
  Rol.yatirimci => 'Yatırımcı',
  Rol.girisimci => 'Girişimci',
  Rol.misafir => 'Misafir',
};

/// "Yatırımcı · ★★★★" (yıldız yoksa yalnız rol).
String rolSatiri(Kisi k) => k.yildiz > 0 ? '${rolAdi(k.rol)} · ${yildizlar(k.yildiz)}' : rolAdi(k.rol);

/// "Kart 61 · ★★★★" (yıldız yoksa "Kart 24").
String kartMetni(Kisi k) => k.yildiz > 0 ? 'Kart ${k.id} · ${yildizlar(k.yildiz)}' : 'Kart ${k.id}';

/// Süre yalnız şu an birlikte olan kişide akar.
int gecenSn(Kisi k, int tick) => k.ile != null ? k.sn + tick : k.sn;

DurumTonu durumTonu(Kisi k) {
  if (k.gorunmuyor) return DurumTonu.uyari;
  return k.ile != null ? DurumTonu.birlikte : DurumTonu.ikincil;
}

/// "Elif Aydın ile · 19 sn" / "Boşta" / "Görünmüyor · 3 dk önce duyuldu".
String durumCumlesi(Kisi k, int tick, Kisi Function(String id) bul) {
  if (k.gorunmuyor) return 'Görünmüyor · 3 dk önce duyuldu';
  final ile = k.ile;
  if (ile != null) return '${gorunenAd(bul(ile))} ile · ${sureYazisi(gecenSn(k, tick))}';
  return 'Boşta';
}

/// Satırın sağındaki süre; hiç görüşmemişse "—".
String sureMetni(Kisi k, int tick) => (k.ile != null || k.sn > 0) ? sureYazisi(gecenSn(k, tick)) : '—';

String sonDuyulma(Kisi k) => k.gorunmuyor ? '3 dk önce' : 'az önce';

/// Zaman çizelgesindeki yeşil dolgunun oranı (0–1).
double cizelgeOrani(Kisi k, int tick) {
  if (k.ile == null) return 0;
  final oran = (20 + gecenSn(k, tick) / 3) / 100;
  return oran > 1 ? 1 : oran;
}
