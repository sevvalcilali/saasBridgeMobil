import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// "⚠" yazı simgesi Android'de renkli emoji olarak çizilir (şartname §10).
// Ekranda yazı olarak değil, yazıyla aynı renkte Material uyarı ikonu olarak
// görünmelidir. Mantık katmanı metni yine "⚠ …" diye üretir.
void main() {
  testWidgets('uyarılar emoji değil ikon: kopuk bandı, kart sağlığı, rapor', (tester) async {
    telefonBoyutu(tester);
    final depo = EtkinlikDeposu(aliciBagli: false, sunucuBagli: false);
    addTearDown(depo.dispose);
    await tester.pumpWidget(YakinlikUygulamasi(depo: depo));

    Finder sekme(String ad) =>
        find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

    void denetle(String neresi, int enAzIkon) {
      expect(find.textContaining('⚠'), findsNothing, reason: neresi);
      expect(find.byIcon(Icons.warning_amber_rounded), findsAtLeastNWidgets(enAzIkon), reason: neresi);
    }

    denetle('Pano · kopuk bandı', 1);
    await tester.tap(sekme('Kurulum'));
    await tester.pump();
    denetle('Kurulum: bant + özet + pil düşük', 3);
    await tester.tap(sekme('Rapor'));
    await tester.pump();
    denetle('Rapor: bant + iki görüşmemiş girişimci', 3);
  });
}
