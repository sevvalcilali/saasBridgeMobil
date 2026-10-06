import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

/// Her ekranın ve durumun görüntüsünü alır: `docs/teslim/ekran/<platform>/`.
/// Depo dışarıdan verilir; saat akmaz, görüntüler tekrarlanabilir olur.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  Finder sekme(String ad) =>
      find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

  testWidgets('tüm ekranlar', (tester) async {
    await tester.pumpWidget(YakinlikUygulamasi(depo: EtkinlikDeposu(aliciBagli: true)));
    await tester.pump(const Duration(milliseconds: 600));
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    Future<void> bekle([int ms = 400]) => tester.pump(Duration(milliseconds: ms));

    // Canlı bağlamada tek pump yalnız bir kare çizer; alt çubuğun renk geçişi
    // gibi animasyonlar bitsin diye görüntüden önce birkaç kare ilerlenir.
    Future<void> cek(String ad) async {
      for (var i = 0; i < 8; i++) {
        await bekle(60);
      }
      await binding.takeScreenshot('$platform/$ad');
    }

    Future<void> dokun(Finder hedef) async {
      await tester.ensureVisible(hedef);
      await bekle(150);
      await tester.tap(hedef);
      await bekle();
    }

    Future<void> asagiKaydir() async {
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -520));
      await bekle(600);
    }

    // ensureVisible sayfayı kaydırmış olabilir; görüntüden önce başa dön.
    Future<void> basaKaydir() async {
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 2000));
      await bekle(600);
    }

    await cek('01_pano_kisiler');
    await dokun(find.text('Salon'));
    await cek('02_pano_salon');
    await dokun(find.text('Bildirimler'));
    await cek('03_pano_bildirimler');
    await dokun(find.text('Kişiler'));
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await bekle(600);
    await cek('04_kisi_detayi');
    await dokun(find.text('✕'));
    await bekle(600);

    await tester.tap(sekme('Kart Ver'));
    await cek('05_kart_ver_adim1');
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await cek('06_kart_ver_bekleme');
    await dokun(find.text('Demo: boş bir kartı yaklaştır'));
    await bekle(1600);
    await cek('07_kart_ver_bulundu');
    await dokun(find.text('Numarayı yaz'));
    await cek('08_kart_ver_numara');
    await dokun(find.text('Kart 88'));
    await cek('09_kart_ver_kontrol');
    await dokun(find.text('Onayla'));
    await cek('10_kart_ver_son_atama');
    await dokun(find.text('Kart iadesi'));
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await basaKaydir();
    await cek('11_kart_iadesi_onay');

    await tester.tap(sekme('Kurulum'));
    await cek('12_kurulum_ust');
    await asagiKaydir();
    await cek('13_kurulum_alt');

    await tester.tap(sekme('Rapor'));
    await cek('14_rapor_ust');
    await asagiKaydir();
    await cek('15_rapor_alt');
  });

  testWidgets('alıcı kopuk', (tester) async {
    await tester.pumpWidget(YakinlikUygulamasi(depo: EtkinlikDeposu(aliciBagli: false)));
    await tester.pump(const Duration(milliseconds: 600));
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('$platform/16_pano_alici_kopuk');
  });
}
