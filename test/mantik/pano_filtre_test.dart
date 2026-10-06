import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/pano_filtre.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const kisiler = SahteVeri.kisiler;
  int adet(PanoFiltre f) => filtreleKisiler(kisiler, filtre: f).length;
  List<String> ara(String q, [PanoFiltre f = PanoFiltre.tumu]) => [
    for (final k in filtreleKisiler(kisiler, filtre: f, arama: q)) k.id,
  ];

  test('filtre sayıları', () {
    expect(adet(PanoFiltre.tumu), 26);
    expect(adet(PanoFiltre.yatirimci), 10);
    expect(adet(PanoFiltre.girisimci), 12);
    expect(adet(PanoFiltre.birlikte), 20);
    expect(adet(PanoFiltre.bosta), 5);
    expect(adet(PanoFiltre.gorunmuyor), 1);
    expect(adet(PanoFiltre.hicGorusmemis), 5);
  });

  test('sıra korunur (liste zıplamaz)', () {
    expect(ara('').first, '24');
    expect(ara('', PanoFiltre.yatirimci).first, '61');
  });

  test('filtre etiketleri', () {
    expect(PanoFiltre.values.map((f) => f.etiket), [
      'Tümü',
      'Yatırımcı',
      'Girişimci',
      'Birlikte',
      'Boşta',
      'Görünmüyor',
      'Hiç görüşmemiş',
    ]);
  });

  test('arama: ad, kurum ve kart no', () {
    expect(ara('nova'), ['24']);
    expect(ara('cem'), ['24']);
    expect(ara('61'), ['61']);
    expect(ara('kart 14'), ['14']);
    expect(ara('kılıç'), ['5', '46']);
  });

  test('arama: Türkçe büyük-küçük harf ve baştaki/sondaki boşluk', () {
    expect(ara('NOVA'), ['24']);
    expect(ara('İREM'), ['31']);
    expect(ara('  cem  '), ['24']);
    expect(ara('IŞIK'), isEmpty);
  });

  test('arama filtreyle birlikte uygulanır; sonuç yoksa boş liste', () {
    expect(ara('nova', PanoFiltre.yatirimci), isEmpty);
    expect(ara('yok böyle biri'), isEmpty);
  });

  test('liste başlığı', () {
    expect(listeBasligi(PanoFiltre.tumu), 'Kişiler');
    expect(listeBasligi(PanoFiltre.yatirimci), 'Yatırımcılar');
    expect(listeBasligi(PanoFiltre.girisimci), 'Girişimciler');
    expect(listeBasligi(PanoFiltre.birlikte), 'Birlikte');
    expect(listeBasligi(PanoFiltre.hicGorusmemis), 'Hiç görüşmemiş');
  });

  test('bildirim süzme, sayıları ve etiketleri', () {
    const b = SahteVeri.bildirimler;
    expect([for (final o in onemSirasi) onemSayisi(b, o)], [4, 1, 2, 1, 0]);
    expect([for (final o in onemSirasi) onemEtiketi(o)], ['Tümü', 'Ciddi', 'Uyarı', 'Olumlu', 'Kural']);
    expect(bildirimleriSuz(b, null), hasLength(4));
    expect(bildirimleriSuz(b, Onem.ciddi).single.baslik, 'Kart kayboldu');
    expect(bildirimleriSuz(const [], Onem.uyari), isEmpty);
  });
}
