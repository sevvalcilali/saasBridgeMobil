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

/// Rapor sekmesi: KPI'lar ve girişimci satırları görüşme kayıtlarından (`/api/sessions`, sekmeye her gelişte ve
/// "Yenile" ile); rapor bir anlık görüntüdür: süreler kayıtların alındığı ana göre. CSV'ler telefonda üretilip paylaşılır. Satıra dokununca kişiye özel rapor.
class RaporEkrani extends StatefulWidget {
  const RaporEkrani({super.key, required this.depo, this.paylas = sistemPaylasimi, this.yenileme = 0});

  final EtkinlikDeposu depo;
  final Paylasici paylas;

  /// Değişince kayıtlar yeniden istenir (Kabuk: Rapor sekmesine her gelişte).
  final int yenileme;

  static const double bolumAraligi = 28;

  @override
  State<RaporEkrani> createState() => _RaporEkraniState();
}

class _RaporEkraniState extends State<RaporEkrani> {
  List<Oturum>? _oturumlar;

  /// Kayıtların alındığı andaki etkinlik saniyesi: rapor bir anlık görüntüdür (web gibi), süreler bununla hesaplanır.
  double _simdi = 0;

  /// Kayıtların alındığı andaki saat ("HH:MM:SS"): etkinlik saniyesini saate çevirmek için _simdi ile birlikte donar.
  String _saat = '00:00:00';
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void didUpdateWidget(RaporEkrani eski) {
    super.didUpdateWidget(eski);
    if (eski.depo != widget.depo || eski.yenileme != widget.yenileme) _yukle();
  }

