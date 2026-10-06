import 'package:shared_preferences/shared_preferences.dart';

/// Görünüm ayarı: sistemi izle, hep açık ya da hep koyu. Telefonda kalıcı.
enum TemaAyari { sistem, acik, koyu }

abstract final class TemaAyarlari {
  static const _anahtar = 'tema';

  static Future<TemaAyari> oku() async {
    final p = await SharedPreferences.getInstance();
    return TemaAyari.values.asNameMap()[p.getString(_anahtar)] ?? TemaAyari.sistem;
  }

  static Future<void> yaz(TemaAyari ayar) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_anahtar, ayar.name);
  }
}

/// Ayar ve sistemin parlaklığından etkin tema.
bool koyuMu(TemaAyari ayar, {required bool sistemKoyu}) => switch (ayar) {
  TemaAyari.sistem => sistemKoyu,
  TemaAyari.acik => false,
  TemaAyari.koyu => true,
};
