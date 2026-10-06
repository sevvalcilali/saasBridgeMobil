import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/tema/olculer.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/tema/tema.dart';
import 'package:yakinlik_mobil/tema/yazi.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

void main() {
  test("yüzey ve metin token'ları README ile aynı", () {
    expect(Renkler.zemin, const Color(0xFFF7F2E9));
    expect(Renkler.yuzey, const Color(0xFFFFFDF8));
    expect(Renkler.acikYuzey, const Color(0xFFEFE7D8));
    expect(Renkler.ayrac, const Color(0xFFE2D8C4));
    expect(Renkler.kenarlik, const Color(0xFFCFC2A9));
    expect(Renkler.metin, const Color(0xFF3B332C));
    expect(Renkler.metinKoyu2, const Color(0xFF4D453C));
    expect(Renkler.metin2, const Color(0xFF6B6156));
    expect(Renkler.metinSoluk, const Color(0xFF92897C));
  });

  test("vurgu ve durum token'ları README ile aynı", () {
    expect(Renkler.vurgu, const Color(0xFF9A6512));
    expect(Renkler.vurguZemin, const Color(0xFFF5E8CF));
    expect(Renkler.vurguBasili, const Color(0xFF7F5410));
    expect(Renkler.vurguKoyu, const Color(0xFF5C3D0A));
    expect(Renkler.birlikte, const Color(0xFF1B7A4E));
    expect(Renkler.birlikteZemin, const Color(0xFFE0F2E4));
    expect(Renkler.uyari, const Color(0xFFB4470E));
    expect(Renkler.ciddi, const Color(0xFFB02A25));
    expect(Renkler.ciddiZemin, const Color(0xFFF9E2E0));
    expect(Renkler.ciddiKoyu, const Color(0xFF8A1F1B));
  });

  test('kişi paleti', () {
    expect(Renkler.kisi(KisiRengi.mavi), const Color(0xFF1245AF));
    expect(Renkler.kisi(KisiRengi.turuncu), const Color(0xFF854412));
    expect(Renkler.kisi(KisiRengi.hardal), const Color(0xFF968403));
    expect(Renkler.kisi(KisiRengi.pembe), const Color(0xFF920F6D));
    expect(Renkler.kisi(KisiRengi.mor), const Color(0xFF895CD2));
    expect(Renkler.kisi(KisiRengi.mercan), const Color(0xFFCC646F));
    expect(Renkler.kisi(KisiRengi.petrol), const Color(0xFF248FB2));
    expect(Renkler.kisi(KisiRengi.gri), const Color(0xFF302F2E));
  });

  test('durum tonu ve önem renkleri', () {
    expect(Renkler.ton(DurumTonu.birlikte), Renkler.birlikte);
    expect(Renkler.ton(DurumTonu.uyari), Renkler.uyari);
    expect(Renkler.ton(DurumTonu.ikincil), Renkler.metin2);
    expect(Renkler.ton(DurumTonu.ciddi), Renkler.ciddi);
    expect(Renkler.onem(Onem.ciddi), Renkler.ciddi);
    expect(Renkler.onem(Onem.uyari), Renkler.uyari);
    expect(Renkler.onem(Onem.olumlu), Renkler.vurguBasili);
  });

  test('yeşil yalnız "birlikte" anlamında kullanılır', () {
    for (final t in DurumTonu.values.where((t) => t != DurumTonu.birlikte)) {
      expect(Renkler.ton(t), isNot(Renkler.birlikte), reason: '$t');
    }
    for (final r in KisiRengi.values) {
      expect(Renkler.kisi(r), isNot(Renkler.birlikte), reason: '$r');
    }
    for (final o in Onem.values) {
      expect(Renkler.onem(o), isNot(Renkler.birlikte), reason: '$o');
    }
  });

  test('yazı stilleri', () {
    expect(Yazi.govde.fontSize, 15);
    expect(Yazi.govde.height, 1.4);
    expect(Yazi.govde.color, Renkler.metin);
    final h1 = Yazi.baslik(22, 1.15);
    expect(h1.fontWeight, FontWeight.w600);
    expect(h1.height, 1.15);
    expect(h1.letterSpacing, closeTo(-0.33, 1e-9));
    expect(Yazi.kicker.fontSize, 11);
    expect(Yazi.kicker.letterSpacing, 1.1);
    expect(Yazi.kicker.color, Renkler.metin2);
    expect(Yazi.olcu(15, rakam: true).fontFeatures, const [FontFeature.tabularFigures()]);
    expect(Yazi.olcu(15).fontFeatures, isNull);
  });

  test('ölçüler', () {
    expect(Olculer.sayfaKenari, 20);
    expect(Olculer.kose, 12);
    expect(Olculer.koseAltSayfa, 20);
    expect(Olculer.dokunmaEnAz, 44);
    expect(Olculer.koseYaricap, BorderRadius.circular(12));
    expect(Olculer.altSayfaGolgesi, hasLength(2));
  });

  test('tema: README eşlemesi', () {
    final t = yakinlikTemasi();
    expect(t.brightness, Brightness.light);
    expect(t.scaffoldBackgroundColor, Renkler.zemin);
    expect(t.colorScheme.primary, Renkler.vurgu);
    expect(t.colorScheme.onPrimary, Renkler.yuzey);
    expect(t.colorScheme.surface, Renkler.yuzey);
    expect(t.colorScheme.onSurface, Renkler.metin);
    expect(t.colorScheme.error, Renkler.ciddi);
    expect(t.colorScheme.outline, Renkler.kenarlik);
    expect(t.dividerColor, Renkler.ayrac);
    expect(t.splashFactory, NoSplash.splashFactory);
    expect(t.textTheme.bodyMedium!.fontSize, 15);
    expect(t.bottomNavigationBarTheme.backgroundColor, Renkler.yuzey);
    expect(t.bottomNavigationBarTheme.selectedItemColor, Renkler.vurguBasili);
    expect(t.bottomNavigationBarTheme.unselectedItemColor, Renkler.metin2);
  });
}
