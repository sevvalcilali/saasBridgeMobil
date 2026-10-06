import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/rapor.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

Kisi bul(String id) => SahteVeri.kisiler.firstWhere((k) => k.id == id);

void main() {
  const kisiler = SahteVeri.kisiler;

  test('KPI: başlangıçta', () {
    final k = raporKpileri(kisiler, 0, kayitli: 25);
    expect(k.map((x) => x.ad), [
      'Görüşme',
      'Yatırımcı–girişimci toplam',
      'Yatırımcıya ulaşan girişimci',
      'Potansiyel anlaşma',
      'Katılımcı',
    ]);
    expect(k.map((x) => x.deger), ['10', '8 dk 42 sn', '10/12', '0', '25']);
    expect(k.map((x) => x.not), ['10 tanesi sürüyor', 'bugün', '', 'işaretlenmedi', 'kayıtlı']);
  });

  test('KPI: toplam süre, birlikte olan 10 girişimciyle akar', () {
    expect(raporKpileri(kisiler, 6, kayitli: 25)[1].deger, '9 dk 42 sn');
    expect(raporKpileri(kisiler, 400, kayitli: 25)[1].deger, '1 sa 15 dk');
  });

  test('satırlar: süreye göre azalan, eşitlikte özgün sıra', () {
    final s = raporSatirlari(kisiler, 0, bul);
    expect(s.map((r) => r.kisi.id), ['31', '39', '45', '41', '43', '35', '37', '24', '5', '33', '49', '51']);
  });

  test('satır: görüşen girişimci', () {
    final ilk = raporSatirlari(kisiler, 0, bul).first;
    expect(ilk.toplam, '1 dk 14 sn');
    expect(ilk.detay, 'Emre Kaya (1 dk 14 sn)');
    expect(ilk.gorusmedi, isFalse);
  });

  test('satır: hiç görüşmemiş girişimci', () {
    final son = raporSatirlari(kisiler, 0, bul).last;
    expect(son.toplam, '—');
    expect(son.detay, '⚠ Hiç yatırımcıyla görüşmedi');
    expect(son.gorusmedi, isTrue);
  });

  test('boş liste', () {
    expect(raporSatirlari(const [], 0, bul), isEmpty);
    expect(raporKpileri(const [], 0, kayitli: 0).map((x) => x.deger), ['0', '0 sn', '0/0', '0', '0']);
  });
}
