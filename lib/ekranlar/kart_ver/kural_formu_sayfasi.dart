import 'package:flutter/material.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/cip.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/kural.dart' as kural_mantik;
import '../../mantik/kural.dart' show Kural, KuralSecimi, gruplar, grupSecimi, kisaAd, kuralCoz, kuralCumlesi;
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Kural formunu tam sayfa açar; kaydedildiyse `true` ile döner.
Future<bool?> kuralFormuGoster(BuildContext context, {required EtkinlikDeposu depo, Kural? kural}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => KuralFormuSayfasi(depo: depo, kural: kural)),
  );
}

/// Bir tarafın form hali: grup ya da belirli kişiler.
class _Taraf {
  _Taraf({this.grup = true, this.grupDegeri = 'investor', List<String>? kisiler}) : kisiler = kisiler ?? [];

  factory _Taraf.secimden(KuralSecimi s) =>
      s.kisilerMi ? _Taraf(grup: false, kisiler: [...s.kisiler!]) : _Taraf(grupDegeri: kural_mantik.grupDegeri(s));

  bool grup;
  String grupDegeri;
  List<String> kisiler;

  Map<String, Object?> govde() => grup ? grupSecimi(grupDegeri).govde() : {'kisiler': kisiler};
}

/// Uyarı kuralı formu (web `KuralFormu.jsx`): tek cümle gibi kurulur — [kim] ile [kiminle] [ne zaman].
/// Kim / kiminle: bir grup ya da aramayla seçilen kişiler. Altta önizleme. Sunucunun hata metni formda.
class KuralFormuSayfasi extends StatefulWidget {
  const KuralFormuSayfasi({super.key, required this.depo, this.kural});

  final EtkinlikDeposu depo;
  final Kural? kural;

  @override
  State<KuralFormuSayfasi> createState() => _KuralFormuSayfasiState();
}

class _KuralFormuSayfasiState extends State<KuralFormuSayfasi> {
  late final _ad = TextEditingController(text: widget.kural?.ad ?? '');
  late final _dakika = TextEditingController(text: '${widget.kural?.dakika ?? 5}');
  late final _kim = widget.kural == null ? _Taraf() : _Taraf.secimden(widget.kural!.kim);
  late final _kiminle = widget.kural == null ? _Taraf(grupDegeri: 'founder') : _Taraf.secimden(widget.kural!.kiminle);
  late bool _yanYana = (widget.kural?.dakika ?? 0) == 0 && widget.kural != null;
  late bool _acik = widget.kural?.acik ?? true;
  String? _hata;
  bool _gonderiliyor = false;

  @override
  void dispose() {
    _ad.dispose();
    _dakika.dispose();
    super.dispose();
  }

  Map<String, Object?> _govde() => {
    'ad': _ad.text.trim(),
    'kim': _kim.govde(),
    'kiminle': _kiminle.govde(),
    'dakika': _yanYana ? 0 : int.tryParse(numaraTemizle(_dakika.text)) ?? -1,
    'acik': _acik,
  };

  /// Önizleme: geçerliyse cümle, değilse eksik olan.
  String _onizleme() {
    final sonuc = kuralCoz(_govde(), widget.depo.katilimcilar);
    if (sonuc is String) return sonuc;
    final k = sonuc as Kural;
    return "${kuralCumlesi(k, widget.depo.katilimcilar)} → Pano'da açılır uyarı";
  }

  bool get _gecerli => kuralCoz(_govde(), widget.depo.katilimcilar) is Kural;

