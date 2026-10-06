import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/kisi_formu.dart';
import '../../mantik/rapor_hesap.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

typedef MetinPaylasici = Future<void> Function(String metin);

Future<void> sistemMetinPaylasimi(String metin) => SharePlus.instance.share(ShareParams(text: metin));

Future<void> kisiRaporuGoster(BuildContext context, {required EtkinlikDeposu depo, required String kisiId, required List<Oturum> oturumlar}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => KisiRaporuSayfasi(depo: depo, kisiId: kisiId, oturumlar: oturumlar)),
  );
}

/// Kişiye özel rapor (web `KisiRaporu.jsx`): yatırımcıya (ya da girişimciye) verilecek tek sayfa. Yalnız o kişinin
/// görüşmeleri; karşı tarafın iletişim bilgisi yalnız paylaşım izni varsa. Dil dürüst: kartlar konuşmayı değil
/// yakınlığı ölçer → "birlikte geçen süre". "Paylaş" metin özetini sistem paylaşım sayfasına verir.
class KisiRaporuSayfasi extends StatelessWidget {
  const KisiRaporuSayfasi({super.key, required this.depo, required this.kisiId, required this.oturumlar, this.paylas = sistemMetinPaylasimi});

  final EtkinlikDeposu depo;
  final String kisiId;
  final List<Oturum> oturumlar;
  final MetinPaylasici paylas;

  static const _karsi = {
    Rol.yatirimci: (baslik: 'Girişimlerle birlikte geçen süre', kacir: 'Kaçırdığınız girişimler', hic: 'hiçbir girişimle', tekil: 'girişim'),
    Rol.girisimci: (baslik: 'Yatırımcılarla birlikte geçen süre', kacir: 'Kaçırdığınız yatırımcılar', hic: 'hiçbir yatırımcıyla', tekil: 'yatırımcı'),
  };

  @override
  Widget build(BuildContext context) {
    final r = kisiRaporu(kisiId, depo.katilimcilar, oturumlar, depo.gecenSn);
    final k = r.kisi;
    final m = _karsi[k.rol];
    return Scaffold(
      backgroundColor: Renkler.zemin,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  HapDugme(etiket: '← Rapor', tur: HapTuru.hayalet, yukseklik: 40, onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  HapDugme(etiket: '⤴ Paylaş', yukseklik: 40, onTap: () => paylas(_metin(r, m))),
                ],
              ),
              const SizedBox(height: 8),
              const Kicker('Kişiye özel rapor'),
              const SizedBox(height: 4),
              Row(
                children: [
                  RolSekli(rol: k.rol, renk: k.renk, boyut: 14),
                  const SizedBox(width: 10),
                  Expanded(child: Semantics(header: true, child: Text(katilimciAdi(k), style: Yazi.baslik(24, 1.15)))),
                ],
              ),
              const SizedBox(height: 4),
              Text('${depo.etkinlikAdi} · ${depo.tarihMekan}', style: Yazi.olcu(13, renk: Renkler.metin2)),
              const SizedBox(height: 18),
              if (m != null) ...[
                Semantics(header: true, child: Text(m.baslik, style: Yazi.baslik(18, 1.2))),
                const SizedBox(height: 4),
                Text(
                  r.karsi.isEmpty
                      ? 'Bugün ${m.hic} birlikte vakit geçirmediniz.'
                      : '${r.ozet.karsiSayisi} ${m.tekil} · toplam ${sureYazisi(r.ozet.karsiSn)}',
                  style: Yazi.olcu(14, renk: Renkler.metin2),
                ),
                const SizedBox(height: 8),
                for (final e in r.karsi) _EsSatiri(es: e),
                const SizedBox(height: 18),
              ],
              if (r.diger.isNotEmpty) ...[
                Semantics(header: true, child: Text(m == null ? 'Tanıştıklarınız' : 'Diğer tanıştıklarınız', style: Yazi.baslik(18, 1.2))),
                const SizedBox(height: 8),
                for (final e in r.diger) _EsSatiri(es: e),
                const SizedBox(height: 18),
              ],
              if (m != null && r.kacirilan.isNotEmpty) ...[
                Semantics(header: true, child: Text('${m.kacir} · ${r.kacirilan.length}', style: Yazi.baslik(18, 1.2))),
                const SizedBox(height: 4),
                Text('Bugün buradaydı, yolunuz kesişmedi.${r.ilgiAlaninda.isNotEmpty ? ' İlgi alanınızdakiler önde.' : ''}', style: Yazi.olcu(13, renk: Renkler.metin2)),
                const SizedBox(height: 8),
                for (final x in r.kacirilan)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        RolSekli(rol: x.rol, renk: x.renk, boyut: 10),
                        const SizedBox(width: 10),
                        Expanded(child: Text(katilimciAdi(x), style: Yazi.olcu(15, agirlik: r.ilgiAlaninda.contains(x.kisiId) ? FontWeight.w600 : FontWeight.w400))),
                        if (r.ilgiAlaninda.contains(x.kisiId)) Text('ilgi alanınızda', style: Yazi.olcu(12, renk: Renkler.vurgu)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _metin(KisiRaporu r, ({String baslik, String kacir, String hic, String tekil})? m) {
    final b = StringBuffer('${katilimciAdi(r.kisi)} — ${depo.etkinlikAdi}\n');
    if (m != null) {
      b.writeln(m.baslik);
      for (final e in r.karsi) {
        b.writeln('• ${katilimciAdi(e.kisi)}: ${sureYazisi(e.toplamSn)}');
      }
    }
    if (r.diger.isNotEmpty) {
      b.writeln('Diğer tanıştıklarınız');
      for (final e in r.diger) {
        b.writeln('• ${katilimciAdi(e.kisi)}: ${sureYazisi(e.toplamSn)}');
      }
    }
    return b.toString();
  }
}

/// Karşı taraf: ad, süre (görüşme sayısı), profil (sektör · aşama · tanıtım), izin varsa iletişim.
class _EsSatiri extends StatelessWidget {
  const _EsSatiri({required this.es});

  final RaporEsi es;

  @override
  Widget build(BuildContext context) {
    final k = es.kisi;
    final bilgi = k.rol == Rol.girisimci
        ? [k.sektor, asamalar.where((a) => a.$1 == k.asama).map((a) => a.$2).firstOrNull ?? '', k.tanitim].where((x) => x.isNotEmpty).join(' · ')
        : (k.sektor.isNotEmpty ? 'İlgi alanı: ${k.sektor}' : '');
    final iletisim = k.paylasim ? [k.web, k.eposta].where((x) => x.isNotEmpty).join(' · ') : '';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Renkler.ayrac))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 4), child: RolSekli(rol: k.rol, renk: k.renk, boyut: 10)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(katilimciAdi(k), style: Yazi.olcu(15, agirlik: FontWeight.w600)),
                if (bilgi.isNotEmpty) Text(bilgi, style: Yazi.olcu(13, renk: Renkler.metin2)),
                if (iletisim.isNotEmpty) Text(iletisim, style: Yazi.olcu(13, renk: Renkler.vurgu)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${sureYazisi(es.toplamSn)}${es.adet > 1 ? ' · ${es.adet} kez' : ''}', style: Yazi.olcu(14, rakam: true, renk: Renkler.metinKoyu2)),
        ],
      ),
    );
  }
}
