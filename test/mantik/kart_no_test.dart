import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kart_no.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  test('numaraTemizle: baştaki sıfırları atar', () {
    expect(numaraTemizle('007'), '7');
    expect(numaraTemizle('70'), '70');
    expect(numaraTemizle('000'), '');
    expect(numaraTemizle(''), '');
  });

  test('numaraGecerli: yalnız 1–99', () {
    for (final g in ['1', '7', '007', '14', '99', '099']) {
      expect(numaraGecerli(g), isTrue, reason: '"$g" geçerli olmalı');
    }
    for (final g in ['', '0', '00', '100', '1a', 'abc', '-3', ' 5', '12345678901234567890']) {
      expect(numaraGecerli(g), isFalse, reason: '"$g" geçersiz olmalı');
    }
  });

  test('yalnizRakam: rakam dışını atar', () {
    expect(yalnizRakam('1a2 b3'), '123');
    expect(yalnizRakam('abc'), '');
  });

  test('acikKartOner: numara ön ekine göre süzer', () {
    const kartlar = SahteVeri.acikKartlar;
    List<String> oner(String n) => [for (final k in acikKartOner(kartlar, n)) k.no];
    expect(oner(''), hasLength(9));
    expect(oner('8'), ['88', '89']);
    expect(oner('9'), ['90', '96', '97']);
    expect(oner('09'), ['90', '96', '97']);
    expect(oner('0'), hasLength(9));
    expect(oner('3'), isEmpty);
  });

  test('acikKartEtiketi', () {
    expect(acikKartEtiketi(SahteVeri.acikKartlar.first), 'boşta');
    expect(acikKartEtiketi(SahteVeri.acikKartlar.last), 'atanmış');
  });

  test('masaAra (sahte veri): yalnız adı olanlar katılımcıdır; ad, kurum ve kart no', () {
    List<String> ara(String q) => [for (final k in masaAra(SahteVeri.katilimcilar, q)) k.kisiId];
    expect(ara(''), hasLength(25));
    expect(ara('peak'), ['k31']);
    expect(ara('PEAK'), ['k31']);
    expect(ara('24'), ['k24']);
    expect(ara('14'), isEmpty); // adsız kart katılımcı değil
  });
  katilimciTestleri();
}

// --- Kayıtlı kişi (M1b) ---
Katilimci _k(String id, String ad, {String? kurum, String? kart, bool ayrildi = false}) =>
    Katilimci(kisiId: id, ad: ad, kurum: kurum, rol: Rol.girisimci, renk: KisiRengi.mavi, atananKart: kart, ayrildi: ayrildi);

void katilimciTestleri() {
  final liste = [_k('k1', 'Ayşe Demir', kurum: 'Atlas', kart: '14'), _k('k2', 'Ali Kaya'), _k('k3', 'Veli Can', kart: '7', ayrildi: false), _k('k4', 'Gitti Gider', ayrildi: true)];

  test('masaAra: ayrılanlar hiç listelenmez; arama ad, kurum ve kart no\'da; kartlı / bekleyen süzgeçleri', () {
    expect(masaAra(liste, '').map((k) => k.kisiId).toList(), ['k1', 'k2', 'k3']);
    expect(masaAra(liste, 'atlas').single.kisiId, 'k1');
    expect(masaAra(liste, '14').single.kisiId, 'k1');
    expect(masaAra(liste, 'ALİ').single.kisiId, 'k2');
    expect(masaAra(liste, '', yalnizKartli: true).map((k) => k.kisiId).toList(), ['k1', 'k3']);
    expect(masaAra(liste, '', yalnizBekleyen: true).single.kisiId, 'k2');
  });

  test('katılımcı metinleri', () {
    expect(katilimciAdi(liste[0]), 'Atlas · Ayşe Demir');
    expect(katilimciAdi(liste[1]), 'Ali Kaya');
    expect(katilimciKartMetni(liste[0]), 'Kart 14');
    expect(katilimciKartMetni(liste[1]), 'Kart bekliyor');
    expect(katilimciKartMetni(liste[3]), 'Ayrıldı');
    expect(katilimciKartMetni(Katilimci(kisiId: 'k9', ad: 'Y', rol: Rol.yatirimci, renk: KisiRengi.gri, yildiz: 3)), 'Kart bekliyor · ★★★');
  });

  test('yaklaştır ve tanı: −55 dBm üstü tek boş kart bulunur; iki kart uyarı; atanmış ya da uzak kart sayılmaz', () {
    const bos = AcikKart('88', rssi: -40, seenAgo: 1);
    const uzak = AcikKart('12', rssi: -70, seenAgo: 1);
    const atanmis = AcikKart('14', atanmis: true, rssi: -38, seenAgo: 0);
    const bayat = AcikKart('30', rssi: -40, seenAgo: 20);
    expect(yaklastirilanKart([bos, uzak, atanmis, bayat]), (kart: '88', uyari: null));
    expect(yaklastirilanKart([uzak, atanmis]), (kart: null, uyari: null));
    final iki = yaklastirilanKart([bos, const AcikKart('89', rssi: -45, seenAgo: 1)]);
    expect(iki.kart, isNull);
    expect(iki.uyari, contains('88, 89'));
  });
}
