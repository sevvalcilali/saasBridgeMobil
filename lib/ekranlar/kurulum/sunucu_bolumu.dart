import 'package:flutter/material.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/sunucu_adresi.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// Kurulum → Sunucu: panonun çalıştığı bilgisayarın adresi. Boş bırakılırsa uygulama sahte veriyle
/// çalışır (sunucusuz deneme). "Bağlan" düzeltilmiş adresi Kabuk'a verir; Kabuk depoyu değiştirir.
class SunucuBolumu extends StatefulWidget {
  const SunucuBolumu({super.key, required this.depo, required this.sunucuAdresi, required this.onSunucuAdresi});

  final EtkinlikDeposu depo;
  final String sunucuAdresi;
  final ValueChanged<String> onSunucuAdresi;

  @override
  State<SunucuBolumu> createState() => _SunucuBolumuState();
}

class _SunucuBolumuState extends State<SunucuBolumu> {
  late final TextEditingController _adres = TextEditingController(text: widget.sunucuAdresi);

  @override
  void didUpdateWidget(SunucuBolumu eski) {
    super.didUpdateWidget(eski);
    if (eski.sunucuAdresi != widget.sunucuAdresi && _adres.text != widget.sunucuAdresi) {
      _adres.text = widget.sunucuAdresi;
    }
  }

  @override
  void dispose() {
    _adres.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adresVar = widget.sunucuAdresi.isNotEmpty;
    final (durum, renk) = !adresVar
        ? ('Sahte veri (sunucu yok)', Renkler.metin2)
        : widget.depo.sunucuBagli
        ? ('● Bağlı', Renkler.birlikte)
        : ('○ Bağlı değil, deneniyor…', Renkler.uyari);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('SUNUCU'),
        const SizedBox(height: 6),
        Text(
          'Panonun çalıştığı bilgisayarın adresi (telefon aynı Wi-Fi\'da olmalı). '
          'Yalnız IP yazmak yeter; port $sunucuVarsayilanPort varsayılır. Boş bırakılırsa sahte veri.',
          style: Yazi.olcu(14, renk: Renkler.metin2),
        ),
        const SizedBox(height: 10),
        AramaAlani(ipucu: 'ör. 192.168.1.10', denetleyici: _adres),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Text(durum, style: Yazi.olcu(14, renk: renk, agirlik: FontWeight.w600))),
            HapDugme(
              etiket: 'Bağlan',
              tur: HapTuru.birincil,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onSunucuAdresi(sunucuAdresiDuzelt(_adres.text));
              },
            ),
          ],
        ),
      ],
    );
  }
}
