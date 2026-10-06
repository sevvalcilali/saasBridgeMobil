import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/sunucu_istemcisi.dart';

import '../yardimci_sunucu.dart';

void main() {
  // flutter_test her HttpClient'ı 400 döndüren sahteyle değiştirir (ağ yasak); bu testler kendi
  // yerel sunucusuna bağlanır, gerçek istemci gerekir.
  HttpOverrides.global = null;
  late SahteSunucu s;
  setUp(() async => s = await SahteSunucu.ac());
  tearDown(() => s.kapat());

  SunucuIstemcisi istemci() => SunucuIstemcisi(s.adres, bekleme: (_) => const Duration(milliseconds: 10));

  test('durumAl: GET /state?grafik=0 (grafik verisi telefona gelmez)', () async {
    final i = istemci();
    addTearDown(i.kapat);
    final d = await i.durumAl();
    expect(d['clock'], '10:00:00');
    expect(s.istekler, ['GET /state?grafik=0']);
  });

  test('olaylar: bağlandı → mesajlar → koptu → yeniden bağlanır', () async {
    final i = istemci();
    addTearDown(i.kapat);
    final olaylar = <SunucuOlayi>[];
    final abonelik = i.olaylar().listen(olaylar.add);
    await bekle(() => s.akisAcilis >= 2 && olaylar.whereType<DurumGeldi>().length >= 3);
    await abonelik.cancel();
    expect(olaylar.first, isA<Baglandi>());
    expect(olaylar.whereType<DurumGeldi>().first.durum['n'], 1);
    expect(olaylar.whereType<Koptu>(), isNotEmpty);
    expect(s.akisAcilis, greaterThanOrEqualTo(2));
  });

  test('olaylar: sunucu akışı açmazsa Koptu gelir, bağlandı denmez', () async {
    s.akisHatali = true;
    final i = istemci();
    addTearDown(i.kapat);
    final ilk = await i.olaylar().first.timeout(const Duration(seconds: 5));
    expect(ilk, isA<Koptu>());
  });

  test('kapat: akış durur, yeniden bağlanmaz', () async {
    final i = istemci();
    final abonelik = i.olaylar().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 60));
    i.kapat();
    await abonelik.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 100)); // kapatma anında yoldaki istek sayılmasın
    final acilis = s.akisAcilis;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(s.akisAcilis, acilis);
  });

  test('komutlar: eşik, sıfırla, kart ata ve iade al doğru uca doğru gövdeyle gider', () async {
    final i = istemci();
    addTearDown(i.kapat);
    expect(await i.esikGonder(-65), isTrue);
    expect(await i.sifirla(), isTrue);
    expect(await i.kartAta('k12', '14'), isTrue);
    expect(await i.kartIadeAl('14'), isTrue);
    expect(await i.kartIadeAl('14', ayrildi: false), isTrue);
    expect(s.istekler, ['POST /control', 'POST /control', 'POST /api/assign', 'POST /api/unassign', 'POST /api/unassign']);
    expect(s.govdeler.map(jsonDecode).toList(), [
      {'cmd': 'threshold', 'value': -65},
      {'cmd': 'reset'},
      {'kisiId': 'k12', 'kart': '14'},
      {'kart': '14', 'ayrildi': true},
      {'kart': '14', 'ayrildi': false},
    ]);
  });

  test('listeler: /api/people ve /api/cards', () async {
    final i = istemci();
    addTearDown(i.kapat);
    expect(await i.kisiler(), [{'kisiId': 'k1'}]);
    expect(s.istekler.last, 'GET /api/people');
  });

  test('sunucu yoksa komut false, durumAl hata fırlatır', () async {
    final i = SunucuIstemcisi('http://127.0.0.1:1', bekleme: (_) => Duration.zero);
    addTearDown(i.kapat);
    expect(await i.esikGonder(-70), isFalse);
    expect(i.durumAl(), throwsA(anything));
  });
}
