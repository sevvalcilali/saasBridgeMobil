import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// M5 gerçek sunucuda: Kurulum → Görünüm → Koyu; dört sekmenin koyu temada görüntüsü, sonra Açık'a dönülür.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('koyu tema', (tester) async {
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

    Finder sekme(String ad) => find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

    await bekle(() => find.textContaining(' ile · ').evaluate().isNotEmpty);
    await tester.tap(sekme('Kurulum'));
    await bekle(() => find.text('Koyu').evaluate().isNotEmpty);
    await tester.tap(find.text('Koyu'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(Renkler.koyu, isTrue);
    await Future<void>.delayed(const Duration(seconds: 5)); // grafik geçmişi gelsin
    await tester.pump(const Duration(milliseconds: 300));
    await cek('m5_koyu_kurulum');
    await tester.tap(sekme('Pano'));
    await tester.pump(const Duration(milliseconds: 300));
    await cek('m5_koyu_pano');
    await tester.tap(find.text('Salon'));
    await tester.pump(const Duration(milliseconds: 300));
    await cek('m5_koyu_salon');
    await tester.tap(sekme('Kart Ver'));
    await tester.pump(const Duration(milliseconds: 300));
    await cek('m5_koyu_kart_ver');
    await tester.tap(sekme('Rapor'));
    await Future<void>.delayed(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
    await cek('m5_koyu_rapor');
    await tester.tap(sekme('Kurulum'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sistem'));
    await tester.pump(const Duration(milliseconds: 300));
  });
}
