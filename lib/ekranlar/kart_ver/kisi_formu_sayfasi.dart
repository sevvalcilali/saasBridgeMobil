import 'package:flutter/material.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/cip.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kisi_formu.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Kişi formunu tam sayfa açar; kaydedildiyse `true` ile döner.
Future<bool?> kisiFormuGoster(BuildContext context, {required EtkinlikDeposu depo, Katilimci? katilimci}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => KisiFormuSayfasi(depo: depo, katilimci: katilimci)),
  );
}

/// Yeni kişi ve düzenleme aynı form (web `KisiFormu.jsx`): Ad, Rol, Kurum, yatırımcıda Yıldız; rapor bilgileri
/// (girişimcide sektör / aşama / tanıtım / web, yatırımcıda ilgi alanları; herkeste e-posta ve paylaşım izni); Not.
/// Renk değiştirilemez. Sunucunun hata metni formda gösterilir.
class KisiFormuSayfasi extends StatefulWidget {
  const KisiFormuSayfasi({super.key, required this.depo, this.katilimci});

  final EtkinlikDeposu depo;

  /// null: yeni kişi.
  final Katilimci? katilimci;

  @override
  State<KisiFormuSayfasi> createState() => _KisiFormuSayfasiState();
}

class _KisiFormuSayfasiState extends State<KisiFormuSayfasi> {
  late KisiFormVerisi _form = widget.katilimci == null
      ? const KisiFormVerisi(ad: '', rol: Rol.girisimci)
      : KisiFormVerisi.katilimcidan(widget.katilimci!);
  late final _ad = TextEditingController(text: _form.ad);
  late final _kurum = TextEditingController(text: _form.kurum);
  late final _sektor = TextEditingController(text: _form.sektor);
  late final _tanitim = TextEditingController(text: _form.tanitim);
  late final _web = TextEditingController(text: _form.web);
  late final _eposta = TextEditingController(text: _form.eposta);
  late final _not = TextEditingController(text: _form.notu);
  String? _hata;
  bool _gonderiliyor = false;

  void _degis(KisiFormVerisi yeni) => setState(() => _form = yeni);

  @override
  void dispose() {
    for (final d in [_ad, _kurum, _sektor, _tanitim, _web, _eposta, _not]) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_form.gecerli || _gonderiliyor) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _gonderiliyor = true;
      _hata = null;
    });
    final k = widget.katilimci;
    final String? hata;
    if (k == null) {
      hata = await widget.depo.kisiEkle(_form.govde());
    } else {
      final fark = duzenlemeFarki(k, _form);
      hata = fark.isEmpty ? null : await widget.depo.kisiGuncelle(k.kisiId, fark);
    }
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
    final yeni = widget.katilimci == null;
    final etiket = Yazi.olcu(13, agirlik: FontWeight.w600, renk: Renkler.metin2);
    Widget alan(String baslik, TextEditingController d, void Function(String) yaz, {String ipucu = '', TextInputType? tur}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: etiket),
            const SizedBox(height: 6),
            AramaAlani(ipucu: ipucu, denetleyici: d, onDegisti: yaz, klavye: tur),
            const SizedBox(height: 14),
          ],
        );

    return Scaffold(
      backgroundColor: Renkler.zemin,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  HapDugme(etiket: '← Vazgeç', tur: HapTuru.hayalet, yukseklik: 40, onTap: () => Navigator.of(context).pop(false)),
                ],
              ),
              const SizedBox(height: 8),
              Semantics(header: true, child: Text(yeni ? 'Yeni kişi' : 'Kişiyi düzenle', style: Yazi.baslik(26, 1.1))),
              const SizedBox(height: 4),
              Text(
                yeni ? 'Kayıt defterine eklenir; kart sonra verilir.' : 'Kişinin rengi değişmez.',
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
              const SizedBox(height: 18),
              alan('Ad', _ad, (v) => _degis(_form.copyWith(ad: v))),
              Text('Rol', style: etiket),
              const SizedBox(height: 6),
              BolmeliAnahtar<Rol>(
                secenekler: const [
                  BolmeSecenegi(deger: Rol.yatirimci, etiket: 'Yatırımcı'),
                  BolmeSecenegi(deger: Rol.girisimci, etiket: 'Girişimci'),
                  BolmeSecenegi(deger: Rol.misafir, etiket: 'Misafir'),
                ],
                secili: _form.rol,
                onSecildi: (r) => _degis(_form.copyWith(rol: r)),
              ),
              const SizedBox(height: 14),
              alan('Kurum', _kurum, (v) => _degis(_form.copyWith(kurum: v))),
              if (_form.rol == Rol.yatirimci) ...[
                Text('Yıldız', style: etiket),
                const SizedBox(height: 6),
                Semantics(
                  label: 'Yıldız: ${_form.yildiz} / 5',
                  child: Row(
                    children: [
                      for (var n = 1; n <= 5; n++)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _degis(_form.copyWith(yildiz: _form.yildiz == n ? 0 : n)),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Text('★', style: Yazi.olcu(28, renk: _form.yildiz >= n ? Renkler.vurgu : Renkler.kenarlik)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const Kicker('Rapor bilgileri (isteğe bağlı)'),
              const SizedBox(height: 10),
              if (_form.rol == Rol.girisimci) ...[
                alan('Sektör', _sektor, (v) => _degis(_form.copyWith(sektor: v)), ipucu: 'ör. Sağlık'),
                Text('Aşama', style: etiket),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (deger, ad) in asamalar)
                      Cip(etiket: ad, secili: _form.asama == deger, onTap: () => _degis(_form.copyWith(asama: _form.asama == deger ? '' : deger))),
                  ],
                ),
                const SizedBox(height: 14),
                alan('Tanıtım (tek cümle)', _tanitim, (v) => _degis(_form.copyWith(tanitim: v))),
                alan('Web sitesi', _web, (v) => _degis(_form.copyWith(web: v)), ipucu: 'ornek.com', tur: TextInputType.url),
              ],
              if (_form.rol == Rol.yatirimci)
                alan('İlgi alanları', _sektor, (v) => _degis(_form.copyWith(sektor: v)), ipucu: 'virgülle: Sağlık, Enerji'),
              alan('E-posta', _eposta, (v) => _degis(_form.copyWith(eposta: v)), tur: TextInputType.emailAddress),
              Semantics(
                checked: _form.paylasim,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _degis(_form.copyWith(paylasim: !_form.paylasim)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_form.paylasim ? Icons.check_box : Icons.check_box_outline_blank, size: 22, color: Renkler.vurgu),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'İletişim bilgisi diğer katılımcıların raporunda görünebilir (kişinin izni alındı)',
                          style: Yazi.olcu(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              alan('Not (isteğe bağlı)', _not, (v) => _degis(_form.copyWith(notu: v))),
              if (_hata case final h?) ...[
                Text(h, style: Yazi.olcu(14, renk: Renkler.ciddi)),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  HapDugme(etiket: 'İptal', onTap: () => Navigator.of(context).pop(false)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HapDugme(
                      etiket: _gonderiliyor ? 'Kaydediliyor…' : (yeni ? 'Kişiyi ekle' : 'Kaydet'),
                      tur: _form.gecerli ? HapTuru.birincil : HapTuru.ikincil,
                      genis: true,
                      yukseklik: 48,
                      onTap: _form.gecerli && !_gonderiliyor ? _kaydet : islevsiz,
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
