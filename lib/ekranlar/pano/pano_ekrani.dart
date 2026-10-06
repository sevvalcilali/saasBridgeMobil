import 'package:flutter/widgets.dart';

import '../../veri/etkinlik_deposu.dart';
import 'ag_bolumu.dart';
import 'bildirimler_bolumu.dart';
import 'kisiler_bolumu.dart';
import 'pano_durumu.dart';
import 'pano_ust.dart';

/// Pano sekmesi: üst alan + seçili bölüm (Kişiler · Ağ · Bildirimler).
class PanoEkrani extends StatelessWidget {
  const PanoEkrani({
    super.key,
    required this.depo,
    required this.durum,
    required this.onKisi,
    required this.onKurulumaGit,
  });

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Bir kişiye dokununca kart numarasıyla çağrılır (Kişi Detayı açılır).
  final ValueChanged<String> onKisi;
  final VoidCallback onKurulumaGit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([depo, durum]),
      builder: (context, _) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanoUst(depo: depo, durum: durum, onKurulumaGit: onKurulumaGit),
              switch (durum.bolum) {
                PanoBolumu.kisiler => KisilerBolumu(depo: depo, durum: durum, onKisi: onKisi),
                PanoBolumu.ag => AgBolumu(depo: depo, onKisi: onKisi),
                PanoBolumu.bildirimler => BildirimlerBolumu(depo: depo, durum: durum, onKisi: onKisi),
              },
            ],
          ),
        );
      },
    );
  }
}
