import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/pano/kisiler_bolumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_ust.dart';
import 'package:yakinlik_mobil/mantik/pano_filtre.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

/// Üst alan + Kişiler bölümünü, Pano ekranındaki gibi tek kaydırma içinde kurar.
class _Kurulum {
  _Kurulum(WidgetTester tester, {bool aliciBagli = true})
    : depo = EtkinlikDeposu(aliciBagli: aliciBagli),
      durum = PanoDurumu() {
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final List<String> acilanlar = [];
  int kurulumaGidis = 0;

  Widget get widget => temali(
    ListenableBuilder(
      listenable: Listenable.merge([depo, durum]),
      builder: (context, _) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanoUst(depo: depo, durum: durum, onKurulumaGit: () => kurulumaGidis++),
            KisilerBolumu(depo: depo, durum: durum, onKisi: acilanlar.add),
          ],
        ),
      ),
    ),
  );
}

Color? _satirZemini(WidgetTester tester, String baslik) {
  final kutu = tester.widget<Container>(
    find.ancestor(of: find.text(baslik), matching: find.byType(Container)).first,
  );
  return (kutu.decoration! as BoxDecoration).color;
}

void main() {
  test('PanoDurumu: başlangıç ve seçimler', () {
    final durum = PanoDurumu();
    addTearDown(durum.dispose);
    expect(durum.bolum, PanoBolumu.kisiler);
    expect(durum.filtre, PanoFiltre.girisimci);
    expect(durum.arama, '');
    expect(durum.onem, isNull);
    var bildirim = 0;
    durum.addListener(() => bildirim++);
    durum.bolumSec(PanoBolumu.salon);
    durum.bolumSec(PanoBolumu.salon); // aynı değer bildirim göndermez
    durum.filtreSec(PanoFiltre.tumu);
    durum.aramaDenetleyici.text = 'nova';
    expect(durum.bolum, PanoBolumu.salon);
    expect(durum.filtre, PanoFiltre.tumu);
    expect(durum.arama, 'nova');
    expect(bildirim, 3);
  });

  testWidgets('üst alan: etkinlik adı, tarih, saat, etiketler, bölüm anahtarı', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu'), findsOneWidget);
    expect(find.text('15:10:09'), findsOneWidget);
    expect(find.text('● Alıcı bağlı'), findsOneWidget);
    expect(find.text('Eşik −72 dBm'), findsOneWidget);
    expect(find.text('Sıfırla'), findsOneWidget);
    expect(find.text('Kişiler'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Salon'), findsOneWidget);
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('alıcı kopukken etiket "Alıcı yok" olur', (tester) async {
    final k = _Kurulum(tester, aliciBagli: false);
    await tester.pumpWidget(k.widget);
    expect(find.text('● Alıcı yok'), findsOneWidget);
    expect(find.text('● Alıcı bağlı'), findsNothing);
  });

  testWidgets('saat ve birlikte süreleri saniyede bir akar', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
    k.depo.ilerlet();
    await tester.pump();
    expect(find.text('15:10:10'), findsOneWidget);
    expect(find.text('Elif Aydın ile · 20 sn'), findsOneWidget);
  });

  testWidgets('varsayılan filtre Girişimci: başlık, sayı ve 12 satır', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('Veri Köprüsü · Can Yıldız'), findsOneWidget);
    expect(find.text('Boşta'), findsNWidgets(3)); // filtre çipi + iki satır
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('birlikte olan satırın zemini yeşil, diğerleri yüzey rengi', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(_satirZemini(tester, 'Nova Robotik · Cem Erdem'), Renkler.birlikteZemin);
    expect(_satirZemini(tester, 'Veri Köprüsü · Can Yıldız'), Renkler.yuzey);
  });

  testWidgets('filtre çipi listeyi süzer', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Yatırımcı'));
    await tester.pump();
    expect(find.text('YATIRIMCILAR'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(10));
    expect(find.text('Ayşe Demir · ★★★★'), findsOneWidget);
    expect(find.text('Görünmüyor · 3 dk önce duyuldu'), findsOneWidget);
  });

  testWidgets('yatay kaydırmayla ulaşılan çip: Hiç görüşmemiş', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.ensureVisible(find.text('Hiç görüşmemiş'));
    await tester.pump();
    await tester.tap(find.text('Hiç görüşmemiş'));
    await tester.pump();
    expect(find.text('HİÇ GÖRÜŞMEMİŞ'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(5));
    expect(find.text('Kart 14'), findsOneWidget);
  });

  testWidgets('arama: Türkçe büyük-küçük harf duyarsız', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'NOVA');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsOneWidget);
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('sonuç yoksa liste boş ve sayı 0', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'yok böyle biri');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('satıra dokununca kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Nova Robotik · Cem Erdem'));
    expect(k.acilanlar, ['24']);
  });

  testWidgets("eşik etiketi Kurulum'a götürür", (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Eşik −72 dBm'));
    expect(k.kurulumaGidis, 1);
  });

  testWidgets('Sıfırla: vazgeçince değişmez, onaylayınca süre sayacı sıfırlanır', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    k.depo.ilerlet();
    k.depo.ilerlet();
    await tester.pump();

    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    expect(find.text('Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.byType(SifirlaDiyalogu), findsNothing);
    expect(k.depo.tick, 2);

    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sıfırla').last); // diyalogdaki onay düğmesi
    await tester.pumpAndSettle();
    expect(find.byType(SifirlaDiyalogu), findsNothing);
    expect(k.depo.tick, 0);
    expect(k.depo.saat, '15:10:11');
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
  });
}
