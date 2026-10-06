import 'package:flutter/material.dart';

import '../../bilesenler/etiketli_deger.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kart_no.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';

/// Adım 3 — Kontrol: kart durumu, "kişi → kart" özeti ve onay.
class KontrolAdimi extends StatelessWidget {
  const KontrolAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    final kart = durum.seciliKart;
    if (kisi == null || kart == null) return const SizedBox.shrink();
    AcikKart? acik;
    for (final k in depo.acikKartlar) {
      if (k.no == kart) acik = k;
    }
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: EtiketliDeger(etiket: 'Durum', deger: acik == null ? 'Duyulmuyor' : 'Açık')),
              const SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Son duyulma', deger: acik == null ? '—' : 'az önce')),
              const SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Kart', deger: acik == null ? '—' : (acik.atanmis ? 'atanmış' : 'boşta'))),
            ],
          ),
          if (durum.kartinSahibi case final sahip?) ...[
            const SizedBox(height: 16),
            // Sözleşme §2: başkasının kartı verilmeden önce masa "geri alındı mı?" diye sorar; onaysız Onayla çalışmaz.
            DecoratedBox(
              decoration: const BoxDecoration(color: Renkler.vurguZemin, borderRadius: Olculer.koseYaricap),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bu kart ${katilimciAdi(sahip)} adına kayıtlı.', style: Yazi.olcu(15, agirlik: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Onaylarsanız ${sahip.ad} panodan düşer, süreleri raporda kalır.', style: Yazi.olcu(13, renk: Renkler.metin2)),
                    const SizedBox(height: 8),
                    Semantics(
                      checked: durum.sahipOnayi,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => durum.sahipOnayla(!durum.sahipOnayi),
                        child: Row(
                          children: [
                            Icon(durum.sahipOnayi ? Icons.check_box : Icons.check_box_outline_blank, size: 22, color: Renkler.vurgu),
                            const SizedBox(width: 8),
                            Text('Kart ${sahip.ad} tarafından geri verildi', style: Yazi.olcu(14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                      '${katilimciAdi(kisi)} → Kart $kart',
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
                  etiket: durum.gonderiliyor ? 'Gönderiliyor…' : 'Onayla',
                  tur: (durum.kartinSahibi != null && !durum.sahipOnayi) ? HapTuru.ikincil : HapTuru.birincil,
                  yukseklik: 48,
                  punto: 16,
                  genis: true,
                  onTap: durum.gonderiliyor ? islevsiz : durum.onayla,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
