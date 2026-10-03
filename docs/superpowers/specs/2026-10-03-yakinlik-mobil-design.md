# Yakınlık Panosu Mobil (Flutter) — Tasarım Şartnamesi

> Tarih: 03.10.2026 · Proje sahibi: Şevval · Durum: **yazılı şartname, onay bekliyor**
> Tasarım kaynağı: `docs/tasarim/` (teslim paketi: `README.md`, `Yakinlik Mobil.dc.html`)
> Web uygulaması: `sevvalcilali/SaasBridge`, dal `faz-0-altyapi` (yerelde `~/Desktop/Projects/saasBridge`)

---

## 1. Amaç

SaasBridge "Yakınlık Panosu" web uygulamasının saha görevlileri için telefon sürümünü, tasarım
teslim paketindeki hifi prototipe sadık kalarak **Flutter** ile yazmak. Uygulama bu aşamada
sunucuya bağlanmaz; prototipteki gömülü sahte veriyle çalışır.

### Verilmiş kararlar (03.10.2026, Şevval)

| Konu | Karar |
|---|---|
| Görsel varyant | **1a Liste** (1b Sade yazılmaz) |
| Proje yeri | Ayrı klasör ve ayrı git deposu: `~/Desktop/Projects/yakinlik_mobil/` |
| Kapsam | **Yalnız prototip eşdeğeri**: gömülü sahte veri, ağ yok |
| Yaklaşım | Bağımlılıksız ve katmanlı: saf Dart mantık + `ChangeNotifier` + `CustomPaint` |
| Git | Yerel depo, her adım kendi commit'i. Push yok, uzak depo yok |

---

## 2. Kapsam

### Var
- **Kabuk:** 4 sekmeli alt çubuk (Pano, Kart Ver, Kurulum, Rapor), alıcı kopuk bandı.
- **Pano:** üst alan (etkinlik adı, saat, etiketler, Sıfırla) + bölüm anahtarı: Kişiler · Ağ · Bildirimler.
- **Kişi Detayı:** alt sayfa (bottom sheet).
- **Kart Ver:** 3 adımlı sihirbaz (Kişi → Kart → Onay) ve **Kart İadesi** modu.
- **Kurulum:** eşik, canlı sinyal grafiği, kalibrasyon bölümü, kart sağlığı.
- **Rapor:** başlık, düğmeler, 5 KPI, girişimci satırları.
- Tek tema: `web` (krem/altın). iOS + Android, dikey kullanım, 390–430 px genişlik.

### Yok
1b varyantı · broadsheet teması · koyu tema · sunucu/ağ · kalıcılık (yeniden açılışta durum sıfırdan
başlar) · sunum modu · CSV yükleme · uygulama ikonu ve açılış ekranı tasarımı.

### Davranış sınırı (prototiple aynı)
- Saat 15:10:09'dan başlar, saniyede bir ilerler. "Birlikte" olan kişilerin süreleri saniyede bir artar.
  Grafik her saniye güncellenir.
- **Onayla / Geri al / İade al yalnız bant gösterir; sahte veriyi değiştirmez.** (Atanan kart
  listelerde görünmez, iade edilen kişi panodan düşmez.)
- Sıfırla yalnız süre sayacını (`tick`) sıfırlar; saat akmaya devam eder.
- Eşik değişince Pano'daki etiket, "eşiğin üstündeki çift" sayısı ve grafikteki eşik çizgisi güncellenir.

### Prototipte işlevi olmayan, burada da işlevsiz kalan düğmeler
`Düzenle` (Kart Ver adım 1) · `— çift seçin —` (Kalibrasyon) · `Yazdır / PDF` · `⤓ Katılımcılar` ·
`⤓ Görüşmeler` · `Yenile` (Rapor). Basılı görünümleri vardır, eylemleri yoktur. Arkalarındaki
ekranlar tasarlanmadığı için bu aşamada eklenmez.

---

## 3. Kaynak önceliği ve bilinçli sapmalar

**Kural:** README bir şeyi açıkça söylüyorsa README geçerlidir. README'nin sustuğu yerde prototipin
ölçüsü ve davranışı geçerlidir. İş kurallarında (süre biçimi gibi) web reposundaki `src/api/` esas alınır.

