import 'package:flutter/widgets.dart';

import '../../bilesenler/kesik_cizgi.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// CANLI SİNYAL: en güçlü 6 çiftin son 90 saniyesi, eşik çizgisi ve lejant.
class SinyalBolumu extends StatelessWidget {
  const SinyalBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  static const double _grafikYuksekligi = 150;

  @override
  Widget build(BuildContext context) {
    final esik = dbmYazisi(depo.esik);
    final altYazi = Yazi.olcu(12, renk: Renkler.metin2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Expanded(child: Kicker('Canlı sinyal (son 90 sn)')),
            const SizedBox(width: 8),
            Text('En güçlü 6 çift', style: Yazi.olcu(13, renk: Renkler.metin2)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, kisit) {
            final seriler = grafikSerileri(
              depo.ciftler,
              depo.seriRenkleri,
              depo.tick,
              kisit.maxWidth,
              _grafikYuksekligi,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Canlı sinyal grafiği: en güçlü ${seriler.length} çift, eşik $esik dBm',
                  child: SizedBox(
                    height: _grafikYuksekligi,
                    child: CustomPaint(
                      painter: _GrafikCizici(
                        seriler: seriler,
                        esikY: grafikY(depo.esik, _grafikYuksekligi),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: grafikSolBosluk, top: 4),
                  child: Row(
                    children: [
                      Text('90 sn önce', style: altYazi),
                      Expanded(
                        child: Text(
                          'kesik çizgi: eşik $esik dBm',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: altYazi,
                        ),
                      ),
                      Text('şimdi', style: altYazi),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [for (final seri in seriler) _LejantOgesi(seri: seri)],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LejantOgesi extends StatelessWidget {
  const _LejantOgesi({required this.seri});

  final GrafikSerisi seri;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Renkler.kisi(seri.renk), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Text(seri.ad, style: Yazi.olcu(13, rakam: true)),
      ],
    );
  }
}

class _GrafikCizici extends CustomPainter {
  _GrafikCizici({required this.seriler, required this.esikY});

  final List<GrafikSerisi> seriler;

  /// Eşik çizgisinin y konumu; grafik sınırları içindedir (S15).
  final double esikY;

  @override
  void paint(Canvas canvas, Size size) {
    // Eşik üstü ("yakın") bölge.
    if (esikY > 0) {
      canvas.drawRect(
        Rect.fromLTRB(grafikSolBosluk, 0, size.width, esikY),
        Paint()..color = Renkler.vurguZemin,
      );
    }
    _yaz(canvas, 'eşik üstü — yakın', const Offset(32, 12), Renkler.vurguBasili);
    _yaz(canvas, '−40', const Offset(0, 14), Renkler.metin2);
    _yaz(canvas, '−65', const Offset(0, 76), Renkler.metin2);
    _yaz(canvas, '−90', const Offset(0, 140), Renkler.metin2);

    for (final seri in seriler) {
      final yol = Path();
      for (final (i, nokta) in seri.noktalar.indexed) {
        if (i == 0) {
          yol.moveTo(nokta.x, nokta.y);
        } else {
          yol.lineTo(nokta.x, nokta.y);
        }
      }
      canvas.drawPath(
        yol,
        Paint()
          ..color = Renkler.kisi(seri.renk)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    kesikCizgi(
      canvas,
      Offset(grafikSolBosluk, esikY),
      Offset(size.width, esikY),
      Paint()
        ..color = Renkler.metin
        ..strokeWidth = 1.2,
      dolu: 5,
      bos: 4,
    );
  }

  /// Metni, taban çizgisinin sol ucu `tabanSol`a gelecek biçimde yazar.
  void _yaz(Canvas canvas, String metin, Offset tabanSol, Color renk) {
    final cizer = TextPainter(
      text: TextSpan(text: metin, style: Yazi.olcu(11, satir: 1.2, renk: renk)),
      textDirection: TextDirection.ltr,
    )..layout();
    final taban = cizer.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    cizer.paint(canvas, Offset(tabanSol.dx, tabanSol.dy - taban));
    cizer.dispose();
  }

  @override
  bool shouldRepaint(_GrafikCizici oldDelegate) => true;
}
