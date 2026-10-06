import '../veri/modeller.dart';
import 'kisi_gorunum.dart';

// Ağ bölümünün yerleşimi. Düğüm konumu FİZİKSEL konum DEĞİLDİR; yalnız rol
// gruplarını gösterir. Konum sıraya bağlıdır, zamanla değişmez (zıplamaz).

/// Bir düğüm satırının yüksekliği (px).
const double agSatirAraligi = 30;

/// Çizginin düğüme değdiği yatay uzaklık: 14 px şekil + 8 px boşluk.
const double _kenarPayi = 22;

class AgDugumu {
  const AgDugumu({required this.kisi, required this.ad});

  final Kisi kisi;
  final String ad;
}

class AgKenari {
  const AgKenari(this.x1, this.y1, this.x2, this.y2);

  final double x1;
  final double y1;
  final double x2;
  final double y2;
}

class AgYerlesimi {
  const AgYerlesimi({
    required this.sol,
    required this.sag,
    required this.kenarlar,
    required this.yukseklik,
  });

  /// Yatırımcılar ve şu an birlikte olan misafirler.
  final List<AgDugumu> sol;

  /// Girişimciler.
  final List<AgDugumu> sag;

  /// Şu an birlikte olan çiftler arasındaki çizgiler.
  final List<AgKenari> kenarlar;
  final double yukseklik;
}

double _y(int satir) => 16 + satir * agSatirAraligi;

AgYerlesimi agYerlesimi(List<Kisi> kisiler, double genislik) {
  final sol = [
    for (final k in kisiler)
      if (k.rol != Rol.girisimci && (k.ile != null || k.rol == Rol.yatirimci)) k,
  ];
  final sag = [
    for (final k in kisiler)
      if (k.rol == Rol.girisimci) k,
  ];
  final kenarlar = <AgKenari>[];
  for (var i = 0; i < sag.length; i++) {
    final j = sol.indexWhere((x) => x.id == sag[i].ile);
    if (j >= 0) kenarlar.add(AgKenari(_kenarPayi, _y(j), genislik - _kenarPayi, _y(i)));
  }
  final satir = sol.length > sag.length ? sol.length : sag.length;
  return AgYerlesimi(
    sol: [for (final k in sol) AgDugumu(kisi: k, ad: gorunenAd(k))],
    sag: [for (final k in sag) AgDugumu(kisi: k, ad: k.kurum ?? gorunenAd(k))],
    kenarlar: kenarlar,
    yukseklik: satir * agSatirAraligi + 10,
  );
}
