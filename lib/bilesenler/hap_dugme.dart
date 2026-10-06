import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

enum HapTuru { birincil, ikincil, hayalet }

/// Prototipte işlevi olmayan düğmeler için (şartname §2): basılı görünümü
/// vardır, eylemi yoktur.
void islevsiz() {}

/// Hap biçimli düğme. Görsel yükseklik `yukseklik` kadardır; dokunma alanı en
/// az 44 px'tir.
class HapDugme extends StatefulWidget {
  const HapDugme({
    super.key,
    required this.etiket,
    required this.onTap,
    this.tur = HapTuru.ikincil,
    this.yukseklik = 44,
    this.punto = 14,
    this.yatayBosluk,
    this.genislik,
    this.genis = false,
    this.zemin,
    this.icerik,
    this.anlam,
  });

  final String etiket;
  final VoidCallback onTap;
  final HapTuru tur;

  /// Görsel yükseklik (en az).
  final double yukseklik;
  final double punto;

  /// Yatay iç boşluk; verilmezse 18 (hayalet düğmede 5).
  final double? yatayBosluk;

  /// Sabit genişlik (ör. 48 × 48 düğmeler).
  final double? genislik;

  /// true ise bulunduğu genişliği doldurur.
  final bool genis;

  /// İkincil düğmenin dolgusu (ör. bant içindeki "Geri al").
  final Color? zemin;

  /// Etiket yerine özel içerik (ör. iki uca yaslı kalibrasyon düğmesi).
  final Widget? icerik;

  /// Ekran okuyucu etiketi (ör. "✕" için "Kapat").
  final String? anlam;

  @override
  State<HapDugme> createState() => _HapDugmeState();
}

class _HapDugmeState extends State<HapDugme> {
  bool _basili = false;

  void _basiliAyarla(bool deger) {
    if (mounted && _basili != deger) setState(() => _basili = deger);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final Color? dolgu;
    final Color yazi;
    final Color? kaplama;
    switch (w.tur) {
      case HapTuru.birincil:
        // Zemin verilirse (ör. kırmızı "Sil", mavi kural "Açık") o renk; basılıyken biraz koyulaşır.
        final z = w.zemin;
        dolgu = z == null ? (_basili ? Renkler.vurguBasili : Renkler.vurgu) : (_basili ? Color.lerp(z, Renkler.metin, 0.2) : z);
        yazi = Renkler.zemin;
        kaplama = null;
      case HapTuru.ikincil:
        dolgu = w.zemin;
        yazi = Renkler.metin;
        kaplama = _basili ? Renkler.ikincilBasili : null;
      case HapTuru.hayalet:
        dolgu = null;
        yazi = Renkler.vurgu;
        kaplama = _basili ? Renkler.hayaletBasili : null;
    }
    final sabit = w.genislik != null;
    final yatay = sabit ? 0.0 : (w.yatayBosluk ?? (w.tur == HapTuru.hayalet ? 5.0 : 18.0));

    final gorsel = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: w.yukseklik,
        minWidth: w.genislik ?? 0,
        maxWidth: w.genislik ?? double.infinity,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dolgu,
          borderRadius: Olculer.hapYaricap,
          border: w.tur == HapTuru.ikincil ? Border.all(color: Renkler.kenarlik) : null,
        ),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(color: kaplama, borderRadius: Olculer.hapYaricap),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: yatay),
            child: Center(
              widthFactor: w.genis ? null : 1,
              heightFactor: 1,
              child:
                  w.icerik ??
                  Text(
                    w.etiket,
                    textAlign: TextAlign.center,
                    style: Yazi.olcu(w.punto, agirlik: FontWeight.w600, satir: 1.2, renk: yazi),
                  ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: w.anlam,
      excludeSemantics: w.anlam != null,
      child: DokunmaHedefi(onTap: w.onTap, onBasili: _basiliAyarla, genis: w.genis, child: gorsel),
    );
  }
}
