import '../mantik/gruplar.dart';
import 'modeller.dart';

/// Sunucunun `/state` (ve `/events` mesajı) JSON'unu uygulama modellerine çevirir.
/// Sözleşme: SaasBridge `SUNUCUDAN_ISTENENLER.md`, web `src/api/client.js durumIsle`.
/// Saf Dart; ağ bilmez. Sunucu bir çifti ancak 1 dk yan yana kalınca "birlikte" sayar,
/// süreler sunucuda akar: burada yerel sayaç yoktur (`tick` hep 0).
class SunucuDurumu {
  const SunucuDurumu({
    required this.kisiler,
    required this.bildirimler,
    required this.ciftler,
    required this.etkinlikAdi,
    required this.tarihMekan,
    required this.saatSn,
    required this.esik,
    required this.aliciBagli,
    required this.canliCiftSayisi,
    required this.canliCiftler,
    required this.gunBoyu,
  });

  final List<Kisi> kisiler;

  /// En yeni başta (sunucu en eskiyi başa koyar).
  final List<Bildirim> bildirimler;

  /// Ölçülen sinyal çiftleri (Kurulum grafiği ve "eşiğin üstünde N çift").
  final List<Cift> ciftler;
  final String etkinlikAdi;
  final String tarihMekan;

  /// Sunucu saati, günün saniyesi.
  final int saatSn;
  final int esik;
  final bool aliciBagli;
  final int canliCiftSayisi;
  final List<CanliCift> canliCiftler;

  /// Çiftlerin bugünkü toplam süreleri (kişi detayı "Bugün kiminle").
  final List<GunBoyuCift> gunBoyu;

  /// `receiverAge` (sn) bundan büyükse alıcı kopuk sayılır.
  static const double aliciEnCokYasSn = 5;

  /// Kart no 100 ve üstü dinleyici cihazdır, kişi değildir.
  static bool kisiKartiMi(String id) => (int.tryParse(id) ?? 1000) < 100;

  static SunucuDurumu ayristir(Map<String, dynamic> ham, {Map<String, int> piller = const {}}) {
    final canli = (ham['live'] as List? ?? const []).cast<Map<String, dynamic>>();
    final es = <String, String>{};
    for (final c in canli) {
      final a = c['a'] as String;
      final b = c['b'] as String;
      es.putIfAbsent(a, () => b);
      es.putIfAbsent(b, () => a);
    }
    final kisiler = <Kisi>[
      for (final k in (ham['people'] as List? ?? const []).cast<Map<String, dynamic>>())
        if (kisiKartiMi(k['id'] as String)) _kisi(k, es, piller),
    ];
    final bildirimler = <Bildirim>[
      for (final b in (ham['alerts'] as List? ?? const []).cast<Map<String, dynamic>>()) _bildirim(b),
    ].reversed.toList();
    final ciftler = <Cift>[
      for (final s in (ham['signals'] as List? ?? const []).cast<Map<String, dynamic>>())
        if (kisiKartiMi(s['a'] as String) && kisiKartiMi(s['b'] as String))
          Cift(s['a'] as String, s['b'] as String, (s['value'] as num).round()),
    ];
    final etkinlik = (ham['event'] as Map?)?.cast<String, dynamic>() ?? const {};
    final alici = ham['receiverAge'] as num?;
    return SunucuDurumu(
      kisiler: kisiler,
      bildirimler: bildirimler,
      ciftler: ciftler,
      etkinlikAdi: etkinlik['name'] as String? ?? '',
      tarihMekan: etkinlik['date'] as String? ?? '',
      saatSn: _saatSn(ham['clock'] as String? ?? ''),
      esik: (ham['threshold'] as num?)?.round() ?? -72,
      aliciBagli: alici != null && alici <= aliciEnCokYasSn,
      canliCiftSayisi: canli.length,
      canliCiftler: [
        for (final c in canli)
          if (kisiKartiMi(c['a'] as String) && kisiKartiMi(c['b'] as String)) CanliCift(c['a'] as String, c['b'] as String),
      ],
      gunBoyu: [
        for (final e in (ham['edges'] as List? ?? const []).cast<Map<String, dynamic>>())
          if (kisiKartiMi(e['a'] as String) && kisiKartiMi(e['b'] as String))
            GunBoyuCift(e['a'] as String, e['b'] as String, (((e['min'] as num?) ?? 0) * 60).round()),
      ],
    );
  }

