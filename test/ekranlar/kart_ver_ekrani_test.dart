import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/adim_gostergesi.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_ekrani.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/nabiz.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Not: Nabız sonsuz bir animasyondur; bu dosyada pumpAndSettle KULLANILMAZ.

class _Kurulum {
  _Kurulum(WidgetTester tester) : depo = EtkinlikDeposu() {
    durum = KartVerDurumu(depo);
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  late final KartVerDurumu durum;

  Widget get widget => temali(KartVerEkrani(depo: depo, durum: durum));
}

const _cem = 'Nova Robotik · Cem Erdem';

Future<_Kurulum> _kisiSecili(WidgetTester tester) async {
  final k = _Kurulum(tester);
  await tester.pumpWidget(k.widget);
  await tester.tap(find.text(_cem));
  await tester.pump();
  return k;
}

void main() {
  testWidgets('açılış: başlık, mod anahtarı, adım göstergesi, kişi listesi', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Kart Ver'), findsOneWidget);
    expect(find.text('Karşılama masası — gelen kişiye kart verin'), findsOneWidget);
    expect(find.text('Kart ver'), findsOneWidget);
    expect(find.text('Kart iadesi'), findsOneWidget);
    expect(find.byType(AdimGostergesi), findsOneWidget);
    expect(find.text('Kişi'), findsOneWidget);
    expect(find.text('Kart'), findsOneWidget);
    expect(find.text('Onay'), findsOneWidget);
    expect(find.text('Tümü (25)'), findsOneWidget);
    expect(find.text('Kart bekliyor (0)'), findsOneWidget);
    expect(find.text('Düzenle'), findsNWidgets(25));
    expect(find.text(_cem), findsOneWidget);
    expect(find.text('Kart 24'), findsOneWidget);
    expect(find.text('Kart 61 · ★★★★'), findsOneWidget);
  });

