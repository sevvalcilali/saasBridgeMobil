import '../veri/modeller.dart';
import 'kart_no.dart';
import 'metin.dart';

// Etkinlik raporu ve kişiye özel rapor hesapları (web `src/api/rapor.js` ile aynı kurallar). Kaynak: kayıt defteri
// (`/api/people`, ayrılanlar dahil) + görüşme kayıtları (`/api/sessions`). Saf Dart.

/// Görüşme kaydı: a/b kişi kimliği (kisiId ya da kayıtsız "kart:N"); start/end etkinlik saniyesi; sürende end null.
class Oturum {
  const Oturum(this.a, this.b, this.start, this.end);

  final String a;
  final String b;
  final double start;
  final double? end;

  bool get suruyor => end == null;

  int sureSn(double simdi) {
    final s = (end ?? simdi) - start;
    return s < 0 ? 0 : s.round();
  }

  static Oturum ayristir(Map<String, dynamic> ham) => Oturum(
    ham['a'] as String,
    ham['b'] as String,
    ((ham['start'] as num?) ?? 0).toDouble(),
    (ham['end'] as num?)?.toDouble(),
  );
}

const _karsiRol = {Rol.yatirimci: Rol.girisimci, Rol.girisimci: Rol.yatirimci};
bool _karsiRolMu(Katilimci? x, Katilimci? y) => x != null && y != null && _karsiRol[x.rol] == y.rol;

/// Kayıtsız kart için yer tutucu ("kart:14" → "Kart 14 (kayıtsız)", rolü yok).
Katilimci kimlikKisisi(String kimlik) {
  final no = kimlik.startsWith('kart:') ? kimlik.substring(5) : kimlik;
  return Katilimci(kisiId: kimlik, ad: 'Kart $no (kayıtsız)', rol: Rol.misafir, renk: KisiRengi.gri);
}

bool kayitsizMi(String kimlik) => kimlik.startsWith('kart:');

/// Geldi: kart aldı ya da alıp ayrıldı.
bool geldi(Katilimci k) => k.atananKart != null || k.ayrildi;

/// "Kart 14" / "ayrıldı" / "kart almadı".
String kisiDurumYazisi(Katilimci k) => k.atananKart != null ? 'Kart ${k.atananKart}' : (k.ayrildi ? 'ayrıldı' : 'kart almadı');

/// Etkinlik saniyesi → saat "HH:MM" (`/state.clock` ve `elapsed` aynı andan).
String etkinlikSaati(num sn, String saat, num elapsed) {
  final p = saat.split(':').map(int.tryParse).toList();
  final simdi = (p[0] ?? 0) * 3600 + (p.length > 1 ? p[1] ?? 0 : 0) * 60 + (p.length > 2 ? p[2] ?? 0 : 0);
  final gun = ((simdi - elapsed + sn) % 86400 + 86400) % 86400;
  String iki(num n) => n.floor().toString().padLeft(2, '0');
  return '${iki(gun / 3600)}:${iki((gun % 3600) / 60)}';
}

class RaporOzeti {
  const RaporOzeti({required this.gorusme, required this.suren, required this.karmaSn, required this.ulasan, required this.girisimci, required this.kisi});

  final int gorusme;
  final int suren;

  /// Yatırımcı–girişimci görüşmelerinin toplam süresi.
  final int karmaSn;

  /// En az bir yatırımcıyla görüşen girişimci sayısı.
  final int ulasan;
  final int girisimci;
  final int kisi;
}

class _KisiToplami {
  int toplamSn = 0;
  int adet = 0;
  final esler = <String>{};
  final karsiEsler = <String, int>{};
}

Map<String, _KisiToplami> _topla(Map<String, Katilimci> harita, List<Oturum> oturumlar, double simdi) {
  final top = <String, _KisiToplami>{};
  for (final o in oturumlar) {
    final sure = o.sureSn(simdi);
    final karsi = _karsiRolMu(harita[o.a], harita[o.b]);
    for (final (ben, es) in [(o.a, o.b), (o.b, o.a)]) {
      final t = top.putIfAbsent(ben, _KisiToplami.new);
      t.toplamSn += sure;
      t.adet++;
      t.esler.add(es);
      if (karsi) t.karsiEsler[es] = (t.karsiEsler[es] ?? 0) + sure;
    }
  }
  return top;
}

RaporOzeti raporOzeti(List<Katilimci> kisiler, List<Oturum> oturumlar, double simdi) {
  final harita = {for (final k in kisiler) k.kisiId: k};
  final top = _topla(harita, oturumlar, simdi);
  var karmaSn = 0;
  for (final o in oturumlar) {
    if (_karsiRolMu(harita[o.a], harita[o.b])) karmaSn += o.sureSn(simdi);
  }
  final girisimciler = kisiler.where((k) => k.rol == Rol.girisimci).toList();
  return RaporOzeti(
    gorusme: oturumlar.length,
    suren: oturumlar.where((o) => o.suruyor).length,
    karmaSn: karmaSn,
    ulasan: girisimciler.where((g) => (top[g.kisiId]?.karsiEsler.isNotEmpty) ?? false).length,
    girisimci: girisimciler.length,
    kisi: kisiler.length,
  );
}

class RaporEsi {
  const RaporEsi({required this.kisi, required this.toplamSn, this.adet = 1});

  final Katilimci kisi;
  final int toplamSn;
  final int adet;
}

