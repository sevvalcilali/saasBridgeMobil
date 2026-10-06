import 'package:flutter/painting.dart';

import '../veri/modeller.dart';

/// Tüm renk token'ları (docs/tasarim/README.md, tema = web).
/// Renk sabiti YALNIZ bu klasörde yazılır; ekranlar buradan okur.
abstract final class Renkler {
  // --- Yüzeyler ---
  static const zemin = Color(0xFFF7F2E9);
  static const yuzey = Color(0xFFFFFDF8);
  static const acikYuzey = Color(0xFFEFE7D8);
  static const ayrac = Color(0xFFE2D8C4);
  static const kenarlik = Color(0xFFCFC2A9);

  // --- Metin ---
  static const metin = Color(0xFF3B332C);
  static const metinKoyu2 = Color(0xFF4D453C);
  static const metin2 = Color(0xFF6B6156);
  static const metinSoluk = Color(0xFF92897C);

  /// Girdi ipucu yazısı: metin renginin %65'i.
  static const ipucu = Color(0xA63B332C);

  // --- Vurgu (altın) ---
  static const vurgu = Color(0xFF9A6512);
  static const vurguZemin = Color(0xFFF5E8CF);
  static const vurguBasili = Color(0xFF7F5410);
  static const vurguKoyu = Color(0xFF5C3D0A);

  // --- Durumlar. YEŞİL yalnız "şu an birlikte" demektir. ---
  static const birlikte = Color(0xFF1B7A4E);
  static const birlikteZemin = Color(0xFFE0F2E4);
  static const uyari = Color(0xFFB4470E);
  static const ciddi = Color(0xFFB02A25);
  static const ciddiZemin = Color(0xFFF9E2E0);
  static const ciddiKoyu = Color(0xFF8A1F1B);

  // --- Kaplamalar ve gölge ---
  /// Alt sayfanın arkasındaki perde: rgba(32,30,29,.35).
  static const perde = Color(0x59201E1D);

  /// İkincil düğme basılıyken: metin %14.
  static const ikincilBasili = Color(0x243B332C);

  /// Hayalet düğme basılıyken: vurgu %18.
  static const hayaletBasili = Color(0x2E9A6512);
  static const golge1 = Color(0x143B332C);
  static const golge2 = Color(0x1F3B332C);

  /// Kişi paleti: renk kişiyi takip eder, sıraya göre değişmez.
  static Color kisi(KisiRengi renk) => switch (renk) {
    KisiRengi.mavi => const Color(0xFF1245AF),
    KisiRengi.turuncu => const Color(0xFF854412),
    KisiRengi.hardal => const Color(0xFF968403),
    KisiRengi.pembe => const Color(0xFF920F6D),
    KisiRengi.mor => const Color(0xFF895CD2),
    KisiRengi.mercan => const Color(0xFFCC646F),
    KisiRengi.petrol => const Color(0xFF248FB2),
    KisiRengi.gri => const Color(0xFF302F2E),
  };

  /// Durum yazısının rengi.
  static Color ton(DurumTonu ton) => switch (ton) {
    DurumTonu.birlikte => birlikte,
    DurumTonu.uyari => uyari,
    DurumTonu.ikincil => metin2,
    DurumTonu.ciddi => ciddi,
  };

  /// Bildirim noktasının rengi.
  static Color onem(Onem onem) => switch (onem) {
    Onem.ciddi => ciddi,
    Onem.uyari => uyari,
    Onem.olumlu => vurguBasili,
  };
}
