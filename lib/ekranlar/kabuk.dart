import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bilesenler/uyari_metni.dart';
import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import '../veri/etkinlik_deposu.dart';
import '../veri/sunucu_ayari.dart';
import '../veri/tema_ayari.dart';
import 'kart_ver/kart_ver_durumu.dart';
import 'kart_ver/kart_ver_ekrani.dart';
import 'kisi_detayi/kisi_detay_sayfasi.dart';
import 'kurulum/kurulum_ekrani.dart';
import 'pano/pano_durumu.dart';
import 'pano/pano_ekrani.dart';
import 'pano/uyari_penceresi.dart';
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

class _KabukState extends State<Kabuk> with WidgetsBindingObserver {
  static const int _sekmeKartVer = 1;
  static const int _sekmeKurulum = 2;
  static const int _sekmeRapor = 3;

  /// Rapor sekmesine her gelişte artar: rapor kayıtları yeniden ister (anlık görüntü tazelenir).
  int _raporYenileme = 0;

  late EtkinlikDeposu _depo;
  late final PanoDurumu _panoDurumu;
  late KartVerDurumu _kartVerDurumu;
  late UyariDurumu _uyariDurumu;
  int _sekme = 0;

  /// Kayıtlı sunucu adresi; boş = sahte veri.
  String _sunucuAdresi = '';

  /// Görünüm ayarı (sistem / açık / koyu).
  TemaAyari _temaAyari = TemaAyari.sistem;

  /// Testler için: şu anki depo.
  @visibleForTesting
  EtkinlikDeposu get depo => _depo;

  @override
  void initState() {
    super.initState();
    _depo = widget.depo ?? (EtkinlikDeposu()..baslat());
    _panoDurumu = PanoDurumu();
    _kartVerDurumu = KartVerDurumu(_depo);
    _uyariDurumu = UyariDurumu(_depo);
    WidgetsBinding.instance.addObserver(this);
    // Kayıtlı adres varsa sahte veriden sunucuya geçilir (ayar okunana dek sahte veri görünür).
    if (widget.depo == null) {
      SunucuAyari.oku().then(_sunucuyaBaglan);
      TemaAyarlari.oku().then((ayar) => _temaUygula(ayar, kaydet: false));
    }
  }

  /// Görünüm: ayarı uygular (sistemi izle / açık / koyu), isterse kaydeder.
  void _temaUygula(TemaAyari ayar, {bool kaydet = true}) {
    if (!mounted) return;
    final sistemKoyu = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    setState(() => _temaAyari = ayar);
    Renkler.koyu = koyuMu(ayar, sistemKoyu: sistemKoyu);
    if (kaydet) TemaAyarlari.yaz(ayar);
  }

  /// Sistem teması değişince (ayar "sistem" ise) uygulama da değişir.
  @override
  void didChangePlatformBrightness() {
    if (_temaAyari == TemaAyari.sistem) _temaUygula(_temaAyari, kaydet: false);
  }

  /// Kurulum → Sunucu → Bağlan: depo değişir (eski kapatılır), Kart Ver durumu yeni depoyla kurulur.
  Future<void> _sunucuyaBaglan(String adres) async {
    if (!mounted || adres == _sunucuAdresi) return;
    final eskiDepo = _depo;
    final eskiKartVer = _kartVerDurumu;
    final eskiUyari = _uyariDurumu;
    final yeni = depoKur(adres)..baslat();
    // Kurulum açıkken bağlanıldıysa yeni depo da grafik geçmişini istesin.
    yeni.grafikIste(_sekme == _sekmeKurulum);
    setState(() {
      _sunucuAdresi = adres;
      _depo = yeni;
      _kartVerDurumu = KartVerDurumu(yeni);
      _uyariDurumu = UyariDurumu(yeni);
    });
    eskiKartVer.dispose();
    eskiUyari.dispose();
    eskiDepo.dispose();
    await SunucuAyari.yaz(adres);
  }

  /// Şartname §10: arka planda saat durur, dönünce kaldığı yerden sürer
  /// (telafi yok). Dışarıdan verilen deponun saatini sahibi yönetir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState durum) {
    if (widget.depo != null) return;
    switch (durum) {
      case AppLifecycleState.resumed:
        _depo.baslat();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _depo.durdur();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uyariDurumu.dispose();
    _kartVerDurumu.dispose();
    _panoDurumu.dispose();
    if (widget.depo == null) _depo.dispose();
    super.dispose();
  }

  void _sekmeSec(int sekme) {
    // Gizlenen sekmedeki girdinin klavyesi açık kalmasın.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sekme = sekme;
      if (sekme == _sekmeRapor) _raporYenileme++;
    });
    // Sinyal geçmişi büyük veri: yalnız Kurulum açıkken istenir.
    _depo.grafikIste(sekme == _sekmeKurulum);
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
      // Krem zemin üstünde koyu, koyu zemin üstünde açık durum çubuğu simgeleri.
      value: Renkler.koyu ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ListenableBuilder(
                listenable: _depo,
                builder: (context, _) => _depo.sunucuBagli ? const SizedBox.shrink() : KopukBandi(), // const değil: tema değişince yeniden çizilsin
              ),
              UyariPenceresi(durum: _uyariDurumu, depo: _depo, onKisi: _kisiDetayiAc),
              Expanded(
                // Sekme değişince ekran durumu ve kaydırma konumu korunur.
                // Gizli sekmedeki animasyonlar TickerMode ile durur; yoksa
                // görünmeden kare çizilmeye devam eder (telefonun şarjı).
                child: IndexedStack(
                  index: _sekme,
                  children: [
                    for (final (i, ekran) in [
                      PanoEkrani(
                        depo: _depo,
                        durum: _panoDurumu,
                        onKisi: _kisiDetayiAc,
                        onKurulumaGit: () => _sekmeSec(_sekmeKurulum),
                      ),
                      KartVerEkrani(depo: _depo, durum: _kartVerDurumu),
                      KurulumEkrani(
                        depo: _depo,
                        sunucuAdresi: _sunucuAdresi,
                        onSunucuAdresi: _sunucuyaBaglan,
                        temaAyari: _temaAyari,
                        onTemaAyari: _temaUygula,
                      ),
                      RaporEkrani(depo: _depo, yenileme: _raporYenileme),
                    ].indexed)
                      TickerMode(enabled: i == _sekme, child: ekran),
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

/// Sunucuya bağlanılamıyorken en üstte görünen bant. Veri silinmez; son veri gösterilir.
class KopukBandi extends StatelessWidget {
  const KopukBandi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 4, Olculer.sayfaKenari, 0),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Renkler.ciddiZemin, borderRadius: Olculer.koseYaricap),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  ...uyariParcalari(
                    '⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… ',
                    boyut: 13,
                    renk: Renkler.ciddiKoyu,
                  ),
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
