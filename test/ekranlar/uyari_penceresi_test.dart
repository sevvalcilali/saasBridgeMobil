import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/pano/uyari_penceresi.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

import '../yardimci.dart';

final simdi = DateTime.now().millisecondsSinceEpoch / 1000;

Bildirim kural(String baslik, {double? t, List<String> kisiler = const ['24', '19']}) => Bildirim(
  baslik: baslik,
  detay: 'Nova Robotik ile Elif Aydın 5 dakikadır birlikte.',
  saat: '15:09',
  onem: Onem.kural,
  kisiler: kisiler,
  t: t ?? simdi,
);

Future<EtkinlikDeposu> _baslat(WidgetTester tester, List<Bildirim> bildirimler) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu(bildirimler: bildirimler);
  addTearDown(depo.dispose);
  await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
  await tester.pump();
  return depo;
}

void main() {
  testWidgets('kural uyarısı gelince pencere açılır; Tamam kapatır; sıradaki gelir', (tester) async {
    await _baslat(tester, [kural('İkinci', t: simdi - 5), kural('Birinci', t: simdi - 10)]);
    expect(find.byType(UyariPenceresi), findsOneWidget);
    expect(find.text('Birinci'), findsOneWidget); // en eski önce
    expect(find.text('+1 uyarı daha'), findsOneWidget);
    expect(find.text('Cem Erdem · Elif Aydın'), findsOneWidget);
    await tester.tap(find.text('Tamam'));
    await tester.pump();
    expect(find.text('Birinci'), findsNothing);
    expect(find.text('İkinci'), findsOneWidget);
    expect(find.text('+1 uyarı daha'), findsNothing);
    await tester.tap(find.text('Tamam'));
    await tester.pump();
    expect(find.text('İkinci'), findsNothing);
  });

  testWidgets('kural olmayan bildirimler ve 2 dakikadan eski kural uyarıları açılmaz', (tester) async {
    await _baslat(tester, [
      Bildirim(baslik: 'Anlaşma', detay: 'd', saat: '15:00', onem: Onem.olumlu, kisiler: const ['24'], t: simdi),
      kural('Bayat', t: simdi - 200),
    ]);
    expect(find.text('Anlaşma'), findsNothing);
    expect(find.text('Bayat'), findsNothing);
  });

  testWidgets('"Kişileri göster" ilk kişinin detayını açar ve uyarıyı kapatır', (tester) async {
    await _baslat(tester, [kural('Yan yana')]);
    await tester.tap(find.text('Kişileri göster'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Robotik · Cem Erdem'), findsWidgets); // detay sayfası
    expect(find.text('Yan yana'), findsNothing);
  });

  testWidgets('bildirimlerde Kural süzgeci ve mavi nokta', (tester) async {
    // "Şimdi" en yeni bildirimin zamanı (sunucu saati): kural uyarısı ondan 500 sn eski → pencere açılmaz.
    await _baslat(tester, [
      Bildirim(baslik: 'Anlaşma', detay: 'd', saat: '15:09', onem: Onem.olumlu, kisiler: const ['24'], t: simdi),
      kural('Yan yana', t: simdi - 500),
    ]);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    expect(find.text('Kural 1'), findsOneWidget);
    await tester.tap(find.text('Kural 1'));
    await tester.pump();
    expect(find.text('Yan yana'), findsOneWidget);
  });
}
