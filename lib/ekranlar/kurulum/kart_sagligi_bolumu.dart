import 'package:flutter/widgets.dart';

import '../../bilesenler/kicker.dart';
import '../../bilesenler/uyari_metni.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// KART SAĞLIĞI: en düşük pilli 8 kart; pili düşük olan satır vurgulanır.
class KartSagligiBolumu extends StatelessWidget {
  const KartSagligiBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  @override
  Widget build(BuildContext context) {
    final satirlar = kartSagligi(depo.kisiler);
    final sorunlu = sorunluKartSayisi(depo.kisiler);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Kart sağlığı'),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${depo.duyulanKartSayisi}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' kart duyuluyor · '),
              TextSpan(
                style: const TextStyle(color: Renkler.ciddi),
                children: uyariParcalari('⚠ $sorunlu sorunlu', boyut: 14, renk: Renkler.ciddi),
              ),
            ],
          ),
          style: Yazi.olcu(14),
        ),
        const SizedBox(height: 8),
        for (final satir in satirlar) _SaglikSatiriGorunumu(satir: satir),
      ],
    );
  }
}

/// Sütunlar: kart no (40) · kişi/kurum (esnek) · durum · pil (48, sağa yaslı).
class _SaglikSatiriGorunumu extends StatelessWidget {
  const _SaglikSatiriGorunumu({required this.satir});

  final SaglikSatiri satir;

  @override
  Widget build(BuildContext context) {
    final durumRengi = satir.sorunlu ? Renkler.ciddi : Renkler.metin2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: satir.sorunlu ? Renkler.ciddiZemin : null,
        border: const Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(satir.kart, style: Yazi.olcu(14, agirlik: FontWeight.w600, rakam: true)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                satir.kisi,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Yazi.olcu(14, renk: satir.adsiz ? Renkler.metin2 : Renkler.metin),
              ),
            ),
            const SizedBox(width: 10),
            UyariMetni(satir.durum, stil: Yazi.olcu(13, renk: durumRengi)),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              child: Text(
                satir.pilYazisi,
                textAlign: TextAlign.right,
                style: Yazi.olcu(14, renk: durumRengi, rakam: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
