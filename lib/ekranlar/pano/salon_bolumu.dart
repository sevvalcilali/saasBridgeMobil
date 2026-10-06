import 'package:flutter/material.dart';

import '../../bilesenler/kicker.dart';
import '../../bilesenler/siluet.dart';
import '../../mantik/bicim.dart';
import '../../mantik/gruplar.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Pano → Salon (web ile aynı, Şevval 06.10.2026): şu an yan yana olanlar küçük karikatür figürlerle küme
/// küme (arka + ön sıra); figürün rengi görüşme süresi; yatırımcı ile girişimcinin buluştuğu kümenin
/// zemini yeşil. Adlar kümenin altında tek satır. Boştakiler salonun kenarında soluk figürler. Kümeler
/// ekranda yer değiştirmez (`yerlestir`); yerleri salondaki yeri DEĞİLDİR. Figüre dokununca kişi açılır.
class SalonBolumu extends StatefulWidget {
  const SalonBolumu({super.key, required this.depo, required this.onKisi});

  final EtkinlikDeposu depo;
  final ValueChanged<String> onKisi;

  @override
  State<SalonBolumu> createState() => _SalonBolumuState();
}

class _SalonBolumuState extends State<SalonBolumu> {
  /// Önceki çizimin yerleri: grup büyüyüp küçülse de aynı yerde kalır, yeni grup boş yere çıkar.
  List<Set<String>?> _yerler = const [];

  @override
  Widget build(BuildContext context) {
    final gruplar = canliGruplar(widget.depo.kisiler, widget.depo.canliCiftler);
    final yerlesim = yerlestir(_yerler, gruplar);
    _yerler = yerlesim.yerler;
    final yerdeki = {for (final g in gruplar) yerlesim.atama[g.anahtar]!: g};
    final bos = bostakiler(widget.depo.kisiler, gruplar);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 12, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zemin sade: figürlerin arkası koyulaşmaz (Şevval 06.10.2026).
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: Olculer.koseYaricap,
              color: Renkler.yuzey,
              border: Border.fromBorderSide(BorderSide(color: Renkler.ayrac)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (gruplar.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('Şu an birlikte olan kimse yok.',
                          textAlign: TextAlign.center, style: Yazi.olcu(15, renk: Renkler.metin2)),
                    )
                  else
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        for (var yi = 0; yi < yerlesim.yerler.length; yi++)
                          if (yerdeki[yi] case final g?)
                            _Kume(grup: g, onKisi: widget.onKisi)
                          else
                            const SizedBox(width: 92, height: 1),
                      ],
                    ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Renkler.ayrac),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Kicker('Boşta', sayi: '${bos.bosta.length} kişi'),
                      if (bos.gorunmeyen.isNotEmpty)
                        Text('  · görünmüyor ${bos.gorunmeyen.length}', style: Yazi.olcu(11, renk: Renkler.metinSoluk)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [for (final k in bos.bosta) _BostaFigur(kisi: k, onTap: () => widget.onKisi(k.id))],
                  ),
                ],
              ),
            ),
          ),
          if (gruplar.isNotEmpty) ...[const SizedBox(height: 10), const _SureAnahtari()],
          const SizedBox(height: 10),
          Text(
            'Grupların yeri salondaki yeri göstermez; yalnız şu an kimlerin birlikte olduğunu gösterir. '
            'Bir figüre dokununca ayrıntı açılır.',
            textAlign: TextAlign.center,
            style: Yazi.olcu(12, renk: Renkler.metinSoluk),
          ),
        ],
      ),
    );
  }
}

const double _fig = 34;
const int _gruptaEnCok = 6; // daha kalabalık grupta ilk 5 kişi + "+N"

/// Bir küme: arka sıra (biraz küçük, geride) + ön sıra (öne biner); altında "N kişi · süre" ve adlar.
class _Kume extends StatelessWidget {
  const _Kume({required this.grup, required this.onKisi});

  final Grup grup;
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    final n = grup.uyeler.length;
    final gorunen = n > _gruptaEnCok ? grup.uyeler.take(_gruptaEnCok - 1).toList() : grup.uyeler;
    final (arkaSayi, _) = grupSiralari(gorunen.length);
    final arka = gorunen.take(arkaSayi).toList();
    final on = gorunen.skip(arkaSayi).toList();
    final fig = n >= 5 ? 30.0 : n == 4 ? 32.0 : _fig;
    final figYukseklik = fig * Siluet.oran;
    final etiket = '$n kişi · ${kisaSure(grup.sn)}';
    final adlar = grup.uyeler.map(baslik).join(' · ');

