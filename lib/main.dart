import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'uygulama.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tasarım dikey telefon içindir (390–430 px genişlik).
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const YakinlikUygulamasi());
}