  Future<void> _yukle() async {
    try {
      final liste = await widget.depo.oturumlar();
      if (!mounted) return;
      setState(() {
        _oturumlar = liste;
        _simdi = widget.depo.gecenSn;
        _saat = widget.depo.saat;
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
        final simdi = _simdi;
        final kisiler = depo.katilimcilar;
        final ozet = raporOzeti(kisiler, oturumlar, simdi);
        final girisimciler = girisimciSatirlari(kisiler, oturumlar, simdi);
        final yatirimcilar = yatirimciSatirlari(kisiler, oturumlar, simdi);
        final anlasmalar = depo.bildirimler.where((b) => b.onem == Onem.olumlu && b.baslik == 'Potansiyel anlaşma').toList();
        final eslesmeler = gucluEslesmeler(kisiler, oturumlar, simdi,
            anlasanlar: {for (final b in anlasmalar) if (b.kisiler.length >= 2) ciftAnahtari(b.kisiler[0], b.kisiler[1])});
        final yogunluk = gunIciYogunluk(oturumlar, simdi, saat: _saat, elapsed: simdi);
        final takip = takipListesi(girisimciler, yatirimcilar);
        final oneriler = onerilenTanistirmalar(kisiler, oturumlar);
        final sektorVar = kisiler.any((k) => k.rol == Rol.yatirimci && k.sektor.trim().isNotEmpty) &&
            kisiler.any((k) => k.rol == Rol.girisimci && k.sektor.trim().isNotEmpty);
        String saatYaz(num sn) => etkinlikSaati(sn, _saat, simdi);
        void kisiAc(String id) => kisiRaporuGoster(context, depo: depo, kisiId: id, oturumlar: oturumlar, simdi: simdi);

        final oran = ozet.girisimci == 0 ? 0 : (ozet.ulasan * 100 / ozet.girisimci).round();
        final dagilim = [
          if (ozet.yatirimci > 0) '${ozet.yatirimci} yatırımcı',
          if (ozet.girisimci > 0) '${ozet.girisimci} girişimci',
          if (ozet.misafir > 0) '${ozet.misafir} misafir',
          if (ozet.ayrilan > 0) '${ozet.ayrilan} ayrıldı',
        ].join(' · ');
        final enYogun = yogunluk.enYogun;
        final kpiler = [
          _Kpi('Katılımcı', '${ozet.kisi}', dagilim),
          _Kpi('Görüşme', '${ozet.gorusme}', [
            if (ozet.gorusme > 0) 'ortalama ${dakikaYazisi(ozet.ortalamaSn)}',
            if (ozet.suren > 0) '${ozet.suren} tanesi sürüyor',
          ].join(' · ')),
          _Kpi('Yatırımcı–girişimci süresi', dakikaYazisi(ozet.karmaSn), 'birlikte geçen toplam'),
          _Kpi('Yatırımcıya ulaşan girişimci', '${ozet.ulasan}/${ozet.girisimci}', '%$oran', oran: oran),
          _Kpi('Potansiyel anlaşma', '${anlasmalar.length}', anlasmalar.isEmpty ? 'bildirim yok' : 'uzun ve tekrarlı görüşmeler',
              olumlu: anlasmalar.isNotEmpty),
          _Kpi('En yoğun zaman', enYogun == null ? '—' : saatYaz(enYogun.bas),
              enYogun == null ? '' : '${saatYaz(enYogun.bas)}–${saatYaz(enYogun.son)} · ${enYogun.adet} görüşme'),
        ];
        final yukleniyor = _oturumlar == null && _hata == null;
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HapDugme(etiket: '⤴ Katılımcılar (CSV)', onTap: () => widget.paylas('katilimcilar.csv', katilimcilarCsv(kisiler, oturumlar, simdi))),
                  HapDugme(etiket: '⤴ Görüşmeler (CSV)', onTap: () => widget.paylas('gorusmeler.csv', gorusmelerCsv(oturumlar, kisiler, simdi, depo.saat))),
                  HapDugme(etiket: 'Yenile', tur: HapTuru.hayalet, onTap: _yukle),
                ],
              ),
              if (_hata case final h?) ...[const SizedBox(height: 10), Text(h, style: Yazi.olcu(14, renk: Renkler.ciddi))],
              const SizedBox(height: 20),
              _KpiIzgarasi(kpiler: kpiler),
              if (yukleniyor) ...[
                const SizedBox(height: RaporEkrani.bolumAraligi),
                Text('Görüşme kayıtları alınıyor…', style: Yazi.olcu(14, renk: Renkler.metin2)),
              ] else ...[
                const SizedBox(height: RaporEkrani.bolumAraligi),
                const _BolumBasligi('Etkinlik sonrası yapılacaklar'),
                const SizedBox(height: 8),
                _Panel(
                  baslik: 'Yatırımcıyla görüşmeyen girişimciler',
                  sayi: takip.girisimciler.length,
                  aciklama: 'Etkinliğe geldi ama hiçbir yatırımcıyla yan yana gelmedi. Etkinlik sonrası tanıştırın.',
                  renk: Renkler.uyari,
                  child: _KisiListesi(kisiler: takip.girisimciler, bos: 'Her girişimci en az bir yatırımcıyla görüştü.', onKisi: kisiAc),
                ),
                const SizedBox(height: 10),
                _Panel(
                  baslik: 'Girişimciyle görüşmeyen yatırımcılar',
                  sayi: takip.yatirimcilar.length,
                  aciklama: 'Geldi ama hiçbir girişimciyle görüşmedi. İlgi alanına uygun girişimleri gönderin.',
                  renk: Renkler.uyari,
                  child: _KisiListesi(kisiler: takip.yatirimcilar, bos: 'Her yatırımcı en az bir girişimciyle görüştü.', onKisi: kisiAc),
                ),
                const SizedBox(height: 10),
                _Panel(
                  baslik: 'Önerilen tanıştırmalar',
                  sayi: oneriler.length,
                  aciklama: 'Yatırımcının ilgi alanı girişimin sektörünü tutuyor ama gün boyu karşılaşmadılar.',
                  renk: Renkler.kural,
                  child: oneriler.isEmpty
                      ? Text(sektorVar ? 'Önerilecek yeni eşleşme yok.' : 'Kişilere sektör ve ilgi alanı girilince burada eşleşme önerileri çıkar.',
                          style: Yazi.olcu(13, renk: Renkler.metin2))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final o in oneriler.take(12)) _TanistirmaSatiri(oneri: o),
                            if (oneriler.length > 12)
                              Text('ve ${oneriler.length - 12} öneri daha', style: Yazi.olcu(13, renk: Renkler.metinSoluk)),
                          ],
                        ),
                ),
                const SizedBox(height: RaporEkrani.bolumAraligi),
                const _BolumBasligi('En güçlü yatırımcı–girişimci eşleşmeleri'),
                const SizedBox(height: 4),
                Text('Gün boyu en uzun birlikte kalan çiftler: takip görüşmesi için ilk adaylar.', style: Yazi.olcu(13, renk: Renkler.metin2)),
                const SizedBox(height: 8),
                _EslesmeListesi(eslesmeler: eslesmeler),
                const SizedBox(height: RaporEkrani.bolumAraligi),
                const _BolumBasligi('Gün içinde görüşme yoğunluğu'),
                const SizedBox(height: 8),
                _YogunlukGrafigi(yogunluk: yogunluk, saatYaz: saatYaz),
                const SizedBox(height: RaporEkrani.bolumAraligi),
                _BolumBasligi('Girişimciler ve ulaştıkları yatırımcılar', sayi: girisimciler.length),
                const SizedBox(height: 4),
                for (final g in girisimciler)
                  _KisiSatiri(
                    key: ValueKey('rapor-kisi-${g.kisi.kisiId}'),
                    kisi: g.kisi,
                    esler: g.yatirimcilar,
                    karsiAd: 'yatırımcı',
                    bos: 'Hiç yatırımcıyla görüşmedi',
                    onTap: () => kisiAc(g.kisi.kisiId),
                  ),
                const SizedBox(height: RaporEkrani.bolumAraligi),
                _BolumBasligi('Yatırımcılar ve görüştükleri girişimciler', sayi: yatirimcilar.length),
                const SizedBox(height: 4),
                for (final y in yatirimcilar)
                  _KisiSatiri(
                    key: ValueKey('rapor-kisi-${y.kisi.kisiId}'),
                    kisi: y.kisi,
                    esler: y.girisimciler,
                    karsiAd: 'girişimci',
                    bos: 'Hiç girişimciyle görüşmedi',
                    onTap: () => kisiAc(y.kisi.kisiId),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Satıra dokununca kişiye özel rapor açılır. Tüm görüşmeler ve çiftler için CSV paylaşın. '
                  'Süreler kartların birbirini duymasına göre ölçülür; konum ve mesafe ölçülmez.',
                  style: Yazi.olcu(12, renk: Renkler.metinSoluk),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Kpi {
  const _Kpi(this.ad, this.deger, this.not, {this.oran, this.olumlu = false});

  final String ad;
  final String deger;
  final String not;

  /// Verilirse altında yüzde çubuğu (0–100).
  final int? oran;
  final bool olumlu;
}

/// 2 sütunlu KPI ızgarası; aynı satırdaki kartlar eşit yüksekliktedir.
class _KpiIzgarasi extends StatelessWidget {
  const _KpiIzgarasi({required this.kpiler});

  final List<_Kpi> kpiler;

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

  final _Kpi kpi;

  @override
  Widget build(BuildContext context) {
    final oran = kpi.oran;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: Olculer.koseYaricap,
        border: oran != null ? Border.all(color: Renkler.birlikte) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kpi.ad, style: Yazi.olcu(13, renk: Renkler.metin2)),
            const SizedBox(height: 4),
            // Uzun süreler ("11 sa 15 dk") alt satıra kırılmasın: sığmazsa küçülür.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(kpi.deger,
                  maxLines: 1,
                  style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1, rakam: true, renk: kpi.olumlu ? Renkler.vurguBasili : null)),
            ),
            if (oran != null) ...[
              const SizedBox(height: 8),
              _Cubuk(oran: oran / 100, renk: Renkler.birlikte, yukseklik: 8),
            ],
            const SizedBox(height: 4),
            if (kpi.not.isNotEmpty)
              Text(kpi.not,
                  style: Yazi.olcu(12, renk: oran != null ? Renkler.birlikte : Renkler.metin2, agirlik: oran != null ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

/// Yatay oran çubuğu (0–1): soluk zemin üstünde dolu kısım.
class _Cubuk extends StatelessWidget {
  const _Cubuk({required this.oran, required this.renk, this.yukseklik = 10});

  final double oran;
  final Color renk;
  final double yukseklik;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(yukseklik);
    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        height: yukseklik,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Renkler.acikYuzey),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: oran.clamp(0.0, 1.0),
              heightFactor: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: renk, borderRadius: r)),
            ),
          ),
        ),
      ),
    );
  }
}