  testWidgets('arama kişi listesini süzer', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'PEAK');
    await tester.pump();
    expect(find.text('Düzenle'), findsOneWidget);
    expect(find.text('Peak Enerji · İrem Korkmaz'), findsOneWidget);
  });

  testWidgets('kişi seçince adım 2: bekleme görünümü', (tester) async {
    await _kisiSecili(tester);
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    expect(find.text('Yaklaştır ve tanı'), findsOneWidget);
    expect(find.text('önerilen'), findsOneWidget);
    expect(find.text('Numarayı yaz'), findsOneWidget);
    expect(find.byType(Nabiz), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
    expect(find.text('Demo: boş bir kartı yaklaştır'), findsOneWidget);
    expect(find.text('← Kişi'), findsOneWidget);
    expect(find.text('Bu kartı seç'), findsNothing);
  });

  testWidgets('demo yaklaştırma: 1,4 sn sonra kart bulunur; seçince Kontrol adımı', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Demo: boş bir kartı yaklaştır'));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Kart 88 bulundu ✓'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Kart 88 bulundu ✓'), findsOneWidget);
    expect(find.text('Açık · az önce duyuldu · boşta'), findsOneWidget);
    expect(find.byType(Nabiz), findsNothing);

    await tester.tap(find.text('Bu kartı seç'));
    await tester.pump();
    expect(find.text('Kontrol'), findsOneWidget);
    expect(find.text('Durum'), findsOneWidget);
    expect(find.text('Açık'), findsOneWidget);
    expect(find.text('Son duyulma'), findsOneWidget);
    expect(find.text('az önce'), findsOneWidget);
    expect(find.text('boşta'), findsOneWidget); // kart 88 açık kartlarda boşta
    expect(find.text('$_cem → Kart 88'), findsOneWidget);
    expect(find.text('← Kart'), findsOneWidget);
    expect(find.text('Onayla'), findsOneWidget);
  });

  testWidgets('onayla: son atama bandı ve adım 1; geri al: bilgi bandı', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('88');
    await tester.pump();
    await tester.tap(find.text('Onayla'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsOneWidget);
    expect(find.text('↶ Geri al'), findsOneWidget);
    expect(find.text('Düzenle'), findsNWidgets(25));

    await tester.ensureVisible(find.text('↶ Geri al'));
    await tester.tap(find.text('↶ Geri al'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsNothing);
    expect(find.text('↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.'), findsOneWidget);
  });

  testWidgets('numara yolu: geçersiz numarada düğme yok; geçerli numarayla seçilir', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    expect(find.text('Kart numarası (kartın üstündeki etiket)'), findsOneWidget);
    expect(find.text('ŞU AN AÇIK KARTLAR'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('boşta'), findsNWidgets(5));
    expect(find.text('atanmış'), findsNWidgets(4));
    expect(find.text('Bu kartı seç'), findsNothing);

    for (final gecersiz in ['0', '00', '100', '12345678901234567890']) {
      await tester.enterText(find.byType(TextField), gecersiz);
      await tester.pump();
      expect(find.text('Bu kartı seç'), findsNothing, reason: '"$gecersiz" geçersiz');
      expect(tester.takeException(), isNull, reason: '"$gecersiz" çökertmemeli');
    }

    await tester.enterText(find.byType(TextField), '007');
    await tester.pump();
    await tester.ensureVisible(find.text('Bu kartı seç'));
    await tester.tap(find.text('Bu kartı seç'));
    await tester.pump();
    expect(find.text('$_cem → Kart 7'), findsOneWidget);
  });

  testWidgets('numara alanı harf kabul etmez; ızgara ön eke göre süzülür', (tester) async {
    final k = await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '8a');
    await tester.pump();
    expect(k.durum.numaraDenetleyici.text, '8');
    expect(find.text('Kart 88'), findsOneWidget);
    expect(find.text('Kart 89'), findsOneWidget);
    expect(find.text('Kart 90'), findsNothing);
  });

  testWidgets('açık karta dokununca Kontrol adımına geçer', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.tap(find.text('Kart 89'));
    await tester.pump();
    expect(find.text('$_cem → Kart 89'), findsOneWidget);
  });

  testWidgets('← Kart ve ← Kişi geri döner', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('89');
    await tester.pump();
    await tester.tap(find.text('← Kart'));
    await tester.pump();
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    await tester.tap(find.text('← Kişi'));
    await tester.pump();
    expect(find.text('Düzenle'), findsNWidgets(25));
  });

  testWidgets('demo beklerken geri dönülürse eski kart sonradan belirmez (S16)', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Demo: boş bir kartı yaklaştır'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('← Kişi'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Peak Enerji · İrem Korkmaz'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Kişi: Peak Enerji · İrem Korkmaz'), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
    expect(find.text('Kart 88 bulundu ✓'), findsNothing);
  });

  testWidgets('yaklaştır modunda alttaki "Bu kartı seç" görünmez (S13)', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '14');
    await tester.pump();
    expect(find.text('Bu kartı seç'), findsOneWidget);
    await tester.tap(find.text('Yaklaştır ve tanı'));
    await tester.pump();
    expect(find.text('Bu kartı seç'), findsNothing);
  });

  testWidgets('Kart iadesi: liste, onay kutusu, vazgeç ve iade al', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    expect(find.text('Kart İadesi'), findsOneWidget);
    expect(find.text('Ayrılan kişiden kartı geri alın'), findsOneWidget);
    expect(find.text('Kart no, ad veya kurum'), findsOneWidget);
    expect(find.byType(AdimGostergesi), findsNothing);
    expect(find.text('Düzenle'), findsNothing);
    expect(find.text('Kart 24'), findsOneWidget);

    await tester.tap(find.text(_cem));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsOneWidget);
    expect(find.text('$_cem panodan düşer; bugünkü süreleri raporda kalır.'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsNothing);

    await tester.tap(find.text(_cem));
    await tester.pump();
    await tester.tap(find.text('İade al'));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsNothing);
    expect(find.text('✓ Kart 24 iade alındı. Cem Erdem panodan düştü; süreleri raporda kalır.'), findsOneWidget);
  });

  testWidgets('iade araması kart numarasıyla da bulur', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '61');
    await tester.pump();
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text(_cem), findsNothing);
  });

  testWidgets('son atama bandı iki modda da görünür', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('88');
    k.durum.onayla();
    await tester.pump();
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsOneWidget);
  });

  testWidgets('Kişi Detayı kısayolları ekranı doğru yerden açar', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    k.durum.kartDegistirBaslat('61');
    await tester.pump();
    expect(find.text('Kişi: Ayşe Demir'), findsOneWidget);
    k.durum.iadeBaslat('61');
    await tester.pump();
    expect(find.text('Kart 61 iade alınsın mı?'), findsOneWidget);
  });

  testWidgets('"Kart bekliyor" süzgeci: sahte veride bekleyen yok, liste boşalır; Tümü geri getirir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Kart bekliyor (0)'));
    await tester.pump();
    expect(find.text('Düzenle'), findsNothing);
    await tester.tap(find.text('Tümü (25)'));
    await tester.pump();
    expect(find.text('Düzenle'), findsNWidgets(25));
  });

  testWidgets('"hareketi azalt" açıkken nabız sabit durur', (tester) async {
    await tester.pumpWidget(
      temali(const MediaQuery(data: MediaQueryData(disableAnimations: true), child: Center(child: Nabiz()))),
    );
    await tester.pumpAndSettle(); // sonsuz animasyon olsaydı zaman aşımına düşerdi
    expect(find.byType(Nabiz), findsOneWidget);
  });
}
