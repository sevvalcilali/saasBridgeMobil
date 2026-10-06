import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/sinyal_grafigi.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// M4 gerçek sunucuda: Kurulum grafiği sunucu geçmişiyle, kalibrasyon çift seçimi ve 10 sn ölçüm.
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/m4_canli_test.dart \
///     -d "iPhone 17 Pro" --dart-define=SUNUCU=http://127.0.0.1:8002
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('kurulum: geçmişli grafik ve kalibrasyon', (tester) async {
    await tester.pumpWidget(const YakinlikUygulamasi());
    Future<void> bekle(bool Function() kosul, [int tur = 100]) async {
      for (var i = 0; i < tur && !kosul(); i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    Future<void> cek(String ad) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      await binding.takeScreenshot('$platform/$ad');
    }

    await bekle(() => find.textContaining(' ile · ').evaluate().isNotEmpty);
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kurulum')));
    await bekle(() => find.text('● Bağlı').evaluate().isNotEmpty); // sahte veri değil, sunucu deposu
    await Future<void>.delayed(const Duration(seconds: 4)); // gerçek zaman: geçmiş yoklaması (2 sn) dönsün
    await tester.pump(const Duration(milliseconds: 300));
    final cizici = tester.widget<CustomPaint>(find.descendant(of: find.byType(SinyalBolumu), matching: find.byType(CustomPaint)).first).painter;
    // ignore: avoid_dynamic_calls
    final noktalar = ((cizici as dynamic).seriler as List).map((s) => (s.noktalar as List).length).toList();
    debugPrint('GRAFIK seriler nokta sayilari: $noktalar');
    expect(noktalar.isNotEmpty && noktalar.first > 1, isTrue, reason: 'geçmiş çizilmedi: $noktalar');
    await cek('m4_kurulum_grafik');
    await tester.ensureVisible(find.text('— çift seçin —'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('— çift seçin —'));
    await bekle(() => find.textContaining('↔').evaluate().isNotEmpty);
    await cek('m4_kalibrasyon_ciftler');
    await tester.tap(find.textContaining('↔').first);
    await bekle(() => find.text('Yüz yüze').evaluate().isNotEmpty);
    await tester.ensureVisible(find.text('Ölç (10 sn)').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Ölç (10 sn)').first);
    await bekle(() => find.textContaining('Tutmaya devam edin…').evaluate().isNotEmpty);
    await cek('m4_kalibrasyon_olcum');
    for (var i = 0; i < 12 && find.text('Yeniden ölç').evaluate().isEmpty; i++) {
      await Future<void>.delayed(const Duration(seconds: 1)); // gerçek 10 sn geri sayım
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('dBm ✓'), findsOneWidget);
    await cek('m4_kalibrasyon_sonuc');
  });
}
