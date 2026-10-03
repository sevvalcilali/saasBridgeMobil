import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Ekran görüntülerini docs/teslim/ekran/ altına yazar.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String ad, List<int> baytlar, [Map<String, Object?>? args]) async {
      final dosya = File('docs/teslim/ekran/$ad.png');
      dosya.createSync(recursive: true);
      dosya.writeAsBytesSync(baytlar);
      return true;
    },
  );
}
