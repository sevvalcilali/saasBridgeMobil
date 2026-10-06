import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kisi_gorunum.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

Kisi bul(String id) => SahteVeri.kisiler.firstWhere((k) => k.id == id);

void main() {
  final cem = bul('24'); // girişimci, Nova Robotik, Elif Aydın (19) ile, 19 sn
  final ayse = bul('61'); // yatırımcı ★★★★, birlikte
  final zeynep = bul('83'); // yatırımcı ★★, boşta
  final kaan = bul('40'); // görünmüyor
  final can = bul('49'); // hiç görüşmemiş girişimci
  final adsiz = bul('14'); // kayıtsız kart

  test('adlar', () {
    expect(gorunenAd(cem), 'Cem Erdem');
    expect(gorunenAd(adsiz), 'Kart 14');
    expect(baslik(cem), 'Nova Robotik');
    expect(baslik(ayse), 'Ayşe Demir');
    expect(baslik(adsiz), 'Kart 14');
    expect(altAd(cem), '· Cem Erdem');
    expect(altAd(ayse), '· ★★★★');
    expect(altAd(adsiz), '');
    expect(tamAd(cem), 'Nova Robotik · Cem Erdem');
    expect(tamAd(ayse), 'Ayşe Demir');
    expect(tamAd(adsiz), 'Kart 14');
  });

  test('rol ve kart metni', () {
    expect(rolAdi(Rol.yatirimci), 'Yatırımcı');
    expect(rolAdi(Rol.girisimci), 'Girişimci');
    expect(rolAdi(Rol.misafir), 'Misafir');
    expect(rolSatiri(ayse), 'Yatırımcı · ★★★★');
    expect(rolSatiri(cem), 'Girişimci');
    expect(kartMetni(ayse), 'Kart 61 · ★★★★');
    expect(kartMetni(cem), 'Kart 24');
  });

  test('süre yalnız birlikte olan kişide akar', () {
    expect(gecenSn(cem, 0), 19);
    expect(gecenSn(cem, 10), 29);
    expect(gecenSn(can, 10), 0);
    expect(sureMetni(cem, 0), '19 sn');
    expect(sureMetni(cem, 41), '1 dk');
    expect(sureMetni(can, 41), '—');
  });

  test('durum cümlesi ve tonu', () {
    expect(durumCumlesi(cem, 0, bul), 'Elif Aydın ile · 19 sn');
    expect(durumTonu(cem), DurumTonu.birlikte);
    expect(durumCumlesi(kaan, 0, bul), 'Görünmüyor · 3 dk önce duyuldu');
    expect(durumTonu(kaan), DurumTonu.uyari);
    expect(durumCumlesi(zeynep, 5, bul), 'Boşta');
    expect(durumTonu(zeynep), DurumTonu.ikincil);
  });

  test('son duyulma', () {
    expect(sonDuyulma(kaan), '3 dk önce');
    expect(sonDuyulma(cem), 'az önce');
  });

  test('çizelge oranı: birlikte değilse 0, en çok 1', () {
    expect(cizelgeOrani(can, 100), 0);
    expect(cizelgeOrani(cem, 0), closeTo(0.2633, 0.0001));
    expect(cizelgeOrani(cem, 1000), 1);
  });
}
