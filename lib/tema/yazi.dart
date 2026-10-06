import 'package:flutter/painting.dart';

import 'renkler.dart';

/// Metin stilleri. Yazı tipi sistem fontudur (iOS SF, Android Roboto).
abstract final class Yazi {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Genel metin stili. `satir` CSS line-height çarpanıdır; `rakam` sayıların
  /// titrememesi için eşit genişlikli rakam açar.
  static TextStyle olcu(
    double punto, {
    FontWeight agirlik = FontWeight.w400,
    double satir = 1.4,
    Color renk = Renkler.metin,
    bool rakam = false,
    FontStyle? stil,
    double harfAraligi = 0,
  }) {
    return TextStyle(
      fontSize: punto,
      fontWeight: agirlik,
      height: satir,
      color: renk,
      fontStyle: stil,
      letterSpacing: harfAraligi,
      fontFeatures: rakam ? _tabular : null,
      leadingDistribution: TextLeadingDistribution.even,
      decoration: TextDecoration.none,
    );
  }

  /// Başlık (h1/h2): ağırlık 600, harf aralığı −0.015em.
  static TextStyle baslik(double punto, double satir) =>
      olcu(punto, agirlik: FontWeight.w600, satir: satir, harfAraligi: -0.015 * punto);

  /// Gövde: 15 px / 1.4.
  static final TextStyle govde = olcu(15);

  /// Kicker: 11 px, harf aralığı .1em, ikincil renk (metin büyük harfe çevrilir).
  static final TextStyle kicker = olcu(11, renk: Renkler.metin2, harfAraligi: 1.1);
}
