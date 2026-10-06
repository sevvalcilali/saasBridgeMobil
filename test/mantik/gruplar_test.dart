import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/gruplar.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

Kisi k(String id, Rol rol, {String? ile, int sn = 0, bool gorunmuyor = false, int yildiz = 0, int bostaSn = 0}) =>
    Kisi(id: id, ad: 'K$id', rol: rol, renk: KisiRengi.mavi, ile: ile, sn: sn, gorunmuyor: gorunmuyor, yildiz: yildiz, bostaSn: bostaSn);

final kisiler = [
  k('2', Rol.yatirimci, ile: '3', sn: 250),
  k('3', Rol.girisimci, ile: '2', sn: 250),
  k('4', Rol.misafir, ile: '3', sn: 90),
  k('5', Rol.yatirimci, ile: '6', sn: 120),
  k('6', Rol.yatirimci, ile: '5', sn: 120),
  k('7', Rol.girisimci),
  k('8', Rol.yatirimci, yildiz: 4, bostaSn: 400),
  k('9', Rol.misafir, gorunmuyor: true),
];
const ciftler = [CanliCift('2', '3'), CanliCift('3', '4'), CanliCift('5', '6'), CanliCift('6', '101')];

void main() {
  test('zincirlenen çiftler tek grup; üyeler yatırımcı → girişimci → misafir; karma = yatırımcı + girişimci', () {
    final g = canliGruplar(kisiler, ciftler);
    expect(g.map((x) => x.uyeler.map((u) => u.id).toList()).toList(), [['2', '3', '4'], ['5', '6']]);
    expect(g.map((x) => x.karma).toList(), [true, false]);
    expect(g.first.sn, 250); // en uzun süren üye
    expect(g.first.anahtar, '2-3-4');
  });

  test('kişisi olmayan kart (101) çifti yok sayılır; çift yoksa grup yok', () {
    expect(canliGruplar(kisiler, const [CanliCift('6', '101')]), isEmpty);
    expect(canliGruplar(kisiler, const []), isEmpty);
  });

  test('boştakiler: önce yalnız kalan önemli yatırımcı, sonra en uzun boşta; görünmeyenler ayrı', () {
    final g = canliGruplar(kisiler, ciftler);
    final b = bostakiler(kisiler, g);
    expect(b.bosta.map((x) => x.id).toList(), ['8', '7']);
    expect(b.gorunmeyen.map((x) => x.id).toList(), ['9']);
    expect(yalnizMi(kisiler[6]), isTrue); // ★4, 400 sn boşta
    expect(yalnizMi(k('1', Rol.yatirimci, yildiz: 2, bostaSn: 400)), isFalse);
    expect(yalnizMi(k('1', Rol.yatirimci, yildiz: 4, bostaSn: 300)), isFalse);
  });

  test('grup sıraları: 2 yan yana; 3 üçgen; 4 ikişer; 5 arkada 2 önde 3; 6 üçer', () {
    expect([2, 3, 4, 5, 6].map(grupSiralari).toList(), [(0, 2), (1, 2), (2, 2), (2, 3), (3, 3)]);
  });

  test('süre rengi: gri → sarı (5 dk) → turuncu (10 dk) → kırmızı (20 dk)', () {
    expect(sureRengi(0), SureRengi.gri);
    expect(sureRengi(299), SureRengi.gri);
    expect(sureRengi(300), SureRengi.sari);
    expect(sureRengi(600), SureRengi.turuncu);
    expect(sureRengi(1200), SureRengi.kirmizi);
  });

  test('duruş kişiye göre sabit (0–2), kalabalıkta tekdüze değil', () {
    final pozlar = {for (final id in ['2', '3', '4', '5', '6', '7', '8', '9']) id: siluetPozu(id)};
    expect(pozlar.values.every((p) => p >= 0 && p <= 2), isTrue);
    expect(pozlar.values.toSet().length, greaterThan(1));
    expect(siluetPozu('42'), siluetPozu('42'));
  });

  test('yerler kararlı: büyüyen grup yerinde kalır, biten grubun yeri boş kalır, yeni grup boş yere girer', () {
    final a = canliGruplar(kisiler, const [CanliCift('2', '3'), CanliCift('5', '6')]);
    final ilk = yerlestir(const [], a);
    expect(ilk.atama, {'2-3': 0, '5-6': 1});
    final b = canliGruplar(kisiler, const [CanliCift('2', '3'), CanliCift('3', '4')]); // 5-6 bitti, 2-3 büyüdü
    final ikinci = yerlestir(ilk.yerler, b);
    expect(ikinci.atama, {'2-3-4': 0});
    expect(ikinci.yerler, hasLength(1)); // sondaki boşluk atılır
    final c = canliGruplar(kisiler, const [CanliCift('5', '6'), CanliCift('2', '3'), CanliCift('3', '4')]);
    final ucuncu = yerlestir([ikinci.yerler[0], null], c);
    expect(ucuncu.atama, {'2-3-4': 0, '5-6': 1});
  });
}
