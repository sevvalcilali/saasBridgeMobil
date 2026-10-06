/// Sunucudaki rol adlarının karşılığı: investor / founder / guest.
enum Rol { yatirimci, girisimci, misafir }

/// Kişi paleti adları. Renk değerleri tema/renkler.dart'tadır.
enum KisiRengi { mavi, turuncu, hardal, pembe, mor, mercan, petrol, gri }

/// Bildirim önemi. `kural`: organizatörün uyarı kuralı tetiklendi (Pano'da açılır uyarı).
enum Onem { ciddi, uyari, olumlu, kural }

/// Durum yazısının anlamsal tonu; rengini tema eşler (mantık renk bilmez).
enum DurumTonu { birlikte, uyari, ikincil, ciddi }

/// Bir karta atanmış kişi. `id` kart numarasıdır; `ad == null` kayıtsız karttır.
class Kisi {
  const Kisi({
    required this.id,
    required this.rol,
    required this.renk,
    this.pil,
    this.ad,
    this.kurum,
    this.ile,
    this.sn = 0,
    this.yildiz = 0,
    this.gorunmuyor = false,
    this.hic = false,
    this.bostaSn = 0,
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

  /// Pil yüzdesi; sunucu kartı duymuyorsa ya da bilinmiyorsa null.
  final int? pil;

  /// 0–5; yatırımcı değilse 0.
  final int yildiz;
  final bool gorunmuyor;

  /// Hiç görüşmemiş.
  final bool hic;

  /// Kaç saniyedir boşta (sunucunun idleSinceS'i); görüşüyorsa 0.
  final int bostaSn;
}

class Bildirim {
  const Bildirim({
    required this.baslik,
    required this.detay,
    required this.saat,
    required this.onem,
    required this.kisiler,
    this.t = 0,
  });

  final String baslik;
  final String detay;
  final String saat;
  final Onem onem;

  /// İlgili kişilerin kart numaraları; satıra dokununca ilki açılır.
  final List<String> kisiler;

  /// Sunucu zamanı (saniye); açılır uyarının kimliği ve "son 2 dakika" için.
  final double t;
}

/// Bir çiftin bugünkü toplam görüşme süresi (sunucunun `edges`'i).
class GunBoyuCift {
  const GunBoyuCift(this.a, this.b, this.sn);

  final String a;
  final String b;
  final int sn;
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
