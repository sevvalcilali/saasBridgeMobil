import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kural_formu_sayfasi.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// M3 gerçek sunucuda: kişi formu açılır (kaydedilmez), Uyarılar'da kural kurulur (sonda sunucudan silinir).
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/m3_canli_test.dart \
///     -d "iPhone 17 Pro" --dart-define=SUNUCU=http://127.0.0.1:8002
const sunucu = String.fromEnvironment('SUNUCU');

Future<dynamic> _json(String yol, {String yontem = 'GET'}) async {
  final c = HttpClient();
  final istek = await c.openUrl(yontem, Uri.parse('$sunucu$yol'));
  final yanit = await istek.close();
  final metin = await utf8.decoder.bind(yanit).join();
  c.close();
  return metin.isEmpty ? null : jsonDecode(metin);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('kişi formu ve uyarı kuralı, gerçek sunucu', (tester) async {
    const kuralAdi = 'Deneme M3: önemli yatırımcı uzun görüşmede';
    addTearDown(() async {
      final kurallar = (await _json('/api/rules') as List).cast<Map<String, dynamic>>();
      for (final k in kurallar.where((k) => k['ad'] == kuralAdi)) {
        await _json('/api/rules/${k['kuralId']}', yontem: 'DELETE');
      }
    });

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
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kart Ver')));
    await bekle(() => find.text('Düzenle').evaluate().isNotEmpty); // kayıtlı kişiler yoklamayla gelir
    await tester.tap(find.text('Düzenle').first);
    await bekle(() => find.text('Kişiyi düzenle').evaluate().isNotEmpty);
    await cek('m3_kisi_duzenle');
    await tester.tap(find.text('← Vazgeç'));
    await bekle(() => find.text('+ Yeni').evaluate().isNotEmpty);

    await tester.tap(find.text('Uyarılar'));
    await bekle(() => find.text('+ Yeni uyarı kuralı').evaluate().isNotEmpty);
    await tester.tap(find.text('+ Yeni uyarı kuralı'));
    await bekle(() => find.text('Yeni uyarı kuralı').evaluate().isNotEmpty);
    await tester.enterText(find.byType(TextField).first, kuralAdi);
    await tester.tap(find.text('★3+ yatırımcılar').first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '2');
    await tester.pump();
    await cek('m3_kural_formu');
    // Kaydet klavyenin altında / ekran dışında: klavyeyi kapat, kaydır, sonra dokun.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.text('Kaydet'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Kaydet'));
    const cumle = '★3+ yatırımcılar ile girişimciler 2 dakikadan uzun birlikte kalınca → açılır uyarı';
    await bekle(() => find.text(cumle).evaluate().isNotEmpty); // form kapanıp liste yeniden yüklenince
    await bekle(() => find.byType(KuralFormuSayfasi).evaluate().isEmpty); // sayfa geçişi bitsin
    expect(find.text(kuralAdi), findsWidgets); // listede; kural hemen tetiklenirse açılır uyarıda da
    await cek('m3_kural_listesi');
    final sunucudaki = (await _json('/api/rules') as List).cast<Map<String, dynamic>>();
    expect(sunucudaki.where((k) => k['ad'] == kuralAdi), hasLength(1));
  });
}
