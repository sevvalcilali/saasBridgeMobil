import 'package:flutter/widgets.dart';

import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';

/// Sihirbazın adım göstergesi: 3 hap (Kişi · Kart · Onay). Etkin = vurgu dolgu,
/// biten = metin renginde numara rozeti, bekleyen = gri rozet.
class AdimGostergesi extends StatelessWidget {
  const AdimGostergesi({super.key, required this.adim});

  /// Etkin adım: 1–3.
  final int adim;

  static const List<String> _adlar = ['Kişi', 'Kart', 'Onay'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Row(
        children: [
          for (var no = 1; no <= _adlar.length; no++) ...[
            if (no > 1) const SizedBox(width: 8),
            Expanded(
              child: _Hap(no: no, ad: _adlar[no - 1], etkin: adim == no, bitti: adim > no),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hap extends StatelessWidget {
  const _Hap({required this.no, required this.ad, required this.etkin, required this.bitti});

  final int no;
  final String ad;
  final bool etkin;
  final bool bitti;

  @override
  Widget build(BuildContext context) {
    final Color yazi;
    final Color rozetZemin;
    final Color rozetYazi;
    if (etkin) {
      yazi = Renkler.zemin;
      rozetZemin = Renkler.zemin;
      rozetYazi = Renkler.vurguBasili;
    } else if (bitti) {
      yazi = Renkler.metin;
      rozetZemin = Renkler.metin;
      rozetYazi = Renkler.zemin;
    } else {
      yazi = Renkler.metin2;
      rozetZemin = Renkler.ayrac;
      rozetYazi = Renkler.metin;
    }
    return Semantics(
      selected: etkin,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: etkin ? Renkler.vurgu : null, borderRadius: Olculer.hapYaricap),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(color: rozetZemin, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$no',
                    textScaler: TextScaler.noScaling,
                    style: Yazi.olcu(12, agirlik: FontWeight.w600, satir: 1, renk: rozetYazi),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(ad, maxLines: 1, overflow: TextOverflow.ellipsis, style: Yazi.olcu(14, renk: yazi)),
            ),
          ],
        ),
      ),
    );
  }
}
