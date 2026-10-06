# Teslim Notu — Yakınlık Panosu Mobil (1a Liste)

## Ne yapıldı

Tasarım teslim paketindeki 1a (Liste) varyantı Flutter ile yazıldı: Kabuk (4 sekme), Pano (Kişiler · Ağ ·
Bildirimler), Kişi Detayı (alt sayfa), Kart Ver (3 adımlı sihirbaz) ve Kart İadesi, Kurulum, Rapor.
Uygulama prototipteki gömülü sahte veriyle çalışır; sunucuya bağlanmaz.

Ekran görüntüleri: `docs/teslim/ekran/ios/` ve `docs/teslim/ekran/android/` (01–16).

## Neyi neden böyle yaptım

- **Katmanlar web reposuyla aynı.** `tema / veri / mantik / bilesenler / ekranlar`. Hesap ekranda değil
  `mantik/`'te; her kuralın birim testi var. Gerçek sunucuya geçiş yalnız `veri/` katmanını değiştirir.
- **Paket eklenmedi.** Grafik ve ağ çizgileri `CustomPaint`, durum `ChangeNotifier`. Uygulama çevrimdışı
  çalışır ve bağımlılık riski taşımaz.
- **README ile prototip ayrıştığında README'ye uyuldu** (şartname §3, S1–S17). Öne çıkanlar: çipler ve adım
  göstergesi hap biçimli; "Görünmüyor" uyarı renginde; süreler web kuralıyla (`1 dk`, `1 sa 16 dk`);
  prototipe broadsheet temasından sızan renkler web token'larıyla değiştirildi.
- **Dokunma hedefleri 44 px.** Etiket (28), çip (36) gibi küçük görsellerin ölçüsü değişmedi; dokunma alanı
  görünmez biçimde genişletildi. İstisna: Pano bölüm anahtarı (README: 40 px) ve Ağ satırları (30 px aralık).
- **Türkçe harf çevirisi elle yapıldı.** Dart'ın büyük/küçük harf çevirisi yerelsiz olduğu için arama
  (`İREM` → `irem`) ve kicker başlıkları (`GİRİŞİMCİLER`) kendi fonksiyonlarımızla çevrilir.
- **Taşma testle güvenceye alındı.** Her ekran 360 / 390 / 402 / 430 px genişlikte ve en büyük yazı
  ölçeğinde taşmadan çiziliyor. Sistem yazı ölçeği 1.3 ile sınırlı.
- **Prototipteki küçük hatalar düzeltildi.** Adsız kart `Kart 14` diye yazılır (prototipte boş/`null`);
  demo yaklaştırma beklerken geri dönülürse eski kart sonradan belirmez; eşik çizgisi grafiğin dışına taşmaz.
- **Uyarı işareti ikon olarak çizilir.** `⚠` Android'de renkli emoji olarak çıkıyordu; her iki platformda da
  yazıyla aynı boyut ve renkte Material uyarı ikonu çizilir (`lib/bilesenler/uyari_metni.dart`).

## Bilinçli olarak yapılmayanlar

- Onayla / Geri al / İade al sahte veriyi değiştirmez; yalnız bant gösterir (karar: yalnız prototip eşdeğeri).
- `Düzenle`, `— çift seçin —`, `Yazdır / PDF`, `⤓ Katılımcılar`, `⤓ Görüşmeler`, `Yenile` işlevsizdir;
  arkalarındaki ekranlar tasarlanmadı.
- 1b varyantı, koyu tema, sunucu bağlantısı, kalıcılık, uygulama ikonu.

## Doğrulama

| Denetim | Sonuç |
|---|---|
| `flutter test` | 209 test, tamamı geçti (`All tests passed!`) |
| `flutter analyze` | `No issues found!` |
| iOS (iPhone 17 Pro simülatörü, iOS 26) ekran görüntüleri | 16 / 16 |
| Android (Pixel_8 emülatörü, Android 17 / API 37) ekran görüntüleri | 16 / 16 |

Prototip başsız Chromium'da aynı 402 × 874 çerçevede açıldı ve 15 durum yan yana karşılaştırıldı.
Renk, yazı boyutu, boşluk ve köşeler örtüşüyor.

Bulunan ve düzeltilen farklar:

- **Android — `⚠` renkli emoji:** Kart sağlığı, kopuk bandı ve rapordaki uyarılar sarı emoji olarak
  çıkıyordu. Material uyarı ikonuyla değiştirildi; testi: `test/ekranlar/uyari_simgesi_test.dart`.
- **Ekran görüntüsü zamanlaması (uygulama hatası değil):** İlk çekimde alt çubuk seçimi bir kare geç
  görünüyordu ve iade onayı aşağı kaymıştı. Görüntü testi birkaç kare ilerleyip sayfayı başa kaydırarak
  çekiyor.

Bağımsız kod incelemesinden sonra düzeltilenler (her biri önce düşen bir testle):

- **Gizli sekmede nabız animasyonu:** Kart Ver 2. adımda bırakılıp başka sekmeye geçilince nabız görünmeden
  saniyede 60 kare çizmeye devam ediyordu (pil). Gizli sekmelerin animasyonları artık durur.
- **Mod değişince bekleyen demo:** "Demo"ya basıp "Numarayı yaz"a ya da "Kart iadesi"ne geçince, geri
  dönüldüğünde yaklaştırılmamış "Kart 88 bulundu" görünebiliyordu. Bekleyen demo artık iptal edilir.
- **Arka planda saat:** Şartname §10'daki "arka plana geçince saat durur, dönünce kaldığı yerden sürer"
  kuralı eksikti; eklendi.

Bilinçli farklar (hata değil):

- Prototip kicker'ları `GIRIŞIMCILER` yazıyor (tarayıcı büyük harfe çevirirken Türkçe kuralı kullanmıyor);
  uygulama doğru Türkçe `GİRİŞİMCİLER` yazar.
- Prototipte uzun KPI değeri (`11 dk 22 sn`) iki satıra kırılıyor; uygulamada tek satırda küçülür.
- Prototipteki `-72` (tire) uygulamada `−72` (eksi işareti).
- Android'de `↶` ve `⤓` iOS'takinden biraz küçük çizilir; tek renkli oldukları için değiştirilmedi.

## Sonraki adımlar

1. Gerçek sunucuya bağlanma: `/state`, `/events` (SSE), `/control`, `/api/*`; sunucu adresi ayarı.
2. İşlevsiz düğmelerin ekranları: kişi düzenleme, kalibrasyon sihirbazı, PDF/CSV.
3. Koyu tema; uygulama ikonu.
