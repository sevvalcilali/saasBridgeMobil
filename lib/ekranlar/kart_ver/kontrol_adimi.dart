import 'package:flutter/widgets.dart';

import '../../bilesenler/etiketli_deger.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import 'kart_ver_durumu.dart';

/// Adım 3 — Kontrol: kart durumu, "kişi → kart" özeti ve onay.
class KontrolAdimi extends StatelessWidget {
  const KontrolAdimi({super.key, required this.durum});

  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    final kart = durum.seciliKart;
    if (kisi == null || kart == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Kontrol', style: Yazi.baslik(18, 1.2)),
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: EtiketliDeger(etiket: 'Durum', deger: 'Açık')),
              SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Son duyulma', deger: 'az önce')),
              SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Pil', deger: '%94')),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  RolSekli(rol: kisi.rol, renk: kisi.renk, boyut: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${tamAd(kisi)} → Kart $kart',
                      style: Yazi.olcu(20, agirlik: FontWeight.w600, satir: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HapDugme(etiket: '← Kart', yukseklik: 48, onTap: durum.kartAdiminaDon),
              const SizedBox(width: 10),
              Expanded(
                child: HapDugme(
                  etiket: 'Onayla',
                  tur: HapTuru.birincil,
                  yukseklik: 48,
                  punto: 16,
                  genis: true,
                  onTap: durum.onayla,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
