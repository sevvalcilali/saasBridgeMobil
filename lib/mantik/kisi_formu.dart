import '../veri/modeller.dart';

// Kişi formu (web `KisiFormu.jsx` + `masaYardim.js` ile aynı kurallar): yeni kişi ve düzenleme aynı alanlar.
// Ad ve rol zorunlu. Gönderimde yıldız yalnız yatırımcıda, aşama yalnız girişimcide; metinler kırpılır.
// Düzenlemede yalnız değişen alanlar gider; renk ve kimlik hiç gönderilmez (sözleşme §1). Saf Dart.

const asamalar = [('fikir', 'Fikir'), ('mvp', 'MVP'), ('gelir', 'Gelir'), ('buyume', 'Büyüme')];

const rolDegeri = {Rol.yatirimci: 'investor', Rol.girisimci: 'founder', Rol.misafir: 'guest'};

class KisiFormVerisi {
  const KisiFormVerisi({
    required this.ad,
    required this.rol,
    this.kurum = '',
    this.yildiz = 0,
    this.notu = '',
    this.sektor = '',
    this.asama = '',
    this.tanitim = '',
    this.web = '',
    this.eposta = '',
    this.paylasim = false,
  });

  factory KisiFormVerisi.katilimcidan(Katilimci k) => KisiFormVerisi(
    ad: k.ad,
    rol: k.rol,
    kurum: k.kurum ?? '',
    yildiz: k.yildiz,
    notu: k.notu,
    sektor: k.sektor,
    asama: k.asama,
    tanitim: k.tanitim,
    web: k.web,
    eposta: k.eposta,
    paylasim: k.paylasim,
  );

  final String ad;
  final Rol rol;
  final String kurum;
  final int yildiz;
  final String notu;
  final String sektor;
  final String asama;
  final String tanitim;
  final String web;
  final String eposta;
  final bool paylasim;

  bool get gecerli => ad.trim().isNotEmpty;

  KisiFormVerisi copyWith({
    String? ad,
    Rol? rol,
    String? kurum,
    int? yildiz,
    String? notu,
    String? sektor,
    String? asama,
    String? tanitim,
    String? web,
    String? eposta,
    bool? paylasim,
  }) => KisiFormVerisi(
    ad: ad ?? this.ad,
    rol: rol ?? this.rol,
    kurum: kurum ?? this.kurum,
    yildiz: yildiz ?? this.yildiz,
    notu: notu ?? this.notu,
    sektor: sektor ?? this.sektor,
    asama: asama ?? this.asama,
    tanitim: tanitim ?? this.tanitim,
    web: web ?? this.web,
    eposta: eposta ?? this.eposta,
    paylasim: paylasim ?? this.paylasim,
  );

  /// `POST /api/people` gövdesi.
  Map<String, Object?> govde() => {
    'ad': ad.trim(),
    'rol': rolDegeri[rol],
    'kurum': kurum.trim(),
    'yildiz': rol == Rol.yatirimci ? yildiz.clamp(0, 5) : 0,
    'not': notu.trim(),
    'sektor': sektor.trim(),
    'asama': rol == Rol.girisimci ? asama : '',
    'tanitim': tanitim.trim(),
    'web': web.trim(),
    'eposta': eposta.trim(),
    'paylasim': paylasim,
  };
}

/// Düzenlemede yalnız değişen alanlar (`PATCH`).
Map<String, Object?> duzenlemeFarki(Katilimci k, KisiFormVerisi form) {
  final eski = KisiFormVerisi.katilimcidan(k).govde();
  final yeni = form.govde();
  return {for (final e in yeni.entries) if (eski[e.key] != e.value) e.key: e.value};
}
