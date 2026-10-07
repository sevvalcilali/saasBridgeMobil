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
  organizatorTestleri();
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

void organizatorTestleri() {
  test('özet ekleri: yatırımcı, misafir, ayrılan sayısı ve ortalama görüşme süresi', () {
    final o = raporOzeti(kisiler, oturumlar, simdi);
    expect((o.yatirimci, o.misafir, o.ayrilan, o.ortalamaSn), (2, 1, 1, 202)); // (300+500+120+60+30)/5
  });

  test('yatırımcı satırları: görüştüğü girişimciler süreye göre; hiç görüşmeyen en altta', () {
    final y = yatirimciSatirlari(kisiler, oturumlar, simdi);
    expect(y.map((x) => x.kisi.kisiId).toList(), ['k1', 'k6']);
    expect([for (final g in y.first.girisimciler) (g.kisi.kisiId, g.toplamSn)], [('k2', 800), ('k3', 120)]);
    expect(y.first.girisimciSn, 920);
    expect(y.last.girisimciler, isEmpty);
  });

  test('gün içi yoğunluk: dilim başına süren görüşme; en yoğun dilim; sıfır süreli de sayılır', () {
    final y = gunIciYogunluk(oturumlar, simdi);
    expect(y.dilimSn, 300);
    expect([for (final d in y.dilimler) (d.bas, d.son, d.adet)], [(0, 300, 4), (300, 600, 2), (600, 900, 1), (900, 1200, 1)]);
    expect((y.enYogun!.bas, y.enYogun!.adet), (0, 4));
    expect(gunIciYogunluk(const [], 50).dilimler, isEmpty);
    expect(gunIciYogunluk(const [Oturum('k1', 'k2', 500, null)], 500).enYogun!.adet, 1);
  });

  test('gün içi yoğunluk: saatin katlarına hizalanır; uzun etkinlikte dilim büyür', () {
    // Etkinlik 0. sn = 09:43:30 (saat 10:00:10, geçen 1000 sn + 0) → 09:40 dilimi = −210. sn.
    expect(gunIciYogunluk(oturumlar, simdi, saat: '10:00:10', elapsed: 1000).dilimler.first.bas, -210);
    expect(gunIciYogunluk(const [Oturum('k1', 'k2', 0, 4 * 3600)], 4 * 3600).dilimSn, 900);
    expect(gunIciYogunluk(const [Oturum('k1', 'k2', 0, 8 * 3600)], 8 * 3600).dilimSn, 1800);
  });

  test('güçlü eşleşmeler: yalnız yatırımcı–girişimci, toplam süreye göre; anlaşma işareti', () {
    final e = gucluEslesmeler(kisiler, oturumlar, simdi, anlasanlar: {'k1|k2'});
    expect([for (final x in e) (x.yatirimci.kisiId, x.girisimci.kisiId, x.toplamSn, x.adet, x.anlasma)],
        [('k1', 'k2', 800, 2, true), ('k1', 'k3', 120, 1, false)]);
    expect(gucluEslesmeler(kisiler, oturumlar, simdi, n: 1), hasLength(1));
    expect(ciftAnahtari('k2', 'k1'), 'k1|k2');
  });

  test('önerilen tanıştırmalar: ilgi alanı tutan, ikisi de gelmiş, hiç görüşmemiş çiftler', () {
    expect(onerilenTanistirmalar(kisiler, oturumlar), isEmpty); // Nova ve Peak zaten görüştü
    final ek = [...kisiler, k('k8', 'Su Ak', Rol.girisimci, kurum: 'Zirve', kart: '9', sektor: 'Sağlık'), k('k9', 'Yok', Rol.girisimci, kurum: 'Bulut', sektor: 'Sağlık')];
    expect([for (final o in onerilenTanistirmalar(ek, oturumlar)) (o.yatirimci.kisiId, o.girisimci.kisiId, o.sektor)], [('k1', 'k8', 'Sağlık')]);
  });

  test('takip listesi: gelmiş ama karşı rolle hiç görüşmemiş girişimci ve yatırımcılar', () {
    final t = takipListesi(girisimciSatirlari(kisiler, oturumlar, simdi), yatirimciSatirlari(kisiler, oturumlar, simdi));
    expect(t.girisimciler.map((x) => x.kisiId).toList(), ['k5']); // k7 kart almadı: gelmedi
    expect(t.yatirimcilar.map((x) => x.kisiId).toList(), ['k6']); // ayrılan da gelmiş sayılır
  });
}
