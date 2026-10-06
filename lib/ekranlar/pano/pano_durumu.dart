import 'package:flutter/widgets.dart';

import '../../mantik/pano_filtre.dart';
import '../../veri/modeller.dart';

enum PanoBolumu { kisiler, salon, bildirimler }

/// Pano ekranının durumu: seçili bölüm, kişi filtresi, arama, bildirim önemi.
/// Sekme değişse de korunur (Kabuk bu nesneyi tutar).
class PanoDurumu extends ChangeNotifier {
  PanoDurumu() {
    aramaDenetleyici.addListener(notifyListeners);
  }

  /// Arama metni burada tutulur: bölüm değişip geri gelince kaybolmaz.
  final TextEditingController aramaDenetleyici = TextEditingController();

  PanoBolumu _bolum = PanoBolumu.kisiler;
  PanoFiltre _filtre = PanoFiltre.girisimci;
  Onem? _onem;

  PanoBolumu get bolum => _bolum;
  PanoFiltre get filtre => _filtre;
  String get arama => aramaDenetleyici.text;

  /// Seçili bildirim önemi; `null` = Tümü.
  Onem? get onem => _onem;

  void bolumSec(PanoBolumu bolum) {
    if (_bolum == bolum) return;
    _bolum = bolum;
    notifyListeners();
  }

  void filtreSec(PanoFiltre filtre) {
    if (_filtre == filtre) return;
    _filtre = filtre;
    notifyListeners();
  }

  void onemSec(Onem? onem) {
    if (_onem == onem) return;
    _onem = onem;
    notifyListeners();
  }

  @override
  void dispose() {
    aramaDenetleyici.dispose();
    super.dispose();
  }
}
