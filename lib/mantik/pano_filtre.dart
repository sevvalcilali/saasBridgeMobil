import '../veri/modeller.dart';
import 'kisi_gorunum.dart';
import 'metin.dart';

// Pano'daki kişi listesi ve bildirim akışının süzme mantığı.

/// Kişiler bölümündeki filtre çipleri, sırasıyla.
enum PanoFiltre {
  tumu('Tümü'),
  yatirimci('Yatırımcı'),
  girisimci('Girişimci'),
  birlikte('Birlikte'),
  bosta('Boşta'),
  gorunmuyor('Görünmüyor'),
  hicGorusmemis('Hiç görüşmemiş');

  const PanoFiltre(this.etiket);

  final String etiket;
}

bool _filtreUyar(Kisi k, PanoFiltre filtre) => switch (filtre) {
  PanoFiltre.tumu => true,
  PanoFiltre.yatirimci => k.rol == Rol.yatirimci,
  PanoFiltre.girisimci => k.rol == Rol.girisimci,
  PanoFiltre.birlikte => k.ile != null,
  PanoFiltre.bosta => k.ile == null && !k.gorunmuyor,
  PanoFiltre.gorunmuyor => k.gorunmuyor,
  PanoFiltre.hicGorusmemis => k.hic,
};

/// Filtre + arama (ad, kurum, kart no). Sıra değişmez: liste zıplamaz.
List<Kisi> filtreleKisiler(
  List<Kisi> kisiler, {
  PanoFiltre filtre = PanoFiltre.tumu,
  String arama = '',
}) {
  final q = trKucuk(arama.trim());
  return [
    for (final k in kisiler)
      if (_filtreUyar(k, filtre) &&
          (q.isEmpty || trKucuk('${k.kurum ?? ''} ${gorunenAd(k)} ${k.id}').contains(q)))
        k,
  ];
}

/// Listenin üstündeki kicker başlığı.
String listeBasligi(PanoFiltre f) => switch (f) {
  PanoFiltre.tumu => 'Kişiler',
  PanoFiltre.yatirimci => 'Yatırımcılar',
  PanoFiltre.girisimci => 'Girişimciler',
  _ => f.etiket,
};

/// Önem çiplerinin sırası; `null` = Tümü.
const List<Onem?> onemSirasi = [null, Onem.ciddi, Onem.uyari, Onem.olumlu];

String onemEtiketi(Onem? onem) => switch (onem) {
  null => 'Tümü',
  Onem.ciddi => 'Ciddi',
  Onem.uyari => 'Uyarı',
  Onem.olumlu => 'Olumlu',
};

List<Bildirim> bildirimleriSuz(List<Bildirim> liste, Onem? onem) {
  if (onem == null) return liste;
  return [
    for (final b in liste)
      if (b.onem == onem) b,
  ];
}

int onemSayisi(List<Bildirim> liste, Onem? onem) => bildirimleriSuz(liste, onem).length;
