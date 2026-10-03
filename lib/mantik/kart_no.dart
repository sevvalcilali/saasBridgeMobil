import '../veri/modeller.dart';
import 'metin.dart';

// Karşılama masası kuralları: kart numarası ve kayıtlı kişi araması.

/// Kişi kartları 1–99'dur; 100 ve üstü dinleyici cihazdır.
const int kartEnBuyuk = 99;

final RegExp _bastakiSifirlar = RegExp(r'^0+');
final RegExp _yalnizRakam = RegExp(r'^[0-9]+$');
final RegExp _rakamDisi = RegExp(r'[^0-9]');

/// Baştaki sıfırları atar: "007" → "7".
String numaraTemizle(String girdi) => girdi.replaceFirst(_bastakiSifirlar, '');

/// Elle yazılan kart numarası geçerli mi: yalnız rakam ve 1–99.
bool numaraGecerli(String girdi) {
  final temiz = numaraTemizle(girdi);
  if (!_yalnizRakam.hasMatch(temiz)) return false;
  final n = int.tryParse(temiz);
  return n != null && n >= 1 && n <= kartEnBuyuk;
}

/// Rakam dışındaki her şeyi atar.
String yalnizRakam(String girdi) => girdi.replaceAll(_rakamDisi, '');

/// "Şu an açık kartlar" ızgarası: girilen numarayla başlayanlar (boş girdi → hepsi).
List<AcikKart> acikKartOner(List<AcikKart> kartlar, String numara) {
  if (numara.isEmpty) return kartlar;
  final onEk = numaraTemizle(numara);
  return [
    for (final k in kartlar)
      if (k.no.startsWith(onEk)) k,
  ];
}

String acikKartEtiketi(AcikKart k) => k.atanmis ? 'atanmış' : 'boşta';

/// Kayıtlı (adı olan) kişilerde ad, kurum ve kart no araması.
/// Kart Ver adım 1 ve Kart İadesi listesi bunu kullanır.
List<Kisi> masaAra(List<Kisi> kisiler, String arama) {
  final q = trKucuk(arama.trim());
  return [
    for (final k in kisiler)
      if (k.ad != null && (q.isEmpty || trKucuk('${k.kurum ?? ''} ${k.ad} ${k.id}').contains(q))) k,
  ];
}
