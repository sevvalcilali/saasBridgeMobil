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

/// Kayıtlı kişilerde ad, kurum ve kart no araması (ayrılanlar listelenmez).
/// Kart Ver adım 1 ve Kart İadesi listesi bunu kullanır; `yalnizKartli`: İade (kartı olanlar).
List<Katilimci> masaAra(List<Katilimci> kisiler, String arama, {bool yalnizKartli = false, bool yalnizBekleyen = false}) {
  final q = trKucuk(arama.trim());
  return [
    for (final k in kisiler)
      if (!k.ayrildi &&
          (!yalnizKartli || k.atananKart != null) &&
          (!yalnizBekleyen || k.kartBekliyor) &&
          (q.isEmpty || trKucuk('${k.kurum ?? ''} ${k.ad} ${k.atananKart ?? ''}').contains(q)))
        k,
  ];
}

/// "Kurum · Ad" ya da yalnız ad.
String katilimciAdi(Katilimci k) => k.kurum != null ? '${k.kurum} · ${k.ad}' : k.ad;

/// Kişi kartındaki ikinci satır: "Kart 24 · ★★★★" / "Kart bekliyor" / "Ayrıldı".
String katilimciKartMetni(Katilimci k) {
  final kart = k.atananKart;
  final metin = kart == null ? (k.ayrildi ? 'Ayrıldı' : 'Kart bekliyor') : 'Kart $kart';
  return k.yildiz > 0 ? '$metin · ${'★' * k.yildiz}' : metin;
}

/// "Yaklaştır ve tanı" (sözleşme §3): alıcıya −55 dBm'den güçlü duyulan tek boş kart bulunmuş sayılır;
/// iki ve daha çoksa "birini uzaklaştırın".
const int yaklastirmaEsigi = -55;

({String? kart, String? uyari}) yaklastirilanKart(List<AcikKart> kartlar) {
  final yakin = [
    for (final k in kartlar)
      if (!k.atanmis && (k.rssi ?? -999) > yaklastirmaEsigi && k.seenAgo <= 8) k.no,
  ];
  if (yakin.length == 1) return (kart: yakin.single, uyari: null);
  if (yakin.length > 1) return (kart: null, uyari: 'Birden çok kart yakın (${yakin.join(', ')}); birini uzaklaştırın.');
  return (kart: null, uyari: null);
}
