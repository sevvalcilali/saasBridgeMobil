import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kisi_formu_sayfasi.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_depo.dart';

import '../yardimci.dart';

/// Çağrıları kaydeden depo; `hata` verilirse onu döner.
class _KayitDepo extends SahteDepo {
  final eklenen = <Map<String, Object?>>[];
  final guncellenen = <(String, Map<String, Object?>)>[];
  String? hata;
  @override
  Future<String?> kisiEkle(Map<String, Object?> govde) async {
    eklenen.add(govde);
    return hata;
  }

  @override
  Future<String?> kisiGuncelle(String kisiId, Map<String, Object?> govde) async {
    guncellenen.add((kisiId, govde));
    return hata;
  }
}

Future<_KayitDepo> _ac(WidgetTester tester, {Katilimci? katilimci}) async {
  telefonBoyutu(tester, yukseklik: 1400);
  final depo = _KayitDepo();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(KisiFormuSayfasi(depo: depo, katilimci: katilimci)));
  return depo;
}

void main() {
  testWidgets('yeni kişi: ad boşken Kişiyi ekle etkisiz; ad yazılıp rol seçilince gövde depoya gider', (tester) async {
    final depo = await _ac(tester);
    expect(find.text('Yeni kişi'), findsOneWidget);
    await tester.tap(find.text('Kişiyi ekle'));
    await tester.pump();
    expect(depo.eklenen, isEmpty);
    await tester.enterText(find.byType(TextField).first, 'Zeynep Ak');
    await tester.tap(find.text('Yatırımcı'));
    await tester.pump();
    expect(find.text('Yıldız'), findsOneWidget);
    expect(find.text('Aşama'), findsNothing);
    await tester.tap(find.text('★').at(3)); // 4 yıldız
    await tester.pump();
    await tester.tap(find.text('Kişiyi ekle'));
    await tester.pump();
    expect(depo.eklenen.single['ad'], 'Zeynep Ak');
    expect(depo.eklenen.single['rol'], 'investor');
    expect(depo.eklenen.single['yildiz'], 4);
  });

  testWidgets('girişimci: sektör ve aşama görünür; aşama çipi seçilir', (tester) async {
    final depo = await _ac(tester);
    await tester.enterText(find.byType(TextField).first, 'Ali');
    expect(find.text('Aşama'), findsOneWidget);
    await tester.tap(find.text('MVP'));
    await tester.pump();
    await tester.tap(find.text('Kişiyi ekle'));
    await tester.pump();
    expect(depo.eklenen.single['asama'], 'mvp');
    expect(depo.eklenen.single['yildiz'], 0);
  });

  testWidgets('düzenleme: alanlar dolu gelir; yalnız değişen alan PATCH gövdesinde', (tester) async {
    const k = Katilimci(kisiId: 'k7', ad: 'Ayşe Demir', kurum: 'Atlas', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 3, eposta: 'a@b.c');
    final depo = await _ac(tester, katilimci: k);
    expect(find.text('Kişiyi düzenle'), findsOneWidget);
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('a@b.c'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check_box_outline_blank)); // paylaşım izni
    await tester.pump();
    await tester.tap(find.text('Kaydet'));
    await tester.pump();
    expect(depo.guncellenen.single.$1, 'k7');
    expect(depo.guncellenen.single.$2, {'paylasim': true});
  });

  testWidgets('sunucu reddederse hata metni formda kalır, sayfa kapanmaz', (tester) async {
    final depo = await _ac(tester);
    depo.hata = 'ad boş olamaz';
    await tester.enterText(find.byType(TextField).first, 'X');
    await tester.pump(); // düğme yeniden kurulsun (ad doldu → etkin)
    await tester.tap(find.text('Kişiyi ekle'));
    await tester.pump();
    await tester.pump(); // depo yanıtı bir sonraki karede
    expect(find.text('ad boş olamaz'), findsOneWidget);
    expect(find.text('Yeni kişi'), findsOneWidget);
  });
}
