import 'dart:async';

import 'package:flutter/material.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kalibrasyon.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Kalibrasyon sihirbazı (web `KalibrasyonSihirbazi.jsx`): elinizdeki iki kartın çiftini seçin; 1) yüz yüze 10 sn
/// tutun → ölçüm; 2) sırt sırta 10 sn → ölçüm; 3) ikisinin ortası eşik önerilir → uygula. Ölçüm sunucunun o çift
/// için verdiği son 10 sn ortancasıdır. Sahte veride "Demo" düğmeleri örnek ölçüm girer.
class KalibrasyonBolumu extends StatefulWidget {
  const KalibrasyonBolumu({super.key, required this.depo, this.saniye = const Duration(seconds: 1)});

  final EtkinlikDeposu depo;

  /// Geri sayım adımı (testlerde kısaltılır).
  final Duration saniye;

  @override
  State<KalibrasyonBolumu> createState() => _KalibrasyonBolumuState();
}

class _KalibrasyonBolumuState extends State<KalibrasyonBolumu> {
  String? _cift; // "a-b"
  double? _yuzyuze;
  double? _sirtsirta;
  int? _olcuyor; // 0 yüz yüze, 1 sırt sırta
  int _kalan = kalibrasyonSn;
  Timer? _sayac;
  String? _uygulama;

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  Cift? get _secili {
    final c = _cift;
    if (c == null) return null;
    for (final x in widget.depo.ciftler) {
      if ('${x.a}-${x.b}' == c) return x;
    }
    return null;
  }

  String _kartAdi(String no) {
    for (final k in widget.depo.katilimcilar) {
      if (k.atananKart == no) return '$no · ${k.kurum ?? k.ad}';
    }
    return no;
  }

  void _cifteGec(String? c) {
    _sayac?.cancel();
    setState(() {
      _cift = c;
      _yuzyuze = null;
      _sirtsirta = null;
      _olcuyor = null;
      _uygulama = null;
    });
  }

  void _olc(int adim) {
    _sayac?.cancel();
    setState(() {
      _olcuyor = adim;
      _kalan = kalibrasyonSn;
    });
    _sayac = Timer.periodic(widget.saniye, (t) {
      if (!mounted) return;
      if (_kalan > 1) {
        setState(() => _kalan--);
        return;
      }
      t.cancel();
      final deger = _secili?.rssi.toDouble();
      setState(() {
        _olcuyor = null;
        if (adim == 0) {
          _yuzyuze = deger;
        } else {
          _sirtsirta = deger;
        }
      });
    });
  }

  void _demo(int adim) => setState(() => adim == 0 ? _yuzyuze = -58.4 : _sirtsirta = -78.0);

  void _uygula(int deger) {
    widget.depo.esikAyarla(deger);
    setState(() => _uygulama = 'Eşik $deger dBm olarak uygulandı.');
  }

