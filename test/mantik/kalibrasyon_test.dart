import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kalibrasyon.dart';

void main() {
  test('önerilen eşik: iki ölçümün ortası (sınırlanmış), fark; fark 6 dB altındaysa "kucuk" uyarısı', () {
    final o = onerilenEsik(-58.4, -78.0)!;
    expect(o.deger, -68);
    expect(o.fark, 19.6);
    expect(o.uyari, isNull);
    final yakin = onerilenEsik(-70, -74)!;
    expect(yakin.uyari, KalibrasyonUyarisi.kucuk);
    expect(yakin.deger, -72);
  });

  test('sırt sırta ölçüm yüz yüzeden güçlüyse "ters": öneri yok', () {
    final o = onerilenEsik(-80, -60)!;
    expect(o.uyari, KalibrasyonUyarisi.ters);
    expect(o.deger, isNull);
    expect(onerilenEsik(null, -60), isNull);
  });

  test('geri sayım: 10 sn pencere, kalan tam saniye, 0\'da biter', () {
    expect(kalanSaniye(0, 0), 10);
    expect(kalanSaniye(0, 1500), 9);
    expect(kalanSaniye(0, 9999), 1);
    expect(kalanSaniye(0, 10000), 0);
    expect(kalanSaniye(0, 12000), 0);
  });

  test('önerilen eşik web (JS Math.round) gibi yuvarlanır: −68,5 → −68', () {
    expect(onerilenEsik(-58, -79)!.deger, -68);
  });
}
