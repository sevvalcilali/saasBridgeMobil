import 'package:flutter/material.dart';

import 'renkler.dart';
import 'yazi.dart';

/// Uygulamanın tek teması (README "Flutter eşlemesi").
ThemeData yakinlikTemasi() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Renkler.zemin,
    colorScheme: const ColorScheme.light(
      primary: Renkler.vurgu,
      onPrimary: Renkler.yuzey,
      surface: Renkler.yuzey,
      onSurface: Renkler.metin,
      error: Renkler.ciddi,
      outline: Renkler.kenarlik,
    ),
    dividerColor: Renkler.ayrac,
    // Sakin hareket: Material dalga efekti yok; basılı durumu bileşenler verir.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textTheme: TextTheme(bodyLarge: Yazi.govde, bodyMedium: Yazi.govde),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Renkler.vurgu,
      selectionColor: Renkler.vurguZemin,
      selectionHandleColor: Renkler.vurgu,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Renkler.yuzey,
      elevation: 0,
      selectedItemColor: Renkler.vurguBasili,
      unselectedItemColor: Renkler.metin2,
      selectedLabelStyle: TextStyle(fontSize: 11, height: 1.4),
      unselectedLabelStyle: TextStyle(fontSize: 11, height: 1.4),
      showUnselectedLabels: true,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Renkler.vurgu,
      inactiveTrackColor: Renkler.ayrac,
      thumbColor: Renkler.vurgu,
      overlayColor: Renkler.hayaletBasili,
      trackHeight: 4,
      tickMarkShape: SliderTickMarkShape.noTickMark,
    ),
  );
}
