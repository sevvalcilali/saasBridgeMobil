import 'dart:async';

import '../mantik/bicim.dart';
import '../mantik/gruplar.dart';
import '../mantik/kurulum.dart';
import 'etkinlik_deposu.dart';
import 'modeller.dart';
import 'sunucu_durumu.dart';
import 'sunucu_istemcisi.dart';

/// Gerçek sunucuya bağlı depo. Açılışta `/state`, sonra `/events` canlı akışı (~2 Hz): süreler ve saat
/// sunucudan gelir, yerel sayaç yoktur. Kopunca son veri kalır, `sunucuBagli` false olur; istemci
/// kendiliğinden yeniden bağlanır. Kartlar (pil, boştakiler) ve kayıtlı kişi sayısı `/api/cards` ve
/// `/api/people`'dan seyrek yoklanır.
class SunucuDeposu extends EtkinlikDeposu {
  SunucuDeposu(this._istemci, {this.yoklamaAraligi = const Duration(seconds: 10)}) : super.temel();

  final SunucuIstemcisi _istemci;
  final Duration yoklamaAraligi;

  SunucuDurumu? _durum;
  bool _bagli = false;
  Map<String, dynamic>? _hamDurum;
  List<Map<String, dynamic>> _kartlar = const [];
  int _kayitli = 0;
  int? _esikYerel; // kaydırıcı bırakılınca hemen görünsün; sunucu doğrulayınca kalkar
  StreamSubscription<SunucuOlayi>? _abonelik;
  Timer? _yoklama;

  /// Kart no → pil (son `/api/cards`).
  Map<String, int> get _piller => {
    for (final k in _kartlar)
      if (k['pil'] is num) k['kart'] as String: (k['pil'] as num).toInt(),
  };

  @override
  bool get sunucuBagli => _bagli;
  @override
  bool get aliciBagli => _durum?.aliciBagli ?? false;
  @override
  List<Bildirim> get bildirimler => _durum?.bildirimler ?? const [];
  @override
  String get etkinlikAdi => _durum?.etkinlikAdi ?? '';
  @override
  String get tarihMekan => _durum?.tarihMekan ?? '';
  @override
  String get raporTarihi {
    final s = DateTime.now();
    return '${s.day.toString().padLeft(2, '0')}.${s.month.toString().padLeft(2, '0')}.${s.year}';
  }

  /// Etkinliğin başı = sunucu saati − geçen süre (`elapsed`).
  @override
  String get cizelgeBaslangici {
    final d = _durum;
    if (d == null) return '—';
    final gecen = ((_hamDurum?['elapsed'] as num?) ?? 0).round();
    return kisaSaatYazisi((d.saatSn - gecen).clamp(0, 24 * 3600 - 1));
  }

  @override
  int get duyulanKartSayisi => _kartlar.length;
  @override
  int get kayitliKatilimci => _kayitli;
  @override
  List<Kisi> get kisiler => _durum?.kisiler ?? const [];
  @override
  List<CanliCift> get canliCiftler => _durum?.canliCiftler ?? const [];
  @override
  List<Cift> get ciftler => _durum?.ciftler ?? const [];

  /// Grafikteki en güçlü çiftlerin rengi: çiftin ilk kişisinin rengi.
  @override
  List<KisiRengi> get seriRenkleri {
    final renk = {for (final k in kisiler) k.id: k.renk};
    final sirali = [...ciftler]..sort((a, b) => b.rssi.compareTo(a.rssi));
    return [for (final c in sirali.take(6)) renk[c.a] ?? KisiRengi.gri];
  }

  /// Alıcının şu an duyduğu kartlar (≤ 8 sn).
  @override
  List<AcikKart> get acikKartlar => [
    for (final k in _kartlar)
      if (((k['seenAgo'] as num?) ?? 999) <= 8) AcikKart(k['kart'] as String, atanmis: k['atanan'] != null),
  ];

  @override
  int get tick => 0;
  @override
  int get saatSn => _durum?.saatSn ?? 0;
  @override
  int get esik => _esikYerel ?? _durum?.esik ?? -72;

  @override
  Kisi bul(String id) => kisiler.firstWhere(
    (k) => k.id == id,
    orElse: () => Kisi(id: id, rol: Rol.misafir, renk: KisiRengi.gri),
  );

  @override
  List<({Kisi kisi, int sn})> gunBoyu(String id) {
    final liste = [
      for (final c in _durum?.gunBoyu ?? const <GunBoyuCift>[])
        if (c.a == id) (kisi: bul(c.b), sn: c.sn) else if (c.b == id) (kisi: bul(c.a), sn: c.sn),
    ]..sort((x, y) => y.sn.compareTo(x.sn));
    return liste;
  }

  @override
  void baslat() {
    if (_abonelik != null) return;
    _istemci.durumAl().then(_durumAyarla, onError: (_) {});
    _abonelik = _istemci.olaylar().listen((olay) {
      switch (olay) {
        case Baglandi():
          _bagli = true;
          notifyListeners();
        case DurumGeldi(:final durum):
          _durumAyarla(durum);
        case Koptu():
          if (!_bagli) return;
          _bagli = false;
          notifyListeners();
      }
    });
    _yokla();
    _yoklama = Timer.periodic(yoklamaAraligi, (_) => _yokla());
  }

  @override
  void durdur() {
    _abonelik?.cancel();
    _abonelik = null;
    _yoklama?.cancel();
    _yoklama = null;
    _istemci.akisiKes();
    if (_bagli) {
      _bagli = false;
      notifyListeners();
    }
  }

  void _durumAyarla(Map<String, dynamic> ham) {
    _hamDurum = ham;
    _durum = SunucuDurumu.ayristir(ham, piller: _piller);
    if (_esikYerel != null && _durum!.esik == _esikYerel) _esikYerel = null;
    _bagli = true;
    notifyListeners();
  }

  Future<void> _yokla() async {
    try {
      final kartlar = await _istemci.kartlar();
      final kisiler = await _istemci.kisiler();
      _kartlar = kartlar;
      _kayitli = kisiler.length;
      final ham = _hamDurum;
      if (ham != null) _durum = SunucuDurumu.ayristir(ham, piller: _piller);
      notifyListeners();
    } catch (_) {
      /* sonraki yoklamada yeniden denenir; bant akışa bağlıdır */
    }
  }

  @override
  Future<void> sifirla() async {
    await _istemci.sifirla();
  }

  @override
  void esikAyarla(int deger) {
    final yeni = esikSinirla(deger);
    if (yeni == esik) return;
    _esikYerel = yeni;
    notifyListeners();
    _istemci.esikGonder(yeni);
  }

  @override
  void dispose() {
    durdur();
    _istemci.kapat();
    super.dispose();
  }
}
