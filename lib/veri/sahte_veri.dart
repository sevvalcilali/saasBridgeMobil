import 'modeller.dart';

/// Prototipteki (docs/tasarim/Yakinlik Mobil.dc.html) sabit veri — birebir.
/// Bu dosyayı yalnız etkinlik_deposu.dart içe aktarır.
abstract final class SahteVeri {
  static const etkinlikAdi = 'Yatırımcı Buluşması';
  static const tarihMekan = '28.09.2026 · Demo Salonu';
  static const raporTarihi = '02.10.2026';
  static const cizelgeBaslangici = '15:10';
  static const baslangicSaatSn = 15 * 3600 + 10 * 60 + 9;
  static const baslangicEsik = -72;
  static const duyulanKartSayisi = 32;
  static const kayitliKatilimci = 25;

  static const kisiler = <Kisi>[
    Kisi(id: '24', ad: 'Cem Erdem', kurum: 'Nova Robotik', rol: Rol.girisimci, renk: KisiRengi.hardal, ile: '19', sn: 19, pil: 92),
    Kisi(id: '31', ad: 'İrem Korkmaz', kurum: 'Peak Enerji', rol: Rol.girisimci, renk: KisiRengi.pembe, ile: '65', sn: 74, pil: 81),
    Kisi(id: '33', ad: 'Onur Çelik', kurum: 'Bitki Teknoloji', rol: Rol.girisimci, renk: KisiRengi.mor, ile: '46', sn: 15, pil: 77),
    Kisi(id: '35', ad: 'Gizem Polat', kurum: 'Akıllı Tarım', rol: Rol.girisimci, renk: KisiRengi.mercan, ile: '71', sn: 59, pil: 88),
    Kisi(id: '37', ad: 'Ece Arslan', kurum: 'Sağlık Cebi', rol: Rol.girisimci, renk: KisiRengi.turuncu, ile: '61', sn: 59, pil: 69),
    Kisi(id: '39', ad: 'Tolga Koç', kurum: 'Hızlı Kargo', rol: Rol.girisimci, renk: KisiRengi.petrol, ile: '47', sn: 72, pil: 90),
    Kisi(id: '41', ad: 'Naz Özkan', kurum: 'Temiz Deniz', rol: Rol.girisimci, renk: KisiRengi.hardal, ile: '4', sn: 70, pil: 83),
    Kisi(id: '43', ad: 'Pelin Güneş', kurum: 'Fin Radar', rol: Rol.girisimci, renk: KisiRengi.mor, ile: '52', sn: 64, pil: 95),
    Kisi(id: '45', ad: 'Uğur Demir', kurum: 'Eğitim Yıldızı', rol: Rol.girisimci, renk: KisiRengi.mercan, ile: '58', sn: 71, pil: 72),
    Kisi(id: '5', ad: 'Aslı Kılıç', kurum: 'Şehir Sensör', rol: Rol.girisimci, renk: KisiRengi.mavi, ile: '44', sn: 19, pil: 65),
    Kisi(id: '49', ad: 'Can Yıldız', kurum: 'Veri Köprüsü', rol: Rol.girisimci, renk: KisiRengi.mavi, pil: 84, hic: true),
    Kisi(id: '51', ad: 'Serkan Doğan', kurum: 'Oyun Evreni', rol: Rol.girisimci, renk: KisiRengi.pembe, pil: 86, hic: true),
    Kisi(id: '61', ad: 'Ayşe Demir', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 4, ile: '37', sn: 59, pil: 91),
    Kisi(id: '46', ad: 'Mehmet Kılıç', rol: Rol.yatirimci, renk: KisiRengi.turuncu, yildiz: 5, ile: '33', sn: 15, pil: 16),
    Kisi(id: '83', ad: 'Zeynep Tekin', rol: Rol.yatirimci, renk: KisiRengi.petrol, yildiz: 2, pil: 79, hic: true),
    Kisi(id: '65', ad: 'Emre Kaya', rol: Rol.yatirimci, renk: KisiRengi.hardal, yildiz: 3, ile: '31', sn: 74, pil: 88),
    Kisi(id: '19', ad: 'Elif Aydın', rol: Rol.yatirimci, renk: KisiRengi.pembe, yildiz: 3, ile: '24', sn: 19, pil: 87),
    Kisi(id: '52', ad: 'Burak Aksoy', rol: Rol.yatirimci, renk: KisiRengi.mor, yildiz: 4, ile: '43', sn: 64, pil: 93),
    Kisi(id: '71', ad: 'Selin Şahin', rol: Rol.yatirimci, renk: KisiRengi.mercan, yildiz: 3, ile: '35', sn: 59, pil: 80),
    Kisi(id: '44', ad: 'Merve Bulut', rol: Rol.yatirimci, renk: KisiRengi.turuncu, yildiz: 2, ile: '5', sn: 19, pil: 76),
    Kisi(id: '58', ad: 'Deniz Yılmaz', rol: Rol.yatirimci, renk: KisiRengi.petrol, yildiz: 4, ile: '45', sn: 71, pil: 70),
    Kisi(id: '40', ad: 'Kaan Öztürk', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 3, pil: 82, gorunmuyor: true),
    Kisi(id: '47', ad: 'Kerem Tekin', rol: Rol.misafir, renk: KisiRengi.turuncu, ile: '39', sn: 72, pil: 74),
    Kisi(id: '4', ad: 'Duygu Kaya', rol: Rol.misafir, renk: KisiRengi.petrol, ile: '41', sn: 70, pil: 72),
    Kisi(id: '22', ad: 'Volkan Aydın', rol: Rol.misafir, renk: KisiRengi.hardal, pil: 87, hic: true),
    Kisi(id: '14', rol: Rol.misafir, renk: KisiRengi.pembe, pil: 66, hic: true),
  ];

