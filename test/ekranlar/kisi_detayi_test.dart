import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/hap_dugme.dart';
import 'package:yakinlik_mobil/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

class _Sonuc {
  bool kapandi = false;
  DetayEylemi? eylem;
}

/// Bir düğmeyle alt sayfayı açar; kapanınca sonucu kaydeder.
Future<_Sonuc> _ac(WidgetTester tester, EtkinlikDeposu depo, String kisiId) async {
  telefonBoyutu(tester);
  addTearDown(depo.dispose);
  final sonuc = _Sonuc();
  await tester.pumpWidget(
    temali(
      Builder(
        builder: (context) => Center(
          child: HapDugme(
            etiket: 'aç',
            onTap: () async {
              sonuc.eylem = await kisiDetayiGoster(context, depo: depo, kisiId: kisiId);
              sonuc.kapandi = true;
            },
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('aç'));
  await tester.pumpAndSettle();
  return sonuc;
}

double _cizelgeOrani(WidgetTester tester) =>
    tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;

void main() {
  testWidgets('girişimci: başlık, rol, alanlar, eş ve çizelge', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('Girişimci'), findsOneWidget);
    expect(find.text('Kart no'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Durum'), findsOneWidget);
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
    expect(find.text('Son duyulma'), findsOneWidget);
    expect(find.text('az önce'), findsOneWidget);
    expect(find.text('Bugünkü toplam'), findsOneWidget);
    expect(find.text('19 sn'), findsNWidgets(2)); // toplam + eş satırı
    expect(find.text('Pil'), findsNothing); // Pil kaldırıldı (web kararı 05.10.2026)
    expect(find.text('Kartı değiştir'), findsOneWidget);
    expect(find.text('Kartı iade al'), findsOneWidget);
    expect(find.text('BUGÜN KİMİNLE'), findsOneWidget);
    expect(find.text('Elif Aydın'), findsOneWidget);
    expect(find.text('GÖRÜŞME ZAMAN ÇİZELGESİ'), findsOneWidget);
    expect(find.text('15:10'), findsOneWidget);
    expect(find.text('şimdi · 15:10'), findsOneWidget);
    expect(_cizelgeOrani(tester), closeTo(0.2633, 0.001));
  });

  testWidgets('içerik saniyede bir güncellenir', (tester) async {
    final depo = EtkinlikDeposu();
    await _ac(tester, depo, '24');
    depo.ilerlet();
    await tester.pump();
    expect(find.text('Elif Aydın ile · 20 sn'), findsOneWidget);
    expect(find.text('20 sn'), findsNWidgets(2));
  });

  testWidgets('durum rengi: birlikte yeşil', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(tester.widget<Text>(find.text('Elif Aydın ile · 19 sn')).style!.color, Renkler.birlikte);
  });

  testWidgets('Kartı değiştir: kartDegistir sonucuyla kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('Kartı değiştir'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.kapandi, isTrue);
    expect(sonuc.eylem, DetayEylemi.kartDegistir);
  });

  testWidgets('Kartı iade al: kartIade sonucuyla kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('Kartı iade al'));
    await tester.pumpAndSettle();
    expect(sonuc.eylem, DetayEylemi.kartIade);
  });

  testWidgets('✕ kapatır; sonuç boş', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.kapandi, isTrue);
    expect(sonuc.eylem, isNull);
  });

  testWidgets('perdeye dokununca kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.eylem, isNull);
  });

  testWidgets('yatırımcı: yıldızlı rol satırı', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '61');
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('Yatırımcı · ★★★★'), findsOneWidget);
    expect(find.text('Sağlık Cebi · Ece Arslan'), findsNothing);
    expect(find.text('Ece Arslan'), findsOneWidget); // eş satırı
  });

  testWidgets('hiç görüşmemiş kişi: boş durum, çizelge boş', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '49');
    expect(find.text('Boşta'), findsOneWidget);
    expect(find.text('Henüz kimseyle görüşmedi.'), findsOneWidget);
    expect(find.text('0 sn'), findsOneWidget);
    expect(_cizelgeOrani(tester), 0);
  });

  testWidgets('görünmüyor: uyarı renginde durum ve "3 dk önce"', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '40');
    final durum = tester.widget<Text>(find.text('Görünmüyor · 3 dk önce duyuldu'));
    expect(durum.style!.color, Renkler.uyari);
    expect(find.text('3 dk önce'), findsOneWidget);
  });

  testWidgets('adsız kart: başlık "Kart 14"', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '14');
    expect(find.text('Kart 14'), findsOneWidget);
    expect(find.text('Misafir'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("yükseklik en çok ekranın %78'i", (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(tester.getSize(find.byType(KisiDetaySayfasi)).height, lessThanOrEqualTo(874 * 0.78 + 0.01));
  });
}