    Widget figur(Kisi k, int i) => _Figur(
      kisi: k,
      genislik: fig,
      ayna: i > (gorunen.length - 1) / 2,
      onTap: () => onKisi(k.id),
    );

    final sahne = SizedBox(
      height: (arka.isEmpty ? figYukseklik : figYukseklik * 1.45) + 6,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Zemin gölgesi: karma grupta yeşil.
          Positioned(
            bottom: 0,
            child: Container(
              width: fig * gorunen.length.clamp(2, 3) * 0.9,
              height: 12,
              decoration: BoxDecoration(
                color: grup.karma ? Renkler.birlikteZemin : Renkler.acikYuzey,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (arka.isNotEmpty)
            Positioned(
              bottom: figYukseklik * 0.45 + 4,
              child: Opacity(
                opacity: 0.85,
                child: Transform.scale(
                  scale: 0.9,
                  alignment: Alignment.bottomCenter,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [for (final (i, k) in arka.indexed) figur(k, i)]),
                ),
              ),
            ),
          Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, k) in on.indexed)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 0), child: figur(k, arka.length + i)),
                if (n > gorunen.length)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 12),
                    child: Text('+${n - gorunen.length}', style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: Renkler.metin2)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: '$etiket${grup.karma ? ', yatırımcı ile girişimci' : ''}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sahne,
            const SizedBox(height: 2),
            Text(etiket, style: Yazi.olcu(12, agirlik: FontWeight.w600, renk: grup.karma ? Renkler.birlikte : Renkler.metin2)),
            Text(adlar, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: Yazi.olcu(11, renk: Renkler.metin2, satir: 1.2)),
          ],
        ),
      ),
    );
  }
}

/// Süre renginde figür; dokununca kişi açılır. Ad ipucu erişilebilirlik etiketinde.
class _Figur extends StatelessWidget {
  const _Figur({required this.kisi, required this.genislik, required this.ayna, required this.onTap});

  final Kisi kisi;
  final double genislik;
  final bool ayna;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${gorunenAd(kisi)} · ${kisaSure(kisi.sn)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Siluet(renk: Renkler.sure(sureRengi(kisi.sn)), rol: kisi.rol, poz: siluetPozu(kisi.id), ayna: ayna, genislik: genislik),
        ),
      ),
    );
  }
}

/// Salonun kenarındaki boştaki kişi: küçük soluk figür, altında adı; yalnız kalan önemli yatırımcı uyarı renginde.
class _BostaFigur extends StatelessWidget {
  const _BostaFigur({required this.kisi, required this.onTap});

  final Kisi kisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final yalniz = yalnizMi(kisi);
    final renk = yalniz ? Renkler.uyari : Renkler.metinSoluk;
    return Semantics(
      button: true,
      label: gorunenAd(kisi),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: yalniz
              ? BoxDecoration(color: Renkler.vurguZemin, borderRadius: Olculer.koseYaricap, border: Border.all(color: Renkler.uyari))
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(opacity: yalniz ? 1 : 0.8, child: Siluet(renk: renk, rol: kisi.rol, poz: siluetPozu(kisi.id), genislik: 20)),
              Text(gorunenAd(kisi), maxLines: 1, overflow: TextOverflow.ellipsis, style: Yazi.olcu(10, renk: renk)),
              if (yalniz)
                Text('yalnız · ${kisaSure(kisi.bostaSn)}', style: Yazi.olcu(10, agirlik: FontWeight.w700, renk: renk)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Süre renklerinin açıklaması: renk tek başına bilgi değildir.
class _SureAnahtari extends StatelessWidget {
  const _SureAnahtari();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Süre:', style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: Renkler.metin2)),
        for (final r in SureRengi.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Renkler.sure(r), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text(sureEtiketleri[r]!, style: Yazi.olcu(12, renk: Renkler.metin2)),
            ],
          ),
      ],
    );
  }
}

/// "1 dk 40 sn" → "1 dk"; 1 dakikadan kısa süre "1 dk" (sunucu 1 dk'dan önce birlikte saymaz).
String kisaSure(int sn) {
  final dk = sn ~/ 60;
  return dk < 1 ? '1 dk' : sureYazisi(dk * 60);
}
