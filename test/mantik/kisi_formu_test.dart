import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kisi_formu.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

void main() {
  test('geçerlilik: ad boş olamaz', () {
    expect(const KisiFormVerisi(ad: ' ', rol: Rol.girisimci).gecerli, isFalse);
    expect(const KisiFormVerisi(ad: 'Ayşe', rol: Rol.yatirimci).gecerli, isTrue);
  });

  test('gönderim: yıldız yalnız yatırımcıda, aşama yalnız girişimcide, metinler kırpılır, paylaşım bool', () {
    const f = KisiFormVerisi(ad: ' Ayşe Demir ', rol: Rol.girisimci, kurum: ' Nova ', yildiz: 4, asama: 'mvp',
        sektor: ' Sağlık ', tanitim: 'x', web: ' nova.co ', eposta: 'a@b.c', paylasim: true, notu: ' n ');
    expect(f.govde(), {
      'ad': 'Ayşe Demir', 'rol': 'founder', 'kurum': 'Nova', 'yildiz': 0, 'not': 'n',
      'sektor': 'Sağlık', 'asama': 'mvp', 'tanitim': 'x', 'web': 'nova.co', 'eposta': 'a@b.c', 'paylasim': true,
    });
    expect(f.copyWith(rol: Rol.yatirimci).govde()['yildiz'], 4);
    expect(f.copyWith(rol: Rol.yatirimci).govde()['asama'], '');
  });

  test('düzenleme farkı: yalnız değişen alanlar; renk ve kimlik hiç gönderilmez', () {
    const k = Katilimci(kisiId: 'k1', ad: 'Ayşe Demir', kurum: 'Atlas', rol: Rol.yatirimci, renk: KisiRengi.mavi,
        yildiz: 4, sektor: 'Enerji', eposta: 'a@b.c', paylasim: false);
    final f = KisiFormVerisi.katilimcidan(k).copyWith(yildiz: 5, paylasim: true);
    expect(duzenlemeFarki(k, f), {'yildiz': 5, 'paylasim': true});
    expect(duzenlemeFarki(k, KisiFormVerisi.katilimcidan(k)), isEmpty);
  });

  test('katılımcıdan form: alanlar taşınır, boşlar boş metin', () {
    const k = Katilimci(kisiId: 'k2', ad: 'Ali', rol: Rol.girisimci, renk: KisiRengi.gri);
    final f = KisiFormVerisi.katilimcidan(k);
    expect((f.ad, f.rol, f.kurum, f.yildiz, f.asama, f.paylasim), ('Ali', Rol.girisimci, '', 0, '', false));
  });
}
