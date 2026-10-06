import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../mantik/gruplar.dart';
import '../veri/modeller.dart';

/// Bir temanın renkleri. Değerler web `tokens.css` ile aynı (açık: "Sıcak Karşılama"; koyu: web'in koyu teması).
class RenkPaleti {
  const RenkPaleti({
    required this.zemin,
    required this.yuzey,
    required this.acikYuzey,
    required this.ayrac,
    required this.kenarlik,
    required this.metin,
    required this.metinKoyu2,
    required this.metin2,
    required this.metinSoluk,
    required this.ipucu,
    required this.vurgu,
    required this.vurguZemin,
    required this.vurguBasili,
    required this.vurguKoyu,
    required this.birlikte,
    required this.birlikteZemin,
    required this.uyari,
    required this.ciddi,
    required this.ciddiZemin,
    required this.ciddiKoyu,
    required this.kural,
    required this.kuralZemin,
    required this.sure1,
    required this.sure5,
    required this.sure10,
    required this.sure20,
    required this.perde,
    required this.ikincilBasili,
    required this.hayaletBasili,
    required this.golge1,
    required this.golge2,
    required this.kisiler,
  });

  final Color zemin, yuzey, acikYuzey, ayrac, kenarlik;
  final Color metin, metinKoyu2, metin2, metinSoluk, ipucu;
  final Color vurgu, vurguZemin, vurguBasili, vurguKoyu;
  final Color birlikte, birlikteZemin, uyari, ciddi, ciddiZemin, ciddiKoyu;
  final Color kural, kuralZemin;
  final Color sure1, sure5, sure10, sure20;
  final Color perde, ikincilBasili, hayaletBasili, golge1, golge2;

  /// Kişi paleti (KisiRengi sırasıyla): renk kişiyi takip eder.
  final Map<KisiRengi, Color> kisiler;
}

/// Açık tema (docs/tasarim/README.md, tema = web).
const acikPalet = RenkPaleti(
  zemin: Color(0xFFF7F2E9),
  yuzey: Color(0xFFFFFDF8),
  acikYuzey: Color(0xFFEFE7D8),
  ayrac: Color(0xFFE2D8C4),
  kenarlik: Color(0xFFCFC2A9),
  metin: Color(0xFF3B332C),
  metinKoyu2: Color(0xFF4D453C),
  metin2: Color(0xFF6B6156),
  metinSoluk: Color(0xFF92897C),
  ipucu: Color(0xA63B332C),
  vurgu: Color(0xFF9A6512),
  vurguZemin: Color(0xFFF5E8CF),
  vurguBasili: Color(0xFF7F5410),
  vurguKoyu: Color(0xFF5C3D0A),
  birlikte: Color(0xFF1B7A4E),
  birlikteZemin: Color(0xFFE0F2E4),
  uyari: Color(0xFFB4470E),
  ciddi: Color(0xFFB02A25),
  ciddiZemin: Color(0xFFF9E2E0),
  ciddiKoyu: Color(0xFF8A1F1B),
  kural: Color(0xFF2B5797),
  kuralZemin: Color(0xFFE3EBF7),
  sure1: Color(0xFF7A7369),
  sure5: Color(0xFF2A7FD0),
  sure10: Color(0xFFD2621A),
  sure20: Color(0xFFC42D28),
  perde: Color(0x59201E1D),
  ikincilBasili: Color(0x243B332C),
  hayaletBasili: Color(0x2E9A6512),
  golge1: Color(0x143B332C),
  golge2: Color(0x1F3B332C),
  kisiler: {
    KisiRengi.mavi: Color(0xFF1245AF),
    KisiRengi.turuncu: Color(0xFF854412),
    KisiRengi.hardal: Color(0xFF968403),
    KisiRengi.pembe: Color(0xFF920F6D),
    KisiRengi.mor: Color(0xFF895CD2),
    KisiRengi.mercan: Color(0xFFCC646F),
    KisiRengi.petrol: Color(0xFF248FB2),
    KisiRengi.gri: Color(0xFF302F2E),
  },
);

