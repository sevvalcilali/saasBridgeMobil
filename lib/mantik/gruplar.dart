import '../veri/modeller.dart';

// Salon görünümü (web `src/api/gruplar.js` ile aynı kurallar): şu an yan yana olan kişiler küme küme.
// Gruplar sunucunun canlı çiftlerinden çıkar: A–B ve B–C birlikteyse A, B, C aynı gruptadır. Sunucu bir
// çifti ancak 1 dk yan yana kalınca "birlikte" sayar, 15 sn ayrı kalınca bitirir; gruplar bu yüzden
// sakindir. Kümelerin ekrandaki yeri salondaki yeri DEĞİLDİR; yerler yalnız ekranda sabit kalsın diye tutulur.

/// Şu an birlikte olan kart çifti (sunucunun `live`'ı).
class CanliCift {
  const CanliCift(this.a, this.b);

  final String a;
  final String b;
}

class Grup {
  const Grup({required this.anahtar, required this.uyeler, required this.karma, required this.sn});

  /// Üye kart no'ları birleşik ("2-3-4"); yer kararlılığı için kimlik.
  final String anahtar;

  /// Yatırımcı → girişimci → misafir, sonra kart no sırasıyla.
  final List<Kisi> uyeler;

  /// Yatırımcı ile girişimci buluştu (etkinliğin amacı): zemin yeşil.
  final bool karma;

  /// Gruptaki en uzun görüşme (saniye).
  final int sn;
}

const _rolSirasi = {Rol.yatirimci: 0, Rol.girisimci: 1, Rol.misafir: 2};
int _noSirasi(String a, String b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0);

/// Canlı çiftlerden gruplar; en küçük kart no'lu grup başta.
List<Grup> canliGruplar(List<Kisi> kisiler, List<CanliCift> ciftler) {
  final kisi = {for (final k in kisiler) k.id: k};
  final ebeveyn = <String, String>{};
  String kok(String x) {
    while (ebeveyn[x] != x) {
      ebeveyn[x] = ebeveyn[ebeveyn[x]!]!;
      x = ebeveyn[x]!;
    }
    return x;
  }

  for (final c in ciftler) {
    if (!kisi.containsKey(c.a) || !kisi.containsKey(c.b)) continue; // kişisi olmayan kart (100+ dinleyici)
    ebeveyn.putIfAbsent(c.a, () => c.a);
    ebeveyn.putIfAbsent(c.b, () => c.b);
    ebeveyn[kok(c.a)] = kok(c.b);
  }
  final kumeler = <String, List<String>>{};
  for (final id in ebeveyn.keys) {
    kumeler.putIfAbsent(kok(id), () => []).add(id);
  }
  final gruplar = <Grup>[];
  for (final idler in kumeler.values) {
    idler.sort(_noSirasi);
    final uyeler = [for (final id in idler) kisi[id]!]
      ..sort((x, y) {
        final rol = _rolSirasi[x.rol]!.compareTo(_rolSirasi[y.rol]!);
        return rol != 0 ? rol : _noSirasi(x.id, y.id);
      });
    final roller = uyeler.map((u) => u.rol).toSet();
    gruplar.add(Grup(
      anahtar: idler.join('-'),
      uyeler: uyeler,
      karma: roller.contains(Rol.yatirimci) && roller.contains(Rol.girisimci),
      sn: uyeler.fold(0, (en, u) => u.sn > en ? u.sn : en),
    ));
  }
  gruplar.sort((x, y) => _noSirasi(x.anahtar.split('-').first, y.anahtar.split('-').first));
  return gruplar;
}

/// Sunucunun "önemli yatırımcı yalnız" kuralı: ★3+ yatırımcı 6 dk kimseyle görüşmedi.
const int yalnizSn = 360;
const int yalnizEnAzYildiz = 3;
bool yalnizMi(Kisi k) => k.rol == Rol.yatirimci && k.yildiz >= yalnizEnAzYildiz && k.bostaSn >= yalnizSn;

