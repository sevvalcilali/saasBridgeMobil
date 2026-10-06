import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/ekranlar/rapor/kisi_raporu_sayfasi.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// M4b gerçek sunucuda: Rapor sunucu kayıtlarıyla, kişiye özel rapor.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('rapor ve kişiye özel rapor', (tester) async {
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

    await bekle(() => find.text('Kişiler').evaluate().isNotEmpty && find.text('● Alıcı bağlı').evaluate().isNotEmpty);
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Rapor')));
    await Future<void>.delayed(const Duration(seconds: 3)); // kayıtlar ve kişiler (gerçek zaman)
    await tester.tap(find.text('Yenile'));
    await Future<void>.delayed(const Duration(seconds: 2));
    await bekle(() => find.textContaining(' sn)').evaluate().isNotEmpty); // "Ad (süre)" satır detayı
    await cek('m4_rapor');
    final satir = find.textContaining(' sn)').first;
    await tester.ensureVisible(satir);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(satir);
    await bekle(() => find.byType(KisiRaporuSayfasi).evaluate().isNotEmpty);
    expect(find.text('Yatırımcılarla birlikte geçen süre'), findsOneWidget);
    await cek('m4_kisi_raporu');
  });
}