/// Koyu tema (web `tokens.css` `[data-theme="dark"]` ile aynı değerler).
const koyuPalet = RenkPaleti(
  zemin: Color(0xFF181614),
  yuzey: Color(0xFF221F1B),
  acikYuzey: Color(0xFF2C2823),
  ayrac: Color(0xFF3A342D),
  kenarlik: Color(0xFF51493F),
  metin: Color(0xFFF2EBE0),
  metinKoyu2: Color(0xFFDCD2C4),
  metin2: Color(0xFFC5B9A8),
  metinSoluk: Color(0xFF968B7C),
  ipucu: Color(0xA6F2EBE0),
  vurgu: Color(0xFFE2A852),
  vurguZemin: Color(0xFF3B2F1C),
  vurguBasili: Color(0xFFF0BE6E),
  vurguKoyu: Color(0xFFF6D094),
  birlikte: Color(0xFF4CC38A),
  birlikteZemin: Color(0xFF16301F),
  uyari: Color(0xFFF08C52),
  ciddi: Color(0xFFF2726A),
  ciddiZemin: Color(0xFF3F1C1A),
  ciddiKoyu: Color(0xFFF7A49E),
  kural: Color(0xFF7FA8EA),
  kuralZemin: Color(0xFF1B2638),
  sure1: Color(0xFFB3AA9D),
  sure5: Color(0xFF5FA4E6),
  sure10: Color(0xFFF38D45),
  sure20: Color(0xFFF2675F),
  perde: Color(0x8C000000),
  ikincilBasili: Color(0x24F2EBE0),
  hayaletBasili: Color(0x2EE2A852),
  golge1: Color(0x66000000),
  golge2: Color(0x4D000000),
  kisiler: {
    KisiRengi.mavi: Color(0xFF3F65EE),
    KisiRengi.turuncu: Color(0xFFD8772C),
    KisiRengi.hardal: Color(0xFF827205),
    KisiRengi.pembe: Color(0xFFA15B88),
    KisiRengi.mor: Color(0xFFAD74EE),
    KisiRengi.mercan: Color(0xFFEA2052),
    KisiRengi.petrol: Color(0xFF3397BE),
    KisiRengi.gri: Color(0xFFC2AEA5),
  },
);

/// Tüm renk token'ları. Renk sabiti YALNIZ bu klasörde yazılır; ekranlar buradan okur.
/// Etkin palet `koyu` ile seçilir (Kabuk ayarlar: sistem / açık / koyu); uygulama kökü değişince yeniden kurulur.
abstract final class Renkler {
  /// Koyu tema açık mı. Dinleyen: uygulama kökü (tema ve tüm ekranlar yeniden çizilir).
  static final ValueNotifier<bool> koyuBildirici = ValueNotifier(false);
  static bool get koyu => koyuBildirici.value;
  static set koyu(bool deger) => koyuBildirici.value = deger;

  static RenkPaleti get palet => koyu ? koyuPalet : acikPalet;

  // --- Yüzeyler ---
  static const seffaf = Color(0x00000000);
  static Color get zemin => palet.zemin;
  static Color get yuzey => palet.yuzey;
  static Color get acikYuzey => palet.acikYuzey;
  static Color get ayrac => palet.ayrac;
  static Color get kenarlik => palet.kenarlik;

  // --- Metin ---
  static Color get metin => palet.metin;
  static Color get metinKoyu2 => palet.metinKoyu2;
  static Color get metin2 => palet.metin2;
  static Color get metinSoluk => palet.metinSoluk;

  /// Girdi ipucu yazısı: metin renginin %65'i.
  static Color get ipucu => palet.ipucu;

  // --- Vurgu (altın) ---
  static Color get vurgu => palet.vurgu;
  static Color get vurguZemin => palet.vurguZemin;
  static Color get vurguBasili => palet.vurguBasili;
  static Color get vurguKoyu => palet.vurguKoyu;

  // --- Durumlar. YEŞİL yalnız "şu an birlikte" demektir. ---
  static Color get birlikte => palet.birlikte;
  static Color get birlikteZemin => palet.birlikteZemin;
  static Color get uyari => palet.uyari;
  static Color get ciddi => palet.ciddi;
  static Color get ciddiZemin => palet.ciddiZemin;
  static Color get ciddiKoyu => palet.ciddiKoyu;

  /// Uyarı kuralı (web --kural): süre renkleriyle karışmasın diye mavi.
  static Color get kural => palet.kural;
  static Color get kuralZemin => palet.kuralZemin;

  // --- Görüşme süresi (salon figürleri): gri → mavi → turuncu → kırmızı (Şevval 06.10.2026) ---
  static Color get sure1 => palet.sure1;
  static Color get sure5 => palet.sure5;
  static Color get sure10 => palet.sure10;
  static Color get sure20 => palet.sure20;

  // --- Kaplamalar ve gölge ---
  /// Alt sayfanın arkasındaki perde.
  static Color get perde => palet.perde;

  /// İkincil düğme basılıyken.
  static Color get ikincilBasili => palet.ikincilBasili;

  /// Hayalet düğme basılıyken.
  static Color get hayaletBasili => palet.hayaletBasili;
  static Color get golge1 => palet.golge1;
  static Color get golge2 => palet.golge2;

  /// Kişi paleti: renk kişiyi takip eder, sıraya göre değişmez.
  static Color kisi(KisiRengi renk) => palet.kisiler[renk]!;

  /// Durum yazısının rengi.
  static Color ton(DurumTonu ton) => switch (ton) {
    DurumTonu.birlikte => birlikte,
    DurumTonu.uyari => uyari,
    DurumTonu.ikincil => metin2,
    DurumTonu.ciddi => ciddi,
  };

  /// Salon figürünün rengi (görüşme süresi).
  static Color sure(SureRengi r) => switch (r) {
    SureRengi.gri => sure1,
    SureRengi.mavi => sure5,
    SureRengi.turuncu => sure10,
    SureRengi.kirmizi => sure20,
  };

  /// Bildirim noktasının rengi.
  static Color onem(Onem onem) => switch (onem) {
    Onem.ciddi => ciddi,
    Onem.uyari => uyari,
    Onem.olumlu => vurguBasili,
    Onem.kural => kural,
  };
}
