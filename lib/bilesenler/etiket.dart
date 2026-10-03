import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

enum EtiketTuru { vurgu, notr }

/// Küçük hap etiket: 11 px, görsel yükseklik 28 px. `onTap` verilirse dokunma
/// alanı 44 px olur.
class Etiket extends StatelessWidget {
  const Etiket(this.metin, {super.key, this.tur = EtiketTuru.vurgu, this.onTap});

  final String metin;
  final EtiketTuru tur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (zemin, yazi) = switch (tur) {
      EtiketTuru.vurgu => (Renkler.vurguZemin, Renkler.vurguKoyu),
      EtiketTuru.notr => (Renkler.acikYuzey, Renkler.metinKoyu2),
    };
    final gorsel = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(color: zemin, borderRadius: Olculer.hapYaricap),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(metin, style: Yazi.olcu(11, renk: yazi, harfAraligi: 0.22)),
          ),
        ),
      ),
    );
    if (onTap == null) return gorsel;
    return Semantics(
      button: true,
      child: DokunmaHedefi(onTap: onTap, child: gorsel),
    );
  }
}
