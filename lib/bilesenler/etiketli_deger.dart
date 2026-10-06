import 'package:flutter/widgets.dart';

import '../tema/renkler.dart';
import '../tema/yazi.dart';

/// Küçük etiket ve altında değeri (tanım listesi öğesi): "Durum" / "Açık".
class EtiketliDeger extends StatelessWidget {
  const EtiketliDeger({super.key, required this.etiket, required this.deger, this.stil});

  final String etiket;
  final String deger;

  /// Değerin stili; verilmezse 15 px / 600.
  final TextStyle? stil;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiket, style: Yazi.olcu(12, renk: Renkler.metin2)),
        const SizedBox(height: 2),
        Text(deger, style: stil ?? Yazi.olcu(15, agirlik: FontWeight.w600)),
      ],
    );
  }
}
