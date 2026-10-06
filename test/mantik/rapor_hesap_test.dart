import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/rapor_hesap.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

Katilimci k(String id, String ad, Rol rol, {String? kurum, String? kart, bool ayrildi = false, String sektor = '', bool paylasim = false, String eposta = ''}) =>
    Katilimci(kisiId: id, ad: ad, kurum: kurum, rol: rol, renk: KisiRengi.mavi, atananKart: kart, ayrildi: ayrildi, sektor: sektor, paylasim: paylasim, eposta: eposta);

final kisiler = [
  k('k1', 'Ayşe Demir', Rol.yatirimci, kart: '2', sektor: 'Sağlık, Enerji', eposta: 'a@b.c', paylasim: true),
  k('k2', 'Ali Kaya', Rol.girisimci, kurum: 'Nova', kart: '3', sektor: 'Sağlık'),
  k('k3', 'Veli Can', Rol.girisimci, kurum: 'Peak', kart: '4', sektor: 'Enerji'),
  k('k4', 'Gül Su', Rol.misafir, kart: '5'),
  k('k5', 'Can Yıldız', Rol.girisimci, kurum: 'Veri', kart: '6'),
  k('k6', 'Gitti', Rol.yatirimci, ayrildi: true),
  k('k7', 'Gelmedi', Rol.girisimci),
];
const oturumlar = [
  Oturum('k1', 'k2', 100, 400), // Ayşe–Nova 300 sn
  Oturum('k2', 'k1', 500, null), // sürüyor: 500→1000 = 500 sn (aynı çift ikinci görüşme)
  Oturum('k1', 'k3', 0, 120), // Ayşe–Peak 120
  Oturum('k2', 'k4', 0, 60), // Nova–misafir 60 (karma değil)
  Oturum('k5', 'kart:14', 0, 30), // kayıtsız kart
];
const simdi = 1000.0;

void main() {
  test('özet: görüşme sayısı, sürenler, karma süre (yalnız yatırımcı–girişimci), ulaşan, girişimci, kişi', () {
    final o = raporOzeti(kisiler, oturumlar, simdi);
    expect((o.gorusme, o.suren, o.karmaSn, o.ulasan, o.girisimci, o.kisi), (5, 1, 920, 2, 4, 7));
  });

  test('girişimci satırları: yatırımcı sayısı, sonra süre, sonra ad; yatırımcılar süreye göre', () {
    final s = girisimciSatirlari(kisiler, oturumlar, simdi);
    expect(s.map((x) => x.kisi.kisiId).toList(), ['k2', 'k3', 'k7', 'k5']); // eşitlikte ad: Gelmedi < Veri · Can Yıldız
    expect(s.first.yatirimcilar.single.kisi.kisiId, 'k1');
    expect(s.first.yatirimcilar.single.toplamSn, 800);
    expect(s.first.yatirimciSn, 800);
    expect(s[3].yatirimcilar, isEmpty);
  });

  test('kişi raporu (yatırımcı): karşı rol listesi en uzun önce, diğerleri ayrı, kaçırılanlar gelmiş girişimciler', () {
    final r = kisiRaporu('k1', kisiler, oturumlar, simdi);
    expect(r.karsi.map((e) => (e.kisi.kisiId, e.toplamSn, e.adet)).toList(), [('k2', 800, 2), ('k3', 120, 1)]);
    expect(r.diger, isEmpty);
    expect(r.kacirilan.map((x) => x.kisiId).toList(), ['k5']); // k7 kart almadı: gelmedi
    expect(r.ozet.karsiSayisi, 2);
    expect(r.ozet.karsiSn, 920);
  });

  test('kişi raporu (girişimci): misafirle görüşme "diğer"de; kayıtsız kart gösterilmez; ilgi eşleşmesi', () {
    final r = kisiRaporu('k2', kisiler, oturumlar, simdi);
    expect(r.karsi.single.kisi.kisiId, 'k1');
    expect(r.diger.single.kisi.kisiId, 'k4');
    final r5 = kisiRaporu('k5', kisiler, oturumlar, simdi);
    expect(r5.karsi, isEmpty);
    expect(r5.diger, isEmpty); // kart:14 kayıtsız
    expect(r5.kacirilan.map((x) => x.kisiId).toList(), ['k1', 'k6']); // ayrılan da gelmiş sayılır
    expect(ilgiEslesir('Sağlık, Enerji', 'enerji'), isTrue);
    expect(ilgiEslesir('Sağlık', 'Enerji'), isFalse);
  });

  test('etkinlik saati: clock − elapsed + sn → HH:MM', () {
    expect(etkinlikSaati(0, '15:10:09', 609), '15:00');
    expect(etkinlikSaati(3600, '00:30:00', 7200), '23:30');
  });
}
