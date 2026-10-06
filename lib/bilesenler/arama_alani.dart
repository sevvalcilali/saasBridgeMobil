import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';

/// Hap biçimli metin girdisi: yüzey zemin, 1 px kenarlık, sol iç boşluk 16.
class AramaAlani extends StatelessWidget {
  const AramaAlani({
    super.key,
    required this.ipucu,
    this.denetleyici,
    this.onDegisti,
    this.yukseklik = 44,
    this.punto = 15,
    this.agirlik = FontWeight.w400,
    this.harfAraligi = 0,
    this.rakam = false,
    this.klavye,
  });

  final String ipucu;
  final TextEditingController? denetleyici;
  final ValueChanged<String>? onDegisti;

  /// En az yükseklik.
  final double yukseklik;
  final double punto;
  final FontWeight agirlik;
  final double harfAraligi;

  /// true: rakam klavyesi açar ve rakam dışını kabul etmez.
  final bool rakam;

  /// Rakam değilse klavye türü (e-posta, adres); verilmezse metin.
  final TextInputType? klavye;

  static const double _satir = 1.4;

  OutlineInputBorder _kenar(Color renk) =>
      OutlineInputBorder(borderRadius: Olculer.hapYaricap, borderSide: BorderSide(color: renk));

  @override
  Widget build(BuildContext context) {
    final dikey = math.max(0.0, (yukseklik - punto * _satir) / 2);
    return TextField(
      controller: denetleyici,
      onChanged: onDegisti,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      keyboardType: rakam ? TextInputType.number : (klavye ?? TextInputType.text),
      textInputAction: rakam ? TextInputAction.done : TextInputAction.search,
      inputFormatters: rakam ? [FilteringTextInputFormatter.digitsOnly] : null,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: Renkler.vurgu,
      style: Yazi.olcu(punto, agirlik: agirlik, satir: _satir, harfAraligi: harfAraligi, rakam: rakam),
      decoration: InputDecoration(
        hintText: ipucu,
        hintStyle: Yazi.olcu(
          punto,
          agirlik: agirlik,
          satir: _satir,
          harfAraligi: harfAraligi,
          renk: Renkler.ipucu,
        ),
        isDense: true,
        filled: true,
        fillColor: Renkler.yuzey,
        contentPadding: EdgeInsets.fromLTRB(16, dikey, 10, dikey),
        border: _kenar(Renkler.kenarlik),
        enabledBorder: _kenar(Renkler.kenarlik),
        focusedBorder: _kenar(Renkler.vurgu),
      ),
    );
  }
}
