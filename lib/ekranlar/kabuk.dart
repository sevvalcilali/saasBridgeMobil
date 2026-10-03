import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import '../veri/etkinlik_deposu.dart';
import 'kart_ver/kart_ver_durumu.dart';
import 'kart_ver/kart_ver_ekrani.dart';
import 'kisi_detayi/kisi_detay_sayfasi.dart';
import 'kurulum/kurulum_ekrani.dart';
import 'pano/pano_durumu.dart';
import 'pano/pano_ekrani.dart';
import 'rapor/rapor_ekrani.dart';

/// Uygulamanın kabuğu: dört sekme, alıcı kopuk bandı ve Kişi Detayı.
class Kabuk extends StatefulWidget {
  const Kabuk({super.key, this.depo});

  /// Testlerde dışarıdan verilir (saat testin denetiminde olur). Verilmezse
  /// Kabuk kendi deposunu kurar, saati başlatır ve kapanırken bırakır.
  final EtkinlikDeposu? depo;

  @override
  State<Kabuk> createState() => _KabukState();
}

class _KabukState extends State<Kabuk> {
  static const int _sekmeKartVer = 1;
  static const int _sekmeKurulum = 2;

  late final EtkinlikDeposu _depo;
  late final PanoDurumu _panoDurumu;
  late final KartVerDurumu _kartVerDurumu;
  int _sekme = 0;

  @override
  void initState() {
    super.initState();
    _depo = widget.depo ?? (EtkinlikDeposu()..baslat());
    _panoDurumu = PanoDurumu();
    _kartVerDurumu = KartVerDurumu(_depo);
  }

  @override
  void dispose() {
    _kartVerDurumu.dispose();
    _panoDurumu.dispose();
    if (widget.depo == null) _depo.dispose();
    super.dispose();
  }

  void _sekmeSec(int sekme) {
    // Gizlenen sekmedeki girdinin klavyesi açık kalmasın.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _sekme = sekme);
  }

  Future<void> _kisiDetayiAc(String kisiId) async {
    final eylem = await kisiDetayiGoster(context, depo: _depo, kisiId: kisiId);
    if (!mounted || eylem == null) return;
    switch (eylem) {
      case DetayEylemi.kartDegistir:
        _kartVerDurumu.kartDegistirBaslat(kisiId);
      case DetayEylemi.kartIade:
        _kartVerDurumu.iadeBaslat(kisiId);
    }
    _sekmeSec(_sekmeKartVer);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Krem zemin üstünde koyu durum çubuğu simgeleri.
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (!_depo.aliciBagli) const KopukBandi(),
              Expanded(
                // Sekme değişince ekran durumu ve kaydırma konumu korunur.
                child: IndexedStack(
                  index: _sekme,
                  children: [
                    PanoEkrani(
                      depo: _depo,
                      durum: _panoDurumu,
                      onKisi: _kisiDetayiAc,
                      onKurulumaGit: () => _sekmeSec(_sekmeKurulum),
                    ),
                    KartVerEkrani(depo: _depo, durum: _kartVerDurumu),
                    KurulumEkrani(depo: _depo),
                    RaporEkrani(depo: _depo),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _sekme,
          onTap: _sekmeSec,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Pano'),
            BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Kart Ver'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Kurulum'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rapor'),
          ],
        ),
      ),
    );
  }
}

/// Alıcı kopukken en üstte görünen bant. Veri silinmez; son veri gösterilir.
class KopukBandi extends StatelessWidget {
  const KopukBandi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 4, Olculer.sayfaKenari, 0),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Renkler.ciddiZemin, borderRadius: Olculer.koseYaricap),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text.rich(
              TextSpan(
                text: '⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… ',
                children: [
                  TextSpan(
                    text: 'son veri gösteriliyor',
                    style: TextStyle(color: Renkler.ciddiKoyu.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              style: Yazi.olcu(13, renk: Renkler.ciddiKoyu),
            ),
          ),
        ),
      ),
    );
  }
}