class _BolumBasligi extends StatelessWidget {
  const _BolumBasligi(this.metin, {this.sayi});

  final String metin;
  final int? sayi;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(text: metin, children: [
          if (sayi != null) TextSpan(text: '  $sayi', style: Yazi.olcu(14, renk: Renkler.metin2, agirlik: FontWeight.w600)),
        ]),
        style: Yazi.baslik(18, 1.2),
      ),
    );
  }
}

/// Yapılacaklar paneli: üstte renkli şerit, başlık ve sayı, açıklama, içerik.
class _Panel extends StatelessWidget {
  const _Panel({required this.baslik, required this.sayi, required this.aciklama, required this.renk, required this.child});

  final String baslik;
  final int sayi;
  final String aciklama;
  final Color renk;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: Olculer.koseYaricap,
        border: Border(top: BorderSide(color: renk, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(baslik, style: Yazi.olcu(15, agirlik: FontWeight.w700, satir: 1.3))),
                const SizedBox(width: 8),
                _Sayi(sayi),
              ],
            ),
            const SizedBox(height: 4),
            Text(aciklama, style: Yazi.olcu(13, renk: Renkler.metin2, satir: 1.35)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Sayi extends StatelessWidget {
  const _Sayi(this.sayi);

  final int sayi;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Renkler.acikYuzey, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Text('$sayi', style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: Renkler.metin2, rakam: true)),
      ),
    );
  }
}

