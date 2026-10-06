import 'package:flutter/widgets.dart';


import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'esik_bolumu.dart';
import 'kart_sagligi_bolumu.dart';
import 'sinyal_grafigi.dart';
import 'sunucu_bolumu.dart';

/// Kurulum sekmesi: eşik, canlı sinyal, kalibrasyon, kart sağlığı.
class KurulumEkrani extends StatelessWidget {
  const KurulumEkrani({super.key, required this.depo, this.sunucuAdresi = '', this.onSunucuAdresi});

  final EtkinlikDeposu depo;

  /// Kayıtlı sunucu adresi ve "Bağlan" geri çağrısı; verilmezse Sunucu bölümü çizilmez (testler).
  final String sunucuAdresi;
  final ValueChanged<String>? onSunucuAdresi;

  static const double _bolumAraligi = 28;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text('Kurulum', style: Yazi.baslik(26, 1.1)),
              ),
              const SizedBox(height: 4),
              Text(
                'Teknik ekran — eşik ayarı, sinyaller ve kart sağlığı. Etkinlik öncesi kullanılır.',
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
              const SizedBox(height: _bolumAraligi),
              if (onSunucuAdresi case final onAdres?) ...[
                SunucuBolumu(depo: depo, sunucuAdresi: sunucuAdresi, onSunucuAdresi: onAdres),
                const SizedBox(height: _bolumAraligi),
              ],
              EsikBolumu(depo: depo),
              const SizedBox(height: _bolumAraligi),
              SinyalBolumu(depo: depo),
              const SizedBox(height: _bolumAraligi),
              const _Kalibrasyon(),
              const SizedBox(height: _bolumAraligi),
              KartSagligiBolumu(depo: depo),
            ],
          ),
        );
      },
    );
  }
}

class _Kalibrasyon extends StatelessWidget {
  const _Kalibrasyon();

  @override
  Widget build(BuildContext context) {
    final dugmeYazisi = Yazi.olcu(14, agirlik: FontWeight.w600, satir: 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Kalibrasyon'),
        const SizedBox(height: 8),
        Text(
          'Elinizdeki iki kartın çiftini seçin. Çift listede yoksa kartlar açık mı, alıcı duyuyor mu '
          'kontrol edin.',
          style: Yazi.olcu(14),
        ),
        const SizedBox(height: 10),
        // Kalibrasyon sihirbazı tasarlanmadı (şartname §2).
        HapDugme(
          etiket: '— çift seçin —',
          yukseklik: 48,
          genis: true,
          zemin: Renkler.yuzey,
          onTap: islevsiz,
          icerik: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('— çift seçin —', style: dugmeYazisi),
              Text('⌄', style: dugmeYazisi),
            ],
          ),
        ),
      ],
    );
  }
}
