import 'package:flutter/widgets.dart';

import '../../bilesenler/cip.dart';
import '../../mantik/pano_filtre.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'pano_durumu.dart';

/// Pano → Bildirimler: önem çipleri ve bildirim satırları.
class BildirimlerBolumu extends StatelessWidget {
  const BildirimlerBolumu({super.key, required this.depo, required this.durum, required this.onKisi});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Satıra dokununca bildirimin ilk kişisinin kart numarasıyla çağrılır.
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    final liste = bildirimleriSuz(depo.bildirimler, durum.onem);
    return Padding(
      // Çip görseli 36 px, dokunma alanı 44 px: üstteki 16 px ve alttaki 14 px
      // boşluğun 4'er pikseli dokunma alanının içindedir.
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 12, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final o in onemSirasi)
                Cip(
                  etiket: onemEtiketi(o),
                  sayi: '${onemSayisi(depo.bildirimler, o)}',
                  secili: o == durum.onem,
                  seciliRenk: Renkler.metin,
                  yatayBosluk: 12,
                  onTap: () => durum.onemSec(o),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _BildirimSatiri(
              bildirim: liste[i],
              onTap: liste[i].kisiler.isEmpty ? null : () => onKisi(liste[i].kisiler.first),
            ),
          ],
          if (liste.isEmpty)
            Text(
              'Bu önemde bildirim yok.',
              style: Yazi.olcu(15, renk: Renkler.metin2, stil: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _BildirimSatiri extends StatelessWidget {
  const _BildirimSatiri({required this.bildirim, required this.onTap});

  final Bildirim bildirim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Olculer.dokunmaEnAz),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: SizedBox.square(
                    dimension: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Renkler.onem(bildirim.onem), shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(bildirim.baslik, style: Yazi.olcu(15, agirlik: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text(bildirim.saat, style: Yazi.olcu(13, renk: Renkler.metin2, rakam: true)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(bildirim.detay, style: Yazi.olcu(14, renk: Renkler.metinKoyu2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
