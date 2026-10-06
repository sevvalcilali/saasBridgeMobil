import 'package:flutter/material.dart';

import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/etiket.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../mantik/bicim.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'pano_durumu.dart';

/// Pano'nun üst alanı: etkinlik adı, canlı saat, durum etiketleri, bölüm anahtarı.
class PanoUst extends StatelessWidget {
  const PanoUst({super.key, required this.depo, required this.durum, required this.onKurulumaGit});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final VoidCallback onKurulumaGit;

  Future<void> _sifirla(BuildContext context) async {
    final onay = await showDialog<bool>(
      context: context,
      barrierColor: Renkler.perde,
      builder: (_) => const SifirlaDiyalogu(),
    );
    if (onay == true) depo.sifirla();
  }

  @override
  Widget build(BuildContext context) {
    final alici = depo.aliciBagli ? 'Alıcı bağlı' : 'Alıcı yok';
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(depo.etkinlikAdi, style: Yazi.baslik(22, 1.15)),
                    ),
                    const SizedBox(height: 4),
                    Text(depo.tarihMekan, style: Yazi.olcu(13, renk: Renkler.metin2)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  depo.saat,
                  style: Yazi.olcu(24, agirlik: FontWeight.w600, satir: 1, rakam: true),
                ),
              ),
            ],
          ),
          // Etiketlerin görseli 28 px, dokunma alanı 44 px: üstteki 12 px ve
          // alttaki 14 px boşluğun 8'er pikseli dokunma alanının içindedir.
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                height: Olculer.dokunmaEnAz,
                child: Center(widthFactor: 1, child: Etiket('● $alici')),
              ),
              Etiket('Eşik ${dbmYazisi(depo.esik)} dBm', tur: EtiketTuru.notr, onTap: onKurulumaGit),
              HapDugme(
                etiket: 'Sıfırla',
                tur: HapTuru.hayalet,
                yukseklik: 28,
                punto: 13,
                yatayBosluk: 6,
                onTap: () => _sifirla(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BolmeliAnahtar<PanoBolumu>(
            yukseklik: 40,
            secenekler: [
              BolmeSecenegi(deger: PanoBolumu.kisiler, etiket: 'Kişiler', ek: '${depo.kisiler.length}'),
              const BolmeSecenegi(deger: PanoBolumu.salon, etiket: 'Salon'),
              BolmeSecenegi(
                deger: PanoBolumu.bildirimler,
                etiket: 'Bildirimler',
                ek: '${depo.bildirimler.length}',
              ),
            ],
            secili: durum.bolum,
            onSecildi: durum.bolumSec,
          ),
        ],
      ),
    );
  }
}

/// Sıfırla onayı. `true` (Sıfırla) ya da `false` (Vazgeç) ile kapanır.
class SifirlaDiyalogu extends StatelessWidget {
  const SifirlaDiyalogu({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Renkler.yuzey,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Olculer.sayfaKenari),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Olculer.koseAltSayfa)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?',
              style: Yazi.olcu(15),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HapDugme(etiket: 'Vazgeç', onTap: () => Navigator.of(context).pop(false)),
                const SizedBox(width: 10),
                HapDugme(
                  etiket: 'Sıfırla',
                  tur: HapTuru.birincil,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