  Future<void> _kaydet() async {
    if (!_gecerli || _gonderiliyor) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _gonderiliyor = true;
      _hata = null;
    });
    final k = widget.kural;
    final hata = k == null ? await widget.depo.kuralEkle(_govde()) : await widget.depo.kuralGuncelle(k.kuralId, _govde());
    if (!mounted) return;
    if (hata != null) {
      setState(() {
        _gonderiliyor = false;
        _hata = hata;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final yeni = widget.kural == null;
    final etiket = Yazi.olcu(13, agirlik: FontWeight.w600, renk: Renkler.metin2);
    final gecerli = _gecerli;
    return Scaffold(
      backgroundColor: Renkler.zemin,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [HapDugme(etiket: '← Vazgeç', tur: HapTuru.hayalet, yukseklik: 40, onTap: () => Navigator.of(context).pop(false))]),
              const SizedBox(height: 8),
              Semantics(header: true, child: Text(yeni ? 'Yeni uyarı kuralı' : 'Kuralı düzenle', style: Yazi.baslik(26, 1.1))),
              const SizedBox(height: 18),
              Text('Kuralın adı (isteğe bağlı; boşsa cümleden oluşur)', style: etiket),
              const SizedBox(height: 6),
              AramaAlani(ipucu: 'ör. Önemli yatırımcı uzun görüşmede', denetleyici: _ad, onDegisti: (_) => setState(() {})),
              const SizedBox(height: 16),
              _SecimSecici(baslik: 'Kim', taraf: _kim, katilimcilar: widget.depo.katilimcilar, onDegis: () => setState(() {})),
              const SizedBox(height: 16),
              _SecimSecici(baslik: 'Kiminle', taraf: _kiminle, katilimcilar: widget.depo.katilimcilar, onDegis: () => setState(() {})),
              const SizedBox(height: 16),
              const Kicker('Ne zaman'),
              const SizedBox(height: 8),
              _Radyo(
                secili: _yanYana,
                onTap: () => setState(() => _yanYana = true),
                child: Text.rich(TextSpan(text: 'Yan yana gelince ', children: [TextSpan(text: '(1 dakika yakın durunca)', style: Yazi.olcu(13, renk: Renkler.metin2))]), style: Yazi.olcu(15)),
              ),
              const SizedBox(height: 6),
              _Radyo(
                secili: !_yanYana,
                onTap: () => setState(() => _yanYana = false),
                child: Row(
                  children: [
                    SizedBox(width: 72, child: AramaAlani(ipucu: '5', denetleyici: _dakika, rakam: true, onDegisti: (_) => setState(() => _yanYana = false))),
                    const SizedBox(width: 10),
                    Expanded(child: Text('dakikadan uzun birlikte kalınca', style: Yazi.olcu(15))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Onay(
                secili: _acik,
                onTap: () => setState(() => _acik = !_acik),
                metin: 'Kural açık (kapalıyken uyarmaz)',
              ),
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: const BoxDecoration(color: Renkler.kuralZemin, borderRadius: Olculer.koseYaricap),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text.rich(
                    TextSpan(text: 'Önizleme: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Renkler.kural), children: [
                      TextSpan(text: _onizleme(), style: TextStyle(fontWeight: FontWeight.w400, color: gecerli ? Renkler.metin : Renkler.uyari)),
                    ]),
                    style: Yazi.olcu(14),
                  ),
                ),
              ),
              if (_hata case final h?) ...[const SizedBox(height: 10), Text(h, style: Yazi.olcu(14, renk: Renkler.ciddi))],
              const SizedBox(height: 14),
              Row(
                children: [
                  HapDugme(etiket: 'İptal', onTap: () => Navigator.of(context).pop(false)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HapDugme(
                      etiket: _gonderiliyor ? 'Kaydediliyor…' : 'Kaydet',
                      tur: gecerli ? HapTuru.birincil : HapTuru.ikincil,
                      genis: true,
                      yukseklik: 48,
                      onTap: gecerli && !_gonderiliyor ? _kaydet : islevsiz,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kuralın bir tarafı: "Bir grup" (çipler) ya da "Belirli kişiler" (arama + seçilenler).
class _SecimSecici extends StatefulWidget {
  const _SecimSecici({required this.baslik, required this.taraf, required this.katilimcilar, required this.onDegis});

  final String baslik;
  final _Taraf taraf;
  final List<Katilimci> katilimcilar;
  final VoidCallback onDegis;

  @override
  State<_SecimSecici> createState() => _SecimSeciciState();
}

class _SecimSeciciState extends State<_SecimSecici> {
  final _arama = TextEditingController();

  @override
  void dispose() {
    _arama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.taraf;
    final secili = t.kisiler.toSet();
    final sonuclar = _arama.text.trim().isEmpty
        ? const <Katilimci>[]
        : masaAra(widget.katilimcilar, _arama.text).where((k) => !secili.contains(k.kisiId)).take(6).toList();
    final adlar = {for (final k in widget.katilimcilar) k.kisiId: kisaAd(k)};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Kicker(widget.baslik),
        const SizedBox(height: 8),
        BolmeliAnahtar<bool>(
          yukseklik: 40,
          secenekler: const [BolmeSecenegi(deger: true, etiket: 'Bir grup'), BolmeSecenegi(deger: false, etiket: 'Belirli kişiler')],
          secili: t.grup,
          onSecildi: (g) {
            t.grup = g;
            widget.onDegis();
          },
        ),
        const SizedBox(height: 10),
        if (t.grup)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in gruplar)
                Cip(
                  etiket: g.etiket,
                  secili: t.grupDegeri == g.deger,
                  seciliRenk: Renkler.kural,
                  onTap: () {
                    t.grupDegeri = g.deger;
                    widget.onDegis();
                  },
                ),
            ],
          )
        else ...[
          if (t.kisiler.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in t.kisiler)
                  Cip(
                    etiket: '${adlar[id] ?? id} ×',
                    secili: true,
                    seciliRenk: Renkler.kural,
                    onTap: () {
                      t.kisiler.remove(id);
                      widget.onDegis();
                    },
                  ),
              ],
            ),
          const SizedBox(height: 8),
          AramaAlani(ipucu: 'Kişi ara: ad ya da kurum', denetleyici: _arama, onDegisti: (_) => setState(() {})),
          for (final k in sonuclar)
            Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  t.kisiler.add(k.kisiId);
                  _arama.clear();
                  widget.onDegis();
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: Olculer.dokunmaEnAz),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Renkler.ayrac))),
                  child: Text('＋ ${katilimciAdi(k)}', style: Yazi.olcu(15)),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _Radyo extends StatelessWidget {
  const _Radyo({required this.secili, required this.onTap, required this.child});

  final bool secili;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: secili,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Icon(secili ? Icons.radio_button_checked : Icons.radio_button_off, size: 22, color: Renkler.kural),
            const SizedBox(width: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _Onay extends StatelessWidget {
  const _Onay({required this.secili, required this.onTap, required this.metin});

  final bool secili;
  final VoidCallback onTap;
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: secili,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Icon(secili ? Icons.check_box : Icons.check_box_outline_blank, size: 22, color: Renkler.kural),
            const SizedBox(width: 8),
            Expanded(child: Text(metin, style: Yazi.olcu(14))),
          ],
        ),
      ),
    );
  }
}
