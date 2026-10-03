import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Katman kurallarını (şartname §4) denetler.
List<File> _dartDosyalari(String klasor) {
  final dizin = Directory(klasor);
  if (!dizin.existsSync()) return const [];
  return [
    for (final f in dizin.listSync(recursive: true))
      if (f is File && f.path.endsWith('.dart')) f,
  ];
}

String _yol(File f) => f.path.replaceAll(r'\', '/');

void main() {
  test('renk sabiti yalnız lib/tema altında yazılır', () {
    final renkSabiti = RegExp(r'Color\(0x|Color\.from(ARGB|RGBO)\(|Colors\.(?!transparent\b)');
    final ihlaller = [
      for (final f in _dartDosyalari('lib'))
        if (!_yol(f).startsWith('lib/tema/') && renkSabiti.hasMatch(f.readAsStringSync())) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });

  test('lib/mantik saf Dart: Flutter ve dart:ui içe aktarmaz', () {
    final yasak = RegExp('''import\\s+['"](package:flutter/|dart:ui)''');
    final ihlaller = [
      for (final f in _dartDosyalari('lib/mantik'))
        if (yasak.hasMatch(f.readAsStringSync())) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });

  test('sahte veriye yalnız EtkinlikDeposu erişir', () {
    final ihlaller = [
      for (final f in _dartDosyalari('lib'))
        if (!_yol(f).startsWith('lib/veri/') && f.readAsStringSync().contains('sahte_veri.dart')) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });
}
