import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/metin.dart';

void main() {
  test('trKucuk: I → ı, İ → i', () {
    expect(trKucuk('IŞIK'), 'ışık');
    expect(trKucuk('İREM'), 'irem');
    expect(trKucuk('Şehir Sensör'), 'şehir sensör');
    expect(trKucuk('NOVA'), 'nova');
    expect(trKucuk(''), '');
  });

  test('trBuyuk: i → İ, ı → I', () {
    expect(trBuyuk('girişimciler'), 'GİRİŞİMCİLER');
    expect(trBuyuk('yatırımcı'), 'YATIRIMCI');
    expect(trBuyuk('Kart sağlığı'), 'KART SAĞLIĞI');
    expect(trBuyuk(''), '');
  });
}
