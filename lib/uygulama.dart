import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ekranlar/kabuk.dart';
import 'tema/tema.dart';
import 'veri/etkinlik_deposu.dart';

/// Uygulamanın kökü: tema, Türkçe yerel, yazı ölçeği sınırı.
class YakinlikUygulamasi extends StatelessWidget {
  const YakinlikUygulamasi({super.key, this.depo});

  /// Testlerde dışarıdan verilir; verilmezse Kabuk kendi deposunu kurar.
  final EtkinlikDeposu? depo;

  /// Sistem yazı ölçeği bu aralığa sınırlanır (sıkışık satırlar taşmasın).
  static const double enKucukYaziOlcegi = 1;
  static const double enBuyukYaziOlcegi = 1.3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yakınlık Panosu',
      debugShowCheckedModeBanner: false,
      theme: yakinlikTemasi(),
      themeMode: ThemeMode.light,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: enKucukYaziOlcegi,
        maxScaleFactor: enBuyukYaziOlcegi,
        child: child!,
      ),
      home: Kabuk(depo: depo),
    );
  }
}
