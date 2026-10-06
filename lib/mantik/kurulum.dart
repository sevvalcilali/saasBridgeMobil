import 'dart:math' as math;

import '../veri/modeller.dart';
import 'kisi_gorunum.dart';

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
const int _dusukPil = 20;
const int _saglikSatirSayisi = 8;

int esikSinirla(num deger) => deger.round().clamp(esikAlt, esikUst).toInt();

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

class SaglikSatiri {
  const SaglikSatiri({
    required this.kart,
    required this.kisi,
    required this.adsiz,
    required this.pil,
    required this.sorunlu,
  });

  final String kart;

  /// Kurum ya da görünen ad.
  final String kisi;

  /// Kayıtsız kart: ikincil renkte yazılır.
  final bool adsiz;
  final int pil;
  final bool sorunlu;

  String get durum => sorunlu ? '⚠ pil düşük' : '✓ iyi';
}

/// En düşük pilli 8 kart. Dart'ın sort'u kararlı olmadığı için özgün sıra
/// ikinci anahtardır.
List<SaglikSatiri> kartSagligi(List<Kisi> kisiler) {
  final sirali = [for (var i = 0; i < kisiler.length; i++) (sira: i, kisi: kisiler[i])]
    ..sort((a, b) {
      final fark = a.kisi.pil.compareTo(b.kisi.pil);
      return fark != 0 ? fark : a.sira.compareTo(b.sira);
    });
  return [
    for (final e in sirali.take(_saglikSatirSayisi))
      SaglikSatiri(
        kart: e.kisi.id,
        kisi: e.kisi.kurum ?? gorunenAd(e.kisi),
        adsiz: e.kisi.ad == null,
        pil: e.kisi.pil,
        sorunlu: e.kisi.pil < _dusukPil,
      ),
  ];
}

int sorunluKartSayisi(List<Kisi> kisiler) => kisiler.where((k) => k.pil < _dusukPil).length;
