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
    '"signals":[{"a":"2","b":"3","value":-60.2}],"edges":[{"a":"2","b":"3","min":9},{"a":"2","b":"7","min":2}]}';

void main() {
  HttpOverrides.global = null;
  late SahteSunucu s;
  setUp(() async {
    s = await SahteSunucu.ac(durum: _durum);
    s.akisMesajlari = null; // akış açık kalır; mesajlar yayinla ile gelir
    s.kartlarYaniti = '[{"kart":"2","rssiAlici":-60,"seenAgo":0.5,"atanan":"k1","pil":35},{"kart":"9","rssiAlici":-70,"seenAgo":1,"atanan":null,"pil":80},'
        '{"kart":"101","rssiAlici":-40,"seenAgo":0.2,"atanan":null,"pil":90}]';
    s.kisilerYaniti = '[{"kisiId":"k1","ad":"Ayşe Demir","rol":"investor","kurum":"Atlas","yildiz":4,"renk":"#3987e5","atananKart":"2","ayrildi":false},'
        '{"kisiId":"k2","ad":"Ali Kaya","rol":"founder","kurum":"","yildiz":0,"renk":"#d95926","atananKart":null,"ayrildi":false},'
        '{"kisiId":"k3","ad":"Gitti","rol":"guest","kurum":"","yildiz":0,"renk":"#898781","atananKart":null,"ayrildi":true}]';
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
    await bekle(() => d.sunucuBagli && d.kisiler.isNotEmpty && d.duyulanKartSayisi > 0 && d.katilimcilar.isNotEmpty);
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
    expect(d.duyulanKartSayisi, 2); // 101 dinleyici cihaz, sayılmaz
    expect(d.kayitliKatilimci, 2); // ayrılan sayılmaz
    expect(d.katilimcilar.map((k) => k.kisiId).toList(), ['k1', 'k2', 'k3']);
    expect(d.katilimcilar[0].kurum, 'Atlas');
    expect(d.katilimcilar[1].kartBekliyor, isTrue);
    expect(d.acikKartlar.first.rssi, -60);
    expect(d.demo, isFalse);
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
    await bekle(() => d.saat == '10:00:06' && bildirim > 0); // bildirim en çok 1 sn ertelenir
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

  test('gunBoyu: kişinin bugün görüştükleri, en uzun önce; tanımadığı kart adsız kişi', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli && d.kisiler.isNotEmpty);
    final liste = d.gunBoyu('2');
    expect(liste.map((x) => (x.kisi.id, x.sn)).toList(), [('3', 540), ('7', 120)]);
    expect(liste.last.kisi.ad, isNull);
    expect(d.gunBoyu('9'), isEmpty);
  });

  test('kartAta / kartIadeAl: sunucuya gider, listeler tazelenir; sunucu yoksa hata metni', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli && d.katilimcilar.isNotEmpty);
    final istekOnce = s.istekler.length;
    expect(await d.kartAta('k2', '9'), isNull);
    expect(await d.kartIadeAl('9', ayrildi: false), isNull);
    expect(s.istekler.where((i) => i == 'POST /api/assign').length, 1);
    expect(s.istekler.where((i) => i == 'POST /api/unassign').length, 1);
    expect(s.istekler.length - istekOnce, greaterThanOrEqualTo(6)); // iki yazma + ikişer yoklama (cards, people)
    final kopuk = SunucuDeposu(SunucuIstemcisi('http://127.0.0.1:1', bekleme: (_) => Duration.zero));
    addTearDown(kopuk.dispose);
    expect(await kopuk.kartAta('k2', '9'), contains('Kart verilemedi'));
  });

  test('eşik isteği başarısız olursa ekran eski değere döner (sözleşme §5)', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli);
    await s.kapat(); // sunucu gitti
    d.esikAyarla(-65);
    expect(d.esik, -65); // hemen görünür
    await bekle(() => d.esik == -70);
    expect(d.esik, -70);
  });

  test('yoklama veri değişmediyse dinleyicileri uyandırmaz; akış mesajları saniyede en çok bir kez bildirir', () async {
    final d = SunucuDeposu(SunucuIstemcisi(s.adres, bekleme: (_) => const Duration(milliseconds: 10)),
        yoklamaAraligi: const Duration(milliseconds: 50));
    addTearDown(d.dispose);
    d.baslat();
    await bekle(() => d.sunucuBagli && d.duyulanKartSayisi > 0);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    var bildirim = 0;
    d.addListener(() => bildirim++);
    await Future<void>.delayed(const Duration(milliseconds: 300)); // ~6 yoklama, veri aynı
    expect(bildirim, 0);
    for (var i = 0; i < 6; i++) {
      await s.yayinla(_durum.replaceAll('"clock":"10:00:05"', '"clock":"10:00:0$i"'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(bildirim, inInclusiveRange(1, 3)); // 6 mesaj ~200 ms'de: birleşir
    expect(d.saat, '10:00:05'); // en son mesaj ekranda
  });

  test('kisiEkle / kisiGuncelle: POST ve PATCH /api/people, başarıda liste tazelenir; 400 hatası metin olarak döner', () async {
    final d = depo();
    d.baslat();
    await bekle(() => d.sunucuBagli && d.katilimcilar.isNotEmpty);
    expect(await d.kisiEkle({'ad': 'Yeni Kişi', 'rol': 'guest'}), isNull);
    expect(await d.kisiGuncelle('k1', {'yildiz': 5}), isNull);
    expect(s.istekler.where((i) => i == 'POST /api/people').length, 1);
    expect(s.istekler.where((i) => i == 'PATCH /api/people/k1').length, 1);
    s.hata = (400, 'ad boş olamaz');
    expect(await d.kisiEkle({'ad': '', 'rol': 'guest'}), 'ad boş olamaz');
  });

  test('kurallar: GET/POST/PATCH/DELETE /api/rules; 400 hatası metin olarak döner', () async {
    s.kurallarYaniti = '[{"kuralId":"r1","ad":"Herkes","kim":{"rol":"herkes","enAzYildiz":0},"kiminle":{"kisiler":["k1"]},"dakika":5,"acik":true}]';
    final d = depo();
    final liste = await d.kurallar();
    expect(liste.single.kuralId, 'r1');
    expect(liste.single.kiminle.kisiler, ['k1']);
    expect(await d.kuralEkle({'ad': '', 'kim': {'rol': 'herkes', 'enAzYildiz': 0}, 'kiminle': {'rol': 'herkes', 'enAzYildiz': 0}, 'dakika': 0}), isNull);
    expect(await d.kuralGuncelle('r1', {'acik': false}), isNull);
    expect(await d.kuralSil('r1'), isNull);
    expect(s.istekler.where((i) => i.startsWith('GET /api/rules')).length, 1);
    expect(s.istekler, containsAll(['POST /api/rules', 'PATCH /api/rules/r1', 'DELETE /api/rules/r1']));
    s.hata = (400, 'kim: en az bir kişi seçin');
    expect(await d.kuralEkle({'kim': {'kisiler': <String>[]}}), 'kim: en az bir kişi seçin');
  });
}
