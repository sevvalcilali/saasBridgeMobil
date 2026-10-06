import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const kisiler = SahteVeri.kisiler;

  test('26 kayıt: 12 girişimci, 10 yatırımcı, 4 misafir; biri adsız', () {
    expect(kisiler, hasLength(26));
    expect(kisiler.where((k) => k.rol == Rol.girisimci), hasLength(12));
    expect(kisiler.where((k) => k.rol == Rol.yatirimci), hasLength(10));
    expect(kisiler.where((k) => k.rol == Rol.misafir), hasLength(4));
    expect(kisiler.where((k) => k.ad == null).map((k) => k.id), ['14']);
  });

  test('kart numaraları benzersiz', () {
    expect(kisiler.map((k) => k.id).toSet(), hasLength(kisiler.length));
  });

  test('her "ile" kayıtlı bir kişiyi gösterir, karşılıklıdır ve süreleri eşittir', () {
    final harita = {for (final k in kisiler) k.id: k};
    for (final k in kisiler.where((k) => k.ile != null)) {
      final es = harita[k.ile];
      expect(es, isNotNull, reason: '${k.id} → ${k.ile} bulunamadı');
      expect(es!.ile, k.id, reason: '${k.id} ↔ ${k.ile} karşılıklı değil');
      expect(es.sn, k.sn, reason: '${k.id} ↔ ${k.ile} süreleri farklı');
    }
  });

  test('yalnız yatırımcının yıldızı vardır', () {
    for (final k in kisiler) {
      expect(k.yildiz, k.rol == Rol.yatirimci ? inInclusiveRange(1, 5) : 0, reason: k.id);
    }
  });

  test('bildirimler kayıtlı kişileri gösterir: 2 uyarı, 1 olumlu, 1 ciddi', () {
    final idler = kisiler.map((k) => k.id).toSet();
    expect(SahteVeri.bildirimler, hasLength(4));
    for (final b in SahteVeri.bildirimler) {
      expect(b.kisiler, isNotEmpty, reason: b.baslik);
      expect(idler.containsAll(b.kisiler), isTrue, reason: b.baslik);
    }
    int adet(Onem o) => SahteVeri.bildirimler.where((b) => b.onem == o).length;
    expect([adet(Onem.uyari), adet(Onem.olumlu), adet(Onem.ciddi)], [2, 1, 1]);
  });

  test('çiftler, seri renkleri ve açık kartlar', () {
    expect(SahteVeri.ciftler, hasLength(10));
    expect(SahteVeri.ciftler.first.rssi, -51);
    expect(SahteVeri.ciftler.last.rssi, -78);
    expect(SahteVeri.seriRenkleri, hasLength(6));
    expect(SahteVeri.acikKartlar.map((k) => k.no), ['88', '89', '90', '96', '97', '61', '46', '24', '5']);
    expect(SahteVeri.acikKartlar.where((k) => k.atanmis).map((k) => k.no), ['61', '46', '24', '5']);
  });

  test('etkinlik sabitleri', () {
    expect(SahteVeri.etkinlikAdi, 'Yatırımcı Buluşması');
    expect(SahteVeri.tarihMekan, '28.09.2026 · Demo Salonu');
    expect(SahteVeri.baslangicSaatSn, 15 * 3600 + 10 * 60 + 9);
    expect(SahteVeri.baslangicEsik, -72);
    expect(SahteVeri.duyulanKartSayisi, 32);
    expect(SahteVeri.kayitliKatilimci, kisiler.where((k) => k.ad != null).length);
  });
}
