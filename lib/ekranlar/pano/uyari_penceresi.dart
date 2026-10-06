import 'package:flutter/material.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../mantik/uyari.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Açılır kural uyarılarının durumu: hangileri görüldü, sırada ne var. Depoyu dinler; yeni kural uyarısı
/// gelince pencere çıkar. Görülenler uygulama açık kaldığı sürece hatırlanır; ilk veride 2 dakikadan eski
/// uyarılar sessizce görülmüş sayılır (web ile aynı).
class UyariDurumu extends ChangeNotifier {
  UyariDurumu(this._depo, {double Function()? simdiT}) : _simdiT = simdiT ?? _telefonSaati {
    _depo.addListener(_guncelle);
    _guncelle();
  }

  final EtkinlikDeposu _depo;
  final double Function() _simdiT;
  final Set<String> _gorulen = {};
  bool _ilkVeriBekleniyor = true;
  List<Bildirim> _sira = const [];

  static double _telefonSaati() => DateTime.now().millisecondsSinceEpoch / 1000;

  /// Açık pencere ve arkasındakiler, en eski önce.
  List<Bildirim> get sira => _sira;
  Bildirim? get acik => _sira.isEmpty ? null : _sira.first;

  void _guncelle() {
    final bildirimler = _depo.bildirimler;
    if (_ilkVeriBekleniyor && bildirimler.isNotEmpty) {
      _ilkVeriBekleniyor = false;
      final taze = acilacakUyarilar(bildirimler, _gorulen, _simdiT(), ilk: true).map(uyariAnahtari).toSet();
      for (final b in bildirimler) {
        if (b.onem == Onem.kural && !taze.contains(uyariAnahtari(b))) _gorulen.add(uyariAnahtari(b));
      }
    }
    final yeni = acilacakUyarilar(bildirimler, _gorulen, _simdiT());
    if (yeni.length == _sira.length && yeni.indexed.every((e) => uyariAnahtari(e.$2) == uyariAnahtari(_sira[e.$1]))) return;
    _sira = yeni;
    notifyListeners();
  }

  /// "Tamam" ya da "Kişileri göster": açık uyarı görüldü, sıradaki gelir.
  void kapat() {
    final b = acik;
    if (b == null) return;
    _gorulen.add(uyariAnahtari(b));
    _guncelle();
  }

  @override
  void dispose() {
    _depo.removeListener(_guncelle);
    super.dispose();
  }
}

/// Pano'nun üstünde açılan kural uyarısı: başlık, ayrıntı, kişiler; "Kişileri göster" ilk kişinin detayını
/// açar, "Tamam" kapatır. Sırada başka uyarı varsa "+N uyarı daha".
class UyariPenceresi extends StatelessWidget {
  const UyariPenceresi({super.key, required this.durum, required this.depo, required this.onKisi});

  final UyariDurumu durum;
  final EtkinlikDeposu depo;
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: durum,
      builder: (context, _) {
        final b = durum.acik;
        if (b == null) return const SizedBox.shrink();
        final adlar = b.kisiler.map((id) => gorunenAd(depo.bul(id))).join(' · ');
        final kalan = durum.sira.length - 1;
        return Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 6, Olculer.sayfaKenari, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Renkler.yuzey,
                borderRadius: Olculer.koseYaricap,
                border: Border.all(color: Renkler.kural, width: 2),
                boxShadow: const [
                  BoxShadow(color: Renkler.golge1, blurRadius: 3, offset: Offset(0, 1)),
                  BoxShadow(color: Renkler.golge2, blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, size: 18, color: Renkler.kural),
                        const SizedBox(width: 6),
                        Text('UYARI KURALI · ${b.saat}',
                            style: Yazi.olcu(11, agirlik: FontWeight.w700, renk: Renkler.kural, harfAraligi: 1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(b.baslik, style: Yazi.olcu(17, agirlik: FontWeight.w600, satir: 1.25)),
                    const SizedBox(height: 2),
                    Text(b.detay, style: Yazi.olcu(14, renk: Renkler.metinKoyu2)),
                    if (adlar.isNotEmpty) Text(adlar, style: Yazi.olcu(12, renk: Renkler.metin2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (kalan > 0)
                          Expanded(child: Text('+$kalan uyarı daha', style: Yazi.olcu(12, agirlik: FontWeight.w600, renk: Renkler.metin2)))
                        else
                          const Spacer(),
                        if (b.kisiler.isNotEmpty) ...[
                          HapDugme(
                            etiket: 'Kişileri göster',
                            yukseklik: 40,
                            punto: 13,
                            onTap: () {
                              final id = b.kisiler.first;
                              durum.kapat();
                              onKisi(id);
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        HapDugme(etiket: 'Tamam', tur: HapTuru.birincil, yukseklik: 40, punto: 13, onTap: durum.kapat),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
