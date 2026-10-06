import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kart_no.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';

/// Adım 2 — Kart: kartın üstündeki numara yazılır; şu an açık kartlar önerilir (yalnız numara; "yaklaştır ve tanı"
/// yok, Şevval kararı 07.10.2026).
class KartAdimi extends StatelessWidget {
  const KartAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: 'Kişi: ',
              children: [
                TextSpan(
                  text: kisi == null ? '' : katilimciAdi(kisi),
                  style: TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                ),
              ],
            ),
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 14),
          _NumaraGirisi(depo: depo, durum: durum),
          // 14 px bölüm aralığı + 6 px üst boşluk.
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HapDugme(etiket: '← Kişi', onTap: durum.kisiAdiminaDon),
              // Yalnız numara geçerliyken (1–99).
              if (durum.numaraSecilebilir)
                HapDugme(etiket: 'Bu kartı seç', tur: HapTuru.birincil, onTap: durum.numaraSec),
            ],
          ),
        ],
      ),
    );
  }
}

/// Numara girdisi + "şu an açık kartlar" ızgarası.
class _NumaraGirisi extends StatelessWidget {
  const _NumaraGirisi({required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Kart numarası (kartın üstündeki etiket)', style: Yazi.olcu(13, renk: Renkler.metin2)),
        const SizedBox(height: 6),
        AramaAlani(
          ipucu: 'Örn. 14',
          denetleyici: durum.numaraDenetleyici,
          onGonder: (_) => durum.numaraSec(), // klavyede "Bitti": geçerliyse 3. adım
          yukseklik: 52,
          punto: 24,
          agirlik: FontWeight.w600,
          harfAraligi: 1.2,
          rakam: true,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: Kicker('Şu an açık kartlar')),
            const SizedBox(width: 8),
            Kicker('${depo.acikKartlar.length}'),
          ],
        ),
        const SizedBox(height: 14),
        _KartIzgarasi(kartlar: acikKartOner(depo.acikKartlar, durum.numara), onSec: durum.acikKartSec),
      ],
    );
  }
}

/// 3 sütunlu kart ızgarası.
class _KartIzgarasi extends StatelessWidget {
  const _KartIzgarasi({required this.kartlar, required this.onSec});

  final List<AcikKart> kartlar;
  final ValueChanged<String> onSec;

  static const int _sutun = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var bas = 0; bas < kartlar.length; bas += _sutun) ...[
          if (bas > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var i = bas; i < bas + _sutun; i++) ...[
                if (i > bas) const SizedBox(width: 8),
                Expanded(
                  child: i < kartlar.length
                      // Atanmış kart ızgaradan seçilemez (başkasının kartı yanlışlıkla alınmasın); numarayla yazılırsa 3. adım sorar.
                      ? _Hucre(kart: kartlar[i], onTap: kartlar[i].atanmis ? null : () => onSec(kartlar[i].no))
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Hucre extends StatelessWidget {
  const _Hucre({required this.kart, required this.onTap});

  final AcikKart kart;

  /// null: seçilemez (atanmış), soluk çizilir.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.55 : 1,
          child: DecoratedBox(
          decoration: BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kart ${kart.no}', style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
                  const SizedBox(height: 2),
                  Text(acikKartEtiketi(kart), style: Yazi.olcu(12, renk: Renkler.metin2)),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
