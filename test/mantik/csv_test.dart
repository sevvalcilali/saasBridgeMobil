import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/csv.dart';
import 'package:yakinlik_mobil/mantik/rapor_hesap.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

void main() {
  const kisiler = [
    Katilimci(kisiId: 'k1', ad: 'Ayşe; Demir', kurum: 'Atlas "A"', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 4, atananKart: '2', sektor: 'Sağlık', eposta: 'a@b.c', paylasim: true),
    Katilimci(kisiId: 'k2', ad: 'Ali', rol: Rol.girisimci, renk: KisiRengi.gri, asama: 'mvp'),
  ];
  const oturumlar = [Oturum('k1', 'k2', 100, 1640), Oturum('k1', 'kart:14', 0, null)];

  test('katılımcılar CSV: BOM, ; ayraç, tırnaklama, dakika virgüllü', () {
    final csv = katilimcilarCsv(kisiler, oturumlar, 2000);
    final satirlar = csv.split('\r\n');
    expect(satirlar.first.startsWith('﻿'), isTrue);
    expect(satirlar.first.substring(1), 'Ad;Rol;Kurum;Yıldız;Kart;Toplam (dk);Görüşme;Görüştüğü kişi;Karşı rolden kişi;Sektör / ilgi alanı;Aşama;E-posta;Paylaşım izni');
    expect(satirlar[1], '"Ayşe; Demir";Yatırımcı;"Atlas ""A""";4;Kart 2;59,0;2;2;1;Sağlık;;a@b.c;evet');
    expect(satirlar[2], 'Ali;Girişimci;;;kart almadı;25,7;1;1;1;;MVP;;hayır');
  });

  test('görüşmeler CSV: kişi adları, saatler, süre; sürmekte olan "sürüyor"', () {
    final csv = gorusmelerCsv(oturumlar, kisiler, 2000, '15:33:20');
    final satirlar = csv.split('\r\n');
    expect(satirlar.first.substring(1), 'Kişi 1;Rol 1;Kişi 2;Rol 2;Başlangıç;Bitiş;Süre (dk)');
    // Başlangıca göre sıralı: kayıtsız kartla olan 0. saniyede başladı.
    expect(satirlar[1], '"Ayşe; Demir";Yatırımcı;Kart 14 (kayıtsız);;15:00;sürüyor;33,3');
    expect(satirlar[2], '"Ayşe; Demir";Yatırımcı;Ali;Girişimci;15:01;15:27;25,7');
  });
}
