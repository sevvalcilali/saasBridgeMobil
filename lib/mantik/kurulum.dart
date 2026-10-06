import 'dart:math' as math;

import '../veri/modeller.dart';

// Kurulum ekranı: eşik, canlı sinyal grafiği geometrisi, kart sağlığı.

/// Eşik kaydırıcısının sınırları (dBm).
const int esikAlt = -95;
const int esikUst = -35;

/// Grafik ekseni: üst kenar −40 dBm, alt kenar −90 dBm.
const double _grafikUstDbm = -40;
const double _grafikAltDbm = -90;

/// Grafiğin solunda eksen etiketlerine ayrılan boşluk (px).
const double grafikSolBosluk = 28;

const int _grafikNoktaSayisi = 31;
const int _grafikCiftSayisi = 6;

/// Yuvarlama web (JS `Math.round`) gibi: yarım yukarı (−68,5 → −68).
int esikSinirla(num deger) => (deger + 0.5).floor().clamp(esikAlt, esikUst).toInt();

/// Şu an eşiğin üstünde (eşikten güçlü) olan çift sayısı.
int esikUstuCiftSayisi(List<Cift> ciftler, int esik) => ciftler.where((c) => c.rssi > esik).length;

/// dBm → piksel (üst = güçlü). Eksen dışındaki değer kenara yapışır.
double grafikY(num dbm, double yukseklik) {
  final y = (dbm - _grafikUstDbm) * yukseklik / (_grafikAltDbm - _grafikUstDbm);
  if (y < 0) return 0;
  if (y > yukseklik) return yukseklik;
  return y;
}

/// Prototipteki deterministik sözde rastgele sayı (0–1).
double sozdeRastgele(int i, int j) {
  final x = math.sin(i * 374.1 + j * 91.7) * 43758.5453;
  return x - x.floorToDouble();
}

class GrafikSerisi {
  const GrafikSerisi({required this.ad, required this.renk, required this.noktalar});

  /// Lejant etiketi: "27 · 28".
  final String ad;
  final KisiRengi renk;
  final List<({double x, double y})> noktalar;
}

/// En güçlü ilk 6 çiftin son 90 saniyelik çizgileri. `tick` arttıkça bir adım
/// sola kayar. x: [grafikSolBosluk, genislik]; y: [0, yukseklik].
List<GrafikSerisi> grafikSerileri(
  List<Cift> ciftler,
  List<KisiRengi> renkler,
  int tick,
  double genislik,
  double yukseklik,
) {
  final adim = (genislik - grafikSolBosluk) / (_grafikNoktaSayisi - 1);
  final adet = math.min(ciftler.length, _grafikCiftSayisi);
  return [
    for (var i = 0; i < adet; i++)
      GrafikSerisi(
        ad: '${ciftler[i].a} · ${ciftler[i].b}',
        renk: renkler[i % renkler.length],
        noktalar: [
          for (var j = 0; j < _grafikNoktaSayisi; j++)
            (
              x: grafikSolBosluk + j * adim,
              y: grafikY(ciftler[i].rssi + (sozdeRastgele(i, j + tick) - 0.5) * 8, yukseklik),
            ),
        ],
      ),
  ];
}

/// Sunucunun geçmişinden (`history`: çift → [(saniye önce, dBm)]) en güçlü 6 çiftin çizgileri. x: saniye önce
/// (sol = `grafikSaniyesi` önce, sağ = şimdi); geçmişi olmayan çift yalnız şimdiki değeriyle tek nokta.
List<GrafikSerisi> grafikSerileriGecmisten(
  Map<String, List<(int, double)>> gecmis,
  List<Cift> ciftler,
  List<KisiRengi> renkler,
  double genislik,
  double yukseklik,
  int grafikSaniyesi,
) {
  final sirali = [...ciftler]..sort((a, b) => b.rssi.compareTo(a.rssi));
  final adet = math.min(sirali.length, _grafikCiftSayisi);
  double x(num snOnce) => grafikSolBosluk + (genislik - grafikSolBosluk) * (1 - snOnce / grafikSaniyesi).clamp(0, 1);
  return [
    for (var i = 0; i < adet; i++)
      GrafikSerisi(
        ad: '${sirali[i].a} · ${sirali[i].b}',
        renk: renkler.isEmpty ? KisiRengi.gri : renkler[i % renkler.length],
        noktalar: [
          for (final (snOnce, dbm) in gecmis['${sirali[i].a}-${sirali[i].b}'] ?? gecmis['${sirali[i].b}-${sirali[i].a}'] ?? [(0, sirali[i].rssi.toDouble())])
            (x: x(snOnce), y: grafikY(dbm, yukseklik)),
        ],
      ),
  ];
}

class SaglikSatiri {
  const SaglikSatiri({
    required this.kart,
    required this.kisi,
    required this.adsiz,
    required this.seenAgo,
    required this.sorunlu,
    this.durumMetni,
  });

  final String kart;

  /// Kurum ya da görünen ad.
  final String kisi;

  /// Kayıtsız kart: ikincil renkte yazılır.
  final bool adsiz;

  /// Kaç saniye önce duyuldu.
  final double seenAgo;
  final bool sorunlu;

  /// Sorunun metni (duyulmuyor / görünmüyor).
  final String? durumMetni;

  String get durum => durumMetni ?? '✓ iyi';

  /// "az önce" / "40 sn önce" / "3 dk önce".
  String get duyulma => duyulmaYazisi(seenAgo);
}

String duyulmaYazisi(double sn) {
  if (sn < 10) return 'az önce';
  if (sn < 60) return '${sn.round()} sn önce';
  return '${sn ~/ 60} dk önce';
}

/// Kart sağlığı ölçütleri (web `kartSagligi.js`): ≥ 60 sn duyulmayan "duyulmuyor" (kayıp), > 30 sn "görünmüyor".
/// Pil gösterilmez (Şevval kararı 07.10.2026). Sorunlular üstte (en ağırı önce), gerisi kart numarasına göre.
const int kayipSn = 60;
const int sessizSn = 30;

({int agirlik, String metin})? _kartSorunu(AcikKart k) {
  if (k.seenAgo >= kayipSn) return (agirlik: 0, metin: '⚠ duyulmuyor');
  if (k.seenAgo > sessizSn) return (agirlik: 1, metin: '◌ görünmüyor');
  return null;
}

/// Alıcının bildiği tüm kartlar (masadaki yedekler, sessiz ve kayıp olanlar dahil).
/// `kartKisi`: kart no → kişi/kurum adı (atanmamış kart adsız).
List<SaglikSatiri> kartSagligi(List<AcikKart> kartlar, Map<String, String> kartKisi) {
  final sirali = [...kartlar]..sort((a, b) {
      final fark = (_kartSorunu(a)?.agirlik ?? 9).compareTo(_kartSorunu(b)?.agirlik ?? 9);
      return fark != 0 ? fark : (int.tryParse(a.no) ?? 0).compareTo(int.tryParse(b.no) ?? 0);
    });
  return [
    for (final k in sirali)
      SaglikSatiri(
        kart: k.no,
        kisi: kartKisi[k.no] ?? 'Kart ${k.no}',
        adsiz: !kartKisi.containsKey(k.no),
        seenAgo: k.seenAgo,
        sorunlu: _kartSorunu(k) != null,
        durumMetni: _kartSorunu(k)?.metin,
      ),
  ];
}

int sorunluKartSayisi(List<AcikKart> kartlar) => kartlar.where((k) => _kartSorunu(k) != null).length;
