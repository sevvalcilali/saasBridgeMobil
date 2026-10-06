import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/rapor/rapor_ekrani.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

Future<EtkinlikDeposu> _kur(WidgetTester tester) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(RaporEkrani(depo: depo)));
  return depo;
}

void main() {
  testWidgets('başlık ve düğmeler', (tester) async {
    await _kur(tester);
    expect(find.text('ETKİNLİK RAPORU'), findsOneWidget);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:10'), findsOneWidget);
    expect(find.text('Yazdır / PDF'), findsOneWidget);
    expect(find.text('⤓ Katılımcılar'), findsOneWidget);
    expect(find.text('⤓ Görüşmeler'), findsOneWidget);
    expect(find.text('Yenile'), findsOneWidget);
  });

  testWidgets('beş KPI', (tester) async {
    await _kur(tester);
    expect(find.text('Görüşme'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('10 tanesi sürüyor'), findsOneWidget);
    expect(find.text('Yatırımcı–girişimci toplam'), findsOneWidget);
    expect(find.text('8 dk 42 sn'), findsOneWidget);
    expect(find.text('bugün'), findsOneWidget);
    expect(find.text('Yatırımcıya ulaşan girişimci'), findsOneWidget);
    expect(find.text('10/12'), findsOneWidget);
    expect(find.text('Potansiyel anlaşma'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('işaretlenmedi'), findsOneWidget);
    expect(find.text('Katılımcı'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('kayıtlı'), findsOneWidget);
  });

  testWidgets('girişimci satırları', (tester) async {
    await _kur(tester);
    expect(find.text('Girişimciler ve ulaştıkları yatırımcılar'), findsOneWidget);
    expect(find.text('Peak Enerji · İrem Korkmaz'), findsOneWidget);
    expect(find.text('1 dk 14 sn'), findsOneWidget);
    expect(find.text('Emre Kaya (1 dk 14 sn)'), findsOneWidget);
    expect(find.text('Veri Köprüsü · Can Yıldız'), findsOneWidget);
    expect(find.textContaining('Hiç yatırımcıyla görüşmedi'), findsNWidgets(2));
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('görüşmemiş girişimcinin detayı ciddi renktedir', (tester) async {
    await _kur(tester);
    final gorusmedi = tester.widget<Text>(find.textContaining('Hiç yatırımcıyla görüşmedi').first);
    expect(gorusmedi.style!.color, Renkler.ciddi);
    final gorustu = tester.widget<Text>(find.text('Emre Kaya (1 dk 14 sn)'));
    expect(gorustu.style!.color, Renkler.metinKoyu2);
  });

  testWidgets('süreler ve hazırlanma saati akar', (tester) async {
    final depo = await _kur(tester);
    for (var i = 0; i < 60; i++) {
      depo.ilerlet();
    }
    await tester.pump();
    expect(find.text('18 dk 42 sn'), findsOneWidget); // 522 + 10 × 60 sn
    expect(find.text('2 dk 14 sn'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:11'), findsOneWidget);
  });

  testWidgets('uzun oturum: saatli süreler yazılır, KPI kartı taşmaz', (tester) async {
    final depo = await _kur(tester);
    for (var i = 0; i < 4000; i++) {
      depo.ilerlet();
    }
    await tester.pump();
    expect(find.text('11 sa 15 dk'), findsOneWidget); // 522 + 10 × 4000 sn
    expect(find.text('1 sa 8 dk'), findsNWidgets(7)); // ör. 74 + 4000 sn
    expect(find.text('1 sa 7 dk'), findsNWidgets(3)); // ör. 19 + 4000 sn
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 16:16'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('düğmeler işlevsizdir: dokununca hiçbir şey değişmez', (tester) async {
    await _kur(tester);
    for (final etiket in ['Yazdır / PDF', '⤓ Katılımcılar', '⤓ Görüşmeler', 'Yenile']) {
      await tester.tap(find.text(etiket));
      await tester.pump();
    }
    expect(find.text('8 dk 42 sn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
