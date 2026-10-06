import '../veri/modeller.dart';

// Uyarı kuralları (web `src/api/kurallar.js` ile aynı): organizatör masada kurar — "[kim] ile [kiminle]
// [yan yana gelince | N dakikadan uzun birlikte kalınca]"; sunucu bakar, uyarınca Pano'da açılır pencere.
// Sözleşme §10: { kuralId, ad, kim, kiminle, dakika, acik }; kim / kiminle: { kisiler: [kisiId] } ya da
// { rol: investor|founder|guest|herkes, enAzYildiz: 0–5 }. Saf Dart.

/// Kuralın bir tarafı: belirli kişiler ya da bir grup.
class KuralSecimi {
  const KuralSecimi.kisiler(this.kisiler) : rol = null, enAzYildiz = 0;
  const KuralSecimi.grup({required this.rol, this.enAzYildiz = 0}) : kisiler = null;

  final List<String>? kisiler;
  final String? rol;
  final int enAzYildiz;

  bool get kisilerMi => kisiler != null;

  static KuralSecimi ayristir(Object? ham) {
    if (ham is Map && ham['kisiler'] is List) {
      return KuralSecimi.kisiler((ham['kisiler'] as List).cast<String>());
    }
    if (ham is Map && ham['rol'] is String) {
      return KuralSecimi.grup(rol: ham['rol'] as String, enAzYildiz: (ham['enAzYildiz'] as num?)?.toInt() ?? 0);
    }
    return const KuralSecimi.grup(rol: 'herkes');
  }

  Map<String, Object?> govde() => kisilerMi ? {'kisiler': kisiler} : {'rol': rol, 'enAzYildiz': enAzYildiz};

  @override
  bool operator ==(Object other) =>
      other is KuralSecimi && other.rol == rol && other.enAzYildiz == enAzYildiz && _ayni(other.kisiler, kisiler);
  @override
  int get hashCode => Object.hash(rol, enAzYildiz, kisiler?.join(','));
}

bool _ayni(List<String>? a, List<String>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class Kural {
  const Kural({
    required this.kuralId,
    required this.ad,
    required this.kim,
    required this.kiminle,
    required this.dakika,
    required this.acik,
  });

  final String kuralId;
  final String ad;
  final KuralSecimi kim;
  final KuralSecimi kiminle;

  /// 0 = yan yana gelince; N = N dakikadan uzun birlikte.
  final int dakika;
  final bool acik;

  static Kural ayristir(Map<String, dynamic> ham) => Kural(
    kuralId: ham['kuralId'] as String? ?? '',
    ad: ham['ad'] as String? ?? '',
    kim: KuralSecimi.ayristir(ham['kim']),
    kiminle: KuralSecimi.ayristir(ham['kiminle']),
    dakika: (ham['dakika'] as num?)?.toInt() ?? 0,
    acik: ham['acik'] as bool? ?? true,
  );

  /// `POST` / `PATCH /api/rules` gövdesi.
  Map<String, Object?> govde() =>
      {'ad': ad, 'kim': kim.govde(), 'kiminle': kiminle.govde(), 'dakika': dakika, 'acik': acik};
}

/// Formun grup seçenekleri (web ile aynı sıra).
class GrupSecenegi {
  const GrupSecenegi(this.deger, this.etiket, this.secim);

  final String deger;
  final String etiket;
  final KuralSecimi secim;
}

const gruplar = [
  GrupSecenegi('investor', 'Yatırımcılar', KuralSecimi.grup(rol: 'investor')),
  GrupSecenegi('investor4', '★4+ yatırımcılar', KuralSecimi.grup(rol: 'investor', enAzYildiz: 4)),
  GrupSecenegi('investor3', '★3+ yatırımcılar', KuralSecimi.grup(rol: 'investor', enAzYildiz: 3)),
  GrupSecenegi('founder', 'Girişimciler', KuralSecimi.grup(rol: 'founder')),
  GrupSecenegi('guest', 'Misafirler', KuralSecimi.grup(rol: 'guest')),
  GrupSecenegi('herkes', 'Herkes', KuralSecimi.grup(rol: 'herkes')),
];

KuralSecimi grupSecimi(String deger) =>
    gruplar.firstWhere((g) => g.deger == deger, orElse: () => gruplar.last).secim;

/// Sunucudan gelen grup seçimi → seçici değeri ('investor4' …); bilinmeyen → 'herkes'.
String grupDegeri(KuralSecimi secim) =>
    gruplar.firstWhere((g) => g.secim == secim, orElse: () => gruplar.last).deger;

const _grupAdi = {'investor': 'yatırımcılar', 'founder': 'girişimciler', 'guest': 'misafirler', 'herkes': 'herkes'};

/// Kişilerde kısa ad (girişimcide kurum), bilinmeyen kimlik olduğu gibi; grupta "★4+ yatırımcılar".
String secimMetni(KuralSecimi secim, List<Katilimci> kisiler) {
  final kisilerListesi = secim.kisiler;
  if (kisilerListesi != null) {
    final harita = {for (final k in kisiler) k.kisiId: k};
    return kisilerListesi.map((id) => harita.containsKey(id) ? kisaAd(harita[id]!) : id).join(', ');
  }
  final yildiz = secim.enAzYildiz > 0 ? '★${secim.enAzYildiz}+ ' : '';
  return yildiz + (_grupAdi[secim.rol] ?? 'herkes');
}

/// Girişimcide kurum, diğerlerinde ad (web `kisaAd`).
String kisaAd(Katilimci k) => k.rol == Rol.girisimci && k.kurum != null ? k.kurum! : k.ad;

String kuralCumlesi(Kural kural, List<Katilimci> kisiler) {
  final ne = kural.dakika > 0 ? '${kural.dakika} dakikadan uzun birlikte kalınca' : 'yan yana gelince';
  return '${secimMetni(kural.kim, kisiler)} ile ${secimMetni(kural.kiminle, kisiler)} $ne';
}
