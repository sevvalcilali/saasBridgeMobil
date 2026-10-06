import '../veri/modeller.dart';
import 'bicim.dart';
import 'kisi_gorunum.dart';

// Rapor ekranı: KPI'lar ve girişimci satırları.

class Kpi {
  const Kpi(this.ad, this.deger, this.not);

  final String ad;
  final String deger;
  final String not;
}

List<Kisi> _girisimciler(List<Kisi> kisiler) => [
  for (final k in kisiler)
    if (k.rol == Rol.girisimci) k,
];

/// Beş KPI. `kayitli`: kayıtlı katılımcı sayısı.
List<Kpi> raporKpileri(List<Kisi> kisiler, int tick, {required int kayitli}) {
  final girisimciler = _girisimciler(kisiler);
  final ulasan = girisimciler.where((k) => k.ile != null).length;
  final toplamSn = girisimciler.fold<int>(0, (toplam, k) => toplam + gecenSn(k, tick));
  return [
    Kpi('Görüşme', '$ulasan', '$ulasan tanesi sürüyor'),
    Kpi('Yatırımcı–girişimci toplam', sureYazisi(toplamSn), 'bugün'),
    Kpi('Yatırımcıya ulaşan girişimci', '$ulasan/${girisimciler.length}', ''),
    const Kpi('Potansiyel anlaşma', '0', 'işaretlenmedi'),
    Kpi('Katılımcı', '$kayitli', 'kayıtlı'),
  ];
}

class RaporSatiri {
  const RaporSatiri({
    required this.kisi,
    required this.toplam,
    required this.detay,
    required this.gorusmedi,
  });

  final Kisi kisi;

  /// "1 dk 14 sn" ya da "—".
  final String toplam;
  final String detay;

  /// true → detay ciddi renkte yazılır.
  final bool gorusmedi;
}

/// Girişimciler, toplam süreye göre azalan. Dart'ın sort'u kararlı olmadığı
/// için özgün sıra ikinci anahtardır.
List<RaporSatiri> raporSatirlari(List<Kisi> kisiler, int tick, Kisi Function(String id) bul) {
  final sirali = [
    for (var i = 0; i < kisiler.length; i++)
      if (kisiler[i].rol == Rol.girisimci) (sira: i, kisi: kisiler[i]),
  ]..sort((a, b) {
      final fark = gecenSn(b.kisi, tick).compareTo(gecenSn(a.kisi, tick));
      return fark != 0 ? fark : a.sira.compareTo(b.sira);
    });
  return [
    for (final e in sirali) _satir(e.kisi, tick, bul),
  ];
}

RaporSatiri _satir(Kisi k, int tick, Kisi Function(String id) bul) {
  final ile = k.ile;
  if (ile == null) {
    return RaporSatiri(kisi: k, toplam: '—', detay: '⚠ Hiç yatırımcıyla görüşmedi', gorusmedi: true);
  }
  final sure = sureYazisi(gecenSn(k, tick));
  return RaporSatiri(kisi: k, toplam: sure, detay: '${gorunenAd(bul(ile))} ($sure)', gorusmedi: false);
}