| # | Konu | Prototip | README / web | Karar |
|---|---|---|---|---|
| S1 | Filtre ve önem çiplerinin köşesi | 12 px | hap (999) | Hap |
| S2 | Adım göstergesi (Kişi/Kart/Onay) köşesi | 12 px | "3 hap" | Hap |
| S3 | Kopuk bandı rengi | zemin `#f9e2e0`, yazı `#8a1f1b` | "sarı bant" (hex yok) | Prototip renkleri |
| S4 | Sekme ikonları | özel SVG | Material ikonlar "yeterlidir" | `grid_view`, `badge_outlined`, `tune`, `bar_chart` |
| S5 | Grafik yazı/çizgi renkleri | `#006786`, `#605d5d`, `#201e1d` (broadsheet'ten sızmış) | belirtilmemiş | Web token'ları: `#7f5410`, `#6b6156`, `#3b332c` |
| S6 | Nötr etiket zemini (Eşik etiketi) | `#f8f4f4` (broadsheet'ten sızmış) | belirtilmemiş | `#efe7d8` (açık yüzey) |
| S7 | "Görünmüyor" durum rengi | `#b02a25` (ciddi) | "uyarı" | `#b4470e` (uyarı) |
| S8 | Kalın metinler (`<strong>`) | 700 | 600 | 600 |
| S9 | Süre biçimi | `1 dk 0 sn`, `61 dk 5 sn` | web: `1 dk`, `1 sa 1 dk` | Web kuralı (§7 `sureYazisi`) |
| S10 | Eksi işareti | dinamik değerde `-72` | `−72` | Her yerde `−` (U+2212) |
| S11 | Sıfırla onayı | tarayıcı `confirm` | "onay diyaloğu" | Temalı diyalog; düğmeler `Vazgeç` / `Sıfırla` |
| S12 | Alıcı kopuk durumu | tasarım aracı düğmesi | durum tarif edilmiş | `--dart-define=ALICI_BAGLI=false` |
| S13 | Sihirbazın altındaki `Bu kartı seç` | numara geçerliyse iki kart modunda da görünür | "Numara" başlığı altında | Yalnız `Numarayı yaz` modunda |
| S14 | Adı olmayan kişi (Kart 14) seçilince | boş ad / `null` yazısı | — | `Kart 14` yazılır (`gorunenAd`) |
| S15 | Grafikte eşik çizgisi eksen dışına çıkınca (−35…−39, −91…−95) | grafik dışına taşar | web: "kenara yapışır" | Grafik kenarına yapışır |
| S16 | Demo yaklaştırma bekleyen zamanlayıcısı | adım değişince iptal edilmez | — | Adım/kişi değişince iptal edilir |
| S17 | 44 px altı düğmeler (etiket 28, çip 36, Geri al 36, Düzenle 36, kapat 40) | görsel ölçü kadar | "tüm dokunma hedefleri ≥ 44" | Görsel ölçü aynı kalır, dokunma alanı görünmez biçimde 44 px'e genişler |

---

## 4. Mimari

Web reposundaki `api / screens / components / theme` ayrımının karşılığı. Kod adları web'deki gibi
Türkçe (ASCII), yorumlar Türkçe.

```
lib/
  main.dart                    runApp
  uygulama.dart                MaterialApp: tema, tr yereli, dikey kilit, Kabuk
  tema/
    renkler.dart               tüm renk token'ları + kişi paleti (renklerin TEK kaynağı)
    olculer.dart               köşe, kenar boşluğu, gölge sabitleri
    yazi.dart                  metin stilleri (h1, h2, gövde, kicker, tabular rakam)
    tema.dart                  ThemeData
  veri/
    modeller.dart              Rol, KisiRengi, Kisi, Onem, Bildirim, Cift, AcikKart
    sahte_veri.dart            prototipteki sabit veri
    etkinlik_deposu.dart       saat/tick, eşik, alıcı durumu, sıfırla (ChangeNotifier)
  mantik/                      saf Dart; Flutter içe aktarmaz
    metin.dart                 Türkçe küçük/büyük harf
    bicim.dart                 süre, saat, dBm, yıldız yazıları
    kisi_gorunum.dart          ad/başlık/durum türetmeleri
    pano_filtre.dart           kişi filtresi + arama, liste başlığı, bildirim süzme
    ag.dart                    ağ yerleşimi (sol/sağ düğümler, kenarlar)
    kart_no.dart               kart numarası kuralları, açık kart önerisi
    kurulum.dart               eşik, grafik geometrisi ve serileri, kart sağlığı
    rapor.dart                 KPI'lar ve girişimci satırları
  bilesenler/                  ekranlar arası ortak, tek işli parçalar
    rol_sekli.dart  hap_dugme.dart  etiket.dart  cip.dart  bolmeli_anahtar.dart
    arama_alani.dart  kicker.dart  basili_opaklik.dart  dokunma_hedefi.dart
  ekranlar/
    kabuk.dart
    pano/        pano_durumu.dart  pano_ekrani.dart  pano_ust.dart  kisiler_bolumu.dart
                 ag_bolumu.dart  bildirimler_bolumu.dart
    kisi_detayi/ kisi_detay_sayfasi.dart
    kart_ver/    kart_ver_durumu.dart  kart_ver_ekrani.dart  adim_gostergesi.dart
                 kisi_adimi.dart  kart_adimi.dart  nabiz.dart  kontrol_adimi.dart  iade_paneli.dart
    kurulum/     kurulum_ekrani.dart  esik_bolumu.dart  sinyal_grafigi.dart  kart_sagligi_bolumu.dart
    rapor/       rapor_ekrani.dart
test/
  mantik/  veri/  bilesenler/  ekranlar/  mimari_test.dart
integration_test/ekran_goruntuleri_test.dart
test_driver/integration_test.dart
```

### Katman kuralları
1. `mantik/` saf Dart'tır: yalnız `veri/modeller.dart`'ı içe aktarır, Flutter içe aktarmaz. Renk
   döndürmez; anlamsal ton döndürür (`DurumTonu.birlikte / uyari / ikincil / ciddi`), rengi ekran eşler.
2. Ekranlar hesap yapmaz: biçimleme, süzme, sıralama `mantik/`'tedir.
3. Sahte veriye **tek** erişim noktası `EtkinlikDeposu`'dur. Gerçek sunucuya geçiş ileride yalnız
   `veri/` katmanını değiştirir.
4. Renk sabiti (`Color(0x…)`) yalnız `lib/tema/` altında yazılır. `test/mimari_test.dart` bunu denetler.
5. Bir dosya bir iş yapar. Büyüyen dosya bölünür.

### Bağımlılıklar
Yalnız Flutter SDK'nın kendi paketleri: `flutter`, `flutter_localizations` (yerleşik Material
metinleri, ör. yapıştır/kopyala menüsü, Türkçe çıksın diye), geliştirmede `flutter_test`,
`integration_test`, `flutter_lints`. pub.dev'den ek paket yok (grafik `CustomPaint` ile çizilir).

---

## 5. Veri modeli ve sahte veri

```dart
enum Rol { yatirimci, girisimci, misafir }            // sunucudaki investor / founder / guest
enum KisiRengi { mavi, turuncu, hardal, pembe, mor, mercan, petrol, gri }
enum Onem { ciddi, uyari, olumlu }

class Kisi {
  final String id;            // kart numarası ("24")
  final String? ad;           // null = kayıtsız kart ("Kart 14")
  final String? kurum;
  final Rol rol;
  final KisiRengi renk;
  final String? ile;          // şu an birlikte olduğu kişinin id'si
  final int sn;               // başlangıç süresi (saniye)
  final int pil;              // %
  final int yildiz;           // 0–5, yatırımcı değilse 0
  final bool gorunmuyor;
  final bool hic;             // hiç görüşmemiş
}
class Bildirim { final String baslik, detay, saat; final Onem onem; final List<String> kisiler; }
class Cift     { final String a, b; final int rssi; }
class AcikKart { final String no; final bool atanmis; }
```

`sahte_veri.dart` prototipin `<script>` bloğundaki değerleri **birebir** taşır:
- `kisiler`: 26 kayıt (12 girişimci, 10 yatırımcı, 4 misafir; biri adsız: Kart 14), aynı sırayla.
- `bildirimler`: 4 kayıt (2 uyarı, 1 olumlu, 1 ciddi).
- `ciftler`: 10 çift (`27–28 −51` … `35–71 −78`). Grafik ilk 6'sını çizer.
- `seriRenkleri`: pembe, mavi, petrol, mor, turuncu, mercan.
- `acikKartlar`: 88, 89, 90, 96, 97 (boşta) · 61, 46, 24, 5 (atanmış).
- Etkinlik sabitleri: ad `Yatırımcı Buluşması`, tarih-mekân `28.09.2026 · Demo Salonu`, rapor
  hazırlanma tarihi `02.10.2026`, çizelge başlangıcı `15:10`, duyulan kart sayısı `32`,
  kayıtlı katılımcı `25`, başlangıç saati 15:10:09, başlangıç eşiği −72.

Doğrulama sayıları (testlerde kullanılır): Tümü 26 · Yatırımcı 10 · Girişimci 12 · Birlikte 20 ·
Boşta 5 · Görünmüyor 1 · Hiç görüşmemiş 5 · adı olan 25.

---

## 6. Durum yönetimi

Paket yok; `ChangeNotifier` + `ListenableBuilder`. Nesneler kurucu parametresiyle aktarılır.

### `EtkinlikDeposu` (`veri/etkinlik_deposu.dart`)
| Alan / işlev | Anlamı |
|---|---|
| `kisiler`, `bildirimler`, `ciftler`, `acikKartlar` | sahte veri (değişmez) |
| `tick` | Sıfırla'dan bu yana geçen saniye |
| `saatSn` | günün saniyesi; `saat` → `15:10:09`, `saatKisa` → `15:10` |
| `esik` | −95…−35 arası tam sayı |
| `aliciBagli` | `bool.fromEnvironment('ALICI_BAGLI', defaultValue: true)` ile kurulur |
| `baslat()` / `dispose()` | 1 sn'lik `Timer.periodic` |
| `ilerlet()` | bir saniye: `tick++`, `saatSn++` (zamanlayıcı bunu çağırır; testler doğrudan çağırır) |
| `sifirla()` | `tick = 0` |
| `esikAyarla(int)`, `esikArtir()`, `esikAzalt()` | sınırlanmış eşik |
| `bul(String id)` | kişiyi getirir |

### `PanoDurumu` (`ekranlar/pano/pano_durumu.dart`)
`bolum` (kisiler / ag / bildirimler, başlangıç: kisiler) · `filtre` (başlangıç: **Girişimci**) ·
`arama` · `onem` (başlangıç: tümü).

### `KartVerDurumu` (`ekranlar/kart_ver/kart_ver_durumu.dart`)
Alanlar: `mod` (ver / iade) · `adim` (1–3) · `seciliKisi` · `seciliKart` · `kartModu`
(yaklastir / numara) · `numara` · `bulundu` · `sonAtama` (ad, kart) · `bilgi` · `arama` · `iadeSecili`.

| İşlev | Etki |
|---|---|
| `kisiSec(id)` | `seciliKisi = id`, `adim = 2`, `bulundu = null`, `numara = ''` |
| `demoYaklastir()` | 1,4 sn sonra `bulundu = '88'`; önceki bekleyen iptal edilir |
| `bulunanSec()` | `seciliKart = bulundu`, `adim = 3` |
| `numaraDegis(metin)` | yalnız rakamlar tutulur |
| `numaraSec()` | geçerliyse `seciliKart = temiz numara`, `adim = 3` |
| `acikKartSec(no)` | `seciliKart = no`, `adim = 3` |
| `kisiAdiminaDon()` | `adim = 1`, `bulundu = null` |
| `kartAdiminaDon()` | `adim = 2`, `bulundu = null` |
| `onayla()` | `sonAtama = (gorunenAd, kart)`, `bilgi = null`, `adim = 1`, seçimler/`numara`/`arama` temizlenir |
| `geriAl()` | `bilgi = '↶ Geri alındı: {gorunenAd} → Kart {kart} ataması kaldırıldı, kart boşta.'`, `sonAtama = null` |
| `modVer()` / `modIade()` | mod değişir; `modVer` ayrıca `iadeSecili = null` |
| `iadeSec(id)` / `iadeVazgec()` | `iadeSecili` ayarlanır / temizlenir |
| `iadeOnayla()` | `iadeSecili = null`, `bilgi = '✓ Kart {id} iade alındı. {gorunenAd} panodan düştü; süreleri raporda kalır.'` |
| `kartDegistirBaslat(id)` | `mod = ver`, `seciliKisi = id`, `adim = 2`, `bulundu = null`, `numara = ''` |
| `iadeBaslat(id)` | `mod = iade`, `iadeSecili = id` |

Adım ya da kişi değişince ve `dispose`'ta bekleyen demo zamanlayıcısı iptal edilir (S16).
`arama` alanı Kart Ver adım 1 ile Kart İadesi arasında ortaktır (prototipteki `masaArama`).

### `Kabuk` (`ekranlar/kabuk.dart`)
Seçili sekmeyi tutar; depo ve iki ekran durumunu oluşturup ekranlara verir. Sekmeler `IndexedStack`
içindedir: sekme değişince ekran durumu ve kaydırma konumu korunur.
- `kisiDetayiAc(id)`: alt sayfayı açar. Sayfa `degistir` ya da `iade` sonucuyla kapanırsa Kabuk
  ilgili `KartVerDurumu` işlevini çağırır ve Kart Ver sekmesine geçer.
- Pano'daki eşik etiketi Kurulum sekmesine geçirir.

---

## 7. Saf mantık (`lib/mantik/`)

| İşlev | Kural |
|---|---|
| `trKucuk(s)` / `trBuyuk(s)` | Dart'ın büyük/küçük harf çevirisi yerelsizdir. `trKucuk`: önce `İ→i`, `I→ı`, sonra `toLowerCase`. `trBuyuk`: önce `i→İ`, `ı→I`, sonra `toUpperCase` |
| `sureYazisi(sn)` | `< 60` → `19 sn` · tam dakika → `2 dk` · aksi `1 dk 14 sn` · `≥ 3600` → `1 sa 16 dk` (dakika 0 ise `1 sa`) |
| `saatYazisi(sn)` / `kisaSaatYazisi(sn)` | `15:10:09` / `15:10`; gün içinde döner (mod 86400) |
| `dbmYazisi(v)` | `−72` (U+2212) |
| `yildizlar(n)` | `★` × n |
| `gorunenAd(k)` | `ad ?? 'Kart {id}'` |
| `baslik(k)` | `kurum ?? gorunenAd` |
| `altAd(k)` | kurum varsa `· {gorunenAd}`; yoksa yıldız varsa `· ★★★`; yoksa boş |
| `tamAd(k)` | kurum varsa `{kurum} · {gorunenAd}`; yoksa `gorunenAd` |
| `rolAdi(rol)` / `rolSatiri(k)` | `Yatırımcı` / `Yatırımcı · ★★★★` |
| `kartMetni(k)` | `Kart 61 · ★★★★` (yıldız yoksa `Kart 24`) |
| `gecenSn(k, tick)` | `ile` varsa `sn + tick`, yoksa `sn` |
| `durumTonu(k)` | görünmüyor → `uyari` · birlikte → `birlikte` · aksi `ikincil` |
| `durumCumlesi(k, tick, bul)` | `Görünmüyor · 3 dk önce duyuldu` / `{eşin gorunenAd'ı} ile · {süre}` / `Boşta` |
| `sureMetni(k, tick)` | `ile` ya da `sn > 0` ise süre, yoksa `—` |
| `sonDuyulma(k)` | görünmüyor → `3 dk önce`, aksi `az önce` |
| `cizelgeOrani(k, tick)` | birlikteyse `min(1, (20 + gecenSn / 3) / 100)`, değilse `0` |
| `filtreleKisiler(kisiler, filtre, arama)` | filtre: Tümü / Yatırımcı / Girişimci / Birlikte (`ile` var) / Boşta (`ile` yok ve görünür) / Görünmüyor / Hiç görüşmemiş (`hic`). Arama: `'{kurum} {gorunenAd} {id}'` içinde, `trKucuk` ile |
| `listeBasligi(filtre)` | Tümü → `Kişiler` · Yatırımcı → `Yatırımcılar` · Girişimci → `Girişimciler` · diğerleri filtre adı |
| `bildirimleriSuz(liste, onem)` / `onemSayilari(liste)` | önem süzme; Tümü 4 · Ciddi 1 · Uyarı 2 · Olumlu 1 |
| `masaAra(kisiler, arama)` | adı olanlar; `'{kurum} {ad} {id}'` içinde arama |
| `numaraTemizle(s)` / `numaraGecerli(s)` | baştaki sıfırlar atılır; yalnız rakam ve 1–99 geçerli |
| `acikKartOner(kartlar, numara)` | boş girdi → hepsi; aksi numara ön ekiyle başlayanlar |
| `agYerlesimi(kisiler, genislik)` | sol: yatırımcılar + birlikte olan misafirler · sağ: girişimciler · satır aralığı 30, `y(i) = 16 + 30i`, yükseklik `max(sol, sağ) × 30 + 10` · kenar: girişimcinin eşi soldaysa `(22, y(j)) → (genislik − 22, y(i))` |
| `esikSinirla(v)` | −95…−35, tam sayı |
| `esikUstuCiftSayisi(ciftler, esik)` | `rssi > esik` olanlar (−72'de 8) |
| `grafikY(dbm, yukseklik)` | `(dbm + 40) / −50 × yukseklik`, `[0, yukseklik]` içine sınırlanır |
| `sozdeRastgele(i, j)` | `frac(sin(i × 374.1 + j × 91.7) × 43758.5453)` |
| `grafikSerileri(ciftler, tick, genislik, yukseklik)` | ilk 6 çift; her seride 31 nokta, `x = 28 + j × ((genislik − 28) / 30)`, `dBm = rssi + (sozdeRastgele(i, j + tick) − 0.5) × 8`, `y = grafikY(dBm, yukseklik)` |
| `kartSagligi(kisiler)` | pile göre artan **kararlı** sıralama, ilk 8; `pil < 20` → sorunlu (`⚠ pil düşük`), aksi `✓ iyi` |
| `raporKpileri(kisiler, tick)` | Görüşme = birlikte olan girişimci sayısı (not: `{n} tanesi sürüyor`) · Yatırımcı–girişimci toplam = girişimcilerin `gecenSn` toplamı (not: `bugün`) · Yatırımcıya ulaşan girişimci `{n}/{girişimci sayısı}` · Potansiyel anlaşma `0` (not: `işaretlenmedi`) · Katılımcı `25` (not: `kayıtlı`) |
| `raporSatirlari(kisiler, tick, bul)` | girişimciler, `gecenSn`'ye göre azalan **kararlı** sıra; toplam (birlikte değilse `—`); detay `{eş} ({süre})` ya da `⚠ Hiç yatırımcıyla görüşmedi` |

Dart'ın `List.sort`'u kararlı olmadığı için sıralamalarda özgün sıra ikinci anahtar olarak kullanılır.

---

## 8. Tema ve ortak bileşenler

### Renk token'ları (`tema/renkler.dart`)
| Ad | Değer | Ad | Değer |
|---|---|---|---|
| `zemin` | `#f7f2e9` | `vurgu` | `#9a6512` |
| `yuzey` | `#fffdf8` | `vurguZemin` | `#f5e8cf` |
| `acikYuzey` | `#efe7d8` | `vurguBasili` (700) | `#7f5410` |
| `metin` | `#3b332c` | `vurguKoyu` (800) | `#5c3d0a` |
| `metin2` (ikincil) | `#6b6156` | `birlikte` | `#1b7a4e` |
| `metinKoyu2` | `#4d453c` | `birlikteZemin` | `#e0f2e4` |
| `metinSoluk` | `#92897c` | `uyari` | `#b4470e` |
| `ayrac` | `#e2d8c4` | `ciddi` | `#b02a25` |
| `kenarlik` | `#cfc2a9` | `ciddiZemin` | `#f9e2e0` |
| `perde` (alt sayfa arkası) | `rgba(32,30,29,.35)` | `ciddiKoyu` | `#8a1f1b` |

Kişi paleti: mavi `#1245af` · turuncu `#854412` · hardal `#968403` · pembe `#920f6d` · mor `#895cd2` ·
mercan `#cc646f` · petrol `#248fb2` · gri `#302f2e`.

**Kural:** yeşil (`birlikte`, `birlikteZemin`) yalnız "şu an birlikte" için kullanılır.

### Ölçüler ve yazı
- Sayfa yatay kenarı 20 · köşe: kart/liste 12, alt sayfa 20, düğme/çip/girdi/etiket hap.
- Gölge (alt sayfa): `0 1px 3px rgba(59,51,44,.08), 0 4px 16px rgba(59,51,44,.12)`.
- Sistem fontu (iOS SF, Android Roboto). Gövde 15 px / 1.4. Başlıklar 600, harf aralığı −0.015em.
- Kicker: 11 px, harf aralığı .1em, `trBuyuk` ile büyük harf, renk `metin2`.
- Rakamlar (saat, süre, eşik, KPI, kart no sütunu): `FontFeature.tabularFigures()`.
- Sistem yazı ölçeği 1.0–1.3 arasına sınırlanır (sıkışık satırlar taşmasın).
- Material dalga efekti kapalıdır (`NoSplash`); basılı durum aşağıdaki gibi verilir.

### Bileşenler
| Bileşen | Tanım |
|---|---|
| `RolSekli` | yatırımcı daire · girişimci 1 px köşeli kare · misafir 45° döndürülmüş, %85 ölçekli kare. Kişi renginde. Erişilebilirlik etiketi rol adıdır |
| `HapDugme` | türler: birincil (zemin `vurgu`, yazı `zemin`; basılıyken `vurguBasili`) · ikincil (1 px `kenarlik`; basılıyken metin %14 kaplama) · hayalet (yazı `vurgu`, yatay iç boşluk 5; basılıyken vurgu %18 kaplama). Yazı 600 / 14 px, iç boşluk 10 × 18, en az yükseklik parametre |
| `Etiket` | 11 px, harf aralığı .02em, iç boşluk 3 × 10, hap. Türler: vurgu (`vurguZemin` / `vurguKoyu`), nötr (`acikYuzey` / `metinKoyu2`) |
| `Cip` | en az 36 px, hap, 13 px, 1 px kenarlık. Seçili dolgu rengi parametre (filtre: `vurgu`, önem: `metin`); seçili yazı `zemin` |
| `BolmeliAnahtar` | 1 px `ayrac` çerçeve, köşe 12; seçili parça zemin `vurgu`, yazı `zemin`. Yükseklik, yazı stili ve ara çizgi parametre |
| `AramaAlani` | en az 44 px, 15 px, zemin `yuzey`, 1 px `kenarlik`, hap, sol iç boşluk 16; ipucu metni metin renginin %65'i |
| `Kicker` | yukarıdaki kicker stili |
| `BasiliOpaklik` | satır düğmeleri: basılıyken opaklık .7 |
| `DokunmaHedefi` | görseli değiştirmeden dokunma alanını en az 44 px yapar (S17) |

---

## 9. Ekranlar

Ölçüler Ek A'da. Metinler prototiptekiyle aynıdır.

### 9.1 Kabuk
- `Scaffold` + `BottomNavigationBar` (sabit tip, 4 öğe, zemin `yuzey`, gölgesiz, ikon 24, etiket 11 px;
  seçili `vurguBasili`, seçilmemiş `metin2`). Gövde `SafeArea` içinde.
- Alıcı kopuksa en üstte bant: `⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… son veri gösteriliyor`
  (son iki sözcük grubu %75 opak). Pano etiketi `● Alıcı yok` olur. Veri gösterilmeye devam eder.

### 9.2 Pano
- **Üst alan:** `Yatırımcı Buluşması` + altında tarih-mekân; sağda canlı saat. Altında:
  `● Alıcı bağlı` (vurgu etiketi), `Eşik −72 dBm` (nötr etiket; dokununca Kurulum), `Sıfırla` (hayalet;
  onay diyaloğu: `Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?`).
- **Bölüm anahtarı:** `Kişiler 26` · `Ağ` · `Bildirimler 4`.
- **Kişiler:** arama (`Ara: ad, kurum, kart no`), yatay kaydırmalı 7 filtre çipi, kicker
  (`GİRİŞİMCİLER 12`), kişi satırları. Satır: rol şekli · `baslik` + ikincil renkte `altAd` · durum
  cümlesi (ton rengiyle) · sağda süre. Birlikte olan satırın zemini `birlikteZemin`. Dokunma → Kişi Detayı.
  Sıra sahte verideki sıradır; zamanla değişmez.
- **Ağ:** başlık satırı (`Yatırımcı ○` / `Girişimci □`), solda daireli adlar, sağda kareli kurum
  adları, birlikte olan çiftler arasında yeşil kesik çizgi (`CustomPaint`, etiketlerin arkasında).
  Altında italik not. Ada dokunma → Kişi Detayı.
- **Bildirimler:** 4 önem çipi (sayılarıyla), satırlar (renkli nokta, başlık, saat, detay). Dokunma →
  bildirimin ilk kişisinin detayı. Boşsa italik `Bu önemde bildirim yok.`

### 9.3 Kişi Detayı
`showModalBottomSheet`: üst köşe 20, en çok ekranın %78'i, kaydırılabilir, tutamaç 36 × 4, arka perde
`perde`, zemin `zemin`. Perdeye dokunma, aşağı çekme ve `✕` kapatır. İçerik saniyede bir güncellenir.
Sayfa açıkken sekmelere dokunulamaz; kısayollar sayfayı kapatıp sekmeyi değiştirir.
- Başlık: rol şekli + `tamAd` + altında `rolSatiri`.
- Alanlar (2 sütun): Kart no · Durum (ton rengiyle) · Son duyulma · Bugünkü toplam · Pil.
- `Kartı değiştir` (birincil) → Kart Ver, adım 2, kişi seçili. `Kartı iade al` (ikincil) → Kart İadesi,
  kişi seçili.
- `BUGÜN KİMİNLE`: eş satırı (şekil, ad, süre) ya da italik `Henüz kimseyle görüşmedi.`
- `GÖRÜŞME ZAMAN ÇİZELGESİ`: `15:10` … `şimdi · {saatKisa}`; 8 px ray, yeşil dolgu `cizelgeOrani`.

### 9.4 Kart Ver / Kart İadesi
- Başlık moda göre: `Kart Ver` + `Karşılama masası — gelen kişiye kart verin` / `Kart İadesi` +
  `Ayrılan kişiden kartı geri alın`. Mod anahtarı: `Kart ver | Kart iadesi`.
- Son atama bandı (`✓ {ad} → Kart {kart} verildi.` + `↶ Geri al`) ve bilgi bandı başlığın altında, iki
  modda da görünür.
- **Adım göstergesi:** 3 hap; etkin = vurgu dolgu, biten = metin renginde numara rozeti, bekleyen = gri rozet.
- **Adım 1 Kişi:** arama (`Kayıtlı kişilerde ara: ad veya kurum`), `Tümü (25) · Kart bekliyor (0)`,
  kişi kartları (şekil, `tamAd`, `kartMetni`, `Düzenle`). Dokunma → adım 2.
- **Adım 2 Kart:** `Kişi: {tamAd}`; anahtar `Yaklaştır ve tanı (önerilen) | Numarayı yaz`.
  - Yaklaştır: nabız animasyonu, `Kartı alıcıya yaklaştırın…`, `Demo: boş bir kartı yaklaştır`.
    1,4 sn sonra `Kart 88 bulundu ✓`, `Açık · az önce duyuldu · boşta`, `Bu kartı seç`.
  - Numara: etiket, rakam girdisi (`Örn. 14`), `ŞU AN AÇIK KARTLAR 9`, 3 sütunlu kart ızgarası (girilen
    numaraya göre süzülür; karta dokunma → adım 3). Numara geçerliyse altta `Bu kartı seç`.
  - Altta `← Kişi`.
- **Adım 3 Kontrol:** `Kontrol`; Durum `Açık` · Son duyulma `az önce` · Pil `%94`; özet kutusu
  `{tamAd} → Kart {no}`; `← Kart` + `Onayla`. Onay → son atama bandı, adım 1, alanlar temiz.
- **Kart İadesi:** arama (`Kart no, ad veya kurum`), kişi satırları (şekil, `tamAd`, `Kart {id}`).
  Dokununca listenin üstünde onay kutusu: `Kart {id} iade alınsın mı?`,
  `{tamAd} panodan düşer; bugünkü süreleri raporda kalır.`, `Vazgeç` + `İade al`.
- **Nabız:** 56 px alan, 2 px vurgu halka `scale .8 → 1.8`, `opacity .7 → 0`, 1,6 sn, ease-out, sonsuz;
  ortada 24 px dolu daire.

### 9.5 Kurulum
- Başlık + açıklama.
- **EŞİK:** 56 px değer + `dBm`; sağda `Şu an N çift eşiğin üstünde.`; `−1` / kaydırıcı (−95…−35, tam
  sayı adımlı, vurgu renkli) / `+1`; altında `−95 · gevşek` — `sıkı · −35`.
- **CANLI SİNYAL (son 90 sn):** sağda `En güçlü 6 çift`. Grafik yüksekliği 150, genişliği içerik
  genişliği; sol 28 px eksen etiketleri (−40 / −65 / −90). Eşik üstü bölge `vurguZemin` dolgu +
  `eşik üstü — yakın` etiketi; 6 çizgi (1,5 px); eşik kesik çizgisi (5–4). Altında
  `90 sn önce · kesik çizgi: eşik −72 dBm · şimdi` ve renk lejantı (`27 · 28` …).
- **KALİBRASYON:** açıklama + tam genişlik `— çift seçin —  ⌄` düğmesi (işlevsiz).
- **KART SAĞLIĞI:** `32 kart duyuluyor · ⚠ 1 sorunlu`; 8 satır: kart no · kişi/kurum (adsızsa ikincil
  renk) · durum · pil. Sorunlu satırın zemini `ciddiZemin`, durum ve pil yazısı `ciddi`.

### 9.6 Rapor
- Kicker `ETKİNLİK RAPORU`, başlık, `28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 {saatKisa}`.
- Düğmeler (sarmalı, işlevsiz): `Yazdır / PDF` (birincil) · `⤓ Katılımcılar` · `⤓ Görüşmeler` (ikincil) ·
  `Yenile` (hayalet).
- 5 KPI, 2 sütunlu yüzey kartları.
- `Girişimciler ve ulaştıkları yatırımcılar`: 12 satır (renk karesi, kurum, `· ad`, toplam; altında detay).

---

## 10. Kenar durumları

- **Yazı simgeleri** (`● ⚠ ★ ✓ ↶ ✕ ← → ⤓ ⌄`): metin olarak yazılır. Ekran görüntüsü doğrulamasında
  renkli emoji gibi çıkan ya da eksik (kutu) görünen simge, aynı boyut ve renkte Material ikonla değiştirilir.
- **Uzun adlar:** satırlarda başlık gerektiğinde alt satıra kırılır; kart sağlığında tek satır + üç nokta.
- **Klavye:** girdi dışına dokununca kapanır. Kart numarası alanı rakam klavyesi açar ve rakam dışını almaz.
- **Dar/geniş ekran:** 390–430 px arasında taşma yok (testle denetlenir). Grafik ve ağ, içerik genişliğine uyar.
- **Uygulama arka plana geçince** zamanlayıcı durur; dönünce kaldığı yerden sürer (sahte saat, telafi yok).
- **Yön:** yalnız dikey. **Tema:** sistem koyu modda olsa da açık tema.
- **Android geri tuşu:** alt sayfayı/diyaloğu kapatır.

---

## 11. Test ve doğrulama

Sıra: önce başarısız test, sonra kod (TDD).

1. **Birim testleri (`test/mantik/`, `test/veri/`)** — §7'deki her işlev; özellikle:
   Türkçe harf çevirisi (`İREM → irem`, `IŞIK → ışık`, `girişimciler → GİRİŞİMCİLER`), süre biçimi
   sınırları (0, 59, 60, 74, 3600, 4560), her filtrenin §5'teki sayısı, arama (ad, kurum, kart no),
   ağ (12 sol, 12 sağ, 10 kenar), kart no (boş, `007`, `0`, `100`, harf), eşik (sınırlar, −72'de 8 çift,
   `grafikY(−72, 150) = 96`), seriler (6 × 31 nokta, tick ile kayar), kart sağlığı (ilk satır Kart 46,
   sıra 46, 5, 14, 37, 58, 45, 4, 47), rapor (tick 0'da 10/12 ve `8 dk 42 sn`), depo (ilerlet, sıfırla, eşik).
2. **Widget testleri (`test/bilesenler/`, `test/ekranlar/`)** — sekme gezinme; filtre ve arama; kişi
   detayı açma/kapama ve iki kısayol; sihirbazın tamamı (kişi → demo yaklaştır 1,4 sn → seç → onayla →
   bant → geri al); numara yolu; açık karttan seçim; iade akışı; eşik `−1` / `+1` / kaydırıcı; sıfırla
   diyaloğu (vazgeç ve onay); bildirim önem süzme ve boş durumu; kopuk bandı; 390 / 402 / 430 px
   genişlikte ve 1.3 yazı ölçeğinde taşma olmaması.
3. **Mimari testi** — `lib/tema/` dışında `Color(0x` geçmez; `lib/mantik/` Flutter içe aktarmaz.
4. **`flutter analyze`** uyarısız.
5. **Görsel doğrulama** — iPhone 17 Pro simülatöründe (402 × 874, prototip çerçevesiyle aynı)
   `integration_test` ile her ekran ve durumun ekran görüntüsü alınır; prototipin tarayıcıdaki aynı
   durumuyla yan yana karşılaştırılır, farklar düzeltilir. Android'de (Pixel_8 emülatörü) açılış ve
   sekme gezinme duman testi; araç zinciri çalışmazsa bu açıkça raporlanır.
6. **Teslim** — `docs/teslim/` altında ekran görüntüleri + kısa "neyi neden böyle yaptım" notu;
   kökte çalıştırma talimatlı `README.md`.

---

## 12. Proje kurulumu ve çalışma şekli

- `flutter create --org com.saasbridge --project-name yakinlik_mobil --platforms=ios,android .`
  (Flutter 3.44.6 / Dart 3.12.2). Görünen ad `Yakınlık Panosu`.
- Çalıştırma: `flutter run` · kopuk durumu: `flutter run --dart-define=ALICI_BAGLI=false` ·
  testler: `flutter test` · çözümleme: `flutter analyze`.
- Her adım kendi commit'i (Türkçe ileti). Push ve uzak depo yok.
- Tasarım kaynağı depoda: `docs/tasarim/`. Şartname: bu dosya. Uygulama planı: `docs/superpowers/plans/`.

---

## 13. Sonraki işler (bu şartnamenin dışında)

Gerçek sunucuya bağlanma (`/state`, `/events`, `/control`, `/api/*`; sunucu adresi ayarı dahil) ·
işlevsiz düğmelerin ekranları (kişi düzenleme, kalibrasyon, PDF/CSV) · koyu tema · 1b varyantı ·
uygulama ikonu.

---

## Ek A. Ölçüler (prototipten; S1–S17 uygulanmış hâli)

Tüm değerler mantıksal piksel. `600 22/1.15` = ağırlık 600, 22 px, satır yüksekliği 1.15.

**Kabuk** — kopuk bandı: dış boşluk `4 20 0`, iç `8 12`, 13 px, köşe 12. Gövde alt boşluğu 24.
Alt çubuk: ikon 24, etiket 11 px.

**Pano üst** — iç boşluk `10 20 0`. Başlık `600 22/1.15`; tarih 13 px `metin2`, üst 4. Saat
`600 24/1`, üst 2. Etiket satırı: üst 12, aralık 8, etiket görsel yüksekliği 28; Sıfırla 13 px, yatay 6.
Bölüm anahtarı: üst 14, yükseklik 40, yazı 14 px (400), sayı 12 px %75 opak, aralık 6, ara çizgi yok.

**Kişiler** — arama: iç boşluk `14 20 0`. Çipler: `12 20 0`, aralık 8, çip yatay 14. Kicker: `20 20 0`,
sayı `metin` renginde, aralık 8. Liste: `10 20 0`, aralık 8. Satır: iç `12 14`, köşe 12, en az 60,
aralık 12; şekil 12; başlık `600 16/1.2`; durum 13 px, üst 3; süre 15 px `metinKoyu2`.

**Ağ** — iç `16 20 0`. Başlık satırı kicker stili. Çizim alanı: üst 10. Satır 30 px, şekil 14, ad 13 px,
aralık 8. Çizgi: `birlikte`, 1,2 px, kesik 4–4. Not: üst 16, 13 px italik `metin2`.

**Bildirimler** — iç `16 20 0`, dikey aralık 14. Çip yatay 12, sayı %70 opak. Satır: en az 44, iç `4 0`,
aralık 12; nokta 8 (üst 7); başlık 600 15 px; saat 13 px `metin2`; detay 14 px `metinKoyu2`, üst 2.
Nokta rengi: ciddi `ciddi`, uyarı `uyari`, olumlu `vurguBasili`.

**Kişi Detayı** — iç `14 20 (10 + alt güvenli alan)`, dikey aralık 18. Tutamaç 36 × 4, köşe 2,
`kenarlik`. Başlık satırı: aralık 12; şekil 14 (üst 6); ad `600 22/1.15`; rol 14 px `metin2`, üst 2;
kapat 40 × 40 ikincil. Alanlar: 2 sütun, aralık `14 × 12`; etiket 12 px `metin2`; değer 600 (kart no
`600 20`), üst 2. Düğmeler: aralık 10, eşit genişlik, 48. Eş satırı: iç `10 0`, alt ayraç, şekil 10,
ad 600. Çizelge: etiketler 12 px `metin2`, üst 8; ray 8 px, `acikYuzey`, köşe 2, üst 4.

**Kart Ver üst** — iç `10 20 0`. Başlık `600 26/1.1`; açıklama 14 px `metin2`, üst 4. Mod anahtarı:
üst 14, 44, yazı `600 15`, ara çizgi var. Son atama bandı: üst 14, iç `10 12`, `vurguZemin` /
`vurguKoyu`, 14 px, köşe 12, aralık 10; Geri al ikincil 36, zemin `zemin`. Bilgi bandı: üst 14,
iç `10 12`, `yuzey`, 14 px, köşe 12.

**Adım göstergesi** — iç `16 20 0`, aralık 8; hap 40, yatay 10, 14 px, aralık 8; rozet 22, `600 12`.
Etkin: zemin `vurgu`, yazı `zemin`, rozet `zemin` / `vurguBasili`. Biten: yazı `metin`, rozet `metin` /
`zemin`. Bekleyen: yazı `metin2`, rozet `ayrac` / `metin`.

**Adım 1** — iç `16 20 0`, aralık 12. Sayaç satırı 14 px `metin2`, aralık 16 (`Tümü` 600 `metin`).
Kart: iç `10 14`, `yuzey`, köşe 12, aralık 12; şekil 12; ad `600 16/1.2`; alt 13 px `metin2`, üst 2;
Düzenle hayalet 36.

**Adım 2** — iç `16 20 0`, aralık 14. `Kişi:` 14 px `metin2`, ad 600 `metin`. Anahtar 44, 14 px,
`önerilen` 11 px %75 opak, ara çizgi var. Bekleme: iç `28 0 16`, aralık 18; nabız 56; metin 16 px; demo
düğmesi ikincil 40. Bulundu: iç `24 0 8`, aralık 14; `600 28/1`; alt 14 px `metin2`; düğme birincil 48,
yatay 28, 16 px. Numara: etiket 13 px `metin2`; girdi 52, `600 24`, harf aralığı .05em, üst 6;
kicker satırı; ızgara 3 sütun, aralık 8; hücre 52, `yuzey`, köşe 12, yatay 12, `600 16` + 12 px `metin2`.
Alt satır: üst 6, aralık 10; `← Kişi` ikincil 44; `Bu kartı seç` birincil 44.

**Adım 3** — iç `16 20 0`, aralık 16. Başlık `600 18`. Alanlar 3 sütun, aralık 12 (etiket 12 px `metin2`,
değer 600, üst 2). Kutu: iç `18 16`, `yuzey`, köşe 12, aralık 14; şekil 14; yazı `600 20/1.2`.
Düğmeler: aralık 10; `← Kart` ikincil 48; `Onayla` birincil, esnek, 48, 16 px.

**Kart İadesi** — iç `16 20 0`, aralık 12. Onay kutusu: iç 16, `yuzey`, köşe 12, aralık 12; soru
`600 18/1.2`; açıklama 14 px `metin2`; düğmeler aralık 10, 44, `İade al` esnek. Satır: en az 52, iç `12 0`,
alt ayraç, aralık 12; şekil 10; ad `600 16/1.2`; kart 14 px `metin2`.

**Kurulum** — iç `10 20 0`, bölüm aralığı 28. Başlık `600 26/1.1`; açıklama 14 px `metin2`, üst 4.
Eşik: değer `600 56/1`, harf aralığı −.02em; `dBm` 18 px; sağ metin 14 px `metin2` (sayı 600 `metin`);
satır üst 6, aralık 8, taban çizgisine hizalı. Denetimler: üst 14, aralık 12; `−1` / `+1` 48 × 48, 18 px.
Uç etiketleri 12 px `metin2`, üst 6. Grafik: üst 10, yükseklik 150, sol eksen 28; eksen ve bölge etiketi
11 px; eksen etiketleri taban çizgisi y = 14 / 76 / 140; bölge etiketi (32, 12). Alt yazı: 12 px `metin2`,
üst 4, sol 28. Lejant: üst 10, aralık `14 × 6`, 13 px, nokta 8. Kalibrasyon: metin 14 px, üst 8; düğme
üst 10, 48, `yuzey`. Sağlık: özet 14 px, üst 6; satırlar üst 8; sütunlar `40 · esnek · içerik · 48`,
aralık 10, iç `9 0`, alt ayraç, 14 px; durum 13 px; pil sağa yaslı.

**Rapor** — iç `10 20 0`, bölüm aralığı 24. Başlık üst 4, `600 26/1.1`; alt yazı 14 px `metin2`, üst 6.
Düğmeler: aralık 8, 44. KPI: 2 sütun, aralık 8; kart iç 14, `yuzey`, köşe 12, aralık 4; etiket 13 px
`metin2`; değer `600 28/1`; not 12 px `metin2`. Bölüm başlığı `600 18/1.2`; satırlar üst 8; satır
iç `10 0`, alt ayraç; kare 8 (köşe 1), aralık 8; kurum 600; toplam `metinKoyu2`; detay 14 px
(`metinKoyu2` ya da `ciddi`), üst 4.
