# Handoff: Yakınlık Panosu — Mobil Uygulama (Flutter)

## Genel bakış
SaasBridge web uygulamasının (repo: `sevvalcilali/SaasBridge`, dal `faz-0-altyapi`; 07.10.2026'dan beri `sevvalcilali/saasBridgeBackend` → `arayuz/`) saha görevlileri için mobil sürümü. Dört ana ekran: **Pano** (Kişiler · Ağ · Bildirimler), **Kart Ver / İade**, **Kurulum**, **Rapor**; artı **Kişi Detayı**. Sunum modu ve CSV yükleme mobile alınmadı.

## Tasarım dosyaları hakkında
Bu paketteki `.dc.html` dosyaları **HTML ile yapılmış tasarım referanslarıdır** — görünüm ve davranışı gösteren prototiplerdir, doğrudan kopyalanacak üretim kodu değildir. Görev: bu tasarımları **Flutter** ile yeniden üretmek. Veri modeli ve iş kuralları web repodaki `src/` ile aynıdır; `src/api/*.js` içindeki sahte veri/ajan aynı sözleşmeyle Dart'a taşınabilir.

## Sadakat
**Yüksek sadakat (hifi).** Renk, tipografi, boşluk ve etkileşimler nihai kabul edilmelidir. İki görsel varyant vardır; biri seçilip uygulanır:
- **1a Liste** — web'e en yakın; yüzey kartları, bölmeli anahtar, ikonlu alt sekme çubuğu, alt sayfa (bottom sheet) detay, 3 adımlı sihirbaz.
- **1b Sade** — kutusuz, tipografik; tarih rayı, metin sekmeler, tam sayfa detay, tek sayfada numaralı akış.
Prototipte `varyant` ve `tema` (`web` = repodaki krem/altın tema, varsayılan; `broadsheet` = alternatif serif tema) tweak'leriyle geçiş yapılır.

Hedef cihaz: 390–430 px genişlik telefon (iOS + Android). Tüm dokunma hedefleri ≥ 44 px.

---

## Tasarım token'ları (tema = web, repodaki `src/theme/tokens.css` ile aynı)

Renkler
- Zemin `#f7f2e9` · Yüzey `#fffdf8` · Metin `#3b332c` · İkincil metin `#6b6156` · Üçüncül `#92897c`
- Ayraç `#e2d8c4` · Kenarlık `#cfc2a9` · Açık yüzey `#efe7d8`
- Vurgu (altın) `#9a6512` · Vurgu zemin `#f5e8cf` · Vurgu koyu metin `#7f5410` / `#5c3d0a`
- Birlikte (yeşil) `#1b7a4e` · Birlikte zemin `#e0f2e4`
- Uyarı `#b4470e` · Ciddi/hata `#b02a25` · Hata zemin `#f9e2e0`

Kişi paleti (kişiyi takip eder; şekil rolü gösterir)
- mavi `#1245af` · turuncu `#854412` · hardal `#968403` · pembe `#920f6d` · mor `#895cd2` · mercan `#cc646f` · petrol `#248fb2` · gri `#302f2e`
- Rol şekli: ○ yatırımcı (daire) · □ girişimci (kare, 1 px köşe) · ◇ misafir (45° döndürülmüş kare, %85 ölçek)
- **Kural:** yeşil yalnız "şu an birlikte" demektir; başka hiçbir yerde kullanılmaz.

Tipografi (sistem fontu: iOS SF / Android Roboto)
- Başlık H1 22–30 px / 600 · H2 18 px / 600 · Satır başlığı 16–18 px / 600
- Gövde 15 px / 400, satır yüksekliği 1.4 · İkincil 13–14 px · Kicker 11 px, harf aralığı .1em, büyük harf
- Büyük rakamlar (süre, eşik, KPI): 20–56 px / 600, `tabular-nums`

Boşluk ve köşe
- Yatay sayfa kenarı 20 px · Bölüm arası 24–28 px · Liste satırı min 60 px · Çip min 36 px · Buton min 44–48 px
- Köşe: kart/liste 12 px · alt sayfa 20 px · buton/çip/input 999 px (hap)
- Gölge (alt sayfa): `0 1px 3px rgba(59,51,44,.08), 0 4px 16px rgba(59,51,44,.12)`

Flutter eşlemesi
```dart
ThemeData(
  scaffoldBackgroundColor: Color(0xFFF7F2E9),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF9A6512), onPrimary: Color(0xFFFFFDF8),
    surface: Color(0xFFFFFDF8), onSurface: Color(0xFF3B332C),
    error: Color(0xFFB02A25), outline: Color(0xFFCFC2A9)),
  dividerColor: Color(0xFFE2D8C4),
  filledButtonTheme: ..., // StadiumBorder, minHeight 44
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Color(0xFFFFFDF8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: Color(0xFFCFC2A9)))),
)
```

---

## Ekranlar

### 0. Kabuk
- `Scaffold` + `BottomNavigationBar` (4 sekme: Pano, Kart Ver, Kurulum, Rapor). 1a: ikon + 11 px etiket, seçili = vurgu rengi, seçilmemiş = ikincil metin, yüzey zemin, üst boşluk 6 px, alt güvenli alan. 1b: ikon yok, 15 px metin, seçili 600 ağırlık + 6 px nokta, üstte 3 px + 1 px çift çizgi (gazete rayı).
- Üstte (alıcı kopuksa) 13 px sarı bant: "⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… son veri gösteriliyor".

### 1. Pano
Üst alan
- 1a: Etkinlik adı H1 22 px, altında "28.09.2026 · Demo Salonu" 13 px ikincil; sağda canlı saat 24 px/600 `tabular-nums` (her saniye artar). Altında yatay çip sırası: `● Alıcı bağlı` (vurgu tag), `Eşik −72 dBm` (nötr tag, dokununca Kurulum'a gider), `Sıfırla` (ghost; onay diyaloğu açar).
- 1b: 3 px + 1 px çift çizgi rayı içinde 12 px büyük harf "28.09.2026 · Demo Salonu | 15:10:09"; H1 30 px; altında satır içi bağlantılar.
- Bölüm anahtarı: Kişiler (26) · Ağ · Bildirimler (4). 1a: `SegmentedButton` görünümü (kenarlık `#e2d8c4`, seçili = vurgu dolgu, 40 px). 1b: `TabBar` metin, seçili alt çizgi 3 px metin rengi.

Kişiler bölümü
- Arama alanı (hap, 44 px, yüzey zemin): "Ara: ad, kurum, kart no".
- Yatay kaydırmalı filtre çipleri (36 px, hap): Tümü · Yatırımcı · Girişimci · Birlikte · Boşta · Görünmüyor · Hiç görüşmemiş. Seçili: vurgu dolgu (1a) / metin rengi dolgu (1b), beyaz yazı.
- Kicker: "GİRİŞİMCİLER 12".
- Liste satırı (1a): 12 px köşeli yüzey kartı, 60 px, 8 px aralık. Sol: 12 px rol şekli kişi renginde. Orta: `Kurum · Ad` 16/600 (ad ikincil renkte), altında 13 px durum: `Elif Aydın ile · 19 sn` (yeşil) / `Boşta` (ikincil) / `Görünmüyor · 3 dk önce duyuldu` (uyarı). Sağ: süre 15 px `tabular-nums`. **Birlikte olan satırın zemini `#e0f2e4`.**
- Liste satırı (1b): kutusuz, 14 px dikey boşluk; kurum 18/600, ad italik 15 ikincil, durum 13; sağda süre 20/600.
- Dokunma → Kişi Detayı.

Ağ bölümü
- İki sütun: solda yatırımcı/misafir (daire, 14 px), sağda girişimci (kare, 14 px); satır 30 px, 13 px ad. Birlikte olan çiftler arasında yeşil kesik çizgi (`4 4`, 1.2 px). Altında italik not: "Düğümlerin konumu fiziksel konum değildir; yalnız rol gruplarını gösterir. Bir ada dokununca ayrıntı açılır." Dokunma → Kişi Detayı. Flutter: `CustomPaint` çizgiler + iki `Column`.

Bildirimler bölümü
- Önem çipleri: Tümü 4 · Ciddi 1 · Uyarı 2 · Olumlu 1.
- Satır: 8 px renkli nokta (ciddi `#b02a25`, uyarı `#b4470e`, olumlu vurgu `#7f5410`), başlık 600 + sağda saat 13 px, altında 14 px detay. Dokunma → ilgili kişinin detayı. Boşsa: "Bu önemde bildirim yok." italik.

### 2. Kişi Detayı
- 1a: `showModalBottomSheet`, üst köşe 20 px, max %78 yükseklik, tutamaç 36×4 px, arka plan `rgba(32,30,29,.35)`. 1b: tam sayfa `Navigator.push`, üstte "← Kişiler" bağlantısı, çift çizgi rayı içinde rol + kart no.
- Başlık: rol şekli + `Kurum · Ad` 22 px (1b: 30 px). Alt başlık: rol (+ yatırımcıda ★ yıldızları).
- Alanlar (2 sütun dl): Kart no 20/600 · Durum (yeşil/uyarı/ikincil) · Son duyulma · Bugünkü toplam `tabular-nums` · Pil %.
- Aksiyonlar: `Kartı değiştir` (primary, → Kart Ver adım 2, kişi seçili) · `Kartı iade al` (secondary, → Kart İadesi, kişi seçili). 48 px, yan yana eşit.
- "BUGÜN KİMİNLE": satır (şekil + ad + süre) ya da italik "Henüz kimseyle görüşmedi."
- "GÖRÜŞME ZAMAN ÇİZELGESİ": 15:10 → şimdi etiketi; 8 px (1b: 6 px) ray, yeşil dolu kısım = birlikte geçen süre.

### 3. Kart Ver / Kart İadesi
- H1 "Kart Ver" 26 px + "Karşılama masası — gelen kişiye kart verin". Mod anahtarı: `Kart ver | Kart iadesi` (1a segment 44 px, 1b alt çizgili metin).
- Son atama bandı (vurgu zemin `#f5e8cf`, 14 px): "✓ Ad → Kart 88 verildi." + `↶ Geri al` butonu. Geri alınca bilgi bandı (yüzey): "↶ Geri alındı: …".

Kart ver — 1a (3 adımlı sihirbaz)
- Adım göstergesi: 3 hap (40 px), aktif = vurgu dolgu, bitti = metin rengi numara rozeti, bekleyen = açık gri rozet.
- Adım 1 Kişi: arama "Kayıtlı kişilerde ara: ad veya kurum"; "Tümü (25) · Kart bekliyor (0)"; liste satırı: şekil + `Kurum · Ad` 16/600 + `Kart 24` 13 px + sağda `Düzenle` ghost. Dokunma → adım 2.
- Adım 2 Kart: "Kişi: **Ad**"; anahtar `Yaklaştır ve tanı (önerilen) | Numarayı yaz`.
  - Yaklaştır: nabız animasyonu (56 px daire, 2 px vurgu halka, 1.6 s `scale .8→1.8, opacity .7→0`), "Kartı alıcıya yaklaştırın…", demo butonu. Kart bulununca: "Kart 88 bulundu ✓" 28/600, "Açık · az önce duyuldu · boşta", `Bu kartı seç` primary 48 px.
  - Numara: etiket "Kart numarası (kartın üstündeki etiket)", numerik input 52 px, 24/600; "ŞU AN AÇIK KARTLAR 9"; 3 sütunlu kart ızgarası (52 px, `Kart 88` 16/600 + `boşta/atanmış` 12 px). Geçerli numara (1–99) girilince `Bu kartı seç` görünür.
  - Alt: `← Kişi` secondary.
- Adım 3 Kontrol: "Kontrol" H2; 3 sütun dl: Durum Açık · Son duyulma az önce · Pil %94; yüzey kutuda şekil + `Ad → Kart 88` 20/600; `← Kart` secondary + `Onayla` primary (esnek, 48 px).
- Onay → son atama bandı, adım 1'e dön, alanlar temizlenir.

Kart ver — 1b (tek sayfa numaralı akış)
- Üç bölüm, solda 32 px/600 adım numarası (aktif/bitti = metin rengi, bekleyen `#cfc2a9`). Biten adım özet satır + "değiştir" bağlantısı. Kart adımında nabız 44 px + metin, altında demo butonu ve "ya da numarayı yazın" + numerik input 48 px + `Seç`. Onay adımında `Ad → Kart 88` 22/600 + tam genişlik `Onayla ve sıradakine geç` 52 px.

Kart iadesi (ortak)
- Arama "Kart no, ad veya kurum"; liste satırı (52 px, alt çizgi ayraç): şekil + ad 16/600 + sağda `Kart 24`. Dokununca yüzey kutuda onay: "Kart 24 iade alınsın mı?" 18/600, açıklama 14 px, `Vazgeç` + `İade al` (primary, esnek).

### 4. Kurulum
- H1 "Kurulum" + açıklama 14 px.
- EŞİK: rakam 56/600 `tabular-nums` + "dBm" 18 px; sağda "Şu an **N** çift eşiğin üstünde." `−1` / `+1` butonları 48×48 + `Slider` (−95…−35, vurgu rengi); altında "−95 · gevşek | sıkı · −35".
- CANLI SİNYAL (son 90 sn): 362×150 grafik. Eşik üstü bölge `#f5e8cf` dolgu + "eşik üstü — yakın" etiketi; Y ekseni −40/−65/−90; 6 çizgi (kişi paleti, 1.5 px) her saniye güncellenir; eşik kesik çizgisi (`5 4`). Altında "90 sn önce | kesik çizgi: eşik −72 dBm | şimdi" ve renk lejantı `27 · 28`. Flutter: `CustomPaint` ya da `fl_chart`.
- KALİBRASYON: metin + tam genişlik açılır buton "— çift seçin —".
- KART SAĞLIĞI: "**32** kart duyuluyor · ⚠ 1 sorunlu"; satırlar `40px 1fr auto 48px` grid: kart no 600 · kişi/kurum (boşsa ikincil) · durum (`✓ iyi` ikincil / `⚠ pil düşük` hata) · pil %. Pil < %20 satır zemini `#f9e2e0`.

### 5. Rapor
- Kicker "ETKİNLİK RAPORU", H1 etkinlik adı, "28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:10".
- Butonlar (sarmalı): `Yazdır / PDF` primary · `⤓ Katılımcılar` · `⤓ Görüşmeler` · `Yenile` ghost; 44 px.
- KPI: 1a 2 sütun yüzey kartları (etiket 13, değer 28/600, not 12); 1b üstte 3 px çizgi, satır başına etiket+italik not solda, değer 34/600 sağda. Beş KPI: Görüşme · Yatırımcı–girişimci toplam · Yatırımcıya ulaşan girişimci (N/12) · Potansiyel anlaşma · Katılımcı.
- "Girişimciler ve ulaştıkları yatırımcılar": satır = 8 px renk karesi + `Kurum · Ad` 600 + sağda toplam süre; altında 14 px detay `Elif Aydın (19 sn)` ya da hata renginde `⚠ Hiç yatırımcıyla görüşmedi`. Süreye göre azalan sıra.

---

## Etkileşim ve davranış
- Canlı saat ve süreler saniyede bir artar (`Timer.periodic`).
- Sekme değişimi detayı kapatır. Pano bölüm anahtarı sekme içinde kalır.
- Filtre/arama anında uygular; arama Türkçe küçük harfe duyarsız (`toLowerCase('tr')`).
- Nabız animasyonu: 1.6 s, ease-out, sonsuz.
- Demo yaklaştırma: 1.4 s sonra "Kart 88 bulundu".
- Numara girişi yalnız rakam; baştaki sıfırlar atılır; 1–99 geçerli.
- Sıfırla: onay diyaloğu "Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?".
- Basılı durum: kart satırı opaklık .7; buton hap/vurgu koyu adım.
- Alıcı kopuk durumu: üst bant + "Alıcı yok" etiketi; son veri gösterilmeye devam eder.

## Durum (state)
`tab`, `pSekme`, `filtre`, `arama`, `secili` (kişi id), `onem`; Kart Ver: `mod`, `adim`, `sKisi`, `sKart`, `kartMod`, `numara`, `bulundu`, `sonAtama`, `bilgi`, `masaArama`, `iadeSecili`; Kurulum: `esik`; Saat: `tick`, `saat`. Veri: kişiler (id, ad, kurum, rol, renk, ile, sn, pil, yildiz, gorunmuyor, hic), bildirimler (baslik, detay, saat, onem, kisiler), çiftler (a, b, rssi). Web repodaki `src/api/` sözleşmesini izleyin.

## Varlıklar
İkonlar: alt sekme çubuğunda 4 basit çizgi ikon (24 px, 1.6 px çizgi) — Flutter'da `Icons.grid_view`, `Icons.badge_outlined`, `Icons.tune`, `Icons.bar_chart` yeterlidir. Görsel yok.

## Dosyalar
- `Yakinlik Mobil.dc.html` — tüm ekranlar, mantık, sahte veri (varyant A/B, tema web/broadsheet).
- `Mobil Ekranlar.dc.html` — iki varyantı yan yana gösteren sunum sayfası.
- `ios-frame.jsx`, `support.js` — yalnız önizleme çerçevesi/çalışma zamanı; uygulamayla ilgisi yok.