/// Grupta olmayanlar: boşta (önce yalnız kalan önemli yatırımcı, sonra en uzun boşta) ve görünmeyenler.
({List<Kisi> bosta, List<Kisi> gorunmeyen}) bostakiler(List<Kisi> kisiler, List<Grup> gruplar) {
  final grupta = {for (final g in gruplar) for (final u in g.uyeler) u.id};
  final disarida = [for (final k in kisiler) if (!grupta.contains(k.id)) k];
  final bosta = [for (final k in disarida) if (!k.gorunmuyor) k].indexed.toList()
    ..sort((x, y) {
      final yalniz = (yalnizMi(y.$2) ? 1 : 0).compareTo(yalnizMi(x.$2) ? 1 : 0);
      if (yalniz != 0) return yalniz;
      final bos = y.$2.bostaSn.compareTo(x.$2.bostaSn);
      return bos != 0 ? bos : x.$1.compareTo(y.$1);
    });
  return (bosta: [for (final x in bosta) x.$2], gorunmeyen: [for (final k in disarida) if (k.gorunmuyor) k]);
}

/// Küme: (arka sıra, ön sıra) kişi sayısı. 2 kişi yan yana, 3 üçgen, 5'te arkada 2 önde 3.
(int, int) grupSiralari(int n) {
  final arka = n <= 2 ? 0 : n ~/ 2;
  return (arka, n - arka);
}

/// Figürün rengi = o kişinin görüşme süresi; yalnız sınır geçilince değişir (sakin). Ölçek
/// gri → mavi → turuncu → kırmızı (Şevval kararı 06.10.2026). Renk hep yazılı süreyle birlikte.
enum SureRengi { gri, mavi, turuncu, kirmizi }

const sureSinirlari = [(SureRengi.gri, 0), (SureRengi.mavi, 300), (SureRengi.turuncu, 600), (SureRengi.kirmizi, 1200)];
const sureEtiketleri = {SureRengi.gri: '1–5 dk', SureRengi.mavi: '5–10 dk', SureRengi.turuncu: '10–20 dk', SureRengi.kirmizi: '20 dk+'};

SureRengi sureRengi(int sn) => sureSinirlari.lastWhere((s) => sn >= s.$2).$1;

int _ozet(String id) => id.codeUnits.fold(7, (t, c) => (t * 31 + c) & 0x7fffffff);

/// Figürün duruşu kişiye göre sabit (0 kollar yanda, 1 el kalkık, 2 elinde bardak): her tikte aynı figür.
int siluetPozu(String id) => _ozet(id) % 3;

/// Kümeleri ekranda sabit yerlere koyar. `yerler`: önceki çizimde her yerdeki grubun üyeleri (null = boş).
/// Bir grup, üyelerinin çoğunun önceden durduğu yere oturur (büyüse de küçülse de kaymaz); yeni grup ilk boş
/// yere; biten grubun yeri boş kalır (sağdakiler kaymasın). Sondaki boşluklar atılır.
({List<Set<String>?> yerler, Map<String, int> atama}) yerlestir(List<Set<String>?> yerler, List<Grup> gruplar) {
  final adaylar = <(int gi, int yi, int ortak)>[];
  for (final (gi, g) in gruplar.indexed) {
    for (final (yi, onceki) in yerler.indexed) {
      if (onceki == null) continue;
      final ortak = g.uyeler.where((u) => onceki.contains(u.id)).length;
      if (ortak > 0) adaylar.add((gi, yi, ortak));
    }
  }
  adaylar.sort((x, y) => y.$3 != x.$3 ? y.$3.compareTo(x.$3) : x.$2.compareTo(y.$2));
  final grubunYeri = <int, int>{};
  final dolu = <int>{};
  for (final (gi, yi, _) in adaylar) {
    if (grubunYeri.containsKey(gi) || dolu.contains(yi)) continue;
    grubunYeri[gi] = yi;
    dolu.add(yi);
  }
  var bos = 0;
  for (var gi = 0; gi < gruplar.length; gi++) {
    if (grubunYeri.containsKey(gi)) continue;
    while (dolu.contains(bos)) {
      bos++;
    }
    grubunYeri[gi] = bos;
    dolu.add(bos);
  }
  final uzunluk = dolu.isEmpty ? 0 : dolu.reduce((a, b) => a > b ? a : b) + 1;
  final yeni = List<Set<String>?>.filled(uzunluk, null);
  final atama = <String, int>{};
  for (final (gi, g) in gruplar.indexed) {
    final yi = grubunYeri[gi]!;
    yeni[yi] = {for (final u in g.uyeler) u.id};
    atama[g.anahtar] = yi;
  }
  return (yerler: yeni, atama: atama);
}
