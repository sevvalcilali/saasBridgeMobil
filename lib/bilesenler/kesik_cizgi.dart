import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Kesikli düz çizgi (Flutter'da hazırı yok). `dolu` px çizer, `bos` px atlar.
void kesikCizgi(
  Canvas canvas,
  Offset bas,
  Offset son,
  Paint boya, {
  required double dolu,
  required double bos,
}) {
  final fark = son - bas;
  final uzunluk = fark.distance;
  if (uzunluk == 0 || dolu <= 0) return;
  final birim = fark / uzunluk;
  var konum = 0.0;
  while (konum < uzunluk) {
    final bitis = math.min(konum + dolu, uzunluk);
    canvas.drawLine(bas + birim * konum, bas + birim * bitis, boya);
    konum += dolu + bos;
  }
}