class GirisimciSatiri {
  const GirisimciSatiri({required this.kisi, required this.yatirimcilar});

  final Katilimci kisi;

  /// Süreye göre azalan.
  final List<RaporEsi> yatirimcilar;

  int get yatirimciSn => yatirimcilar.fold(0, (t, y) => t + y.toplamSn);
}

int _adSirasi(Katilimci p, Katilimci q) => trKucuk(katilimciAdi(p)).compareTo(trKucuk(katilimciAdi(q)));

/// Girişimciler: ulaştığı yatırımcı sayısı, sonra süre, sonra ad.
List<GirisimciSatiri> girisimciSatirlari(List<Katilimci> kisiler, List<Oturum> oturumlar, double simdi) {
  final harita = {for (final k in kisiler) k.kisiId: k};
  final top = _topla(harita, oturumlar, simdi);
  final satirlar = [
    for (final k in kisiler)
      if (k.rol == Rol.girisimci)
        GirisimciSatiri(
          kisi: k,
          yatirimcilar: [
            for (final e in (top[k.kisiId]?.karsiEsler ?? const <String, int>{}).entries)
              if (harita[e.key] case final y?) RaporEsi(kisi: y, toplamSn: e.value),
          ]..sort((p, q) => q.toplamSn.compareTo(p.toplamSn)),
        ),
  ]..sort((p, q) {
      final sayi = q.yatirimcilar.length.compareTo(p.yatirimcilar.length);
      if (sayi != 0) return sayi;
      final sure = q.yatirimciSn.compareTo(p.yatirimciSn);
      return sure != 0 ? sure : _adSirasi(p.kisi, q.kisi);
    });
  return satirlar;
}

/// Yatırımcının ilgi alanları (virgül/noktalı virgülle) girişimin sektörünü içeriyor mu.
bool ilgiEslesir(String ilgiAlanlari, String sektor) {
  final hedef = trKucuk(sektor.trim());
  return hedef.isNotEmpty && ilgiAlanlari.split(RegExp('[,;]')).any((a) => trKucuk(a.trim()) == hedef);
}

class KisiRaporuOzeti {
  const KisiRaporuOzeti({required this.karsiSayisi, required this.karsiSn, required this.toplamSn});

  final int karsiSayisi;
  final int karsiSn;
  final int toplamSn;
}

class KisiRaporu {
  const KisiRaporu({required this.kisi, required this.karsi, required this.diger, required this.kacirilan, required this.ilgiAlaninda, required this.ozet});

  final Katilimci kisi;

  /// Karşı rolden görüştükleri (yatırımcıya girişimler, girişimciye yatırımcılar), en uzun önce.
  final List<RaporEsi> karsi;

  /// Diğer tanıştıkları.
  final List<RaporEsi> diger;

  /// Karşı rolden gelip hiç görüşmedikleri; yatırımcıda ilgi alanındakiler önde.
  final List<Katilimci> kacirilan;
  final Set<String> ilgiAlaninda;
  final KisiRaporuOzeti ozet;
}

KisiRaporu kisiRaporu(String kisiId, List<Katilimci> kisiler, List<Oturum> oturumlar, double simdi) {
  final harita = {for (final k in kisiler) k.kisiId: k};
  final kisi = harita[kisiId] ?? kimlikKisisi(kisiId);
  final esler = <String, ({Katilimci kisi, int toplamSn, int adet})>{};
  for (final o in oturumlar) {
    if (o.a != kisiId && o.b != kisiId) continue;
    final digerId = o.a == kisiId ? o.b : o.a;
    final karsi = harita[digerId];
    if (karsi == null) continue; // kayıtsız kart: kim olduğu bilinmiyor, katılımcıya gösterilmez
    final e = esler[digerId];
    esler[digerId] = (kisi: karsi, toplamSn: (e?.toplamSn ?? 0) + o.sureSn(simdi), adet: (e?.adet ?? 0) + 1);
  }
  final satirlar = [for (final e in esler.values) RaporEsi(kisi: e.kisi, toplamSn: e.toplamSn, adet: e.adet)]
    ..sort((p, q) {
      final sure = q.toplamSn.compareTo(p.toplamSn);
      return sure != 0 ? sure : _adSirasi(p.kisi, q.kisi);
    });
  final karsi = satirlar.where((x) => _karsiRolMu(kisi, x.kisi)).toList();
  final diger = satirlar.where((x) => !_karsiRolMu(kisi, x.kisi)).toList();
  bool ilgili(Katilimci k) => kisi.rol == Rol.yatirimci && ilgiEslesir(kisi.sektor, k.sektor);
  final kacirilan = [
    for (final k in kisiler)
      if (_karsiRol[kisi.rol] == k.rol && geldi(k) && !esler.containsKey(k.kisiId)) k,
  ]..sort((p, q) {
      final ilgi = (ilgili(q) ? 1 : 0).compareTo(ilgili(p) ? 1 : 0);
      return ilgi != 0 ? ilgi : _adSirasi(p, q);
    });
  int topla(List<RaporEsi> d) => d.fold(0, (t, x) => t + x.toplamSn);
  return KisiRaporu(
    kisi: kisi,
    karsi: karsi,
    diger: diger,
    kacirilan: kacirilan,
    ilgiAlaninda: {for (final k in kacirilan) if (ilgili(k)) k.kisiId},
    ozet: KisiRaporuOzeti(karsiSayisi: karsi.length, karsiSn: topla(karsi), toplamSn: topla(satirlar)),
  );
}
