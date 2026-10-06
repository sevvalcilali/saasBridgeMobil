import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/ekranlar/pano/uyari_penceresi.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// Gerçek sunucuya bağlı uçtan uca deneme (M1): uygulama `--dart-define=SUNUCU=http://…:8002` ile açılır,
/// Pano'da sunucudan gelen kişiler görünene dek beklenir, Pano ve Kurulum'un görüntüsü alınır.
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/sunucu_canli_test.dart \
///     -d "iPhone 17 Pro" --dart-define=SUNUCU=http://127.0.0.1:8002
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('sunucudan canlı veri', (tester) async {
    await tester.pumpWidget(const YakinlikUygulamasi());
    // Gerçek ağ: pumpAndSettle sonsuz animasyonda takılır; kişiler gelene dek kare kare beklenir.
    var kisiGeldi = false;
    for (var i = 0; i < 100 && !kisiGeldi; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      kisiGeldi = find.textContaining(' ile · ').evaluate().isNotEmpty;
    }
    expect(kisiGeldi, isTrue, reason: 'sunucudan görüşen kişi gelmedi');
    expect(find.text('● Alıcı bağlı'), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await binding.takeScreenshot('$platform/m1_pano_sunucu');

    await tester.tap(find.text('Salon'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Süre:'), findsOneWidget);
    await binding.takeScreenshot('$platform/m2_salon_sunucu');
    await tester.tap(find.text('Kişiler'));
    await tester.pump(const Duration(milliseconds: 200));

    // Sunucuda "herkes ile herkes yan yana" kuralı varsa açılır uyarı gelir (deneme betiği kuralı önceden ekler).
    var uyari = false;
    for (var i = 0; i < 150 && !uyari; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      uyari = find.byType(UyariPenceresi).evaluate().isNotEmpty && find.text('Tamam').evaluate().isNotEmpty;
    }
    if (uyari) {
      await binding.takeScreenshot('$platform/m2_uyari_sunucu');
      await tester.tap(find.text('Tamam'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kurulum')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('● Bağlı'), findsOneWidget);
    await binding.takeScreenshot('$platform/m1_kurulum_sunucu');
  });
}
