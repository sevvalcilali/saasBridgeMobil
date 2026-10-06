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
  const Cift(this.a, this.b, this.rssi, {this.ham});

  final String a;
  final String b;

  /// Yuvarlanmış değer (liste, grafik, eşik sayımı).
  final int rssi;
  /// Sunucunun ham değeri (son 10 sn ortancası); verilmezse yuvarlanmış değer.
  final double? ham;

  /// Kalibrasyon ölçümü bunu kullanır (yuvarlanmamış).
  double get dbm => ham ?? rssi.toDouble();
}

/// Alıcının şu an duyduğu kart (`/api/cards`).
class AcikKart {
  const AcikKart(this.no, {this.atanmis = false, this.seenAgo = 0});

  final String no;
  final bool atanmis;


  /// Kaç saniye önce duyuldu.
  final double seenAgo;
}

/// Kayıtlı kişi (`/api/people`): kartı olsun olmasın. Kart Ver 1. adımı ve İade bununla çalışır.
/// `atananKart == null && !ayrildi` = kart bekliyor; `ayrildi` = kart iadesi yapıldı.
class Katilimci {
  const Katilimci({
    required this.kisiId,
    required this.ad,
    required this.rol,
    required this.renk,
    this.kurum,
    this.yildiz = 0,
    this.atananKart,
    this.ayrildi = false,
    this.notu = '',
    this.sektor = '',
    this.asama = '',
    this.tanitim = '',
    this.web = '',
    this.eposta = '',
    this.paylasim = false,
  });

  final String kisiId;
  final String ad;
  final String? kurum;
  final Rol rol;
  final KisiRengi renk;
  final int yildiz;
  final String? atananKart;
  final bool ayrildi;
  final String notu;

  // Rapor bilgileri (kişiye özel rapor 2. adım): girişimcide sektör/aşama/tanıtım/web; yatırımcıda ilgi alanları (sektor).
  final String sektor;

  /// fikir | mvp | gelir | buyume ya da boş; yalnız girişimcide.
  final String asama;
  final String tanitim;
  final String web;
  final String eposta;

  /// İletişim bilgisi başkalarının raporunda görünebilir mi (KVKK; varsayılan hayır).
  final bool paylasim;

  bool get kartBekliyor => atananKart == null && !ayrildi;
}
