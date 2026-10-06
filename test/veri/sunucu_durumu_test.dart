import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sunucu_durumu.dart';

/// Gerçek sunucudan (saasBridgeBackend, benzetim) alınmış kırpılmış örnek.
Map<String, dynamic> ornek() =>
    jsonDecode(File('test/veri/ornek/durum.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('kişiler: kart no kimlik, rol ve renk eşlenir, yıldız tier', () {
    final d = SunucuDurumu.ayristir(ornek());
    final ayse = d.kisiler.firstWhere((k) => k.ad == 'Ayşe Demir');
    expect(ayse.id, '84');
    expect(ayse.rol, Rol.yatirimci);
    expect(ayse.renk, KisiRengi.mavi); // #3987e5
    expect(ayse.kurum, 'Atlas Ventures');
    expect(ayse.yildiz, 3);
    expect(ayse.pil, isNull); // durumda pil yok; kartlardan gelir
  });

  test('kayıtsız kart ("Kart 14") adsız kişidir', () {
    final d = SunucuDurumu.ayristir(ornek());
    final kart = d.kisiler.firstWhere((k) => k.id == '14');
    expect(kart.ad, isNull);
    expect(kart.kurum, isNull);
  });

  test('görüşen kişi: eşi canlı çiftlerden, süre dakikadan saniyeye', () {
    final ham = ornek();
    final d = SunucuDurumu.ayristir(ham);
    final canli = (ham['live'] as List).first as Map<String, dynamic>;
    final a = d.kisiler.firstWhere((k) => k.id == canli['a']);
    final b = d.kisiler.firstWhere((k) => k.id == canli['b']);
    expect(a.ile, b.id);
    expect(b.ile, a.id);
    final hamA = (ham['people'] as List).cast<Map<String, dynamic>>().firstWhere((k) => k['id'] == a.id);
    expect(a.sn, ((hamA['live'] as num) * 60).round());
    expect(d.canliCiftler.first.a, canli['a']);
    expect(d.canliCiftler.length, (ham['live'] as List).length);
  });

  test('boştaki kişi: eşi yok, süre bugünkü toplam; hiç görüşmemiş = toplam 0', () {
    final d = SunucuDurumu.ayristir({
      ...ornek(),
      'live': <dynamic>[],
      'people': [
        {'id': '7', 'role': 'founder', 'name': 'A', 'org': 'X', 'color': '#d95926', 'tier': 0,
          'status': 'idle', 'live': 0, 'min': 12.5, 'seenAgo': 0, 'idleSinceS': 90},
        {'id': '8', 'role': 'guest', 'name': 'B', 'org': '', 'color': '#898781', 'tier': 0,
          'status': 'away', 'live': 0, 'min': 0, 'seenAgo': 200, 'idleSinceS': 0},
      ],
    });
    final a = d.kisiler[0];
    final b = d.kisiler[1];
    expect(a.ile, isNull);
    expect(a.sn, 750);
    expect(a.hic, isFalse);
    expect(a.gorunmuyor, isFalse);
    expect(a.bostaSn, 90);
    expect(b.hic, isTrue);
    expect(b.gorunmuyor, isTrue);
    expect(b.rol, Rol.misafir);
    expect(b.renk, KisiRengi.gri);
  });

  test('bildirimler: en yeni başta; önem deal→olumlu, warn→uyarı, serious→ciddi, kural→kural; t taşınır', () {
    final d = SunucuDurumu.ayristir({
      ...ornek(),
      'alerts': [
        {'t': 1, 'clock': '13:01', 'kind': 'lost', 'severity': 'serious', 'title': 'Kart kayıp', 'detail': 'd1', 'people': ['84']},
        {'t': 2, 'clock': '13:02', 'kind': 'warn', 'severity': 'warn', 'title': 'Yalnız', 'detail': 'd2', 'people': ['5']},
        {'t': 3, 'clock': '13:03', 'kind': 'kural', 'severity': 'kural', 'title': 'Kural', 'detail': 'd3', 'people': ['5', '28']},
        {'t': 4, 'clock': '13:04', 'kind': 'deal', 'severity': 'deal', 'title': 'Anlaşma', 'detail': 'd4', 'people': ['5', '28']},
      ],
    });
    expect(d.bildirimler.map((b) => b.baslik).toList(), ['Anlaşma', 'Kural', 'Yalnız', 'Kart kayıp']);
    expect(d.bildirimler.map((b) => b.onem).toList(), [Onem.olumlu, Onem.kural, Onem.uyari, Onem.ciddi]);
    expect(d.bildirimler.first.t, 4);
    expect(d.bildirimler.first.saat, '13:04');
    expect(d.bildirimler.first.kisiler, ['5', '28']);
  });

  test('etkinlik, saat, eşik, alıcı ve sinyal çiftleri', () {
    final ham = ornek();
    final d = SunucuDurumu.ayristir(ham);
    final saat = (ham['clock'] as String).split(':').map(int.parse).toList();
    expect(d.etkinlikAdi, 'Yatırımcı Buluşması');
    expect(d.tarihMekan, '28.09.2026 · Demo Salonu');
    expect(d.saatSn, saat[0] * 3600 + saat[1] * 60 + saat[2]);
    expect(d.esik, -72);
    expect(d.aliciBagli, isTrue);
    expect(d.ciftler, isNotEmpty);
    expect(d.ciftler.first.rssi, -84); // signals[].value yuvarlanır
    expect(d.canliCiftSayisi, (ham['live'] as List).length);
  });

  test('alıcı: receiverAge yoksa ya da 5 sn\'den eskiyse kopuk', () {
    expect(SunucuDurumu.ayristir({...ornek(), 'receiverAge': null}).aliciBagli, isFalse);
    expect(SunucuDurumu.ayristir({...ornek(), 'receiverAge': 7.2}).aliciBagli, isFalse);
    expect(SunucuDurumu.ayristir({...ornek(), 'receiverAge': 4.9}).aliciBagli, isTrue);
  });

  test('kart pilleri verilirse kişiye yazılır', () {
    final d = SunucuDurumu.ayristir(ornek(), piller: {'84': 63});
    expect(d.kisiler.firstWhere((k) => k.id == '84').pil, 63);
    expect(d.kisiler.firstWhere((k) => k.id == '14').pil, isNull);
  });

  test('bilinmeyen sunucu rengi griye düşer; 100+ dinleyici kartlar atılır', () {
    final d = SunucuDurumu.ayristir({
      ...ornek(),
      'live': <dynamic>[],
      'people': [
        {'id': '3', 'role': 'investor', 'name': 'A', 'org': '', 'color': '#123456', 'tier': 1, 'status': 'idle', 'live': 0, 'min': 0},
        {'id': '101', 'role': 'guest', 'name': 'Kart 101', 'org': '', 'color': '#3987e5', 'tier': 0, 'status': 'idle', 'live': 0, 'min': 0},
      ],
    });
    expect(d.kisiler.map((k) => k.id).toList(), ['3']);
    expect(d.kisiler.first.renk, KisiRengi.gri);
  });

  test('gün boyu: edges çiftin bugünkü toplam süresi (dakika → saniye); dinleyici kartlar atılır', () {
    final d = SunucuDurumu.ayristir({
      ...ornek(),
      'edges': [{'a': '84', 'b': '56', 'min': 5.5}, {'a': '84', 'b': '101', 'min': 9}],
    });
    expect(d.gunBoyu.single.a, '84');
    expect(d.gunBoyu.single.sn, 330);
  });

  test('history: çift anahtarı → (saniye önce, dBm) listesi; dinleyici çiftler atılır; chartSeconds', () {
    final d = SunucuDurumu.ayristir({
      ...ornek(),
      'history': {'2-3': [[90, -60.5], [88, -61.0]], '2-101': [[90, -50.0]]},
      'chartSeconds': 90,
    });
    expect(d.gecmis.keys.toList(), ['2-3']);
    expect(d.gecmis['2-3'], [(90, -60.5), (88, -61.0)]);
    expect(d.grafikSaniyesi, 90);
    expect(SunucuDurumu.ayristir(ornek()).gecmis, isEmpty); // grafik=0: boş
  });
}