/// Renk karesi + ad (girişimcide "Kurum · Ad").
class _Ad extends StatelessWidget {
  const _Ad(this.kisi, {this.punto = 14, this.agirlik = FontWeight.w600});

  final Katilimci kisi;
  final double punto;
  final FontWeight agirlik;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 8,
          child: DecoratedBox(decoration: BoxDecoration(color: Renkler.kisi(kisi.renk), borderRadius: const BorderRadius.all(Radius.circular(2)))),
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(katilimciAdi(kisi), style: Yazi.olcu(punto, agirlik: agirlik))),
      ],
    );
  }
}

class _KisiListesi extends StatelessWidget {
  const _KisiListesi({required this.kisiler, required this.bos, required this.onKisi});

  final List<Katilimci> kisiler;
  final String bos;
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    if (kisiler.isEmpty) return Text('✓ $bos', style: Yazi.olcu(13, agirlik: FontWeight.w600, renk: Renkler.birlikte));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final k in kisiler)
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onKisi(k.kisiId),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Flexible(child: _Ad(k)),
                    if (k.yildiz > 0) Text(' ${yildizlar(k.yildiz)}', style: Yazi.olcu(12, renk: Renkler.vurguBasili)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TanistirmaSatiri extends StatelessWidget {
  const _TanistirmaSatiri({required this.oneri});

  final Tanistirma oneri;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _Ad(oneri.yatirimci, punto: 13),
          Text('→', style: Yazi.olcu(13, renk: Renkler.metinSoluk)),
          _Ad(oneri.girisimci, punto: 13),
          DecoratedBox(
            decoration: BoxDecoration(color: Renkler.kuralZemin, borderRadius: BorderRadius.circular(999)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Text(oneri.sektor, style: Yazi.olcu(12, renk: Renkler.kural)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sıralı eşleşmeler: sıra, iki ad, süre çubuğu, süre ve kaç kez; anlaşmada rozet.
class _EslesmeListesi extends StatelessWidget {
  const _EslesmeListesi({required this.eslesmeler});

  final List<Eslesme> eslesmeler;

  @override
  Widget build(BuildContext context) {
    if (eslesmeler.isEmpty) return Text('Henüz yatırımcı–girişimci görüşmesi yok.', style: Yazi.olcu(14, renk: Renkler.metin2));
    final enCok = eslesmeler.first.toplamSn < 1 ? 1 : eslesmeler.first.toplamSn;
    return DecoratedBox(
      decoration: BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Column(
        children: [
          for (final (i, e) in eslesmeler.indexed)
            DecoratedBox(
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: Renkler.ayrac))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox.square(
                      dimension: 24,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: i == 0 ? Renkler.birlikte : Renkler.acikYuzey, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${i + 1}',
                              style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: i == 0 ? Renkler.yuzey : Renkler.metin2, rakam: true)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Ad(e.yatirimci, punto: 13),
                          const SizedBox(height: 2),
                          _Ad(e.girisimci, punto: 13),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(child: _Cubuk(oran: e.toplamSn / enCok, renk: Renkler.birlikte)),
                              const SizedBox(width: 10),
                              Text.rich(
                                TextSpan(text: dakikaYazisi(e.toplamSn), children: [
                                  TextSpan(text: ' · ${e.adet} kez', style: TextStyle(fontWeight: FontWeight.w400, color: Renkler.metinSoluk)),
                                ]),
                                style: Yazi.olcu(13, agirlik: FontWeight.w700, rakam: true),
                              ),
                            ],
                          ),
                          if (e.anlasma) ...[
                            const SizedBox(height: 6),
                            DecoratedBox(
                              decoration: BoxDecoration(color: Renkler.vurguZemin, borderRadius: BorderRadius.circular(999)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                child: Text('★ anlaşma', style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: Renkler.vurguBasili)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gün içi yoğunluk: her çubuk bir dilim, yüksekliği o arada süren görüşme sayısı; en yoğun dilim turuncu.
class _YogunlukGrafigi extends StatelessWidget {
  const _YogunlukGrafigi({required this.yogunluk, required this.saatYaz});

  final Yogunluk yogunluk;
  final String Function(num) saatYaz;

  static const double _alan = 130;

  @override
  Widget build(BuildContext context) {
    final dilimler = yogunluk.dilimler;
    if (dilimler.isEmpty) return Text('Henüz görüşme yok.', style: Yazi.olcu(14, renk: Renkler.metin2));
    final tepe = dilimler.map((d) => d.adet).fold(1, (a, b) => a > b ? a : b);
    final adim = (dilimler.length / 5).ceil().clamp(1, 1000);
    final enYogun = yogunluk.enYogun;
    return DecoratedBox(
      decoration: BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: 'Gün içi görüşme yoğunluğu grafiği',
              child: SizedBox(
                height: _alan + 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in dilimler)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (dilimler.length <= 14 && d.adet > 0)
                                Text('${d.adet}', style: Yazi.olcu(10, renk: Renkler.metin2, rakam: true)),
                              // Az dilimde çubuk kalın blok olmasın (web ile aynı: en çok 44 px).
                              Container(
                                constraints: const BoxConstraints(maxWidth: 44),
                                height: d.adet == 0 ? 2 : _alan * d.adet / tepe,
                                decoration: BoxDecoration(
                                  color: enYogun != null && d.bas == enYogun.bas ? Renkler.sure10 : Renkler.sure5.withValues(alpha: 0.55),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1, child: ColoredBox(color: Renkler.kenarlik)),
            const SizedBox(height: 3),
            Row(
              children: [
                for (final (i, d) in dilimler.indexed)
                  Expanded(
                    // Saat etiketi sütundan geniş: sağa taşar (seyrek etiket, üst üste binmez).
                    child: SizedBox(
                      height: 14,
                      child: OverflowBox(
                        minWidth: 0,
                        maxWidth: 60,
                        alignment: Alignment.centerLeft,
                        child: Text(i % adim == 0 ? saatYaz(d.bas) : '', maxLines: 1, style: Yazi.olcu(10, renk: Renkler.metin2, rakam: true)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(text: 'Her çubuk ${yogunluk.dilimSn ~/ 60} dakika: o arada süren görüşme sayısı.', children: [
                if (enYogun != null) ...[
                  const TextSpan(text: ' En yoğun: '),
                  TextSpan(text: '${saatYaz(enYogun.bas)}–${saatYaz(enYogun.son)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' (${enYogun.adet} görüşme).'),
                ],
              ]),
              style: Yazi.olcu(12, renk: Renkler.metin2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Girişimci ya da yatırımcı: ad (yatırımcıda yıldız), "N yatırımcı · toplam", altında görüştükleri çip çip.
/// Dokununca kişiye özel rapor.
class _KisiSatiri extends StatelessWidget {
  const _KisiSatiri({super.key, required this.kisi, required this.esler, required this.karsiAd, required this.bos, required this.onTap});

  final Katilimci kisi;
  final List<RaporEsi> esler;
  final String karsiAd;
  final String bos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final toplam = esler.fold(0, (t, e) => t + e.toplamSn);
    final profil = [if (kisi.rol != Rol.girisimci && kisi.kurum != null) kisi.kurum!, kisi.sektor].where((x) => x.trim().isNotEmpty).join(' · ');
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: esler.isEmpty ? Renkler.ciddiZemin : null,
            border: Border(bottom: BorderSide(color: Renkler.ayrac)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: esler.isEmpty ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Flexible(child: _Ad(kisi, punto: 15)),
                    if (kisi.yildiz > 0) Text(' ${yildizlar(kisi.yildiz)}', style: Yazi.olcu(12, renk: Renkler.vurguBasili)),
                  ],
                ),
                if (profil.isNotEmpty) Text(profil, style: Yazi.olcu(12, renk: Renkler.metin2)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${esler.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ' $karsiAd'),
                    if (toplam > 0) ...[
                      const TextSpan(text: '   '),
                      TextSpan(text: dakikaYazisi(toplam), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' toplam'),
                    ],
                  ]),
                  style: Yazi.olcu(13, renk: Renkler.metinKoyu2, rakam: true),
                ),
                const SizedBox(height: 6),
                if (esler.isEmpty)
                  UyariMetni('⚠ $bos', stil: Yazi.olcu(13, agirlik: FontWeight.w700, renk: Renkler.ciddi))
                else
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final e in esler)
                        DecoratedBox(
                          decoration: BoxDecoration(color: Renkler.acikYuzey, borderRadius: BorderRadius.circular(999)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: _Ad(e.kisi, punto: 12, agirlik: FontWeight.w500)),
                                const SizedBox(width: 6),
                                Text(dakikaYazisi(e.toplamSn), style: Yazi.olcu(12, agirlik: FontWeight.w700, renk: Renkler.metin2, rakam: true)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
