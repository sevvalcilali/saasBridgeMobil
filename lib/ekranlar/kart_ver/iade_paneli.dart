import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kart_no.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';

/// Kart İadesi: arama, onay kutusu ve kartı olan kişilerin listesi.
class IadePaneli extends StatelessWidget {
  const IadePaneli({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final liste = masaAra(depo.katilimcilar, durum.arama, yalnizKartli: true);
    final secili = durum.iadeKisisi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AramaAlani(ipucu: 'Kart no, ad veya kurum', denetleyici: durum.aramaDenetleyici),
          if (secili != null) ...[
            const SizedBox(height: 12),
            _OnayKutusu(kisi: secili, onVazgec: durum.iadeVazgec, onOnay: durum.iadeOnayla),
          ],
          const SizedBox(height: 12),
          for (final k in liste) _IadeSatiri(kisi: k, onTap: () => durum.iadeSec(k.kisiId)),
        ],
      ),
    );
  }
}

class _OnayKutusu extends StatelessWidget {
  const _OnayKutusu({required this.kisi, required this.onVazgec, required this.onOnay});

  final Katilimci kisi;
  final VoidCallback onVazgec;
  final VoidCallback onOnay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kart ${kisi.atananKart} iade alınsın mı?',
              style: Yazi.olcu(18, agirlik: FontWeight.w600, satir: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              '${katilimciAdi(kisi)} panodan düşer; bugünkü süreleri raporda kalır.',
              style: Yazi.olcu(14, renk: Renkler.metin2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                HapDugme(etiket: 'Vazgeç', onTap: onVazgec),
                const SizedBox(width: 10),
                Expanded(
                  child: HapDugme(etiket: 'İade al', tur: HapTuru.birincil, genis: true, onTap: onOnay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IadeSatiri extends StatelessWidget {
  const _IadeSatiri({required this.kisi, required this.onTap});

  final Katilimci kisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Renkler.ayrac)),
          ),
          child: Row(
            children: [
              RolSekli(rol: kisi.rol, renk: kisi.renk, boyut: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Text(katilimciAdi(kisi), style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
              ),
              const SizedBox(width: 12),
              Text('Kart ${kisi.atananKart}', style: Yazi.olcu(14, renk: Renkler.metin2, rakam: true)),
            ],
          ),
        ),
      ),
    );
  }
}
