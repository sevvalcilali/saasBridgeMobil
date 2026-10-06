import 'package:flutter/widgets.dart';

import '../mantik/metin.dart';
import '../tema/yazi.dart';

/// Bölüm üst başlığı: 11 px, büyük harf, harf aralığı .1em, ikincil renk.
/// `sayi` verilirse yanında metin renginde yazılır ("GİRİŞİMCİLER 12").
class Kicker extends StatelessWidget {
  const Kicker(this.metin, {super.key, this.sayi});

  final String metin;
  final String? sayi;

  @override
  Widget build(BuildContext context) {
    final baslik = Text(trBuyuk(metin), style: Yazi.kicker);
    final sayi = this.sayi;
    return Semantics(
      header: true,
      child: sayi == null
          ? baslik
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(child: baslik),
                const SizedBox(width: 8),
                Text(sayi, style: Yazi.olcu(11, harfAraligi: 1.1, rakam: true)),
              ],
            ),
    );
  }
}