  static const bildirimler = <Bildirim>[
    Bildirim(
      baslik: 'Pil düşük',
      detay: 'Kart 46 · Mehmet Kılıç · %16 — kartı masada değiştirin',
      saat: '15:09',
      onem: Onem.uyari,
      kisiler: ['46'],
    ),
    Bildirim(
      baslik: 'Yeni görüşme',
      detay: 'Nova Robotik · Cem Erdem, Elif Aydın ile',
      saat: '15:09',
      onem: Onem.olumlu,
      kisiler: ['24', '19'],
    ),
    Bildirim(
      baslik: 'Yalnız kaldı',
      detay: "Veri Köprüsü · Can Yıldız 8 dk'dır görüşmüyor",
      saat: '15:04',
      onem: Onem.uyari,
      kisiler: ['49'],
    ),
    Bildirim(
      baslik: 'Kart kayboldu',
      detay: "Kart 40 · Kaan Öztürk 3 dk'dır duyulmuyor",
      saat: '15:02',
      onem: Onem.ciddi,
      kisiler: ['40'],
    ),
  ];

  static const ciftler = <Cift>[
    Cift('27', '28', -51),
    Cift('61', '90', -49),
    Cift('4', '94', -55),
    Cift('5', '80', -57),
    Cift('47', '58', -60),
    Cift('44', '67', -63),
    Cift('19', '24', -66),
    Cift('39', '51', -69),
    Cift('33', '46', -74),
    Cift('35', '71', -78),
  ];

  /// Grafikte ilk 6 çiftin renkleri (kişi paletinden).
  static const seriRenkleri = <KisiRengi>[
    KisiRengi.pembe,
    KisiRengi.mavi,
    KisiRengi.petrol,
    KisiRengi.mor,
    KisiRengi.turuncu,
    KisiRengi.mercan,
  ];

  static const acikKartlar = <AcikKart>[
    AcikKart('88'),
    AcikKart('89'),
    AcikKart('90'),
    AcikKart('96'),
    AcikKart('97'),
    AcikKart('61', atanmis: true),
    AcikKart('46', atanmis: true),
    AcikKart('24', atanmis: true),
    AcikKart('5', atanmis: true),
  ];
}
