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
import 'kisi_formu_sayfasi.dart';

/// Adım 1 — Kişi: kayıtlı kişilerde arama ve kişi kartları.
class KisiAdimi extends StatelessWidget {
  const KisiAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final liste = masaAra(depo.katilimcilar, durum.arama, yalnizBekleyen: durum.yalnizBekleyen);
    final bekleyen = masaAra(depo.katilimcilar, '', yalnizBekleyen: true).length;
    final ikincil = Yazi.olcu(14, renk: Renkler.metin2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AramaAlani(
                  ipucu: 'Kayıtlı kişilerde ara: ad veya kurum',
                  denetleyici: durum.aramaDenetleyici,
                ),
              ),
              const SizedBox(width: 8),
              // Kayıt defterinde olmayan gelen: önce eklenir, sonra kart verilir.
              HapDugme(etiket: '+ Yeni', yukseklik: 44, onTap: () => kisiFormuGoster(context, depo: depo)),
            ],
          ),
          const SizedBox(height: 12),
          // Süzgeç: Tümü / Kart bekliyor (dokununca değişir).
          Wrap(
            spacing: 16,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => durum.bekleyenSuzgeci(false),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tümü',
                        style: TextStyle(fontWeight: durum.yalnizBekleyen ? FontWeight.w400 : FontWeight.w600, color: Renkler.metin),
                      ),
                      TextSpan(text: ' (${depo.kayitliKatilimci})'),
                    ],
                  ),
                  style: ikincil,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => durum.bekleyenSuzgeci(true),
                child: Text(
                  'Kart bekliyor ($bekleyen)',
                  style: durum.yalnizBekleyen ? Yazi.olcu(14, agirlik: FontWeight.w600) : ikincil,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _KisiKarti(
              kisi: liste[i],
              onTap: () => durum.kisiSec(liste[i].kisiId),
              onDuzenle: () => kisiFormuGoster(context, depo: depo, katilimci: liste[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _KisiKarti extends StatelessWidget {
  const _KisiKarti({required this.kisi, required this.onTap, required this.onDuzenle});

  final Katilimci kisi;
  final VoidCallback onTap;
  final VoidCallback onDuzenle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: Olculer.dokunmaEnAz),
                    child: Row(
                      children: [
                        RolSekli(rol: kisi.rol, renk: kisi.renk),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(katilimciAdi(kisi), style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
                              const SizedBox(height: 2),
                              Text(katilimciKartMetni(kisi), style: Yazi.olcu(13, renk: Renkler.metin2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            HapDugme(etiket: 'Düzenle', tur: HapTuru.hayalet, yukseklik: 36, onTap: onDuzenle),
          ],
        ),
      ),
    );
  }
}
