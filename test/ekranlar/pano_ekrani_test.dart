import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_durumu.dart';
import 'package:yakinlik_mobil/bilesenler/siluet.dart';
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

  testWidgets('Salon: kümeler (etiket, adlar), boştakiler, süre anahtarı ve not', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Salon'));
    await tester.pump();
    expect(find.byType(Siluet), findsWidgets);
    expect(find.text('2 kişi · 1 dk'), findsWidgets); // Cem Erdem – Elif Aydın 19 sn: 1 dk'dan kısa "1 dk" yazılır
    expect(find.text('Elif Aydın · Nova Robotik'), findsOneWidget); // yatırımcı önce, girişimcide kurum
    expect(find.text('BOŞTA'), findsOneWidget);
    expect(find.text('Can Yıldız'), findsOneWidget); // hiç görüşmemiş → boşta figürü
    expect(find.text('Kaan Öztürk'), findsNothing); // görünmeyen boşta çizilmez
    expect(find.textContaining('görünmüyor 1'), findsOneWidget);
    expect(find.text('Süre:'), findsOneWidget);
    expect(find.text('20 dk+'), findsOneWidget);
    expect(find.textContaining('Grupların yeri salondaki yeri göstermez'), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsNothing);
  });

  testWidgets('Salon: figüre ve boştaki figüre dokununca kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Salon'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Cem Erdem · ')));
    await tester.tap(find.text('Can Yıldız')); // boştaki figürün adı
    expect(k.acilanlar, ['24', '49']);
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

    await tester.tap(find.text('Salon'));
    await tester.pump();
    await tester.tap(find.text('Kişiler'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'nova');
    expect(find.byType(BasiliOpaklik), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
  });
}
