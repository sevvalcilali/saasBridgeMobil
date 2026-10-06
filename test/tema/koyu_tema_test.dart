import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/kurulum_ekrani.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/tema/tema.dart';
import 'package:yakinlik_mobil/tema/yazi.dart';
import 'package:yakinlik_mobil/ekranlar/kabuk.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/tema_ayari.dart';

import '../yardimci.dart';

void main() {
  tearDown(() => Renkler.koyu = false);

  test('koyu palet: web koyu token\'larıyla aynı; yeşil yine yalnız "birlikte"', () {
    expect(Renkler.zemin, const Color(0xFFF7F2E9));
    Renkler.koyu = true;
    expect(Renkler.zemin, const Color(0xFF181614));
    expect(Renkler.vurgu, const Color(0xFFE2A852));
    expect(Renkler.birlikte, const Color(0xFF4CC38A));
    expect(Renkler.sure5, const Color(0xFF5FA4E6));
    expect(Renkler.kisi(KisiRengi.mavi), const Color(0xFF3F65EE));
    expect(yakinlikTemasi().brightness, Brightness.dark);
    expect(yakinlikTemasi().scaffoldBackgroundColor, const Color(0xFF181614));
  });

  test('koyuMu: sistem ayarı cihazı izler, açık/koyu sabittir', () {
    expect(koyuMu(TemaAyari.sistem, sistemKoyu: true), isTrue);
    expect(koyuMu(TemaAyari.sistem, sistemKoyu: false), isFalse);
    expect(koyuMu(TemaAyari.acik, sistemKoyu: true), isFalse);
    expect(koyuMu(TemaAyari.koyu, sistemKoyu: false), isTrue);
  });

  testWidgets('Kurulum → Görünüm → Koyu: uygulama koyu palete geçer ve ayar kaydedilir', (tester) async {
    telefonBoyutu(tester);
    SharedPreferences.setMockInitialValues({});
    final depo = EtkinlikDeposu();
    addTearDown(depo.dispose);
    await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
    await tester.pump();
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Kurulum')));
    await tester.pump();
    expect(find.text('GÖRÜNÜM'), findsOneWidget);
    await tester.tap(find.text('Koyu'));
    await tester.pump();
    expect(Renkler.koyu, isTrue);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!.brightness, Brightness.dark);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!.scaffoldBackgroundColor, const Color(0xFF181614));
    expect((await SharedPreferences.getInstance()).getString('tema'), 'koyu');
    await tester.tap(find.text('Açık'));
    await tester.pump();
    expect(Renkler.koyu, isFalse);
  });

  testWidgets('tema ayarı verilmezse Görünüm bölümü yok (eski testler)', (tester) async {
    telefonBoyutu(tester);
    final depo = EtkinlikDeposu();
    addTearDown(depo.dispose);
    await tester.pumpWidget(temali(KurulumEkrani(depo: depo)));
    expect(find.text('GÖRÜNÜM'), findsNothing);
  });

  test('gövde ve kicker yazı stilleri etkin paletin rengini alır (önbelleğe alınmaz)', () {
    expect(Yazi.govde.color, const Color(0xFF3B332C));
    Renkler.koyu = true;
    expect(Yazi.govde.color, const Color(0xFFF2EBE0));
    expect(Yazi.kicker.color, const Color(0xFFC5B9A8));
    expect(yakinlikTemasi().textTheme.bodyMedium!.color, const Color(0xFFF2EBE0));
  });

  testWidgets('kopukluk bandı tema değişince yeni paletle çizilir', (tester) async {
    telefonBoyutu(tester);
    final depo = EtkinlikDeposu(sunucuBagli: false);
    addTearDown(depo.dispose);
    await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
    await tester.pump();
    Color zemin() => (tester.widget<DecoratedBox>(find.descendant(of: find.byType(KopukBandi), matching: find.byType(DecoratedBox)).first).decoration as BoxDecoration).color!;
    expect(zemin(), const Color(0xFFF9E2E0));
    Renkler.koyu = true;
    await tester.pump();
    expect(zemin(), const Color(0xFF3F1C1A));
  });
}
