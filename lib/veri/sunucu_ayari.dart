import 'package:shared_preferences/shared_preferences.dart';

import '../mantik/sunucu_adresi.dart';
import 'etkinlik_deposu.dart';
import 'sunucu_deposu.dart';
import 'sunucu_istemcisi.dart';

/// Sunucu adresi ayarı: telefonda kalıcı (shared_preferences). Hiç kaydedilmemişse derleme değişkeni
/// (`flutter run --dart-define=SUNUCU=http://192.168.1.10:8002`); o da yoksa boş = sahte veri.
abstract final class SunucuAyari {
  static const _anahtar = 'sunucuAdresi';
  static const String derlemeAdresi = String.fromEnvironment('SUNUCU');

  static Future<String> oku() async {
    final p = await SharedPreferences.getInstance();
    return sunucuAdresiDuzelt(p.getString(_anahtar) ?? derlemeAdresi);
  }

  static Future<void> yaz(String adres) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_anahtar, adres);
  }
}

/// Adrese göre depo: boşsa sahte veri, değilse gerçek sunucu.
EtkinlikDeposu depoKur(String adres) =>
    adres.isEmpty ? EtkinlikDeposu() : SunucuDeposu(SunucuIstemcisi(adres));
