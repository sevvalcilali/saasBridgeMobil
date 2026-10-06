import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kabuk.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/kalibrasyon_bolumu.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/sahte_depo.dart';

import '../yardimci.dart';

Future<EtkinlikDeposu> _ac(WidgetTester tester, {Duration saniye = const Duration(seconds: 1)}) async {
  telefonBoyutu(tester, yukseklik: 1200);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(SingleChildScrollView(child: KalibrasyonBolumu(depo: depo, saniye: saniye))));
  return depo;
}

Future<void> _ciftSec(WidgetTester tester) async {
  await tester.tap(find.text('— çift seçin —'));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('↔').first); // alt sayfadaki ilk çift (en güçlü)
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('çift seçilmeden adımlar yok; seçilince iki adım ve şu anki değer', (tester) async {
    await _ac(tester);
    expect(find.text('Yüz yüze'), findsNothing);
    await _ciftSec(tester);
    expect(find.text('Yüz yüze'), findsOneWidget);
    expect(find.text('Sırt sırta'), findsOneWidget);
    expect(find.textContaining('Şu an '), findsOneWidget);
  });

  testWidgets('demo ölçümlerle öneri: fark ve eşik; uygula → depo eşiği değişir', (tester) async {
    final depo = await _ac(tester);
    await _ciftSec(tester);
    await tester.tap(find.text('Demo').first);
    await tester.pump();
    expect(find.textContaining('önerilen eşik'), findsNothing); // ikinci ölçüm yok
    await tester.tap(find.text('Demo').last);
    await tester.pump();
    expect(find.text('Fark 19.6 dB · önerilen eşik −68 dBm (şu an −72).'), findsOneWidget);
    await tester.tap(find.text('Eşiği uygula (−68)'));
    await tester.pump();
    expect(depo.esik, -68);
    expect(find.text('Eşik -68 dBm olarak uygulandı.'), findsOneWidget);
  });

  testWidgets('Ölç: 10 sn geri sayım, sonunda çiftin şu anki değeri ölçüm olur', (tester) async {
    final depo = await _ac(tester, saniye: const Duration(milliseconds: 10));
    await _ciftSec(tester);
    await tester.tap(find.text('Ölç (10 sn)').first);
    await tester.pump();
    expect(find.textContaining('Tutmaya devam edin…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150)); // 10 × 10 ms geri sayım
    await tester.pump(); // son ölçümün çizimi
    final enGuclu = ([...depo.ciftler]..sort((a, b) => b.rssi.compareTo(a.rssi))).first;
    expect(find.text('${enGuclu.rssi < 0 ? '−${-enGuclu.rssi}' : enGuclu.rssi} dBm ✓'), findsOneWidget);
    expect(find.text('Yeniden ölç'), findsOneWidget);
  });

  testWidgets('Kurulum sekmesi açılınca depodan grafik geçmişi istenir, ayrılınca bırakılır', (tester) async {
    telefonBoyutu(tester);
    final depo = _GrafikDepo();
    addTearDown(depo.dispose);
    await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kurulum')));
    await tester.pump();
    expect(depo.istekler, [true]);
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Pano')));
    await tester.pump();
    expect(depo.istekler, [true, false]);
    expect(find.byType(Kabuk), findsOneWidget);
  });
}

class _GrafikDepo extends SahteDepo {
  final istekler = <bool>[];
  @override
  void grafikIste(bool iste) => istekler.add(iste);
}
