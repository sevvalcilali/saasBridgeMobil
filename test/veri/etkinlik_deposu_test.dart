import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

void main() {
  test('başlangıç durumu', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    expect(d.tick, 0);
    expect(d.saat, '15:10:09');
    expect(d.saatKisa, '15:10');
    expect(d.esik, -72);
    expect(d.aliciBagli, isTrue);
    expect(d.etkinlikAdi, 'Yatırımcı Buluşması');
    expect(d.tarihMekan, '28.09.2026 · Demo Salonu');
    expect(d.raporTarihi, '02.10.2026');
    expect(d.cizelgeBaslangici, '15:10');
    expect(d.duyulanKartSayisi, 32);
    expect(d.kayitliKatilimci, 25);
    expect(d.kisiler, hasLength(26));
    expect(d.bildirimler, hasLength(4));
    expect(d.ciftler, hasLength(10));
    expect(d.seriRenkleri, hasLength(6));
    expect(d.acikKartlar, hasLength(9));
  });

  test('alıcı durumu ve bildirimler dışarıdan verilebilir', () {
    final d = EtkinlikDeposu(aliciBagli: false, bildirimler: const []);
    addTearDown(d.dispose);
    expect(d.aliciBagli, isFalse);
    expect(d.bildirimler, isEmpty);
  });

  test('ilerlet: tick ve saat birer saniye artar, dinleyiciler haberdar olur', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.ilerlet();
    d.ilerlet();
    expect(d.tick, 2);
    expect(d.saat, '15:10:11');
    expect(bildirim, 2);
  });

  test('sifirla: yalnız süre sayacı sıfırlanır, saat akmaya devam eder', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    d.ilerlet();
    d.ilerlet();
    d.sifirla();
    expect(d.tick, 0);
    expect(d.saat, '15:10:11');
    d.ilerlet();
    expect(d.tick, 1);
    expect(d.saat, '15:10:12');
  });

  test('eşik: sınırlarda durur, ±1 çalışır', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    d.esikAyarla(-200);
    expect(d.esik, -95);
    d.esikAzalt();
    expect(d.esik, -95);
    d.esikAyarla(0);
    expect(d.esik, -35);
    d.esikArtir();
    expect(d.esik, -35);
    d.esikAyarla(-70);
    d.esikArtir();
    expect(d.esik, -69);
    d.esikAzalt();
    d.esikAzalt();
    expect(d.esik, -71);
  });

  test('değişmeyen eşik bildirim göndermez', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.esikAyarla(-72);
    expect(bildirim, 0);
    d.esikAyarla(-71);
    expect(bildirim, 1);
  });

  test('bul: kişiyi getirir; bilinmeyen kart hata verir', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    expect(d.bul('24').ad, 'Cem Erdem');
    expect(() => d.bul('999'), throwsStateError);
  });

  testWidgets('baslat: saniyede bir ilerler; dispose zamanlayıcıyı durdurur', (tester) async {
    final d = EtkinlikDeposu();
    d.baslat();
    d.baslat(); // ikinci çağrı yeni zamanlayıcı açmaz
    await tester.pump(const Duration(seconds: 3));
    expect(d.tick, 3);
    d.dispose();
    await tester.pump(const Duration(seconds: 3));
    // Zamanlayıcı durmasaydı test "A Timer is still pending" hatasıyla düşerdi.
  });

  testWidgets('durdur: saat durur; baslat kaldığı yerden sürdürür', (tester) async {
    final d = EtkinlikDeposu();
    d.baslat();
    await tester.pump(const Duration(seconds: 2));
    expect(d.tick, 2);
    d.durdur();
    await tester.pump(const Duration(seconds: 5));
    expect(d.tick, 2);
    d.baslat();
    await tester.pump(const Duration(seconds: 1));
    expect(d.tick, 3);
    d.dispose();
  });
}
