import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/uyari.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

Bildirim b(String baslik, {Onem onem = Onem.kural, double t = 1000, List<String> kisiler = const ['2', '3']}) =>
    Bildirim(baslik: baslik, detay: 'd', saat: '10:00', onem: onem, kisiler: kisiler, t: t);

void main() {
  test('yalnız kural uyarıları açılır; görülenler atlanır; en eski önce (sıra)', () {
    final liste = [b('yeni', t: 1300), b('anlaşma', onem: Onem.olumlu, t: 1200), b('eski', t: 1100)];
    final acilacak = acilacakUyarilar(liste, {uyariAnahtari(liste[2])}, 1300);
    expect(acilacak.map((x) => x.baslik).toList(), ['yeni']);
    expect(acilacakUyarilar(liste, const {}, 1300).map((x) => x.baslik).toList(), ['eski', 'yeni']);
  });

  test('ilk açılışta yalnız son 2 dakikanın uyarıları çıkar (eskiler sessizce görülmüş sayılır)', () {
    final liste = [b('taze', t: 1000), b('bayat', t: 1000 - ilkAcilistaSn - 1)];
    expect(acilacakUyarilar(liste, const {}, 1000, ilk: true).map((x) => x.baslik).toList(), ['taze']);
    expect(acilacakUyarilar(liste, const {}, 1000).length, 2);
  });

  test('anahtar: zaman + başlık + kişiler; aynı anda aynı kişilerle iki farklı kural ayrı sayılır', () {
    expect(uyariAnahtari(b('A')), '1000.0-A-2.3');
    expect(uyariAnahtari(b('A')) == uyariAnahtari(b('B')), isFalse);
  });
}
