import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

/// Filtre çipi: görsel 36 px, hap, 13 px; dokunma alanı 44 px.
class Cip extends StatelessWidget {
  const Cip({
    super.key,
    required this.etiket,
    required this.secili,
    required this.onTap,
    this.sayi,
    this.seciliRenk,
    this.yatayBosluk = 14,
  });

  final String etiket;
  final bool secili;
  final VoidCallback onTap;

  /// Etiketin yanında soluk sayı (önem çipleri).
  final String? sayi;

  /// Seçili dolgu: filtre çiplerinde vurgu, önem çiplerinde metin rengi.
  /// Seçili çipin zemini; verilmezse vurgu.
  final Color? seciliRenk;
  final double yatayBosluk;

  @override
  Widget build(BuildContext context) {
    final yazi = secili ? Renkler.zemin : Renkler.metin;
    final sayi = this.sayi;
    return Semantics(
      button: true,
      selected: secili,
      child: DokunmaHedefi(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: secili ? (seciliRenk ?? Renkler.vurgu) : null,
              border: Border.all(color: secili ? (seciliRenk ?? Renkler.vurgu) : Renkler.ayrac),
              borderRadius: Olculer.hapYaricap,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: yatayBosluk),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text.rich(
                  TextSpan(
                    text: etiket,
                    children: [
                      if (sayi != null)
                        TextSpan(
                          text: ' $sayi',
                          style: TextStyle(color: yazi.withValues(alpha: 0.7)),
                        ),
                    ],
                  ),
                  style: Yazi.olcu(13, renk: yazi),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
