import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/tema/tema.dart';

/// Bir widget'ı uygulama temasıyla ve Scaffold içinde sarar.
Widget temali(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: yakinlikTemasi(),
    home: Scaffold(body: child),
  );
}

/// Test yüzeyini telefon boyutuna getirir (mantıksal piksel). Varsayılan,
/// prototip çerçevesiyle aynıdır: 402 × 874.
void telefonBoyutu(WidgetTester tester, {double genislik = 402, double yukseklik = 874}) {
  tester.view.physicalSize = Size(genislik, yukseklik);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
