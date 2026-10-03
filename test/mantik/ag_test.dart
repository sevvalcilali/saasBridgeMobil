import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/ag.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  final y = agYerlesimi(SahteVeri.kisiler, 362);

  test('sol: yatırımcılar + birlikte olan misafirler; sağ: girişimciler', () {
    expect(y.sol.map((d) => d.kisi.id), ['61', '46', '83', '65', '19', '52', '71', '44', '58', '40', '47', '4']);
    expect(y.sag.map((d) => d.kisi.id), ['24', '31', '33', '35', '37', '39', '41', '43', '45', '5', '49', '51']);
    expect(y.sol.first.ad, 'Ayşe Demir');
    expect(y.sag.first.ad, 'Nova Robotik');
  });

  test('yükseklik: en kalabalık sütun × 30 + 10', () {
    expect(y.yukseklik, 370);
  });

  test('kenarlar: birlikte olan 10 çift', () {
    expect(y.kenarlar, hasLength(10));
    // Nova Robotik (sağ 0. satır) ↔ Elif Aydın (sol 4. satır)
    final k = y.kenarlar.first;
    expect([k.x1, k.y1, k.x2, k.y2], [22, 136, 340, 16]);
  });

  test('kenarlar genişliğe uyar', () {
    expect(agYerlesimi(SahteVeri.kisiler, 390).kenarlar.first.x2, 368);
  });

  test('boş liste', () {
    final bos = agYerlesimi(const [], 362);
    expect(bos.sol, isEmpty);
    expect(bos.sag, isEmpty);
    expect(bos.kenarlar, isEmpty);
    expect(bos.yukseklik, 10);
  });
}
