import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kart_no.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';
import 'nabiz.dart';

/// Adım 2 — Kart: "Yaklaştır ve tanı" ya da "Numarayı yaz".
class KartAdimi extends StatelessWidget {
  const KartAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    final numaraModu = durum.kartModu == KartSecimModu.numara;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: 'Kişi: ',
              children: [
                TextSpan(
                  text: kisi == null ? '' : katilimciAdi(kisi),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                ),
              ],
            ),
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 14),
          BolmeliAnahtar<KartSecimModu>(
            ekPunto: 11,
            araCizgi: true,
            secenekler: const [
              BolmeSecenegi(deger: KartSecimModu.yaklastir, etiket: 'Yaklaştır ve tanı', ek: 'önerilen'),
              BolmeSecenegi(deger: KartSecimModu.numara, etiket: 'Numarayı yaz'),
            ],
            secili: durum.kartModu,
            onSecildi: durum.kartModuSec,
          ),
          const SizedBox(height: 14),
          if (numaraModu)
            _NumaraGirisi(depo: depo, durum: durum)
          else if (durum.bulundu case final kart?)
            _Bulundu(kart: kart, onSec: durum.bulunanSec)
          else
            _Bekleme(onDemo: depo.demo ? durum.demoYaklastir : null, uyari: durum.yaklastirmaUyarisi),
          // 14 px bölüm aralığı + 6 px üst boşluk.
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HapDugme(etiket: '← Kişi', onTap: durum.kisiAdiminaDon),
              // Yalnız "Numarayı yaz" modunda ve numara geçerliyken (S13).
              if (numaraModu && durum.numaraSecilebilir)
                HapDugme(etiket: 'Bu kartı seç', tur: HapTuru.birincil, onTap: durum.numaraSec),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kart bekleniyor: nabız; sahte veride demo düğmesi, gerçek sunucuda alıcı bekleniyor (uyarı: iki kart yakın).
class _Bekleme extends StatelessWidget {
  const _Bekleme({required this.onDemo, this.uyari});

  final VoidCallback? onDemo;
  final String? uyari;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Demo düğmesinin görseli 40 px, dokunma alanı 44 px: üstündeki 18 px ve
      // altındaki 16 px boşluğun 2'şer pikseli dokunma alanının içindedir.
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Column(
        children: [
          const Nabiz(),
          const SizedBox(height: 18),
          Text('Kartı alıcıya yaklaştırın…', textAlign: TextAlign.center, style: Yazi.olcu(16)),
          if (uyari case final u?) ...[
            const SizedBox(height: 8),
            Text(u, textAlign: TextAlign.center, style: Yazi.olcu(14, renk: Renkler.uyari)),
          ],
          const SizedBox(height: 16),
          if (onDemo case final demo?) HapDugme(etiket: 'Demo: boş bir kartı yaklaştır', yukseklik: 40, onTap: demo),
        ],
      ),
    );
  }
}

/// Kart bulundu: numara + seç düğmesi.
class _Bulundu extends StatelessWidget {
  const _Bulundu({required this.kart, required this.onSec});

  final String kart;
  final VoidCallback onSec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        children: [
          Text(
            'Kart $kart bulundu ✓',
            textAlign: TextAlign.center,
            style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1),
          ),
          const SizedBox(height: 14),
          Text(
            'Açık · az önce duyuldu · boşta',
            textAlign: TextAlign.center,
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 14),
          HapDugme(
            etiket: 'Bu kartı seç',
            tur: HapTuru.birincil,
            yukseklik: 48,
            punto: 16,
            yatayBosluk: 28,
            onTap: onSec,
          ),
        ],
      ),
    );
  }
}

/// Numara girdisi + "şu an açık kartlar" ızgarası.
class _NumaraGirisi extends StatelessWidget {
  const _NumaraGirisi({required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Kart numarası (kartın üstündeki etiket)', style: Yazi.olcu(13, renk: Renkler.metin2)),
        const SizedBox(height: 6),
        AramaAlani(
          ipucu: 'Örn. 14',
          denetleyici: durum.numaraDenetleyici,
          yukseklik: 52,
          punto: 24,
          agirlik: FontWeight.w600,
          harfAraligi: 1.2,
          rakam: true,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: Kicker('Şu an açık kartlar')),
            const SizedBox(width: 8),
            Kicker('${depo.acikKartlar.length}'),
          ],
        ),
        const SizedBox(height: 14),
        _KartIzgarasi(kartlar: acikKartOner(depo.acikKartlar, durum.numara), onSec: durum.acikKartSec),
      ],
    );
  }
}

/// 3 sütunlu kart ızgarası.
class _KartIzgarasi extends StatelessWidget {
  const _KartIzgarasi({required this.kartlar, required this.onSec});

  final List<AcikKart> kartlar;
  final ValueChanged<String> onSec;

  static const int _sutun = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var bas = 0; bas < kartlar.length; bas += _sutun) ...[
          if (bas > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var i = bas; i < bas + _sutun; i++) ...[
                if (i > bas) const SizedBox(width: 8),
                Expanded(
                  child: i < kartlar.length
                      ? _Hucre(kart: kartlar[i], onTap: () => onSec(kartlar[i].no))
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Hucre extends StatelessWidget {
  const _Hucre({required this.kart, required this.onTap});

  final AcikKart kart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kart ${kart.no}', style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
                  const SizedBox(height: 2),
                  Text(acikKartEtiketi(kart), style: Yazi.olcu(12, renk: Renkler.metin2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
