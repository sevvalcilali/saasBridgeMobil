import 'package:flutter/material.dart';

import '../../bilesenler/etiketli_deger.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Kişi Detayı'ndaki kısayollar.
enum DetayEylemi { kartDegistir, kartIade }

/// Kişi Detayı'nı alt sayfa olarak açar. Kısayola basılırsa eylemle, aksi halde
/// (✕, perde, aşağı çekme) `null` ile tamamlanır.
Future<DetayEylemi?> kisiDetayiGoster(
  BuildContext context, {
  required EtkinlikDeposu depo,
  required String kisiId,
}) {
  return showModalBottomSheet<DetayEylemi>(
    context: context,
    isScrollControlled: true,
    // Köşe, zemin ve gölgeyi sayfa kendisi çizer.
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Renkler.perde,
    builder: (_) => KisiDetaySayfasi(depo: depo, kisiId: kisiId),
  );
}

class KisiDetaySayfasi extends StatelessWidget {
  const KisiDetaySayfasi({super.key, required this.depo, required this.kisiId});

  final EtkinlikDeposu depo;
  final String kisiId;

  /// Sayfa ekranın en çok bu kadarını kaplar.
  static const double _enCokOran = 0.78;

  @override
  Widget build(BuildContext context) {
    final enCok = MediaQuery.sizeOf(context).height * _enCokOran;
    final altGuvenli = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        final k = depo.bul(kisiId);
        final gunBoyu = depo.gunBoyu(k.id);
        final toplam = sureYazisi(gecenSn(k, depo.tick));
        return Container(
          constraints: BoxConstraints(maxHeight: enCok),
          decoration: BoxDecoration(
            color: Renkler.zemin,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Olculer.koseAltSayfa)),
            boxShadow: Olculer.altSayfaGolgesi,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutamaç kaydırma alanının dışındadır: aşağı çekince sayfa kapanır.
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 18),
                child: Center(child: _Tutamac()),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(Olculer.sayfaKenari, 0, Olculer.sayfaKenari, 10 + altGuvenli),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _baslik(context, k),
                      const SizedBox(height: 18),
                      _alanlar(k, toplam),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: HapDugme(
                              etiket: 'Kartı değiştir',
                              tur: HapTuru.birincil,
                              yukseklik: 48,
                              genis: true,
                              onTap: () => Navigator.of(context).pop(DetayEylemi.kartDegistir),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: HapDugme(
                              etiket: 'Kartı iade al',
                              yukseklik: 48,
                              genis: true,
                              onTap: () => Navigator.of(context).pop(DetayEylemi.kartIade),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Kicker('Bugün kiminle'),
                      if (gunBoyu.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Henüz kimseyle görüşmedi.',
                            style: Yazi.olcu(15, renk: Renkler.metin2, stil: FontStyle.italic),
                          ),
                        )
                      else
                        for (final e in gunBoyu) _EsSatiri(es: e.kisi, sure: sureYazisi(e.sn)),
                      const SizedBox(height: 18),
                      const Kicker('Görüşme zaman çizelgesi'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(depo.cizelgeBaslangici, style: Yazi.olcu(12, renk: Renkler.metin2)),
                          Text('şimdi · ${depo.saatKisa}', style: Yazi.olcu(12, renk: Renkler.metin2)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _Cizelge(oran: cizelgeOrani(k, depo.tick)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _baslik(BuildContext context, Kisi k) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: RolSekli(rol: k.rol, renk: k.renk, boyut: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(tamAd(k), style: Yazi.baslik(22, 1.15)),
              ),
              const SizedBox(height: 2),
              Text(rolSatiri(k), style: Yazi.olcu(14, renk: Renkler.metin2)),
            ],
          ),
        ),
        // Görsel 40 px, dokunma alanı 44 px: 12 px boşluğun 2'si dokunma alanında.
        const SizedBox(width: 10),
        HapDugme(
          etiket: '✕',
          anlam: 'Kapat',
          genislik: 40,
          yukseklik: 40,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _alanlar(Kisi k, String toplam) {
    Widget satir(Widget sol, Widget sag) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: sol),
        const SizedBox(width: 12),
        Expanded(child: sag),
      ],
    );
    return Column(
      children: [
        satir(
          EtiketliDeger(
            etiket: 'Kart no',
            deger: k.id,
            stil: Yazi.olcu(20, agirlik: FontWeight.w600, satir: 1.2, rakam: true),
          ),
          EtiketliDeger(
            etiket: 'Durum',
            deger: durumCumlesi(k, depo.tick, depo.bul),
            stil: Yazi.olcu(15, agirlik: FontWeight.w600, renk: Renkler.ton(durumTonu(k))),
          ),
        ),
        const SizedBox(height: 14),
        satir(
          EtiketliDeger(etiket: 'Son duyulma', deger: sonDuyulma(k)),
          EtiketliDeger(
            etiket: 'Bugünkü toplam',
            deger: toplam,
            stil: Yazi.olcu(15, agirlik: FontWeight.w600, rakam: true),
          ),
        ),
      ],
    );
  }
}

class _Tutamac extends StatelessWidget {
  const _Tutamac();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Renkler.kenarlik, borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
    );
  }
}

/// "Bugün kiminle" satırı: şekil, ad, süre.
class _EsSatiri extends StatelessWidget {
  const _EsSatiri({required this.es, required this.sure});

  final Kisi es;
  final String sure;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            RolSekli(rol: es.rol, renk: es.renk, boyut: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Text(gorunenAd(es), style: Yazi.olcu(15, agirlik: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Text(sure, style: Yazi.olcu(15, rakam: true)),
          ],
        ),
      ),
    );
  }
}

/// Zaman çizelgesi: 8 px ray; yeşil dolgu birlikte geçen süreyi gösterir.
class _Cizelge extends StatelessWidget {
  const _Cizelge({required this.oran});

  final double oran;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: Renkler.acikYuzey,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: oran,
              heightFactor: 1,
              child: ColoredBox(color: Renkler.birlikte),
            ),
          ),
        ),
      ),
    );
  }
}
