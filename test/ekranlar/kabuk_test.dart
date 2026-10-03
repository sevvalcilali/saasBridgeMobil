import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/kabuk.dart';
import 'package:yakinlik_mobil/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Not: Kart Ver adım 2'de Nabız sonsuz animasyondur; o adım açıkken
// pumpAndSettle KULLANILMAZ.

const _cem = 'Nova Robotik · Cem Erdem';
// "⚠" ekranda ikon olarak çizilir; metin ikonun ardından gelir.
const _bantMetni = 'Sunucuya bağlanılamıyor, yeniden deneniyor… son veri gösteriliyor';

Future<EtkinlikDeposu> _baslat(WidgetTester tester, {bool aliciBagli = true}) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu(aliciBagli: aliciBagli);
  addTearDown(depo.dispose);
  await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
  await tester.pump();
  return depo;
}

Finder _sekme(String ad) =>
    find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

int _seciliSekme(WidgetTester tester) =>
    tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex;

void main() {
  testWidgets('açılış: Pano ve dört sekme', (tester) async {
    await _baslat(tester);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    for (final ad in ['Pano', 'Kart Ver', 'Kurulum', 'Rapor']) {
      expect(_sekme(ad), findsOneWidget, reason: ad);
    }
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('sekmeler arasında gezinme', (tester) async {
    await _baslat(tester);
    await tester.tap(_sekme('Kart Ver'));
    await tester.pump();
    expect(find.text('Karşılama masası — gelen kişiye kart verin'), findsOneWidget);
    await tester.tap(_sekme('Kurulum'));
    await tester.pump();
    expect(find.text('EŞİK'), findsOneWidget);
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    expect(find.text('ETKİNLİK RAPORU'), findsOneWidget);
    await tester.tap(_sekme('Pano'));
    await tester.pump();
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('sekme değişince ekran durumu korunur', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Yatırımcı'));
    await tester.pump();
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    await tester.tap(_sekme('Pano'));
    await tester.pump();
    expect(find.text('YATIRIMCILAR'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(10));
  });

  testWidgets("eşik etiketi Kurulum sekmesine geçirir", (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Eşik −72 dBm'));
    await tester.pump();
    expect(_seciliSekme(tester), 2);
    expect(find.text('EŞİK'), findsOneWidget);
  });

  testWidgets('kişiye dokununca detay açılır; ✕ ile kapanır, sekme değişmez', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsOneWidget);
    expect(find.text('Kartı değiştir'), findsOneWidget);
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('detay → Kartı değiştir: Kart Ver sekmesi, adım 2, kişi seçili', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kartı değiştir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // sayfanın kapanma animasyonu
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(_seciliSekme(tester), 1);
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
  });

  testWidgets('detay → Kartı iade al: Kart İadesi, kişi seçili', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kartı iade al'));
    await tester.pumpAndSettle();
    expect(_seciliSekme(tester), 1);
    expect(find.text('Kart İadesi'), findsOneWidget);
    expect(find.text('Kart 24 iade alınsın mı?'), findsOneWidget);
  });

  testWidgets('bildirimden ve ağdan kişi detayı açılır', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    await tester.tap(find.text('Kart kayboldu'));
    await tester.pumpAndSettle();
    expect(find.text('Kaan Öztürk'), findsOneWidget);
    expect(find.text('Yatırımcı · ★★★'), findsOneWidget);
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Nova Robotik'));
    await tester.pumpAndSettle();
    expect(find.text(_cem), findsOneWidget);
  });

  testWidgets('saat: dışarıdan verilen depo ilerleyince ekran güncellenir', (tester) async {
    final depo = await _baslat(tester);
    depo.ilerlet();
    await tester.pump();
    expect(find.text('15:10:10'), findsOneWidget);
  });

  testWidgets('saat: kendi deposuyla açılınca kendiliğinden akar', (tester) async {
    telefonBoyutu(tester);
    await tester.pumpWidget(const YakinlikUygulamasi());
    await tester.pump();
    expect(find.text('15:10:09'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('15:10:11'), findsOneWidget);
  });

  testWidgets('alıcı bağlıyken kopuk bandı yok', (tester) async {
    await _baslat(tester);
    expect(find.byType(KopukBandi), findsNothing);
    expect(find.text('● Alıcı bağlı'), findsOneWidget);
  });

  testWidgets('alıcı kopukken bant her sekmede görünür; son veri gösterilmeye devam eder', (tester) async {
    await _baslat(tester, aliciBagli: false);
    expect(find.textContaining(_bantMetni), findsOneWidget);
    expect(find.text('● Alıcı yok'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    expect(find.textContaining(_bantMetni), findsOneWidget);
    expect(find.text('8 dk 42 sn'), findsOneWidget);
  });

  testWidgets('sistem yazı ölçeği 1.3 ile sınırlanır', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _baslat(tester);
    final olcek = MediaQuery.textScalerOf(tester.element(find.byType(Kabuk)));
    expect(olcek.scale(10), closeTo(13, 1e-6));
  });

  testWidgets('yerel Türkçe: yerleşik Material metinleri Türkçe', (tester) async {
    await _baslat(tester);
    final baglam = tester.element(find.byType(Kabuk));
    expect(Localizations.localeOf(baglam).languageCode, 'tr');
    expect(MaterialLocalizations.of(baglam).pasteButtonLabel, 'Yapıştır');
  });
}
