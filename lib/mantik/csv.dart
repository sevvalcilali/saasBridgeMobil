import '../veri/modeller.dart';
import 'kart_no.dart';
import 'kisi_formu.dart';
import 'rapor_hesap.dart';

// Rapor CSV dışa aktarma (web `csvDisa.js` ile aynı biçim): Türkçe Excel uyumlu — UTF-8 BOM, ";" ayraç, ondalıkta
// virgül, gerekirse tırnak. Telefonda üretilir, sistem paylaşım sayfasına verilir.

const _rolAdi = {Rol.yatirimci: 'Yatırımcı', Rol.girisimci: 'Girişimci', Rol.misafir: 'Misafir'};

String csvAlan(Object? v) {
  final s = v == null ? '' : v.toString();
  return RegExp(r'[;"\r\n]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;
}

String csvMetni(List<String> basliklar, List<List<Object?>> satirlar) =>
    '﻿${[basliklar, ...satirlar].map((r) => r.map(csvAlan).join(';')).join('\r\n')}\r\n';

/// Dakika, tek ondalık, Türkçe virgül: 1540 sn → "25,7".
String dakikaCsv(int sn) => ((sn / 60 * 10).round() / 10).toStringAsFixed(1).replaceAll('.', ',');

String katilimcilarCsv(List<Katilimci> kisiler, List<Oturum> oturumlar, double simdi) {
  final harita = {for (final k in kisiler) k.kisiId: k};
  final toplam = <String, int>{};
  final adet = <String, int>{};
  final esler = <String, Set<String>>{};
  final karsi = <String, Set<String>>{};
  for (final o in oturumlar) {
    final sure = o.sureSn(simdi);
    for (final (ben, es) in [(o.a, o.b), (o.b, o.a)]) {
      toplam[ben] = (toplam[ben] ?? 0) + sure;
      adet[ben] = (adet[ben] ?? 0) + 1;
      esler.putIfAbsent(ben, () => {}).add(es);
      final x = harita[ben];
      final y = harita[es];
      if (x != null && y != null && ((x.rol == Rol.yatirimci && y.rol == Rol.girisimci) || (x.rol == Rol.girisimci && y.rol == Rol.yatirimci))) {
        karsi.putIfAbsent(ben, () => {}).add(es);
      }
    }
  }
  final sirali = [...kisiler]..sort((p, q) {
      final s = (toplam[q.kisiId] ?? 0).compareTo(toplam[p.kisiId] ?? 0);
      return s != 0 ? s : katilimciAdi(p).compareTo(katilimciAdi(q));
    });
  return csvMetni(
    ['Ad', 'Rol', 'Kurum', 'Yıldız', 'Kart', 'Toplam (dk)', 'Görüşme', 'Görüştüğü kişi', 'Karşı rolden kişi', 'Sektör / ilgi alanı', 'Aşama', 'E-posta', 'Paylaşım izni'],
    [
      for (final k in sirali)
        [
          k.ad, _rolAdi[k.rol], k.kurum ?? '', k.yildiz > 0 ? k.yildiz : '', kisiDurumYazisi(k), dakikaCsv(toplam[k.kisiId] ?? 0),
          adet[k.kisiId] ?? 0, esler[k.kisiId]?.length ?? 0, k.rol == Rol.misafir ? '' : (karsi[k.kisiId]?.length ?? 0),
          k.sektor, asamalar.where((a) => a.$1 == k.asama).map((a) => a.$2).firstOrNull ?? '', k.eposta, k.paylasim ? 'evet' : 'hayır',
        ],
    ],
  );
}

String gorusmelerCsv(List<Oturum> oturumlar, List<Katilimci> kisiler, double simdi, String saat) {
  final harita = {for (final k in kisiler) k.kisiId: k};
  String ad(String id) => harita[id]?.ad ?? kimlikKisisi(id).ad;
  String rol(String id) => harita[id] == null ? '' : _rolAdi[harita[id]!.rol]!;
  final sirali = [...oturumlar]..sort((p, q) => p.start.compareTo(q.start));
  return csvMetni(
    ['Kişi 1', 'Rol 1', 'Kişi 2', 'Rol 2', 'Başlangıç', 'Bitiş', 'Süre (dk)'],
    [
      for (final o in sirali)
        [ad(o.a), rol(o.a), ad(o.b), rol(o.b), etkinlikSaati(o.start, saat, simdi), o.end == null ? 'sürüyor' : etkinlikSaati(o.end!, saat, simdi), dakikaCsv(o.sureSn(simdi))],
    ],
  );
}
