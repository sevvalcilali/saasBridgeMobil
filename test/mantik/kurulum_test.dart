import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kurulum.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const ciftler = SahteVeri.ciftler;
  const renkler = SahteVeri.seriRenkleri;

  test('esikSinirla: −95…−35 arası tam sayı', () {
    expect(esikSinirla(-100), -95);
    expect(esikSinirla(-20), -35);
    expect(esikSinirla(-72), -72);
    expect(esikSinirla(-71.6), -72);
  });

  test('esikUstuCiftSayisi: eşikten güçlü çiftler', () {
    expect(esikUstuCiftSayisi(ciftler, -72), 8);
    expect(esikUstuCiftSayisi(ciftler, -95), 10);
    expect(esikUstuCiftSayisi(ciftler, -51), 1);
    expect(esikUstuCiftSayisi(ciftler, -35), 0);
  });

  test('grafikY: −40 üstte, −90 altta', () {
    expect(grafikY(-40, 150), closeTo(0, 1e-9));
    expect(grafikY(-90, 150), closeTo(150, 1e-9));
    expect(grafikY(-72, 150), closeTo(96, 1e-9));
  });

  test('grafikY: eksen dışındaki değer kenara yapışır', () {
    expect(grafikY(-35, 150), 0);
    expect(grafikY(-95, 150), 150);
  });

  test('sozdeRastgele: 0–1 arası ve deterministik', () {
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 40; j++) {
        final r = sozdeRastgele(i, j);
        expect(r, inInclusiveRange(0, 1));
        expect(sozdeRastgele(i, j), r);
      }
    }
  });

  test('grafikSerileri: 6 seri × 31 nokta, eksen içinde', () {
    final seriler = grafikSerileri(ciftler, renkler, 0, 362, 150);
    expect(seriler, hasLength(6));
    expect(seriler.first.ad, '27 · 28');
    expect(seriler.first.renk, KisiRengi.pembe);
    expect(seriler.last.ad, '44 · 67');
    for (final seri in seriler) {
      expect(seri.noktalar, hasLength(31));
      expect(seri.noktalar.first.x, 28);
      expect(seri.noktalar.last.x, closeTo(362, 1e-9));
      for (final n in seri.noktalar) {
        expect(n.y, inInclusiveRange(0, 150));
      }
    }
  });

  test('grafik her saniye bir adım sola kayar', () {
    final t0 = grafikSerileri(ciftler, renkler, 0, 362, 150);
    final t1 = grafikSerileri(ciftler, renkler, 1, 362, 150);
    expect(t1.first.noktalar[0].y, closeTo(t0.first.noktalar[1].y, 1e-9));
    expect(t1.first.noktalar[29].y, closeTo(t0.first.noktalar[30].y, 1e-9));
  });

  test('grafikSerileri: altıdan az çift ve boş liste', () {
    expect(grafikSerileri(ciftler.sublist(0, 2), renkler, 0, 362, 150), hasLength(2));
    expect(grafikSerileri(const [], renkler, 0, 362, 150), isEmpty);
  });

  test('kartSagligi: pile göre artan, eşitlikte özgün sıra, ilk 8', () {
    final satirlar = kartSagligi(SahteVeri.kisiler);
    expect(satirlar.map((r) => r.kart), ['46', '5', '14', '37', '58', '45', '4', '47']);
    expect(satirlar.first.sorunlu, isTrue);
    expect(satirlar.first.durum, '⚠ pil düşük');
    expect(satirlar.first.kisi, 'Mehmet Kılıç');
    expect(satirlar.first.pil, 16);
    expect(satirlar[1].kisi, 'Şehir Sensör');
    expect(satirlar[1].sorunlu, isFalse);
    expect(satirlar[1].durum, '✓ iyi');
    expect(satirlar[2].kisi, 'Kart 14');
    expect(satirlar[2].adsiz, isTrue);
  });

  test('sorunluKartSayisi', () {
    expect(sorunluKartSayisi(SahteVeri.kisiler), 1);
    expect(sorunluKartSayisi(const []), 0);
  });
}
