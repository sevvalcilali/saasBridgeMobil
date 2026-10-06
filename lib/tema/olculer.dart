import 'package:flutter/painting.dart';

import 'renkler.dart';

/// Boşluk, köşe ve gölge sabitleri (README "Boşluk ve köşe").
abstract final class Olculer {
  /// Sayfanın yatay kenar boşluğu.
  static const double sayfaKenari = 20;

  /// Kart ve liste köşesi.
  static const double kose = 12;

  /// Alt sayfanın üst köşeleri.
  static const double koseAltSayfa = 20;

  /// Düğme, çip, girdi ve etiket köşesi (hap).
  static const double hap = 999;

  /// En küçük dokunma hedefi.
  static const double dokunmaEnAz = 44;

  static const BorderRadius koseYaricap = BorderRadius.all(Radius.circular(kose));
  static const BorderRadius hapYaricap = BorderRadius.all(Radius.circular(hap));

  static const List<BoxShadow> altSayfaGolgesi = [
    BoxShadow(color: Renkler.golge1, offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Renkler.golge2, offset: Offset(0, 4), blurRadius: 16),
  ];
}
