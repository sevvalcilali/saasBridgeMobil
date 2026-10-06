import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/pano/ag_bolumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_ekrani.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

import '../yardimci.dart';

class _Kurulum {
  _Kurulum(WidgetTester tester, {List<Bildirim>? bildirimler})
    : depo = EtkinlikDeposu(bildirimler: bildirimler),
      durum = PanoDurumu() {
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final List<String> acilanlar = [];

  Widget get widget =>
      temali(PanoEkrani(depo: depo, durum: durum, onKisi: acilanlar.add, onKurulumaGit: () {}));
}

void main() {
  testWidgets('açılışta Kişiler bölümü görünür', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
  });

  testWidgets('Ağ: başlıklar, düğümler ve not', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    expect(find.text('YATIRIMCI ○'), findsOneWidget);
    expect(find.text('GİRİŞİMCİ □'), findsOneWidget);
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('Kerem Tekin'), findsOneWidget); // birlikte olan misafir solda
    expect(find.text('Volkan Aydın'), findsNothing); // boştaki misafir ağda yok
    expect(find.text('Nova Robotik'), findsOneWidget);
    expect(find.text('Oyun Evreni'), findsOneWidget);
    expect(
      find.text(
        'Düğümlerin konumu fiziksel konum değildir; yalnız rol gruplarını gösterir. '
        'Bir ada dokununca ayrıntı açılır.',
      ),
      findsOneWidget,
    );
    expect(find.text('GİRİŞİMCİLER'), findsNothing);
  });

  testWidgets('Ağ: birlikte olan çiftler arasında çizgi çizilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AgBolumu), matching: find.byType(CustomPaint)),
      paints..line(),
    );
  });

  testWidgets('Ağ: ada dokununca kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Ayşe Demir'));
    await tester.tap(find.text('Nova Robotik'));
    expect(k.acilanlar, ['61', '24']);
  });

  testWidgets('Bildirimler: dört satır ve sayılı önem çipleri', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    expect(find.text('Tümü 4'), findsOneWidget);
    expect(find.text('Ciddi 1'), findsOneWidget);
    expect(find.text('Uyarı 2'), findsOneWidget);
    expect(find.text('Olumlu 1'), findsOneWidget);
    expect(find.text('Pil düşük'), findsOneWidget);
    expect(find.text('Yeni görüşme'), findsOneWidget);
    expect(find.text('Yalnız kaldı'), findsOneWidget);
    expect(find.text('Kart kayboldu'), findsOneWidget);
    expect(find.text('Kart 46 · Mehmet Kılıç · %16 — kartı masada değiştirin'), findsOneWidget);
    expect(find.text('15:02'), findsOneWidget);
  });

  testWidgets('Bildirimler: önem çipi süzer; satıra dokununca ilk kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    await tester.tap(find.text('Ciddi 1'));
    await tester.pump();
    expect(find.text('Kart kayboldu'), findsOneWidget);
    expect(find.text('Pil düşük'), findsNothing);
    await tester.tap(find.text('Kart kayboldu'));
    expect(k.acilanlar, ['40']);

    await tester.tap(find.text('Olumlu 1'));
    await tester.pump();
    await tester.tap(find.text('Yeni görüşme'));
    expect(k.acilanlar, ['40', '24']);
  });

  testWidgets('Bildirimler: boşsa "Bu önemde bildirim yok."', (tester) async {
    final k = _Kurulum(tester, bildirimler: const []);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    expect(find.text('Tümü 0'), findsOneWidget);
    expect(find.text('Bu önemde bildirim yok.'), findsOneWidget);
  });

  testWidgets('arama metni ve filtre, bölüm değişip geri gelince korunur', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'nova');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsOneWidget);

    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Kişiler'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'nova');
    expect(find.byType(BasiliOpaklik), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
  });
}
