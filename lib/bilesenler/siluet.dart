import 'package:flutter/widgets.dart';

import '../tema/renkler.dart';
import '../veri/modeller.dart';

/// Karikatür insan figürü (salon görünümü; web `Siluet.jsx` ile aynı çizim): büyük yuvarlak baş, iki göz,
/// gülümseme, dolgulu yuvarlak gövde, kısa bacaklar. Çizim alanı 60 × 100; `genislik` ile ölçeklenir.
/// Renk = görüşme süresi. Üç duruş: 0 kollar yanda, 1 el kalkık (konuşuyor), 2 elinde bardak.
/// Varsayılan sağa bakar; `ayna` sola çevirir (grubun ortasına dönsün). Rol işareti göğüste:
/// ○ yatırımcı, □ girişimci, ◇ misafir.
class Siluet extends StatelessWidget {
  const Siluet({super.key, required this.renk, required this.rol, this.poz = 0, this.ayna = false, this.genislik = 34});

  final Color renk;
  final Rol rol;
  final int poz;
  final bool ayna;
  final double genislik;

  static const double oran = 100 / 60;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(genislik, genislik * oran),
      painter: _SiluetCizici(renk: renk, rol: rol, poz: poz, ayna: ayna),
    );
  }
}

class _SiluetCizici extends CustomPainter {
  const _SiluetCizici({required this.renk, required this.rol, required this.poz, required this.ayna});

  final Color renk;
  final Rol rol;
  final int poz;
  final bool ayna;

  @override
  void paint(Canvas canvas, Size size) {
    final olcek = size.width / 60;
    canvas.save();
    canvas.scale(olcek);
    if (ayna) {
      canvas.translate(60, 0);
      canvas.scale(-1, 1);
    }
    final cizgi = Paint()
      ..color = renk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dolgu = Paint()..color = renk.withValues(alpha: 0.16);
    final yuzey = Paint()..color = Renkler.yuzey;

    // Gövde: dolgu + çizgi.
    final govde = Path()
      ..moveTo(18, 42)
      ..quadraticBezierTo(30, 34, 42, 42)
      ..lineTo(45, 70)
      ..quadraticBezierTo(30, 75, 15, 70)
      ..close();
    canvas.drawPath(govde, dolgu);
    canvas.drawPath(govde, cizgi);
    // Kollar.
    final sol = Path()..moveTo(18, 44);
    final sag = Path()..moveTo(42, 44);
    switch (poz) {
      case 1:
        sol.quadraticBezierTo(11, 55, 14, 66);
        sag.quadraticBezierTo(52, 44, 54, 32);
      case 2:
        sol.quadraticBezierTo(9, 52, 14, 58);
        sag.quadraticBezierTo(49, 55, 46, 66);
      default:
        sol.quadraticBezierTo(11, 55, 14, 66);
        sag.quadraticBezierTo(49, 55, 46, 66);
    }
    canvas.drawPath(sol, cizgi);
    canvas.drawPath(sag, cizgi);
    if (poz == 2) {
      final bardak = Path()
        ..moveTo(9.5, 53.5)
        ..lineTo(17, 53.5)
        ..lineTo(16, 61)
        ..lineTo(10.5, 61)
        ..close();
      canvas.drawPath(bardak, yuzey);
      canvas.drawPath(bardak, cizgi);
    }
    // Bacaklar ve ayaklar.
    final bacaklar = Path()
      ..moveTo(23, 72)
      ..lineTo(22, 92)
      ..moveTo(37, 72)
      ..lineTo(38, 92)
      ..moveTo(22, 92)
      ..lineTo(15.5, 93.5)
      ..moveTo(38, 92)
      ..lineTo(44.5, 93.5);
    canvas.drawPath(bacaklar, cizgi);
    // Baş ve yüz.
    canvas.drawCircle(const Offset(30, 19), 12.5, yuzey);
    canvas.drawCircle(const Offset(30, 19), 12.5, cizgi);
    final goz = Paint()..color = renk;
    canvas.drawCircle(const Offset(25.5, 18), 1.5, goz);
    canvas.drawCircle(const Offset(34.5, 18), 1.5, goz);
    final gulus = Path()
      ..moveTo(26, 24)
      ..quadraticBezierTo(30, 27.5, 34, 24);
    canvas.drawPath(gulus, cizgi..strokeWidth = 1.8);
    canvas.restore();

    // Rol işareti (aynalanmaz; göğüs ortasında).
    canvas.save();
    canvas.scale(olcek);
    final isaretCizgi = Paint()
      ..color = renk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    switch (rol) {
      case Rol.yatirimci:
        canvas.drawCircle(const Offset(30, 56), 3.8, yuzey);
        canvas.drawCircle(const Offset(30, 56), 3.8, isaretCizgi);
      case Rol.girisimci:
        final kare = RRect.fromRectAndRadius(const Rect.fromLTWH(26.5, 52.5, 7, 7), const Radius.circular(1));
        canvas.drawRRect(kare, yuzey);
        canvas.drawRRect(kare, isaretCizgi);
      case Rol.misafir:
        final elmas = Path()
          ..moveTo(30, 51.8)
          ..lineTo(34.2, 56)
          ..lineTo(30, 60.2)
          ..lineTo(25.8, 56)
          ..close();
        canvas.drawPath(elmas, yuzey);
        canvas.drawPath(elmas, isaretCizgi);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SiluetCizici eski) =>
      eski.renk != renk || eski.rol != rol || eski.poz != poz || eski.ayna != ayna;
}
