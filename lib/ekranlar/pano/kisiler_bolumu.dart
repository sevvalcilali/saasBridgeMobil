import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/basili_opaklik.dart';
import '../../bilesenler/cip.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../mantik/pano_filtre.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'pano_durumu.dart';

/// Pano → Kişiler: arama, filtre çipleri, başlık ve kişi satırları.
class KisilerBolumu extends StatelessWidget {
  const KisilerBolumu({super.key, required this.depo, required this.durum, required this.onKisi});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Satıra dokununca kişinin kart numarasıyla çağrılır.
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    final liste = filtreleKisiler(depo.kisiler, filtre: durum.filtre, arama: durum.arama);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 14, Olculer.sayfaKenari, 0),
          child: AramaAlani(ipucu: 'Ara: ad, kurum, kart no', denetleyici: durum.aramaDenetleyici),
        ),
        // Çip görseli 36 px, dokunma alanı 44 px: üstteki 12 px ve alttaki 20 px
        // boşluğun 4'er pikseli dokunma alanının içindedir.
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Olculer.sayfaKenari),
          child: Row(
            children: [
              for (final f in PanoFiltre.values) ...[
                if (f != PanoFiltre.values.first) const SizedBox(width: 8),
                Cip(etiket: f.etiket, secili: f == durum.filtre, onTap: () => durum.filtreSec(f)),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
          child: Kicker(listeBasligi(durum.filtre), sayi: '${liste.length}'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < liste.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _KisiSatiri(kisi: liste[i], depo: depo, onTap: () => onKisi(liste[i].id)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KisiSatiri extends StatelessWidget {
  const _KisiSatiri({required this.kisi, required this.depo, required this.onTap});

  final Kisi kisi;
  final EtkinlikDeposu depo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alt = altAd(kisi);
    return BasiliOpaklik(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Yeşil zemin yalnız "şu an birlikte" demektir.
          color: kisi.ile != null ? Renkler.birlikteZemin : Renkler.yuzey,
          borderRadius: Olculer.koseYaricap,
        ),
        child: Row(
          children: [
            RolSekli(rol: kisi.rol, renk: kisi.renk),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: baslik(kisi),
                      children: [
                        if (alt.isNotEmpty)
                          TextSpan(
                            text: ' $alt',
                            style: const TextStyle(fontWeight: FontWeight.w400, color: Renkler.metin2),
                          ),
                      ],
                    ),
                    style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    durumCumlesi(kisi, depo.tick, depo.bul),
                    style: Yazi.olcu(13, renk: Renkler.ton(durumTonu(kisi))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(sureMetni(kisi, depo.tick), style: Yazi.olcu(15, renk: Renkler.metinKoyu2, rakam: true)),
          ],
        ),
      ),
    );
  }
}
