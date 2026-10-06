import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kural.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

Katilimci k(String id, String ad, {String? kurum, Rol rol = Rol.yatirimci}) =>
    Katilimci(kisiId: id, ad: ad, kurum: kurum, rol: rol, renk: KisiRengi.mavi);

void main() {
  final kisiler = [k('k1', 'Ayşe Demir'), k('k2', 'Ali Kaya', kurum: 'Nova Robotik', rol: Rol.girisimci)];

  test('grup seçenekleri web ile aynı sırada; değer ↔ seçim gidiş dönüş', () {
    expect(gruplar.map((g) => g.deger).toList(), ['investor', 'investor4', 'investor3', 'founder', 'guest', 'herkes']);
    expect(grupSecimi('investor4'), const KuralSecimi.grup(rol: 'investor', enAzYildiz: 4));
    expect(grupDegeri(const KuralSecimi.grup(rol: 'investor', enAzYildiz: 3)), 'investor3');
    expect(grupDegeri(const KuralSecimi.grup(rol: 'uydurma')), 'herkes'); // bilinmeyen → herkes
    expect(grupSecimi('yok'), const KuralSecimi.grup(rol: 'herkes'));
  });

  test('seçim metni: kişilerde kısa ad (girişimcide kurum), bilinmeyen kimlik olduğu gibi; grupta ★ ve çoğul ad', () {
    expect(secimMetni(const KuralSecimi.kisiler(['k1', 'k2', 'k9']), kisiler), 'Ayşe Demir, Nova Robotik, k9');
    expect(secimMetni(const KuralSecimi.grup(rol: 'investor', enAzYildiz: 4), kisiler), '★4+ yatırımcılar');
    expect(secimMetni(const KuralSecimi.grup(rol: 'founder'), kisiler), 'girişimciler');
    expect(secimMetni(const KuralSecimi.grup(rol: 'herkes'), kisiler), 'herkes');
  });

  test('kural cümlesi: yan yana / N dakikadan uzun', () {
    const yanYana = Kural(kuralId: 'r1', ad: 'A', kim: KuralSecimi.kisiler(['k1']), kiminle: KuralSecimi.grup(rol: 'herkes'), dakika: 0, acik: true);
    const dakikali = Kural(kuralId: 'r2', ad: 'B', kim: KuralSecimi.grup(rol: 'investor', enAzYildiz: 4), kiminle: KuralSecimi.grup(rol: 'founder'), dakika: 5, acik: false);
    expect(kuralCumlesi(yanYana, kisiler), 'Ayşe Demir ile herkes yan yana gelince');
    expect(kuralCumlesi(dakikali, kisiler), '★4+ yatırımcılar ile girişimciler 5 dakikadan uzun birlikte kalınca');
  });

  test('JSON: sunucu biçiminden kural ve geri (sözleşme §10)', () {
    final ham = {
      'kuralId': 'r3', 'ad': '★4+ yatırımcılar ile girişimciler · 5 dk',
      'kim': {'rol': 'investor', 'enAzYildiz': 4}, 'kiminle': {'kisiler': ['k2']}, 'dakika': 5, 'acik': true,
    };
    final kural = Kural.ayristir(ham);
    expect(kural.kim, const KuralSecimi.grup(rol: 'investor', enAzYildiz: 4));
    expect(kural.kiminle, const KuralSecimi.kisiler(['k2']));
    expect(kural.dakika, 5);
    expect(kural.govde(), {'ad': ham['ad'], 'kim': ham['kim'], 'kiminle': ham['kiminle'], 'dakika': 5, 'acik': true});
    expect(Kural.ayristir({'kuralId': 'r4', 'ad': '', 'kim': {}, 'kiminle': null, 'dakika': null}).kim, const KuralSecimi.grup(rol: 'herkes'));
  });
}
