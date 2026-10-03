import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../mantik/kisi_gorunum.dart';
import '../tema/renkler.dart';
import '../veri/modeller.dart';

/// Rol şekli: ○ yatırımcı · □ girişimci (1 px köşe) · ◇ misafir (45° dönük,
/// %85 ölçek). Kişi renginde. Kimlik yalnız renkle verilmez: şekil rolü söyler.
class RolSekli extends StatelessWidget {
  const RolSekli({super.key, required this.rol, required this.renk, this.boyut = 12});

  final Rol rol;
  final KisiRengi renk;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    final daire = rol == Rol.yatirimci;
    final Widget kutu = SizedBox.square(
      dimension: boyut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Renkler.kisi(renk),
          shape: daire ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: daire ? null : const BorderRadius.all(Radius.circular(1)),
        ),
      ),
    );
    return Semantics(
      label: rolAdi(rol),
      child: rol == Rol.misafir
          ? Transform.rotate(
              angle: math.pi / 4,
              child: Transform.scale(scale: 0.85, child: kutu),
            )
          : kutu,
    );
  }
}
