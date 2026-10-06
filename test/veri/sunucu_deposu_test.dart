import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sunucu_deposu.dart';
import 'package:yakinlik_mobil/veri/sunucu_istemcisi.dart';

import '../yardimci_sunucu.dart';

const _durum =
    '{"clock":"10:00:05","elapsed":65,"threshold":-70,"receiverAge":0.5,"event":{"name":"Buluşma","date":"1.1.2026 · Salon"},'
    '"live":[{"a":"2","b":"3"}],"alerts":[{"t":1,"clock":"09:59","kind":"deal","severity":"deal","title":"Anlaşma","detail":"x","people":["2","3"]}],'
    '"people":[{"id":"2","role":"investor","name":"Ayşe","org":"","color":"#3987e5","tier":4,"status":"talking","live":1.5,"min":9},'
    '{"id":"3","role":"founder","name":"Ali","org":"Nova","color":"#d95926","tier":0,"status":"talking","live":1.5,"min":9}],'
    '"signals":[{"a":"2","b":"3","value":-60.2}]}';

void main() {
  HttpOverrides.global = null;
  late SahteSunucu s;
  setUp(() async {
    s = await SahteSunucu.ac(durum: _durum);
    s.akisMesajlari = null; // akış açık kalır; mesajlar yayinla ile gelir
    s.kartlarYaniti = '[{"kart":"2","rssiAlici":-60,"seenAgo":0.5,"atanan":"k1","pil":35},{"kart":"9","rssiAlici":-70,"seenAgo":1,"atanan":null,"pil":80}]';
    s.kisilerYaniti = '[{"kisiId":"k1"},{"kisiId":"k2"},{"kisiId":"k3"}]';
  });
  tearDown(() => s.kapat());

  SunucuDeposu depo() {
    final d = SunucuDeposu(SunucuIstemcisi(s.adres, bekleme: (_) => const Duration(milliseconds: 10)));
    addTearDown(d.dispose);
    return d;
  }

  test('baslat: durum ve akış gelir; kişiler, saat, eşik, bildirim, çiftler dolar', () async {
    final d = depo();
    expect(d.sunucuBagli, isFalse);
    expect(d.kisiler, isEmpty);
    d.baslat();
    await bekle(() => d.sunucuBagli && d.kisiler.isNotEmpty && d.duyulanKartSayisi > 0);
    expect(d.sunucuBagli, isTrue);
    expect(d.aliciBagli, isTrue);
    expect(d.etkinlikAdi, 'Buluşma');
    expect(d.tarihMekan, '1.1.2026 · Salon');
    expect(d.saat, '10:00:05');
    expect(d.saatKisa, '10:00');
    expect(d.cizelgeBaslangici, '09:59'); // saat − elapsed
    expect(d.esik, -70);
    expect(d.tick, 0);
    expect(d.bul('2').ile, '3');
    expect(d.bul('2').sn, 90);
    expect(d.bul('2').pil, 35); // /api/cards'tan
    expect(d.bildirimler.single.onem, Onem.olumlu);
    expect(d.ciftler.single.rssi, -60);
    expect(d.duyulanKartSayisi, 2);
    expect(d.kayitliKatilimci, 3);
    expect(d.acikKartlar.map((k) => (k.no, k.atanmis)).toList(), [('2', true), ('9', false)]);
    expect(d.seriRenkleri, hasLength(1));
  });

  test('akıştan yeni durum gelince dinleyiciler haberdar olur ve veri değişir', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli && d.kisiler.isNotEmpty);
    var bildirim = 0;
    d.addListener(() => bildirim++);
    await s.yayinla(_durum.replaceAll('"clock":"10:00:05"', '"clock":"10:00:06"').replaceAll('"threshold":-70', '"threshold":-66'));
    await bekle(() => d.saat == '10:00:06');
    expect(d.esik, -66);
    expect(bildirim, greaterThan(0));
  });

  test('akış kopunca sunucuBagli false olur, son veri kalır; yeniden bağlanınca true', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli && d.kisiler.isNotEmpty);
    await s.akislariKes();
    await bekle(() => !d.sunucuBagli);
    expect(d.kisiler, hasLength(2));
    expect(d.saat, '10:00:05');
    await bekle(() => d.sunucuBagli && s.akisAcilis >= 2);
    expect(d.sunucuBagli, isTrue);
  });

  test('esikAyarla hemen ekrana yansır ve sunucuya gider; sifirla komut yollar', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli);
    d.esikAyarla(-65);
    expect(d.esik, -65);
    d.esikArtir();
    expect(d.esik, -64);
    await d.sifirla();
    komutlar() => s.govdeler.where((g) => g.isNotEmpty).toList(); // GET yoklamalarının boş gövdesi sayılmaz
    await bekle(() => komutlar().length >= 3);
    expect(komutlar(), ['{"cmd":"threshold","value":-65}', '{"cmd":"threshold","value":-64}', '{"cmd":"reset"}']);
  });

  test('durdur: akış kapanır, yeniden bağlanmaz; baslat yeniden açar', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli);
    d.durdur();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final acilis = s.akisAcilis;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(s.akisAcilis, acilis);
    d.baslat();
    await bekle(() => s.akisAcilis > acilis);
    expect(s.akisAcilis, greaterThan(acilis));
  });

  test('bul: tanımadığı kart no için boş kişi döner (ekran çökmesin)', () async {
    final d = depo();
    expect(d.bul('77').id, '77');
    expect(d.bul('77').ad, isNull);
  });
}
