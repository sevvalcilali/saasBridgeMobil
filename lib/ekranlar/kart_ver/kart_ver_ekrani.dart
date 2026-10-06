import 'package:flutter/widgets.dart';

import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'adim_gostergesi.dart';
import 'iade_paneli.dart';
import 'kart_adimi.dart';
import 'kart_ver_durumu.dart';
import 'kisi_adimi.dart';
import 'kontrol_adimi.dart';

/// Kart Ver sekmesi: "Kart ver" sihirbazı ve "Kart iadesi" modu.
class KartVerEkrani extends StatelessWidget {
  const KartVerEkrani({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: durum,
      builder: (context, _) {
        final ver = durum.mod == KartVerModu.ver;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(ver ? 'Kart Ver' : 'Kart İadesi', style: Yazi.baslik(26, 1.1)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ver ? 'Karşılama masası — gelen kişiye kart verin' : 'Ayrılan kişiden kartı geri alın',
                      style: Yazi.olcu(14, renk: Renkler.metin2),
                    ),
                    const SizedBox(height: 14),
                    BolmeliAnahtar<KartVerModu>(
                      punto: 15,
                      agirlik: FontWeight.w600,
                      araCizgi: true,
                      secenekler: const [
                        BolmeSecenegi(deger: KartVerModu.ver, etiket: 'Kart ver'),
                        BolmeSecenegi(deger: KartVerModu.iade, etiket: 'Kart iadesi'),
                      ],
                      secili: durum.mod,
                      onSecildi: (mod) => mod == KartVerModu.ver ? durum.modVer() : durum.modIade(),
                    ),
                    if (durum.sonAtama case final atama?) ...[
                      const SizedBox(height: 14),
                      _SonAtamaBandi(atama: atama, onGeriAl: durum.geriAl),
                    ],
                    if (durum.bilgi case final bilgi?) ...[
                      const SizedBox(height: 14),
                      _BilgiBandi(bilgi),
                    ],
                  ],
                ),
              ),
              if (!ver)
                IadePaneli(depo: depo, durum: durum)
              else ...[
                AdimGostergesi(adim: durum.adim),
                switch (durum.adim) {
                  1 => KisiAdimi(depo: depo, durum: durum),
                  2 => KartAdimi(depo: depo, durum: durum),
                  _ => KontrolAdimi(durum: durum),
                },
              ],
            ],
          ),
        );
      },
    );
  }
}

/// "✓ Ad → Kart 88 verildi." + Geri al.
class _SonAtamaBandi extends StatelessWidget {
  const _SonAtamaBandi({required this.atama, required this.onGeriAl});

  final SonAtama atama;
  final VoidCallback onGeriAl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.vurguZemin, borderRadius: Olculer.koseYaricap),
      child: Padding(
        // Geri al görseli 36 px, dokunma alanı 44 px: 10 px dikey boşluğun
        // 4 pikseli dokunma alanının içindedir.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '✓ ${atama.ad} → Kart ${atama.kart} verildi.',
                style: Yazi.olcu(14, renk: Renkler.vurguKoyu),
              ),
            ),
            const SizedBox(width: 10),
            HapDugme(etiket: '↶ Geri al', yukseklik: 36, zemin: Renkler.zemin, onTap: onGeriAl),
          ],
        ),
      ),
    );
  }
}

/// Geri alma ya da iade sonrası bilgi metni.
class _BilgiBandi extends StatelessWidget {
  const _BilgiBandi(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(metin, style: Yazi.olcu(14)),
      ),
    );
  }
}
