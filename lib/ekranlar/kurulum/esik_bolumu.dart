import 'package:flutter/material.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// EŞİK: büyük değer, "eşiğin üstündeki çift" sayısı, −1 / kaydırıcı / +1.
class EsikBolumu extends StatelessWidget {
  const EsikBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  @override
  Widget build(BuildContext context) {
    final ustu = esikUstuCiftSayisi(depo.ciftler, depo.esik);
    final ucYazisi = Yazi.olcu(12, renk: Renkler.metin2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Eşik'),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              dbmYazisi(depo.esik),
              style: Yazi.olcu(56, agirlik: FontWeight.w600, satir: 1, rakam: true, harfAraligi: -1.12),
            ),
            const SizedBox(width: 8),
            Text('dBm', style: Yazi.olcu(18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Şu an ',
                  children: [
                    TextSpan(
                      text: '$ustu',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                    ),
                    const TextSpan(text: ' çift eşiğin üstünde.'),
                  ],
                ),
                textAlign: TextAlign.right,
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            HapDugme(
              etiket: '−1',
              anlam: 'Eşiği bir azalt',
              genislik: 48,
              yukseklik: 48,
              punto: 18,
              onTap: depo.esikAzalt,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: depo.esik.toDouble(),
                min: esikAlt.toDouble(),
                max: esikUst.toDouble(),
                divisions: esikUst - esikAlt,
                padding: EdgeInsets.zero,
                semanticFormatterCallback: (deger) => '${dbmYazisi(deger.round())} dBm',
                onChanged: (deger) => depo.esikAyarla(deger.round()),
              ),
            ),
            const SizedBox(width: 12),
            HapDugme(
              etiket: '+1',
              anlam: 'Eşiği bir artır',
              genislik: 48,
              yukseklik: 48,
              punto: 18,
              onTap: depo.esikArtir,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('−95 · gevşek', style: ucYazisi),
            Text('sıkı · −35', style: ucYazisi),
          ],
        ),
      ],
    );
  }
}
