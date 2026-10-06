import 'package:flutter/material.dart';

import '../tema/renkler.dart';

// "⚠" yazı simgesi Android'de renkli emoji olarak çizilir. Ekranda her "⚠",
// yazıyla aynı boyut ve renkte Material uyarı ikonuyla değiştirilir (şartname
// §10). Mantık katmanı metni "⚠ pil düşük" diye üretmeye devam eder; değişim
// yalnız görünümdedir.

const String _uyariIsareti = '⚠';

/// Metni parçalara böler; her "⚠" yerine uyarı ikonu koyar.
List<InlineSpan> uyariParcalari(String metin, {required double boyut, required Color renk}) {
  final parcalar = metin.split(_uyariIsareti);
  return [
    for (var i = 0; i < parcalar.length; i++) ...[
      if (i > 0)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(Icons.warning_amber_rounded, size: boyut, color: renk, semanticLabel: 'Uyarı'),
        ),
      if (parcalar[i].isNotEmpty) TextSpan(text: parcalar[i]),
    ],
  ];
}

/// "⚠" içerebilen tek parça metin.
class UyariMetni extends StatelessWidget {
  const UyariMetni(this.metin, {super.key, required this.stil});

  final String metin;
  final TextStyle stil;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: uyariParcalari(metin, boyut: stil.fontSize ?? 14, renk: stil.color ?? Renkler.metin)),
      style: stil,
    );
  }
}
