import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/uyari_metni.dart';
import '../../mantik/bicim.dart';
import '../../mantik/csv.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/rapor_hesap.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kisi_raporu_sayfasi.dart';

/// Dosya paylaşımı (sistem paylaşım sayfası); testlerde yerine kayıt eden işlev verilir.
typedef Paylasici = Future<void> Function(String dosyaAdi, String icerik);

Future<void> sistemPaylasimi(String dosyaAdi, String icerik) async {
  final dosya = XFile.fromData(utf8.encode(icerik), name: dosyaAdi, mimeType: 'text/csv');
  await SharePlus.instance.share(ShareParams(files: [dosya], subject: dosyaAdi));
}

/// Rapor sekmesi: KPI'lar ve girişimci satırları görüşme kayıtlarından (`/api/sessions`, açılışta ve "Yenile"
/// ile); süreler sunucunun saatiyle akar. CSV'ler telefonda üretilip paylaşılır. Satıra dokununca kişiye özel rapor.
class RaporEkrani extends StatefulWidget {
  const RaporEkrani({super.key, required this.depo, this.paylas = sistemPaylasimi});

  final EtkinlikDeposu depo;
  final Paylasici paylas;

  static const double bolumAraligi = 28;

  @override
  State<RaporEkrani> createState() => _RaporEkraniState();
}

class _RaporEkraniState extends State<RaporEkrani> {
  List<Oturum>? _oturumlar;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void didUpdateWidget(RaporEkrani eski) {
    super.didUpdateWidget(eski);
    if (eski.depo != widget.depo) _yukle();
  }

  Future<void> _yukle() async {
    try {
      final liste = await widget.depo.oturumlar();
      if (!mounted) return;
      setState(() {
        _oturumlar = liste;
        _hata = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hata = 'Görüşme kayıtları alınamadı — sunucuya ulaşılamıyor.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final depo = widget.depo;
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        final oturumlar = _oturumlar ?? const <Oturum>[];
        final simdi = depo.gecenSn;
        final ozet = raporOzeti(depo.katilimcilar, oturumlar, simdi);
        final satirlar = girisimciSatirlari(depo.katilimcilar, oturumlar, simdi);
        final anlasma = depo.bildirimler.where((b) => b.onem == Onem.olumlu && b.baslik == 'Potansiyel anlaşma').length;
        final kpiler = [
          ('Görüşme', '${ozet.gorusme}', '${ozet.suren} tanesi sürüyor'),
          ('Yatırımcı–girişimci toplam', sureYazisi(ozet.karmaSn), 'bugün'),
          ('Yatırımcıya ulaşan girişimci', '${ozet.ulasan}/${ozet.girisimci}', ''),
          ('Potansiyel anlaşma', '$anlasma', anlasma == 0 ? 'bildirim yok' : 'bildirimden'),
          ('Katılımcı', '${ozet.kisi}', 'kayıtlı'),
        ];
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Kicker('Etkinlik raporu'),
              const SizedBox(height: 4),
              Semantics(header: true, child: Text(depo.etkinlikAdi, style: Yazi.baslik(26, 1.1))),
              const SizedBox(height: 6),
              Text('${depo.tarihMekan} · Hazırlanma: ${depo.raporTarihi} ${depo.saatKisa}', style: Yazi.olcu(14, renk: Renkler.metin2)),
              const SizedBox(height: RaporEkrani.bolumAraligi),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HapDugme(etiket: '⤴ Katılımcılar (CSV)', onTap: () => widget.paylas('katilimcilar.csv', katilimcilarCsv(depo.katilimcilar, oturumlar, simdi))),
                  HapDugme(etiket: '⤴ Görüşmeler (CSV)', onTap: () => widget.paylas('gorusmeler.csv', gorusmelerCsv(oturumlar, depo.katilimcilar, simdi, depo.saat))),
                  HapDugme(etiket: 'Yenile', tur: HapTuru.hayalet, onTap: _yukle),
                ],
              ),
              if (_hata case final h?) ...[const SizedBox(height: 10), Text(h, style: Yazi.olcu(14, renk: Renkler.ciddi))],
              const SizedBox(height: RaporEkrani.bolumAraligi),
              _KpiIzgarasi(kpiler: kpiler),
              const SizedBox(height: RaporEkrani.bolumAraligi),
              Semantics(header: true, child: Text('Girişimciler ve ulaştıkları yatırımcılar', style: Yazi.baslik(18, 1.2))),
              const SizedBox(height: 8),
              if (_oturumlar == null && _hata == null)
                Text('Görüşme kayıtları alınıyor…', style: Yazi.olcu(14, renk: Renkler.metin2))
              else
                for (final satir in satirlar)
                  _GirisimciSatiriGorunumu(
                    satir: satir,
                    onTap: () => kisiRaporuGoster(context, depo: depo, kisiId: satir.kisi.kisiId, oturumlar: oturumlar),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// 2 sütunlu KPI ızgarası; aynı satırdaki kartlar eşit yüksekliktedir.
class _KpiIzgarasi extends StatelessWidget {
  const _KpiIzgarasi({required this.kpiler});

  final List<(String, String, String)> kpiler;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kpiler.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _KpiKarti(kpi: kpiler[i])),
                const SizedBox(width: 8),
                Expanded(child: i + 1 < kpiler.length ? _KpiKarti(kpi: kpiler[i + 1]) : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KpiKarti extends StatelessWidget {
  const _KpiKarti({required this.kpi});

  final (String, String, String) kpi;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kpi.$1, style: Yazi.olcu(13, renk: Renkler.metin2)),
            const SizedBox(height: 4),
            // Uzun süreler ("11 sa 15 dk") alt satıra kırılmasın: sığmazsa küçülür.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(kpi.$2, maxLines: 1, style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1, rakam: true)),
            ),
            const SizedBox(height: 4),
            Text(kpi.$3, style: Yazi.olcu(12, renk: Renkler.metin2)),
          ],
        ),
      ),
    );
  }
}

/// Bir girişimci: renk karesi, kurum · ad, yatırımcılarla toplam süre; altında yatırımcılar ya da uyarı.
class _GirisimciSatiriGorunumu extends StatelessWidget {
  const _GirisimciSatiriGorunumu({required this.satir, required this.onTap});

  final GirisimciSatiri satir;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final k = satir.kisi;
    final gorusmedi = satir.yatirimcilar.isEmpty;
    final detay = gorusmedi
        ? '⚠ Hiç yatırımcıyla görüşmedi'
        : satir.yatirimcilar.map((y) => '${y.kisi.ad} (${sureYazisi(y.toplamSn)})').join(', ');
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Renkler.ayrac))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 8,
                      child: DecoratedBox(decoration: BoxDecoration(color: Renkler.kisi(k.renk), borderRadius: const BorderRadius.all(Radius.circular(1)))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: k.kurum ?? k.ad,
                          children: [if (k.kurum != null) TextSpan(text: ' · ${k.ad}', style: TextStyle(fontWeight: FontWeight.w400, color: Renkler.metin2))],
                        ),
                        style: Yazi.olcu(15, agirlik: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(gorusmedi ? '—' : sureYazisi(satir.yatirimciSn), style: Yazi.olcu(15, renk: Renkler.metinKoyu2, rakam: true)),
                  ],
                ),
                const SizedBox(height: 4),
                UyariMetni(detay, stil: Yazi.olcu(14, renk: gorusmedi ? Renkler.ciddi : Renkler.metinKoyu2)),
                Text(katilimciKartMetni(k), style: Yazi.olcu(12, renk: Renkler.metinSoluk)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
