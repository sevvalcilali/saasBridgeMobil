import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';

class BolmeSecenegi<T> {
  const BolmeSecenegi({required this.deger, required this.etiket, this.ek});

  final T deger;
  final String etiket;

  /// Etiketin yanında soluk küçük yazı: sayı ("26") ya da "önerilen".
  final String? ek;
}

/// Bölmeli anahtar: 1 px çerçeve, köşe 12; seçili parça vurgu dolguludur.
class BolmeliAnahtar<T> extends StatelessWidget {
  const BolmeliAnahtar({
    super.key,
    required this.secenekler,
    required this.secili,
    required this.onSecildi,
    this.yukseklik = 44,
    this.punto = 14,
    this.agirlik = FontWeight.w400,
    this.ekPunto = 12,
    this.araCizgi = false,
  });

  final List<BolmeSecenegi<T>> secenekler;
  final T secili;
  final ValueChanged<T> onSecildi;
  final double yukseklik;
  final double punto;
  final FontWeight agirlik;
  final double ekPunto;

  /// Parçalar arasında 1 px ayraç çizer.
  final bool araCizgi;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: yukseklik,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Renkler.ayrac),
        borderRadius: Olculer.koseYaricap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < secenekler.length; i++) Expanded(child: _parca(secenekler[i], ilk: i == 0)),
        ],
      ),
    );
  }

  Widget _parca(BolmeSecenegi<T> secenek, {required bool ilk}) {
    final seciliMi = secenek.deger == secili;
    final renk = seciliMi ? Renkler.zemin : Renkler.metin;
    return Semantics(
      button: true,
      selected: seciliMi,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSecildi(secenek.deger),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: seciliMi ? Renkler.vurgu : null,
            border: araCizgi && !ilk ? Border(left: BorderSide(color: Renkler.ayrac)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            // Dar ekranda ya da büyük yazıda etiket sığmazsa küçülür, taşmaz.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(secenek.etiket, style: Yazi.olcu(punto, agirlik: agirlik, renk: renk)),
                  if (secenek.ek case final ek? when ek.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(ek, style: Yazi.olcu(ekPunto, renk: renk.withValues(alpha: 0.75))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
