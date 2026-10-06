import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/kurulum_ekrani.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/sinyal_grafigi.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

Future<EtkinlikDeposu> _kur(WidgetTester tester) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(KurulumEkrani(depo: depo)));
  return depo;
}

Finder _grafik() => find.descendant(of: find.byType(SinyalBolumu), matching: find.byType(CustomPaint));

void main() {
  testWidgets('başlık ve eşik bölümü', (tester) async {
    await _kur(tester);
    expect(find.text('Kurulum'), findsOneWidget);
    expect(
      find.text('Teknik ekran — eşik ayarı, sinyaller ve kart sağlığı. Etkinlik öncesi kullanılır.'),
      findsOneWidget,
    );
    expect(find.text('EŞİK'), findsOneWidget);
    expect(find.text('−72'), findsOneWidget);
    expect(find.text('dBm'), findsOneWidget);
    expect(find.text('Şu an 8 çift eşiğin üstünde.'), findsOneWidget);
    expect(find.text('−1'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('−95 · gevşek'), findsOneWidget);
    expect(find.text('sıkı · −35'), findsOneWidget);
  });

  testWidgets('canlı sinyal, kalibrasyon ve kart sağlığı bölümleri', (tester) async {
    await _kur(tester);
    expect(find.text('CANLI SİNYAL (SON 90 SN)'), findsOneWidget);
    expect(find.text('En güçlü 6 çift'), findsOneWidget);
    expect(find.text('90 sn önce'), findsOneWidget);
    expect(find.text('kesik çizgi: eşik −72 dBm'), findsOneWidget);
    expect(find.text('şimdi'), findsOneWidget);
    expect(find.text('27 · 28'), findsOneWidget);
    expect(find.text('44 · 67'), findsOneWidget);
    expect(find.text('33 · 46'), findsNothing); // ilk altı çiftin dışındakiler çizilmez
    expect(find.text('KALİBRASYON'), findsOneWidget);
    expect(find.text('— çift seçin —'), findsOneWidget);
    expect(find.text('⌄'), findsOneWidget);
    expect(find.text('KART SAĞLIĞI'), findsOneWidget);
    expect(find.textContaining('32 kart duyuluyor · '), findsOneWidget);
    expect(find.textContaining('1 sorunlu'), findsOneWidget);
    // Pil yok: yalnız son duyulma. Görünmeyen Kaan Öztürk (3 dk önce duyuldu) en üstte "duyulmuyor".
    expect(find.text('Kaan Öztürk'), findsOneWidget);
    expect(find.textContaining('duyulmuyor'), findsOneWidget);
    expect(find.text('3 dk önce'), findsOneWidget);
    expect(find.text('✓ iyi'), findsNWidgets(30));
    expect(find.textContaining('pil'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Kart 14'), findsOneWidget);
  });

  testWidgets('grafik: eşik üstü bölge, altı çizgi ve kesik eşik çizgisi', (tester) async {
    await _kur(tester);
    expect(
      _grafik(),
      paints
        ..rect()
        ..path()
        ..path()
        ..path()
        ..path()
        ..path()
        ..path()
        ..line(),
    );
  });

  testWidgets('−1 ve +1 eşiği değiştirir; yazılar güncellenir', (tester) async {
    final depo = await _kur(tester);
    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(depo.esik, -71);
    expect(find.text('−71'), findsOneWidget);
    expect(find.text('kesik çizgi: eşik −71 dBm'), findsOneWidget);
    await tester.tap(find.text('−1'));
    await tester.tap(find.text('−1'));
    await tester.pump();
    expect(depo.esik, -73);
    expect(find.text('−73'), findsOneWidget);
  });

  testWidgets('eşiğin üstündeki çift sayısı eşikle değişir', (tester) async {
    final depo = await _kur(tester);
    depo.esikAyarla(-60);
    await tester.pump();
    expect(find.text('Şu an 4 çift eşiğin üstünde.'), findsOneWidget);
    depo.esikAyarla(-95);
    await tester.pump();
    expect(find.text('Şu an 10 çift eşiğin üstünde.'), findsOneWidget);
  });

  testWidgets('eşik sınırlarda durur; grafik taşmaz (S15)', (tester) async {
    final depo = await _kur(tester);
    depo.esikAyarla(-95);
    await tester.pump();
    await tester.tap(find.text('−1'));
    await tester.pump();
    expect(depo.esik, -95);
    expect(tester.takeException(), isNull);

    depo.esikAyarla(-35);
    await tester.pump();
    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(depo.esik, -35);
    expect(find.text('Şu an 0 çift eşiğin üstünde.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kaydırıcı eşiği değiştirir ve sınırlar içinde kalır', (tester) async {
    final depo = await _kur(tester);
    await tester.drag(find.byType(Slider), const Offset(-600, 0));
    await tester.pump();
    expect(depo.esik, -95);
    await tester.drag(find.byType(Slider), const Offset(600, 0));
    await tester.pump();
    expect(depo.esik, -35);
  });

  testWidgets('kart sağlığı: sorunlu satır vurgulanır', (tester) async {
    await _kur(tester);
    final kutu = tester.widget<DecoratedBox>(
      find.ancestor(of: find.text('Kaan Öztürk'), matching: find.byType(DecoratedBox)).first,
    );
    expect((kutu.decoration as BoxDecoration).color, Renkler.ciddiZemin);
    expect(tester.widget<Text>(find.text('3 dk önce')).style!.color, Renkler.ciddi);
    // Adsız kart ikincil renkte yazılır.
    expect(tester.widget<Text>(find.text('Kart 14')).style!.color, Renkler.metin2);
  });

  testWidgets('"— çift seçin —" işlevsizdir: dokununca hiçbir şey değişmez', (tester) async {
    final depo = await _kur(tester);
    await tester.ensureVisible(find.text('— çift seçin —'));
    await tester.tap(find.text('— çift seçin —'));
    await tester.pump();
    expect(depo.esik, -72);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saniye ilerleyince grafik yeniden çizilir, yazılar bozulmaz', (tester) async {
    final depo = await _kur(tester);
    depo.ilerlet();
    await tester.pump();
    expect(_grafik(), paints..path());
    expect(find.text('27 · 28'), findsOneWidget);
  });

  testWidgets('sunucu bölümü: adres yazılıp Bağlan\'a basılınca düzeltilmiş adres geri çağrıya gider', (tester) async {
    telefonBoyutu(tester);
    final depo = EtkinlikDeposu();
    addTearDown(depo.dispose);
    String? alinan;
    await tester.pumpWidget(temali(KurulumEkrani(depo: depo, sunucuAdresi: '', onSunucuAdresi: (a) => alinan = a)));
    expect(find.text('SUNUCU'), findsOneWidget);
    expect(find.text('Sahte veri (sunucu yok)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '192.168.1.10');
    await tester.tap(find.text('Bağlan'));
    await tester.pump();
    expect(alinan, 'http://192.168.1.10:8002');
  });

  testWidgets('sunucu bölümü: adres varken bağlı/bağlı değil yazar', (tester) async {
    telefonBoyutu(tester);
    final depo = EtkinlikDeposu();
    addTearDown(depo.dispose);
    await tester.pumpWidget(temali(KurulumEkrani(depo: depo, sunucuAdresi: 'http://10.0.0.5:8002', onSunucuAdresi: (_) {})));
    expect(find.text('● Bağlı'), findsOneWidget); // sahte depo hep bağlı
  });
}
