import 'package:flutter/widgets.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/uyari_metni.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../mantik/rapor.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// Rapor sekmesi: başlık, düğmeler, 5 KPI ve girişimci satırları.
class RaporEkrani extends StatelessWidget {
  const RaporEkrani({super.key, required this.depo});

  final EtkinlikDeposu depo;

  static const double _bolumAraligi = 24;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        final kpiler = raporKpileri(depo.kisiler, depo.tick, kayitli: depo.kayitliKatilimci);
        final satirlar = raporSatirlari(depo.kisiler, depo.tick, depo.bul);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Kicker('Etkinlik raporu'),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(depo.etkinlikAdi, style: Yazi.baslik(26, 1.1)),
              ),
              const SizedBox(height: 6),
              Text(
                '${depo.tarihMekan} · Hazırlanma: ${depo.raporTarihi} ${depo.saatKisa}',
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
              const SizedBox(height: _bolumAraligi),
              // Yazdırma ve dışa aktarma ekranları tasarlanmadı (şartname §2).
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HapDugme(etiket: 'Yazdır / PDF', tur: HapTuru.birincil, onTap: islevsiz),
                  HapDugme(etiket: '⤓ Katılımcılar', onTap: islevsiz),
                  HapDugme(etiket: '⤓ Görüşmeler', onTap: islevsiz),
                  HapDugme(etiket: 'Yenile', tur: HapTuru.hayalet, onTap: islevsiz),
                ],
              ),
              const SizedBox(height: _bolumAraligi),
              _KpiIzgarasi(kpiler: kpiler),
              const SizedBox(height: _bolumAraligi),
              Semantics(
                header: true,
                child: Text('Girişimciler ve ulaştıkları yatırımcılar', style: Yazi.baslik(18, 1.2)),
              ),
              const SizedBox(height: 8),
              for (final satir in satirlar) _RaporSatiriGorunumu(satir: satir),
            ],
          ),
        );
      },
    );
  }
}

/// 2 sütunlu KPI ızgarası; aynı satırdaki kartlar eşit yüksekliktedir.
class _KpiIzgarasi extends StatelessWidget {
  const _KpiIzgarasi({required this.kpiler});

  final List<Kpi> kpiler;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kpiler.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _KpiKarti(kpi: kpiler[i])),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < kpiler.length ? _KpiKarti(kpi: kpiler[i + 1]) : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KpiKarti extends StatelessWidget {
  const _KpiKarti({required this.kpi});

  final Kpi kpi;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kpi.ad, style: Yazi.olcu(13, renk: Renkler.metin2)),
            const SizedBox(height: 4),
            // Uzun süreler ("11 sa 15 dk") alt satıra kırılmasın: sığmazsa küçülür.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                kpi.deger,
                maxLines: 1,
                style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1, rakam: true),
              ),
            ),
            const SizedBox(height: 4),
            Text(kpi.not, style: Yazi.olcu(12, renk: Renkler.metin2)),
          ],
        ),
      ),
    );
  }
}

/// Bir girişimci: renk karesi, kurum · ad, toplam süre; altında detay.
class _RaporSatiriGorunumu extends StatelessWidget {
  const _RaporSatiriGorunumu({required this.satir});

  final RaporSatiri satir;

  @override
  Widget build(BuildContext context) {
    final kisi = satir.kisi;
    final alt = altAd(kisi);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Renkler.kisi(kisi.renk),
                      borderRadius: const BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
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
                    style: Yazi.olcu(15, agirlik: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(satir.toplam, style: Yazi.olcu(15, renk: Renkler.metinKoyu2, rakam: true)),
              ],
            ),
            const SizedBox(height: 4),
            UyariMetni(
              satir.detay,
              stil: Yazi.olcu(14, renk: satir.gorusmedi ? Renkler.ciddi : Renkler.metinKoyu2),
            ),
          ],
        ),
      ),
    );
  }
}
