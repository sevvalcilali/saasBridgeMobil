import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_ekrani.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kural_formu_sayfasi.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

Future<KartVerDurumu> _ac(WidgetTester tester) async {
  telefonBoyutu(tester, yukseklik: 1400);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  final durum = KartVerDurumu(depo);
  addTearDown(durum.dispose);
  await tester.pumpWidget(temali(KartVerEkrani(depo: depo, durum: durum)));
  await tester.tap(find.text('Uyarılar'));
  await tester.pumpAndSettle();
  return durum;
}

void main() {
  testWidgets('Uyarılar modu: başlık, boş durum, yeni kural formu açılır', (tester) async {
    await _ac(tester);
    expect(find.text('Uyarı Kuralları'), findsOneWidget);
    expect(find.textContaining('Henüz kural yok'), findsOneWidget);
    await tester.tap(find.text('+ Yeni uyarı kuralı'));
    await tester.pumpAndSettle();
    expect(find.byType(KuralFormuSayfasi), findsOneWidget);
    expect(find.text('Yeni uyarı kuralı'), findsOneWidget);
  });

  testWidgets('kural kur: ★3+ yatırımcılar ile girişimciler 2 dk; kaydedilince listede; Kapalı yap; sil (onaylı)', (tester) async {
    await _ac(tester);
    await tester.tap(find.text('+ Yeni uyarı kuralı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('★3+ yatırımcılar').first); // Kim tarafı
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '2'); // dakika alanı
    await tester.pump();
    expect(find.textContaining("★3+ yatırımcılar ile girişimciler 2 dakikadan uzun birlikte kalınca → Pano'da açılır uyarı"), findsOneWidget);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.byType(KuralFormuSayfasi), findsNothing);
    expect(find.text('★3+ yatırımcılar ile girişimciler · 2 dk'), findsOneWidget); // üretilen ad
    expect(find.text('Açık'), findsOneWidget);
    await tester.tap(find.text('Açık'));
    await tester.pumpAndSettle();
    expect(find.text('Kapalı'), findsOneWidget);
    await tester.tap(find.text('Sil'));
    await tester.pump();
    expect(find.text('Silinsin mi?'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pump();
    expect(find.text('Silinsin mi?'), findsNothing);
    await tester.tap(find.text('Sil'));
    await tester.pump();
    await tester.tap(find.text('Sil').last); // onay düğmesi
    await tester.pumpAndSettle();
    expect(find.textContaining('Henüz kural yok'), findsOneWidget);
  });

  testWidgets('belirli kişiler: aramayla seçilir, önizleme kişinin adıyla; yan yana', (tester) async {
    await _ac(tester);
    await tester.tap(find.text('+ Yeni uyarı kuralı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Belirli kişiler').first); // Kim
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'ayşe'); // kim arama alanı (ad alanından sonra)
    await tester.pump();
    await tester.tap(find.text('＋ Ayşe Demir'));
    await tester.pump();
    await tester.tap(find.textContaining('Yan yana gelince'));
    await tester.pump();
    expect(find.textContaining("Ayşe Demir ile girişimciler yan yana gelince → Pano'da açılır uyarı"), findsOneWidget);
  });
}
