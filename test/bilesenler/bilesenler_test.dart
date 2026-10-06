import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/arama_alani.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/bilesenler/bolmeli_anahtar.dart';
import 'package:yakinlik_mobil/bilesenler/cip.dart';
import 'package:yakinlik_mobil/bilesenler/dokunma_hedefi.dart';
import 'package:yakinlik_mobil/bilesenler/etiket.dart';
import 'package:yakinlik_mobil/bilesenler/etiketli_deger.dart';
import 'package:yakinlik_mobil/bilesenler/hap_dugme.dart';
import 'package:yakinlik_mobil/bilesenler/kesik_cizgi.dart';
import 'package:yakinlik_mobil/bilesenler/kicker.dart';
import 'package:yakinlik_mobil/bilesenler/rol_sekli.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

import '../yardimci.dart';

class _DenemeCizici extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    kesikCizgi(canvas, Offset.zero, const Offset(20, 0), Paint(), dolu: 4, bos: 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  group('DokunmaHedefi', () {
    testWidgets('küçük görseli büyütmeden 44 × 44 dokunma alanı verir', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: DokunmaHedefi(onTap: () => sayac++, child: const SizedBox(width: 20, height: 20)))),
      );
      expect(tester.getSize(find.byType(DokunmaHedefi)), const Size(44, 44));
      // Görselin dışına, ama 44 px'lik alanın içine dokun.
      await tester.tapAt(tester.getCenter(find.byType(DokunmaHedefi)) + const Offset(18, 18));
      expect(sayac, 1);
    });
  });

  group('HapDugme', () {
    Finder dolguKutusu() =>
        find.descendant(of: find.byType(HapDugme), matching: find.byType(DecoratedBox)).first;

    testWidgets('dokununca çağırır; görsel 36 px olsa da dokunma alanı 44 px', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: HapDugme(etiket: 'Geri al', yukseklik: 36, onTap: () => sayac++))),
      );
      await tester.tap(find.text('Geri al'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(HapDugme)).height, 44);
      expect(tester.getSize(dolguKutusu()).height, 36);
    });

    testWidgets('genis: bulunduğu genişliği doldurur', (tester) async {
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 300,
              child: HapDugme(etiket: 'Onayla', tur: HapTuru.birincil, yukseklik: 48, genis: true, onTap: islevsiz),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(HapDugme)), const Size(300, 48));
      expect(tester.getSize(dolguKutusu()), const Size(300, 48));
    });

    testWidgets('sabit genişlik: 48 × 48', (tester) async {
      await tester.pumpWidget(
        temali(const Center(child: HapDugme(etiket: '+1', genislik: 48, yukseklik: 48, punto: 18, onTap: islevsiz))),
      );
      expect(tester.getSize(find.byType(HapDugme)), const Size(48, 48));
    });

    testWidgets('birincil düğme basılıyken koyulaşır', (tester) async {
      await tester.pumpWidget(
        temali(const Center(child: HapDugme(etiket: 'Onayla', tur: HapTuru.birincil, onTap: islevsiz))),
      );
      Color? dolgu() => (tester.widget<DecoratedBox>(dolguKutusu()).decoration as BoxDecoration).color;
      expect(dolgu(), Renkler.vurgu);
      final hareket = await tester.startGesture(tester.getCenter(find.text('Onayla')));
      await tester.pump(const Duration(milliseconds: 150));
      expect(dolgu(), Renkler.vurguBasili);
      await hareket.up();
      await tester.pump();
      expect(dolgu(), Renkler.vurgu);
    });

    testWidgets('birincil düğmeye zemin verilirse o renkle dolar (ör. kırmızı Sil)', (tester) async {
      await tester.pumpWidget(
        temali(Center(child: HapDugme(etiket: 'Sil', tur: HapTuru.birincil, zemin: Renkler.ciddi, onTap: islevsiz))),
      );
      final susleme = tester.widget<DecoratedBox>(dolguKutusu()).decoration as BoxDecoration;
      expect(susleme.color, Renkler.ciddi);
    });

    testWidgets('ikincil düğme kenarlıklıdır; zemin verilebilir', (tester) async {
      await tester.pumpWidget(
        temali(Center(child: HapDugme(etiket: '↶ Geri al', zemin: Renkler.zemin, onTap: islevsiz))),
      );
      final susleme = tester.widget<DecoratedBox>(dolguKutusu()).decoration as BoxDecoration;
      expect(susleme.color, Renkler.zemin);
      expect(susleme.border, Border.all(color: Renkler.kenarlik));
    });
  });

  group('Etiket', () {
    testWidgets('dokunulabilir etiket: dokunma alanı 44 px', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: Etiket('Eşik −72 dBm', tur: EtiketTuru.notr, onTap: () => sayac++))),
      );
      await tester.tap(find.text('Eşik −72 dBm'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(Etiket)).height, 44);
    });

    testWidgets('dokunulamaz etiket 28 px', (tester) async {
      await tester.pumpWidget(temali(const Center(child: Etiket('● Alıcı bağlı'))));
      expect(tester.getSize(find.byType(Etiket)).height, 28);
    });
  });

  group('Cip', () {
    BoxDecoration susleme(WidgetTester tester, String metin) =>
        tester
                .widget<DecoratedBox>(
                  find.ancestor(of: find.text(metin), matching: find.byType(DecoratedBox)).first,
                )
                .decoration
            as BoxDecoration;

    testWidgets('seçili çip dolgu rengini alır; dokununca çağırır', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Cip(etiket: 'Tümü', secili: true, onTap: islevsiz),
                Cip(etiket: 'Yatırımcı', secili: false, onTap: () => sayac++),
              ],
            ),
          ),
        ),
      );
      expect(susleme(tester, 'Tümü').color, Renkler.vurgu);
      expect(susleme(tester, 'Yatırımcı').color, isNull);
      await tester.tap(find.text('Yatırımcı'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(Cip).first).height, 44);
    });

    testWidgets('sayı etiketin yanında; seçili renk değiştirilebilir', (tester) async {
      await tester.pumpWidget(
        temali(
          Center(
            child: Cip(etiket: 'Ciddi', sayi: '1', secili: true, seciliRenk: Renkler.metin, onTap: islevsiz),
          ),
        ),
      );
      expect(find.text('Ciddi 1'), findsOneWidget);
      expect(susleme(tester, 'Ciddi 1').color, Renkler.metin);
    });
  });

  group('BolmeliAnahtar', () {
    testWidgets('seçince değeri bildirir; ek yazı etiketin yanında', (tester) async {
      String? secilen;
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 362,
              child: BolmeliAnahtar<String>(
                yukseklik: 40,
                secenekler: const [
                  BolmeSecenegi(deger: 'kisiler', etiket: 'Kişiler', ek: '26'),
                  BolmeSecenegi(deger: 'ag', etiket: 'Ağ'),
                  BolmeSecenegi(deger: 'bildirimler', etiket: 'Bildirimler', ek: '4'),
                ],
                secili: 'kisiler',
                onSecildi: (d) => secilen = d,
              ),
            ),
          ),
        ),
      );
      expect(find.text('26'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(tester.getSize(find.byType(BolmeliAnahtar<String>)), const Size(362, 40));
      await tester.tap(find.text('Ağ'));
      expect(secilen, 'ag');
    });
  });

  group('AramaAlani', () {
    testWidgets('yazınca bildirir; en az 44 px', (tester) async {
      String? son;
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 362,
              child: AramaAlani(ipucu: 'Ara: ad, kurum, kart no', onDegisti: (s) => son = s),
            ),
          ),
        ),
      );
      expect(find.text('Ara: ad, kurum, kart no'), findsOneWidget);
      expect(tester.getSize(find.byType(AramaAlani)).height, greaterThanOrEqualTo(44));
      await tester.enterText(find.byType(TextField), 'nova');
      expect(son, 'nova');
    });

    testWidgets('rakam modu harf kabul etmez', (tester) async {
      final denetleyici = TextEditingController();
      addTearDown(denetleyici.dispose);
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 200,
              child: AramaAlani(ipucu: 'Örn. 14', denetleyici: denetleyici, rakam: true, yukseklik: 52, punto: 24),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '1a2b');
      expect(denetleyici.text, '12');
      expect(tester.getSize(find.byType(AramaAlani)).height, greaterThanOrEqualTo(52));
    });
  });

  group('Kicker', () {
    testWidgets('Türkçe büyük harf ve sayı', (tester) async {
      await tester.pumpWidget(temali(const Center(child: Kicker('Girişimciler', sayi: '12'))));
      expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });

  group('RolSekli', () {
    testWidgets('anlam etiketi rol adıdır; boyut korunur', (tester) async {
      final anlam = tester.ensureSemantics();
      await tester.pumpWidget(
        temali(
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RolSekli(rol: Rol.yatirimci, renk: KisiRengi.mavi),
                RolSekli(rol: Rol.girisimci, renk: KisiRengi.hardal),
                RolSekli(rol: Rol.misafir, renk: KisiRengi.pembe, boyut: 14),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Yatırımcı'), findsOneWidget);
      expect(find.bySemanticsLabel('Girişimci'), findsOneWidget);
      expect(find.bySemanticsLabel('Misafir'), findsOneWidget);
      expect(tester.getSize(find.byType(RolSekli).first), const Size(12, 12));
      expect(tester.getSize(find.byType(RolSekli).last), const Size(14, 14));
      anlam.dispose();
    });
  });

  group('BasiliOpaklik', () {
    testWidgets('dokununca çağırır; basılıyken soluklaşır', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(
          Center(
            child: BasiliOpaklik(
              onTap: () => sayac++,
              child: const SizedBox(width: 200, height: 60, child: Text('satır')),
            ),
          ),
        ),
      );
      double opaklik() => tester
          .widget<Opacity>(find.descendant(of: find.byType(BasiliOpaklik), matching: find.byType(Opacity)))
          .opacity;
      await tester.tap(find.text('satır'));
      expect(sayac, 1);
      expect(opaklik(), 1);
      final hareket = await tester.startGesture(tester.getCenter(find.byType(BasiliOpaklik)));
      await tester.pump(const Duration(milliseconds: 150));
      expect(opaklik(), 0.7);
      await hareket.up();
      await tester.pump();
      expect(opaklik(), 1);
    });
  });

  group('EtiketliDeger', () {
    testWidgets('etiket ve değer', (tester) async {
      await tester.pumpWidget(temali(const Center(child: EtiketliDeger(etiket: 'Pil', deger: '%94'))));
      expect(find.text('Pil'), findsOneWidget);
      expect(find.text('%94'), findsOneWidget);
    });
  });

  group('kesikCizgi', () {
    testWidgets('dolu ve boş aralıklarla parça parça çizer', (tester) async {
      await tester.pumpWidget(
        temali(Center(child: CustomPaint(key: const Key('cizim'), size: const Size(20, 10), painter: _DenemeCizici()))),
      );
      expect(
        find.byKey(const Key('cizim')),
        paints
          ..line(p1: Offset.zero, p2: const Offset(4, 0))
          ..line(p1: const Offset(8, 0), p2: const Offset(12, 0))
          ..line(p1: const Offset(16, 0), p2: const Offset(20, 0)),
      );
    });
  });
}
