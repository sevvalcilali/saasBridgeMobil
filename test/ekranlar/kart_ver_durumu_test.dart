import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

void main() {
  late EtkinlikDeposu depo;
  late KartVerDurumu d;

  setUp(() {
    depo = EtkinlikDeposu();
    d = KartVerDurumu(depo);
  });

  tearDown(() {
    d.dispose();
    depo.dispose();
  });

  test('başlangıç durumu', () {
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.kartModu, KartSecimModu.yaklastir);
    expect(d.bulundu, isNull);
    expect(d.sonAtama, isNull);
    expect(d.bilgi, isNull);
    expect(d.iadeKisisi, isNull);
    expect(d.arama, '');
    expect(d.numara, '');
    expect(d.numaraSecilebilir, isFalse);
  });

  test('kisiSec: adım 2; numara temizlenir', () {
    d.numaraDenetleyici.text = '14';
    d.kisiSec('24');
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
    expect(d.numara, '');
    expect(d.bulundu, isNull);
  });

  test('kartModuSec', () {
    d.kartModuSec(KartSecimModu.numara);
    expect(d.kartModu, KartSecimModu.numara);
  });

  testWidgets('demoYaklastir: 1,4 sn sonra Kart 88 bulunur; seçince adım 3', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1399));
    expect(d.bulundu, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(d.bulundu, '88');
    d.bulunanSec();
    expect(d.adim, 3);
    expect(d.seciliKart, '88');
  });

  testWidgets('demo: art arda basılırsa son basıştan 1,4 sn sonra, tek kez bulunur', (tester) async {
    d.kisiSec('24');
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1000));
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(d.bulundu, isNull);
    await tester.pump(const Duration(milliseconds: 400));
    expect(d.bulundu, '88');
    expect(bildirim, 1);
  });

  testWidgets('demo beklerken geri dönülürse eski kart sonradan belirmez (S16)', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 500));
    d.kisiAdiminaDon();
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    d.kisiSec('31');
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    expect(d.adim, 2);
  });

  testWidgets('demo beklerken başka kişiye geçilirse iptal olur (S16)', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 500));
    d.kartDegistirBaslat('31');
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    expect(d.kisi!.id, '31');
  });

  test('bulunanSec: kart bulunmadıysa etkisiz', () {
    d.kisiSec('24');
    d.bulunanSec();
    expect(d.adim, 2);
    expect(d.seciliKart, isNull);
  });

  test('numara: yalnız rakam; 1–99 geçerli; baştaki sıfır atılır', () {
    d.kisiSec('24');
    d.numaraDenetleyici.text = '0';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraSec(); // geçersizken etkisiz
    expect(d.adim, 2);
    d.numaraDenetleyici.text = '100';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '12345678901234567890';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '1a4';
    expect(d.numara, '14');
    expect(d.numaraSecilebilir, isTrue);
    d.numaraDenetleyici.text = '007';
    expect(d.numaraSecilebilir, isTrue);
    d.numaraSec();
    expect(d.adim, 3);
    expect(d.seciliKart, '7');
  });

  test('acikKartSec: adım 3', () {
    d.kisiSec('24');
    d.acikKartSec('89');
    expect(d.adim, 3);
    expect(d.seciliKart, '89');
  });

  test('adımlar arası geri dönüş', () {
    d.kisiSec('24');
    d.acikKartSec('89');
    d.kartAdiminaDon();
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
    d.kisiAdiminaDon();
    expect(d.adim, 1);
  });

  test('onayla: son atama bandı, adım 1, alanlar temiz', () {
    d.aramaDenetleyici.text = 'nova';
    d.kisiSec('24');
    d.numaraDenetleyici.text = '88';
    d.numaraSec();
    d.onayla();
    expect(d.sonAtama, (ad: 'Cem Erdem', kart: '88'));
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.bulundu, isNull);
    expect(d.numara, '');
    expect(d.arama, '');
    expect(d.bilgi, isNull);
  });

  test('onayla: kişi ya da kart seçili değilse etkisiz', () {
    d.onayla();
    expect(d.sonAtama, isNull);
    d.kisiSec('24');
    d.onayla();
    expect(d.sonAtama, isNull);
    expect(d.adim, 2);
  });

  test('geriAl: bilgi metni yazılır, bant kalkar; bant yokken etkisiz', () {
    d.kisiSec('24');
    d.acikKartSec('88');
    d.onayla();
    d.geriAl();
    expect(d.sonAtama, isNull);
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
    d.geriAl();
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
  });

  test('yeni onay önceki bilgi metnini siler', () {
    d.kisiSec('24');
    d.acikKartSec('88');
    d.onayla();
    d.geriAl();
    d.kisiSec('31');
    d.acikKartSec('89');
    d.onayla();
    expect(d.bilgi, isNull);
    expect(d.sonAtama, (ad: 'İrem Korkmaz', kart: '89'));
  });

  test('iade: seç, vazgeç, onayla', () {
    d.modIade();
    expect(d.mod, KartVerModu.iade);
    d.iadeSec('24');
    expect(d.iadeKisisi!.id, '24');
    d.iadeVazgec();
    expect(d.iadeKisisi, isNull);
    d.iadeOnayla(); // seçim yokken etkisiz
    expect(d.bilgi, isNull);
    d.iadeSec('24');
    d.iadeOnayla();
    expect(d.iadeKisisi, isNull);
    expect(d.bilgi, '✓ Kart 24 iade alındı. Cem Erdem panodan düştü; süreleri raporda kalır.');
  });

  test('modVer iade seçimini temizler; mod değişimi sihirbazı bozmaz', () {
    d.kisiSec('24');
    d.modIade();
    d.iadeSec('31');
    d.modVer();
    expect(d.mod, KartVerModu.ver);
    expect(d.iadeKisisi, isNull);
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
  });

  test('kartDegistirBaslat: Kart ver modu, adım 2, kişi seçili', () {
    d.modIade();
    d.numaraDenetleyici.text = '5';
    d.kartDegistirBaslat('61');
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 2);
    expect(d.kisi!.id, '61');
    expect(d.numara, '');
    expect(d.bulundu, isNull);
  });

  test('iadeBaslat: Kart iadesi modu, kişi seçili', () {
    d.iadeBaslat('61');
    expect(d.mod, KartVerModu.iade);
    expect(d.iadeKisisi!.id, '61');
  });

  test('adsız kart: ad yerine "Kart 14" yazılır (S14)', () {
    d.kartDegistirBaslat('14');
    d.acikKartSec('88');
    d.onayla();
    expect(d.sonAtama!.ad, 'Kart 14');
    d.iadeBaslat('14');
    d.iadeOnayla();
    expect(d.bilgi, '✓ Kart 14 iade alındı. Kart 14 panodan düştü; süreleri raporda kalır.');
  });
}
