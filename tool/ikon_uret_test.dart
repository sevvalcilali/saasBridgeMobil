// Uygulama ikonu üretici: `flutter test tool/ikon_uret_test.dart` → assets/ikon/ikon.png (1024×1024) ve
// ikon_on.png (Android uyarlanabilir ön katman). Sonra `dart run flutter_launcher_icons`.
// Görsel: krem zemin, altın ve mavi iki karikatür figür yan yana (salon görünümündeki figürler).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/siluet.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

Widget _ikon({required bool zemin}) => Container(
  width: 1024,
  height: 1024,
  decoration: BoxDecoration(
    color: zemin ? Renkler.zemin : null,
    borderRadius: zemin ? BorderRadius.circular(224) : null,
  ),
  child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Siluet(renk: Renkler.vurgu, rol: Rol.yatirimci, poz: 1, genislik: 330),
        const SizedBox(width: 24),
        Siluet(renk: Renkler.sure5, rol: Rol.girisimci, poz: 2, ayna: true, genislik: 330),
      ],
    ),
  ),
);

void main() {
  for (final (ad, zemin) in [('ikon', true), ('ikon_on', false)]) {
    testWidgets('$ad.png', (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final anahtar = GlobalKey();
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 1024)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(key: anahtar, child: _ikon(zemin: zemin)),
          ),
        ),
      );
      await tester.runAsync(() async {
        final sinir = anahtar.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final resim = await sinir.toImage();
        final bayt = await resim.toByteData(format: ui.ImageByteFormat.png);
        File('assets/ikon/$ad.png').writeAsBytesSync(bayt!.buffer.asUint8List());
      });
    });
  }
}
