import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/rapor/kisi_raporu_sayfasi.dart';
import 'package:yakinlik_mobil/ekranlar/rapor/rapor_ekrani.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/mantik/rapor_hesap.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/sahte_depo.dart';

import '../yardimci.dart';

Future<({EtkinlikDeposu depo, List<(String, String)> paylasilan})> _kur(WidgetTester tester) async {
  telefonBoyutu(tester, yukseklik: 1400);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  final paylasilan = <(String, String)>[];
  await tester.pumpWidget(temali(RaporEkrani(depo: depo, paylas: (ad, icerik) async => paylasilan.add((ad, icerik)))));
  await tester.pump(); // oturumlar gelsin
  return (depo: depo, paylasilan: paylasilan);
}

void main() {
  testWidgets('başlık ve düğmeler', (tester) async {
    await _kur(tester);
    expect(find.text('ETKİNLİK RAPORU'), findsOneWidget);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:10'), findsOneWidget);
    expect(find.text('⤴ Katılımcılar (CSV)'), findsOneWidget);
    expect(find.text('⤴ Görüşmeler (CSV)'), findsOneWidget);
    expect(find.text('Yenile'), findsOneWidget);
  });

  testWidgets('altı özet kartı görüşme kayıtlarından; süreler dakikaya yuvarlı; ulaşan oranı', (tester) async {
    await _kur(tester);
    expect(find.text('Katılımcı'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.textContaining('yatırımcı · '), findsWidgets);
    expect(find.text('Görüşme'), findsOneWidget);
    expect(find.textContaining('10 tanesi sürüyor'), findsOneWidget);
    expect(find.text('Yatırımcı–girişimci süresi'), findsOneWidget);
    expect(find.text('6 dk'), findsOneWidget); // 380 sn (misafirle olan 142 sn sayılmaz)
    expect(find.text('Yatırımcıya ulaşan girişimci'), findsOneWidget);
    expect(find.text('8/12'), findsOneWidget);
    expect(find.text('%67'), findsOneWidget);
    expect(find.text('Potansiyel anlaşma'), findsOneWidget);
    expect(find.text('En yoğun zaman'), findsOneWidget);
  });

  testWidgets('yapılacaklar, eşleşmeler, yoğunluk grafiği ve kişi bölümleri', (tester) async {
    await _kur(tester);
    expect(find.text('Etkinlik sonrası yapılacaklar'), findsOneWidget);
    expect(find.text('Yatırımcıyla görüşmeyen girişimciler'), findsOneWidget);
    expect(find.text('Girişimciyle görüşmeyen yatırımcılar'), findsOneWidget);
    expect(find.text('Önerilen tanıştırmalar'), findsOneWidget);
    expect(find.textContaining('sektör ve ilgi alanı girilince'), findsOneWidget); // sahte veride sektör yok
    expect(find.text('En güçlü yatırımcı–girişimci eşleşmeleri'), findsOneWidget);
    expect(find.textContaining('Her çubuk 5 dakika'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Gün içi görüşme yoğunluğu grafiği'), findsOneWidget);
    expect(find.textContaining('Girişimciler ve ulaştıkları yatırımcılar'), findsOneWidget);
    expect(find.textContaining('Yatırımcılar ve görüştükleri girişimciler'), findsOneWidget);
  });

  testWidgets('girişimci satırı: görüştüğü yatırımcılar çip çip; görüşmeyen ciddi renkte', (tester) async {
    await _kur(tester);
    final irem = find.byKey(const ValueKey('rapor-kisi-k31'));
    expect(find.descendant(of: irem, matching: find.text('Emre Kaya')), findsOneWidget);
    expect(find.descendant(of: irem, matching: find.text('1 dk')), findsWidgets);
    final gorusmedi = find.textContaining('Hiç yatırımcıyla görüşmedi');
    expect(gorusmedi, findsNWidgets(4)); // 2 görüşmemiş + 2 misafirle görüşen
    expect(tester.widget<Text>(gorusmedi.first).style!.color, Renkler.ciddi);
  });

  testWidgets('rapor anlık görüntüdür: süreler kayıtların alındığı anda donar, Yenile ile güncellenir', (tester) async {
    final k = await _kur(tester);
    for (var i = 0; i < 60; i++) {
      k.depo.ilerlet();
    }
    await tester.pump();
    expect(find.text('6 dk'), findsOneWidget); // değişmedi
    await tester.tap(find.text('Yenile'));
    await tester.pump();
    expect(find.text('14 dk'), findsWidgets); // 380 + 8 × 60 sn = 860 sn
    final irem = find.byKey(const ValueKey('rapor-kisi-k31'));
    expect(find.descendant(of: irem, matching: find.text('2 dk')), findsWidgets); // 134 sn
  });

  testWidgets('Rapor sekmesine her gelişte kayıtlar yeniden istenir', (tester) async {
    telefonBoyutu(tester);
    final depo = _SayanDepo();
    addTearDown(depo.dispose);
    await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
    await tester.pump();
    final ilk = depo.istek;
    Finder sekme(String ad) => find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));
    await tester.tap(sekme('Rapor'));
    await tester.pump();
    expect(depo.istek, ilk + 1);
    await tester.tap(sekme('Pano'));
    await tester.pump();
    await tester.tap(sekme('Rapor'));
    await tester.pump();
    expect(depo.istek, ilk + 2);
  });

  testWidgets('CSV paylaşımı: dosya adı ve içerik', (tester) async {
    final k = await _kur(tester);
    await tester.tap(find.text('⤴ Katılımcılar (CSV)'));
    await tester.tap(find.text('⤴ Görüşmeler (CSV)'));
    await tester.pump();
    expect(k.paylasilan.map((p) => p.$1).toList(), ['katilimcilar.csv', 'gorusmeler.csv']);
    expect(k.paylasilan.first.$2, startsWith('﻿Ad;Rol;Kurum'));
    expect(k.paylasilan.last.$2, contains('sürüyor'));
  });

  testWidgets('satıra dokununca kişiye özel rapor: yatırımcılarla süre, kaçırılanlar, paylaş', (tester) async {
    await _kur(tester);
    final irem = find.byKey(const ValueKey('rapor-kisi-k31'));
    await tester.ensureVisible(irem);
    await tester.tap(irem);
    await tester.pumpAndSettle();
    expect(find.byType(KisiRaporuSayfasi), findsOneWidget);
    expect(find.text('Peak Enerji · İrem Korkmaz'), findsOneWidget);
    expect(find.text('Yatırımcılarla birlikte geçen süre'), findsOneWidget);
    expect(find.text('1 yatırımcı · toplam 1 dk 14 sn'), findsOneWidget);
    expect(find.text('Emre Kaya'), findsOneWidget);
    expect(find.textContaining('Kaçırdığınız yatırımcılar'), findsOneWidget);
    expect(find.text('Ayşe Demir'), findsOneWidget); // kaçırılan
    await tester.tap(find.text('← Rapor'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiRaporuSayfasi), findsNothing);
  });
}

class _SayanDepo extends SahteDepo {
  int istek = 0;
  @override
  Future<List<Oturum>> oturumlar() {
    istek++;
    return super.oturumlar();
  }
}
