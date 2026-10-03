import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget testlerinin varsayılan yazı tipi her harfi kare çizer; gerçekte sığan
/// satırlar taşmış görünür. Flutter SDK ile gelen Roboto yüklenir, böylece
/// ölçüler Android'deki gerçek ölçülere yakın olur.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _robotoYukle();
  await testMain();
}

Directory? _yaziTipiKlasoru() {
  final kok = Platform.environment['FLUTTER_ROOT'];
  final adaylar = [
    if (kok != null) '$kok/bin/cache/artifacts/material_fonts',
    // flutter_tester: <kök>/bin/cache/artifacts/engine/<platform>/flutter_tester
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts',
  ];
  for (final yol in adaylar) {
    final klasor = Directory(yol);
    if (klasor.existsSync()) return klasor;
  }
  return null;
}

Future<void> _robotoYukle() async {
  final klasor = _yaziTipiKlasoru();
  if (klasor == null) return;
  final yukleyici = FontLoader('Roboto');
  const dosyalar = ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf'];
  for (final ad in dosyalar) {
    final dosya = File('${klasor.path}/$ad');
    if (dosya.existsSync()) {
      yukleyici.addFont(Future<ByteData>.value(ByteData.sublistView(dosya.readAsBytesSync())));
    }
  }
  await yukleyici.load();
}
