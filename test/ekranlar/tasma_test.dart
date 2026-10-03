import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Her ekran ve durum, farklı telefon genişliklerinde ve en büyük yazı
// ölçeğinde taşmadan çizilmelidir. Flutter'da taşma (RenderFlex overflow) bir
// hata olarak raporlanır; `tester.takeException()` onu yakalar.
//
// 360 px: şartnamedeki 390–430 aralığının altındaki yaygın Android genişliği.
// Ölçek 2.0: uygulama bunu 1.3'e sınırlar.

const _genislikler = [360.0, 390.0, 402.0, 430.0];
const _olcekler = [1.0, 2.0];

void main() {
  for (final genislik in _genislikler) {
    for (final olcek in _olcekler) {
      testWidgets('taşma yok: ${genislik.round()} px, sistem yazı ölçeği $olcek', (tester) async {
        telefonBoyutu(tester, genislik: genislik, yukseklik: 800);
        tester.platformDispatcher.textScaleFactorTestValue = olcek;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final depo = EtkinlikDeposu();
        addTearDown(depo.dispose);
        await tester.pumpWidget(YakinlikUygulamasi(depo: depo));

        Future<void> denetle(String neresi) async {
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$neresi (${genislik.round()} px, ölçek $olcek)');
        }

        Future<void> dokun(Finder hedef) async {
          await tester.ensureVisible(hedef);
          await tester.pump();
          await tester.tap(hedef);
          await tester.pump();
        }

        Finder sekme(String ad) =>
            find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

        await denetle('Pano · Kişiler');
        await dokun(find.text('Tümü'));
        await denetle('Pano · Tümü filtresi');
        await dokun(find.text('Ağ'));
        await denetle('Pano · Ağ');
        await dokun(find.text('Bildirimler'));
        await denetle('Pano · Bildirimler');

        await dokun(find.text('Kart kayboldu'));
        await tester.pumpAndSettle();
        await denetle('Kişi Detayı');
        await tester.tap(find.text('✕'));
        await tester.pumpAndSettle();

        await tester.tap(sekme('Kart Ver'));
        await denetle('Kart Ver · adım 1');
        await dokun(find.text('Nova Robotik · Cem Erdem'));
        await denetle('Kart Ver · adım 2 (bekleme)');
        await dokun(find.text('Demo: boş bir kartı yaklaştır'));
        await tester.pump(const Duration(milliseconds: 1500));
        await denetle('Kart Ver · kart bulundu');
        await dokun(find.text('Numarayı yaz'));
        await denetle('Kart Ver · numara');
        await tester.enterText(find.byType(TextField), '14');
        await denetle('Kart Ver · numara yazıldı');
        await dokun(find.text('Bu kartı seç'));
        await denetle('Kart Ver · adım 3');
        await dokun(find.text('Onayla'));
        await denetle('Kart Ver · son atama bandı');
        await dokun(find.text('↶ Geri al'));
        await denetle('Kart Ver · bilgi bandı');
        await dokun(find.text('Kart iadesi'));
        await denetle('Kart İadesi');
        await dokun(find.text('Nova Robotik · Cem Erdem'));
        await denetle('Kart İadesi · onay kutusu');

        await tester.tap(sekme('Kurulum'));
        await denetle('Kurulum');
        depo.esikAyarla(-95);
        await denetle('Kurulum · eşik −95');

        await tester.tap(sekme('Rapor'));
        await denetle('Rapor');

        // Uzun oturum: bir saati aşan süreler de taşmamalı.
        for (var i = 0; i < 4000; i++) {
          depo.ilerlet();
        }
        await denetle('Rapor · uzun oturum');
        await tester.tap(sekme('Pano'));
        await tester.pump();
        await dokun(find.text('Kişiler'));
        await denetle('Pano · uzun oturum');
      });
    }
  }
}