  Future<void> _ciftSec() async {
    final ciftler = [...widget.depo.ciftler]..sort((a, b) => b.rssi.compareTo(a.rssi));
    final secim = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Renkler.yuzey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 16),
          children: [
            Text('Çift seçin (en güçlü üstte)', style: Yazi.olcu(16, agirlik: FontWeight.w600)),
            const SizedBox(height: 8),
            if (ciftler.isEmpty) Text('Duyulan çift yok.', style: Yazi.olcu(14, renk: Renkler.metin2)),
            for (final c in ciftler)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Kart ${_kartAdi(c.a)}  ↔  Kart ${_kartAdi(c.b)}', style: Yazi.olcu(15)),
                trailing: Text('${dbmYazisi(c.rssi)} dBm', style: Yazi.olcu(14, renk: Renkler.metin2, rakam: true)),
                onTap: () => Navigator.of(ctx).pop('${c.a}-${c.b}'),
              ),
          ],
        ),
      ),
    );
    if (secim != null) _cifteGec(secim);
  }

  @override
  Widget build(BuildContext context) {
    final secili = _secili;
    final oneri = onerilenEsik(_yuzyuze, _sirtsirta);
    final dugmeYazisi = Yazi.olcu(14, agirlik: FontWeight.w600, satir: 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Kalibrasyon'),
        const SizedBox(height: 8),
        Text(
          'Elinizdeki iki kartın çiftini seçin. Çift listede yoksa kartlar açık mı, alıcı duyuyor mu kontrol edin.',
          style: Yazi.olcu(14),
        ),
        const SizedBox(height: 10),
        HapDugme(
          etiket: secili == null ? '— çift seçin —' : 'Kart ${secili.a} ↔ Kart ${secili.b}',
          yukseklik: 48,
          genis: true,
          zemin: Renkler.yuzey,
          onTap: _ciftSec,
          icerik: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(secili == null ? '— çift seçin —' : 'Kart ${_kartAdi(secili.a)}  ↔  Kart ${_kartAdi(secili.b)}', style: dugmeYazisi, overflow: TextOverflow.ellipsis)),
              Text('⌄', style: dugmeYazisi),
            ],
          ),
        ),
        if (secili != null) ...[
          const SizedBox(height: 6),
          Text('Şu an ${dbmYazisi(secili.rssi)} dBm', style: Yazi.olcu(13, renk: Renkler.metin2, rakam: true)),
          const SizedBox(height: 12),
          for (final (i, (baslik, yonerge)) in const [
            ('Yüz yüze', 'İki kartı iki kişi göğüs hizasında, yüz yüze ve konuşur gibi tutsun.'),
            ('Sırt sırta', 'Şimdi sırt sırta dursunlar (ya da 2–3 adım uzaklaşsınlar).'),
          ].indexed)
            _Adim(
              no: i + 1,
              baslik: baslik,
              yonerge: yonerge,
              olcum: i == 0 ? _yuzyuze : _sirtsirta,
              olcuyor: _olcuyor == i,
              kalan: _kalan,
              etkin: _olcuyor == null,
              onOlc: () => _olc(i),
              onDemo: widget.depo.demo ? () => _demo(i) : null,
            ),
          if (oneri != null) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(color: Renkler.vurguZemin, borderRadius: Olculer.koseYaricap),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (oneri.uyari == KalibrasyonUyarisi.ters)
                      Text('Sırt sırta ölçüm yüz yüzeden güçlü çıktı — ölçümler karışmış olabilir. İki adımı tekrarlayın.',
                          style: Yazi.olcu(14, renk: Renkler.ciddi))
                    else ...[
                      Text('Fark ${oneri.fark} dB · önerilen eşik ${dbmYazisi(oneri.deger!)} dBm (şu an ${dbmYazisi(widget.depo.esik)}).',
                          style: Yazi.olcu(14, rakam: true)),
                      if (oneri.uyari == KalibrasyonUyarisi.kucuk) ...[
                        const SizedBox(height: 4),
                        Text('Fark küçük: eşik iki durumu güvenilir ayıramayabilir. Sırt sırta adımında biraz uzaklaşın.',
                            style: Yazi.olcu(13, renk: Renkler.uyari)),
                      ],
                      const SizedBox(height: 8),
                      HapDugme(
                        etiket: 'Eşiği uygula (${dbmYazisi(oneri.deger!)})',
                        tur: HapTuru.birincil,
                        yukseklik: 44,
                        onTap: oneri.deger == widget.depo.esik ? islevsiz : () => _uygula(oneri.deger!),
                      ),
                      if (_uygulama case final u?) ...[const SizedBox(height: 6), Text(u, style: Yazi.olcu(13, renk: Renkler.birlikte))],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _Adim extends StatelessWidget {
  const _Adim({
    required this.no,
    required this.baslik,
    required this.yonerge,
    required this.olcum,
    required this.olcuyor,
    required this.kalan,
    required this.etkin,
    required this.onOlc,
    required this.onDemo,
  });

  final int no;
  final String baslik;
  final String yonerge;
  final double? olcum;
  final bool olcuyor;
  final int kalan;
  final bool etkin;
  final VoidCallback onOlc;
  final VoidCallback? onDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 28, child: Text('$no', style: Yazi.olcu(22, agirlik: FontWeight.w600, renk: olcum != null ? Renkler.birlikte : Renkler.metin))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: Yazi.olcu(15, agirlik: FontWeight.w600)),
                Text(yonerge, style: Yazi.olcu(13, renk: Renkler.metin2)),
                const SizedBox(height: 6),
                if (olcuyor)
                  Text('Tutmaya devam edin… $kalan sn', style: Yazi.olcu(14, agirlik: FontWeight.w600, rakam: true))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      HapDugme(etiket: olcum == null ? 'Ölç (10 sn)' : 'Yeniden ölç', yukseklik: 36, onTap: etkin ? onOlc : islevsiz),
                      if (onDemo case final d?) HapDugme(etiket: 'Demo', tur: HapTuru.hayalet, yukseklik: 36, onTap: etkin ? d : islevsiz),
                      if (olcum != null) Text('${dbmYazisi(olcum!.round())} dBm ✓', style: Yazi.olcu(14, agirlik: FontWeight.w600, renk: Renkler.birlikte, rakam: true)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
