import 'package:flutter/widgets.dart';

import '../../bilesenler/kesik_cizgi.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/ag.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// Pano → Ağ: solda yatırımcı/misafir, sağda girişimci; şu an birlikte olan
/// çiftler arasında yeşil kesik çizgi. Düğüm konumu fiziksel konum değildir.
class AgBolumu extends StatelessWidget {
  const AgBolumu({super.key, required this.depo, required this.onKisi});

  final EtkinlikDeposu depo;
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Kicker('Yatırımcı ○')),
              SizedBox(width: 8),
              Flexible(child: Kicker('Girişimci □')),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, kisit) {
              final genislik = kisit.maxWidth;
              final yerlesim = agYerlesimi(depo.kisiler, genislik);
              // Uzun adlar karşı sütuna taşmasın.
              final sutun = BoxConstraints(maxWidth: genislik / 2 - 8);
              return SizedBox(
                height: yerlesim.yukseklik,
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _KenarCizici(yerlesim.kenarlar))),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: sutun,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final d in yerlesim.sol)
                              _Dugum(dugum: d, solda: true, onTap: () => onKisi(d.kisi.id)),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ConstrainedBox(
                        constraints: sutun,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final d in yerlesim.sag)
                              _Dugum(dugum: d, solda: false, onTap: () => onKisi(d.kisi.id)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Düğümlerin konumu fiziksel konum değildir; yalnız rol gruplarını gösterir. '
            'Bir ada dokununca ayrıntı açılır.',
            style: Yazi.olcu(13, renk: Renkler.metin2, stil: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Bir düğüm satırı: solda daire + ad, sağda ad + kare (1 px köşe).
class _Dugum extends StatelessWidget {
  const _Dugum({required this.dugum, required this.solda, required this.onTap});

  final AgDugumu dugum;
  final bool solda;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = Semantics(
      label: rolAdi(dugum.kisi.rol),
      child: SizedBox.square(
        dimension: 14,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Renkler.kisi(dugum.kisi.renk),
            shape: solda ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: solda ? null : const BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ),
    );
    final ad = Flexible(
      child: Text(dugum.ad, maxLines: 1, overflow: TextOverflow.ellipsis, style: Yazi.olcu(13)),
    );
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: agSatirAraligi,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: solda
                ? [sekil, const SizedBox(width: 8), ad]
                : [ad, const SizedBox(width: 8), sekil],
          ),
        ),
      ),
    );
  }
}

class _KenarCizici extends CustomPainter {
  _KenarCizici(this.kenarlar);

  final List<AgKenari> kenarlar;

  @override
  void paint(Canvas canvas, Size size) {
    final boya = Paint()
      ..color = Renkler.birlikte
      ..strokeWidth = 1.2;
    for (final k in kenarlar) {
      kesikCizgi(canvas, Offset(k.x1, k.y1), Offset(k.x2, k.y2), boya, dolu: 4, bos: 4);
    }
  }

  @override
  bool shouldRepaint(_KenarCizici oldDelegate) => oldDelegate.kenarlar != kenarlar;
}