  static Kisi _kisi(Map<String, dynamic> k, Map<String, String> es, Map<String, int> piller) {
    final id = k['id'] as String;
    final ad = k['name'] as String? ?? '';
    final kurum = k['org'] as String? ?? '';
    final durum = k['status'] as String? ?? 'idle';
    final goruyor = durum == 'talking';
    final canliDk = (k['live'] as num?) ?? 0;
    final toplamDk = (k['min'] as num?) ?? 0;
    final adsiz = ad.isEmpty || ad == 'Kart $id';
    return Kisi(
      id: id,
      ad: adsiz ? null : ad,
      kurum: kurum.isEmpty ? null : kurum,
      rol: _rol(k['role'] as String?),
      renk: sunucuRengi(k['color'] as String?),
      pil: piller[id],
      ile: goruyor ? es[id] : null,
      sn: ((goruyor ? canliDk : toplamDk) * 60).round(),
      yildiz: (k['tier'] as num?)?.toInt() ?? 0,
      gorunmuyor: durum == 'away',
      hic: !goruyor && toplamDk == 0,
      bostaSn: ((k['idleSinceS'] as num?) ?? 0).round(),
    );
  }

  static Bildirim _bildirim(Map<String, dynamic> b) => Bildirim(
    baslik: b['title'] as String? ?? '',
    detay: b['detail'] as String? ?? '',
    saat: b['clock'] as String? ?? '',
    onem: _onem(b['severity'] as String?),
    kisiler: (b['people'] as List? ?? const []).cast<String>(),
    t: ((b['t'] as num?) ?? 0).toDouble(),
  );

  static Rol _rol(String? rol) => switch (rol) {
    'investor' => Rol.yatirimci,
    'founder' => Rol.girisimci,
    _ => Rol.misafir,
  };

  // Web ile aynı (src/api/bildirim.js): deal olumlu, warn uyarı, serious ciddi, kural kural.
  static Onem _onem(String? onem) => switch (onem) {
    'deal' => Onem.olumlu,
    'serious' => Onem.ciddi,
    'kural' => Onem.kural,
    _ => Onem.uyari,
  };

  static int _saatSn(String saat) {
    final p = saat.split(':').map(int.tryParse).toList();
    if (p.length < 2 || p.any((x) => x == null)) return 0;
    return p[0]! * 3600 + p[1]! * 60 + (p.length > 2 ? p[2]! : 0);
  }
}

/// Sunucunun kişi rengi (hex) → uygulama paleti. Web `src/api/renkler.js` ile aynı tablo;
/// #199e70 petrole eşlenir (yeşil yalnız "birlikte" demektir). Bilinmeyen renk gri.
KisiRengi sunucuRengi(String? hex) => switch (hex?.toLowerCase()) {
  '#3987e5' => KisiRengi.mavi,
  '#d95926' => KisiRengi.turuncu,
  '#199e70' => KisiRengi.petrol,
  '#c98500' => KisiRengi.hardal,
  '#d55181' => KisiRengi.pembe,
  '#9085e9' => KisiRengi.mor,
  '#e66767' => KisiRengi.mercan,
  _ => KisiRengi.gri,
};

/// `/api/people` kaydı → kayıtlı kişi (sözleşme §1).
Katilimci katilimciAyristir(Map<String, dynamic> k) => Katilimci(
  kisiId: k['kisiId'] as String,
  ad: k['ad'] as String? ?? '',
  kurum: (k['kurum'] as String?)?.isEmpty ?? true ? null : k['kurum'] as String,
  rol: switch (k['rol'] as String?) { 'investor' => Rol.yatirimci, 'founder' => Rol.girisimci, _ => Rol.misafir },
  renk: sunucuRengi(k['renk'] as String?),
  yildiz: (k['yildiz'] as num?)?.toInt() ?? 0,
  atananKart: k['atananKart'] as String?,
  ayrildi: k['ayrildi'] as bool? ?? false,
);
