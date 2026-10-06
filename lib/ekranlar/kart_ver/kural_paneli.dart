import 'package:flutter/material.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../mantik/kural.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'kural_formu_sayfasi.dart';

/// Kart Ver → Uyarılar (web `KuralPaneli.jsx`): organizatör her etkinlik için kural kurar; koşul sağlanınca
/// Pano'da açılır uyarı. Kurallar sunucuda; her açılışta istenir. Silme satır içinde onaylanır.
class KuralPaneli extends StatefulWidget {
  const KuralPaneli({super.key, required this.depo});

  final EtkinlikDeposu depo;

  @override
  State<KuralPaneli> createState() => _KuralPaneliState();
}

class _KuralPaneliState extends State<KuralPaneli> {
  List<Kural>? _kurallar;
  String? _hata;
  String? _silinecek;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void didUpdateWidget(KuralPaneli eski) {
    super.didUpdateWidget(eski);
    if (eski.depo != widget.depo) _yukle();
  }

  Future<void> _yukle() async {
    try {
      final liste = await widget.depo.kurallar();
      if (!mounted) return;
      setState(() {
        _kurallar = liste;
        _hata = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hata = 'Kurallar alınamadı — sunucuya ulaşılamıyor.');
    }
  }

  Future<void> _islem(Future<String?> Function() islem) async {
    final hata = await islem();
    if (!mounted) return;
    if (hata != null) {
      setState(() => _hata = hata);
      return;
    }
    await _yukle();
  }

  Future<void> _form([Kural? kural]) async {
    final kaydedildi = await kuralFormuGoster(context, depo: widget.depo, kural: kural);
    if (kaydedildi == true) await _yukle();
  }

  @override
  Widget build(BuildContext context) {
    final liste = _kurallar;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Koşul sağlanınca Pano'da açılır uyarı çıkar ve bildirim akışına düşer. Bir çift için bir görüşmede bir kez uyarır. "
            'Kurallar bu etkinliğe özeldir; "Sıfırla"da kalır.',
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 12),
          HapDugme(etiket: '+ Yeni uyarı kuralı', tur: HapTuru.birincil, yukseklik: 48, genis: true, onTap: _form),
          if (_hata case final h?) ...[const SizedBox(height: 12), Text(h, style: Yazi.olcu(14, renk: Renkler.ciddi))],
          const SizedBox(height: 14),
          if (liste == null)
            Text('Kurallar alınıyor…', style: Yazi.olcu(14, renk: Renkler.metin2))
          else if (liste.isEmpty)
            Text('Henüz kural yok. Örnek: "★4+ yatırımcılar ile girişimciler 5 dakikadan uzun birlikte kalınca".',
                style: Yazi.olcu(15, renk: Renkler.metin2, stil: FontStyle.italic))
          else
            for (final k in liste) ...[
              _KuralSatiri(
                kural: k,
                cumle: kuralCumlesi(k, widget.depo.katilimcilar),
                silinecek: _silinecek == k.kuralId,
                onAcik: () => _islem(() => widget.depo.kuralGuncelle(k.kuralId, {'acik': !k.acik})),
                onDuzenle: () => _form(k),
                onSil: () => setState(() => _silinecek = k.kuralId),
                onSilOnay: () => _islem(() async {
                  _silinecek = null;
                  return widget.depo.kuralSil(k.kuralId);
                }),
                onSilVazgec: () => setState(() => _silinecek = null),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _KuralSatiri extends StatelessWidget {
  const _KuralSatiri({
    required this.kural,
    required this.cumle,
    required this.silinecek,
    required this.onAcik,
    required this.onDuzenle,
    required this.onSil,
    required this.onSilOnay,
    required this.onSilVazgec,
  });

  final Kural kural;
  final String cumle;
  final bool silinecek;
  final VoidCallback onAcik;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;
  final VoidCallback onSilOnay;
  final VoidCallback onSilVazgec;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: Olculer.koseYaricap,
        border: Border(left: BorderSide(color: kural.acik ? Renkler.kural : Renkler.kenarlik, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kural.ad, style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2, renk: kural.acik ? Renkler.metin : Renkler.metin2)),
            const SizedBox(height: 2),
            Text('$cumle → açılır uyarı', style: Yazi.olcu(13, renk: Renkler.metin2)),
            const SizedBox(height: 8),
            if (silinecek)
              Row(
                children: [
                  Expanded(child: Text('Silinsin mi?', style: Yazi.olcu(14, agirlik: FontWeight.w600))),
                  HapDugme(etiket: 'Vazgeç', yukseklik: 36, onTap: onSilVazgec),
                  const SizedBox(width: 8),
                  HapDugme(etiket: 'Sil', tur: HapTuru.birincil, yukseklik: 36, zemin: Renkler.ciddi, onTap: onSilOnay),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HapDugme(etiket: kural.acik ? 'Açık' : 'Kapalı', tur: kural.acik ? HapTuru.birincil : HapTuru.ikincil, yukseklik: 36, zemin: kural.acik ? Renkler.kural : null, onTap: onAcik),
                  HapDugme(etiket: 'Düzenle', tur: HapTuru.hayalet, yukseklik: 36, onTap: onDuzenle),
                  HapDugme(etiket: 'Sil', tur: HapTuru.hayalet, yukseklik: 36, onTap: onSil),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
