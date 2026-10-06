import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/sahte_depo.dart';

void main() {
  late EtkinlikDeposu depo;
  late KartVerDurumu d;

  setUp(() {
    depo = EtkinlikDeposu();
    d = KartVerDurumu(depo);
  });

  tearDown(() {
    d.dispose();
    depo.dispose();
  });

  test('başlangıç durumu', () async {
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.sonAtama, isNull);
    expect(d.bilgi, isNull);
    expect(d.iadeKisisi, isNull);
    expect(d.arama, '');
    expect(d.numara, '');
    expect(d.numaraSecilebilir, isFalse);
  });

  test('kisiSec: adım 2; numara temizlenir', () async {
    d.numaraDenetleyici.text = '14';
    d.kisiSec('k24');
    expect(d.adim, 2);
    expect(d.kisi!.kisiId, 'k24');
    expect(d.numara, '');
  });

  test('numara: yalnız rakam; 1–99 geçerli; baştaki sıfır atılır', () async {
    d.kisiSec('k24');
    d.numaraDenetleyici.text = '0';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraSec(); // geçersizken etkisiz
    expect(d.adim, 2);
    d.numaraDenetleyici.text = '100';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '12345678901234567890';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '1a4';
    expect(d.numara, '14');
    expect(d.numaraSecilebilir, isTrue);
    d.numaraDenetleyici.text = '007';
    expect(d.numaraSecilebilir, isTrue);
    d.numaraSec();
    expect(d.adim, 3);
    expect(d.seciliKart, '7');
  });

  test('acikKartSec: adım 3', () async {
    d.kisiSec('k24');
    d.acikKartSec('89');
    expect(d.adim, 3);
    expect(d.seciliKart, '89');
  });

  test('adımlar arası geri dönüş', () async {
    d.kisiSec('k24');
    d.acikKartSec('89');
    d.kartAdiminaDon();
    expect(d.adim, 2);
    expect(d.kisi!.kisiId, 'k24');
    d.kisiAdiminaDon();
    expect(d.adim, 1);
  });

  test('onayla: son atama bandı, adım 1, alanlar temiz', () async {
    d.aramaDenetleyici.text = 'nova';
    d.kisiSec('k24');
    d.numaraDenetleyici.text = '88';
    d.numaraSec();
    await d.onayla();
    expect(d.sonAtama, (ad: 'Cem Erdem', kart: '88'));
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.numara, '');
    expect(d.arama, '');
    expect(d.bilgi, isNull);
  });

  test('onayla: kişi ya da kart seçili değilse etkisiz', () async {
    await d.onayla();
    expect(d.sonAtama, isNull);
    d.kisiSec('k24');
    await d.onayla();
    expect(d.sonAtama, isNull);
    expect(d.adim, 2);
  });

  test('geriAl: bilgi metni yazılır, bant kalkar; bant yokken etkisiz', () async {
    d.kisiSec('k24');
    d.acikKartSec('88');
    await d.onayla();
    await d.geriAl();
    expect(d.sonAtama, isNull);
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
    await d.geriAl();
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
  });

  test('yeni onay önceki bilgi metnini siler', () async {
    d.kisiSec('k24');
    d.acikKartSec('88');
    await d.onayla();
    await d.geriAl();
    d.kisiSec('k31');
    d.acikKartSec('89');
    await d.onayla();
    expect(d.bilgi, isNull);
    expect(d.sonAtama, (ad: 'İrem Korkmaz', kart: '89'));
  });

  test('iade: seç, vazgeç, onayla', () async {
    d.modIade();
    expect(d.mod, KartVerModu.iade);
    d.iadeSec('k24');
    expect(d.iadeKisisi!.kisiId, 'k24');
    d.iadeVazgec();
    expect(d.iadeKisisi, isNull);
    await d.iadeOnayla(); // seçim yokken etkisiz
    expect(d.bilgi, isNull);
    d.iadeSec('k24');
    await d.iadeOnayla();
    expect(d.iadeKisisi, isNull);
    expect(d.bilgi, '✓ Kart 24 iade alındı. Cem Erdem panodan düştü; süreleri raporda kalır.');
  });

  test('modVer iade seçimini temizler; mod değişimi sihirbazı bozmaz', () async {
    d.kisiSec('k24');
    d.modIade();
    d.iadeSec('k31');
    d.modVer();
    expect(d.mod, KartVerModu.ver);
    expect(d.iadeKisisi, isNull);
    expect(d.adim, 2);
    expect(d.kisi!.kisiId, 'k24');
  });

  test('kartDegistirBaslat: Kart ver modu, adım 2, kişi seçili', () async {
    d.modIade();
    d.numaraDenetleyici.text = '5';
    d.kartDegistirBaslat('61');
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 2);
    expect(d.kisi!.kisiId, 'k61');
    expect(d.numara, '');
  });

  test('iadeBaslat: Kart iadesi modu, kişi seçili', () async {
    d.iadeBaslat('61');
    expect(d.mod, KartVerModu.iade);
    expect(d.iadeKisisi!.kisiId, 'k61');
  });

  test('kişisi olmayan kart (Kart 14): Kartı değiştir ve iade etkisiz (kayıtlı kişi yok)', () async {
    d.kartDegistirBaslat('14');
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    d.iadeBaslat('14');
    expect(d.iadeKisisi, isNull);
  });

  test('sunucu kabul etmezse: hata metni, sihirbaz 3. adımda kalır; sonraki kişi seçimi hatayı siler', () async {
    final kotuDepo = _HataliDepo();
    addTearDown(kotuDepo.dispose);
    final h = KartVerDurumu(kotuDepo);
    addTearDown(h.dispose);
    h.kisiSec('k24');
    h.acikKartSec('88');
    await h.onayla();
    expect(h.hata, contains('kabul etmedi'));
    expect(h.adim, 3);
    expect(h.sonAtama, isNull);
    h.kisiAdiminaDon();
    h.kisiSec('k31');
    expect(h.hata, isNull);
  });

  test('başkasına atanmış kart: sahibi gösterilir, onay verilmeden Onayla etkisiz (sözleşme §2)', () async {
    d.kisiSec('k24'); // Cem Erdem
    d.acikKartSec('61'); // Ayşe Demir'in kartı
    expect(d.kartinSahibi?.ad, 'Ayşe Demir');
    await d.onayla();
    expect(d.sonAtama, isNull);
    expect(d.adim, 3);
    d.sahipOnayla(true);
    await d.onayla();
    expect(d.sonAtama, (ad: 'Cem Erdem', kart: '61'));
    d.kisiSec('k24');
    d.acikKartSec('88'); // boş kart: sahip yok, onay gerekmez
    expect(d.kartinSahibi, isNull);
    d.acikKartSec('61');
    expect(d.sahipOnayi, isFalse); // her yeni kart seçiminde onay sıfırlanır
  });

  test('gönderim sürerken seçim değişirse başarı sonrası yeni seçim silinmez', () async {
    final yavas = _YavasDepo();
    addTearDown(yavas.dispose);
    final y = KartVerDurumu(yavas);
    addTearDown(y.dispose);
    y.kisiSec('k24');
    y.acikKartSec('88');
    final gonderim = y.onayla();
    y.kisiAdiminaDon();
    y.kisiSec('k31');
    yavas.tamamla.complete();
    await gonderim;
    expect(y.sonAtama, (ad: 'Cem Erdem', kart: '88'));
    expect(y.kisi!.kisiId, 'k31'); // yeni seçim korundu
    expect(y.adim, 2);
  });

  test('geriAl: önceki hata temizlenir', () async {
    final h = KartVerDurumu(_IadeHataliDepo());
    addTearDown(h.dispose);
    h.kisiSec('k24');
    h.acikKartSec('88');
    await h.onayla();
    await h.geriAl();
    expect(h.hata, contains('İade alınamadı'));
    expect(h.sonAtama, isNotNull);
  });
}

/// Sunucunun reddettiği durum.
class _HataliDepo extends SahteDepo {
  @override
  Future<String?> kartAta(String kisiId, String kart) async => 'Kart verilemedi: sunucu kabul etmedi.';
}

/// `kartAta` dışarıdan tamamlanana dek bekler.
class _YavasDepo extends SahteDepo {
  final tamamla = Completer<void>();
  @override
  Future<String?> kartAta(String kisiId, String kart) async {
    await tamamla.future;
    return null;
  }
}

/// İade reddedilir, atama kabul edilir.
class _IadeHataliDepo extends SahteDepo {
  @override
  Future<String?> kartIadeAl(String kart, {bool ayrildi = true}) async => 'İade alınamadı: sunucu kabul etmedi.';
}
