import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/bilesenler/rol_sekli.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_ekrani.dart';
import 'package:yakinlik_mobil/uygulama.dart';

/// Gerçek sunucuda kart verme (M1b): ilk kayıtlı kişiye boş bir kart verilir ("Numarayı yaz"), bant görünür,
/// "Geri al" ile kaldırılır; sonda kişinin eski kartı sunucuya geri yazılır (deneme verisi bozulmasın).
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/kart_ver_canli_test.dart \
///     -d "iPhone 17 Pro" --dart-define=SUNUCU=http://127.0.0.1:8002
const sunucu = String.fromEnvironment('SUNUCU');

Future<dynamic> _json(String yol, {Map<String, Object?>? govde}) async {
  final c = HttpClient();
  final istek = await c.openUrl(govde == null ? 'GET' : 'POST', Uri.parse('$sunucu$yol'));
  if (govde != null) {
    istek.headers.contentType = ContentType.json;
    istek.write(jsonEncode(govde));
  }
  final yanit = await istek.close();
  final metin = await utf8.decoder.bind(yanit).join();
  c.close();
  return jsonDecode(metin);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  testWidgets('kart ver ve geri al, gerçek sunucu', (tester) async {
    final kisiler = (await _json('/api/people') as List).cast<Map<String, dynamic>>();
    final kisi = kisiler.firstWhere((k) => k['atananKart'] != null && k['ayrildi'] == false);
    final eskiKart = kisi['atananKart'] as String;
    final kartlar = (await _json('/api/cards') as List).cast<Map<String, dynamic>>();
    final bosKart = kartlar.firstWhere((k) => k['atanan'] == null)['kart'] as String;
    addTearDown(() => _json('/api/assign', govde: {'kisiId': kisi['kisiId'], 'kart': eskiKart}));

    await tester.pumpWidget(const YakinlikUygulamasi());
    Future<void> bekle(bool Function() kosul, [int tur = 100]) async {
      for (var i = 0; i < tur && !kosul(); i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    await bekle(() => find.textContaining(' ile · ').evaluate().isNotEmpty);
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kart Ver')));
    await bekle(() => find.text('Düzenle').evaluate().isNotEmpty);
    // İlk kişi kartına dokun (rol şekli dokunma alanının içinde).
    await tester.tap(find.descendant(of: find.byType(KartVerEkrani), matching: find.byType(RolSekli)).first);
    await bekle(() => find.text('Numarayı yaz').evaluate().isNotEmpty);
    await tester.tap(find.text('Numarayı yaz'));
    await bekle(() => find.text('Bu kartı seç').evaluate().isNotEmpty || find.byType(TextField).evaluate().isNotEmpty);
    await tester.enterText(find.byType(TextField).last, bosKart);
    await bekle(() => find.text('Bu kartı seç').evaluate().isNotEmpty);
    await tester.tap(find.text('Bu kartı seç'));
    await bekle(() => find.text('Onayla').evaluate().isNotEmpty);
    expect(find.text('boşta'), findsOneWidget);
    await binding.takeScreenshot('$platform/m1b_kontrol');
    await tester.tap(find.text('Onayla'));
    await bekle(() => find.textContaining('verildi.').evaluate().isNotEmpty);
    expect(find.textContaining('→ Kart $bosKart verildi.'), findsOneWidget);
    await binding.takeScreenshot('$platform/m1b_kart_verildi');

    final sonra = (await _json('/api/people') as List).cast<Map<String, dynamic>>();
    expect(sonra.firstWhere((k) => k['kisiId'] == kisi['kisiId'])['atananKart'], bosKart);

    await tester.tap(find.text('↶ Geri al'));
    await bekle(() => find.textContaining('Geri alındı').evaluate().isNotEmpty);
    final geri = (await _json('/api/people') as List).cast<Map<String, dynamic>>();
    expect(geri.firstWhere((k) => k['kisiId'] == kisi['kisiId'])['atananKart'], isNull);
  });
}
