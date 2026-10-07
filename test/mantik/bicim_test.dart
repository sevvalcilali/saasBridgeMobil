import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/bicim.dart';

void main() {
  dakikaTestleri();
  test('sureYazisi: saniye, dakika, saat', () {
    expect(sureYazisi(0), '0 sn');
    expect(sureYazisi(19), '19 sn');
    expect(sureYazisi(59), '59 sn');
    expect(sureYazisi(60), '1 dk');
    expect(sureYazisi(74), '1 dk 14 sn');
    expect(sureYazisi(522), '8 dk 42 sn');
    expect(sureYazisi(3599), '59 dk 59 sn');
  });

  test('sureYazisi: uzun oturum (bir saat ve üstü)', () {
    expect(sureYazisi(3600), '1 sa');
    expect(sureYazisi(4560), '1 sa 16 dk');
    expect(sureYazisi(7199), '2 sa');
    expect(sureYazisi(36000), '10 sa');
  });

  test('sureYazisi: eksi değer sıfır sayılır', () {
    expect(sureYazisi(-5), '0 sn');
  });

  test('saat: gün içinde döner', () {
    expect(saatYazisi(54609), '15:10:09');
    expect(kisaSaatYazisi(54609), '15:10');
    expect(saatYazisi(86399), '23:59:59');
    expect(saatYazisi(86400), '00:00:00');
    expect(kisaSaatYazisi(86400 + 61), '00:01');
  });

  test('dbmYazisi: gerçek eksi işareti (U+2212)', () {
    expect(dbmYazisi(-72), '−72');
    expect(dbmYazisi(-35), '−35');
    expect(dbmYazisi(0), '0');
  });

  test('yildizlar', () {
    expect(yildizlar(3), '★★★');
    expect(yildizlar(0), '');
  });
}

void dakikaTestleri() {
  test('dakikaYazisi: özet yerleri için dakikaya yuvarlar; 0 "—", 1 dk altı "<1 dk"', () {
    expect(dakikaYazisi(0), '—');
    expect(dakikaYazisi(30), '<1 dk');
    expect(dakikaYazisi(90), '2 dk');
    expect(dakikaYazisi(4380), '1 sa 13 dk');
  });
}
