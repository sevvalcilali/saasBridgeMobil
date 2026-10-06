/// Sunucudaki rol adlarının karşılığı: investor / founder / guest.
enum Rol { yatirimci, girisimci, misafir }

/// Kişi paleti adları. Renk değerleri tema/renkler.dart'tadır.
enum KisiRengi { mavi, turuncu, hardal, pembe, mor, mercan, petrol, gri }

/// Bildirim önemi.
enum Onem { ciddi, uyari, olumlu }

/// Durum yazısının anlamsal tonu; rengini tema eşler (mantık renk bilmez).
enum DurumTonu { birlikte, uyari, ikincil, ciddi }

/// Bir karta atanmış kişi. `id` kart numarasıdır; `ad == null` kayıtsız karttır.
class Kisi {
  const Kisi({
    required this.id,
    required this.rol,
    required this.renk,
    required this.pil,
    this.ad,
    this.kurum,
    this.ile,
    this.sn = 0,
    this.yildiz = 0,
    this.gorunmuyor = false,
    this.hic = false,
  });

  final String id;
  final String? ad;
  final String? kurum;
  final Rol rol;
  final KisiRengi renk;

  /// Şu an birlikte olduğu kişinin kart numarası.
  final String? ile;

  /// Başlangıçtaki süre (saniye).
  final int sn;

  /// Pil yüzdesi.
  final int pil;

  /// 0–5; yatırımcı değilse 0.
  final int yildiz;
  final bool gorunmuyor;

  /// Hiç görüşmemiş.
  final bool hic;
}

class Bildirim {
  const Bildirim({
    required this.baslik,
    required this.detay,
    required this.saat,
    required this.onem,
    required this.kisiler,
  });

  final String baslik;
  final String detay;
  final String saat;
  final Onem onem;

  /// İlgili kişilerin kart numaraları; satıra dokununca ilki açılır.
  final List<String> kisiler;
}

/// Sinyali ölçülen kart çifti (dBm).
class Cift {
  const Cift(this.a, this.b, this.rssi);

  final String a;
  final String b;
  final int rssi;
}

/// Alıcının şu an duyduğu kart.
class AcikKart {
  const AcikKart(this.no, {this.atanmis = false});

  final String no;
  final bool atanmis;
}
