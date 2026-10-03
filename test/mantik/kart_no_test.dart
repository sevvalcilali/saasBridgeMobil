import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kart_no.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  test('numaraTemizle: baştaki sıfırları atar', () {
    expect(numaraTemizle('007'), '7');
    expect(numaraTemizle('70'), '70');
    expect(numaraTemizle('000'), '');
    expect(numaraTemizle(''), '');
  });

  test('numaraGecerli: yalnız 1–99', () {
    for (final g in ['1', '7', '007', '14', '99', '099']) {
      expect(numaraGecerli(g), isTrue, reason: '"$g" geçerli olmalı');
    }
    for (final g in ['', '0', '00', '100', '1a', 'abc', '-3', ' 5', '12345678901234567890']) {
      expect(numaraGecerli(g), isFalse, reason: '"$g" geçersiz olmalı');
    }
  });

  test('yalnizRakam: rakam dışını atar', () {
    expect(yalnizRakam('1a2 b3'), '123');
    expect(yalnizRakam('abc'), '');
  });

  test('acikKartOner: numara ön ekine göre süzer', () {
    const kartlar = SahteVeri.acikKartlar;
    List<String> oner(String n) => [for (final k in acikKartOner(kartlar, n)) k.no];
    expect(oner(''), hasLength(9));
    expect(oner('8'), ['88', '89']);
    expect(oner('9'), ['90', '96', '97']);
    expect(oner('09'), ['90', '96', '97']);
    expect(oner('0'), hasLength(9));
    expect(oner('3'), isEmpty);
  });

  test('acikKartEtiketi', () {
    expect(acikKartEtiketi(SahteVeri.acikKartlar.first), 'boşta');
    expect(acikKartEtiketi(SahteVeri.acikKartlar.last), 'atanmış');
  });

  test('masaAra: yalnız adı olanlar; ad, kurum ve kart no', () {
    List<String> ara(String q) => [for (final k in masaAra(SahteVeri.kisiler, q)) k.id];
    expect(ara(''), hasLength(25));
    expect(ara('peak'), ['31']);
    expect(ara('PEAK'), ['31']);
    expect(ara('24'), ['24']);
    expect(ara('14'), isEmpty);
  });
}
