# Yakınlık Panosu — Mobil

SaasBridge "Yakınlık Panosu"nun saha görevlileri için telefon uygulaması (Flutter, iOS + Android).
Dört sekme: **Pano** (Kişiler · Ağ · Bildirimler), **Kart Ver / İade**, **Kurulum**, **Rapor**; artı **Kişi Detayı**.

Uygulama gerçek sunucuya (saasBridgeBackend, `/state` + `/events`) bağlanır: adres Kurulum → Sunucu'dan
girilir ve telefonda kalır; boş bırakılırsa gömülü sahte veriyle çalışır. Bu sürümde Onayla, Geri al ve
İade al henüz sunucuya gitmez; yalnız bant gösterir (M1'in ikinci yarısı).

## Çalıştırma

Gerekenler: Flutter 3.44.6 (Dart 3.12.2), iOS için Xcode, Android için Android SDK.

```bash
flutter pub get
flutter run                                    # açık simülatör/emülatörde
flutter run --dart-define=SUNUCU=http://192.168.1.10:8002   # açılışta bu sunucuya bağlan (Kurulum'dan da girilir)
flutter run --dart-define=ALICI_BAGLI=false    # sahte veride "alıcı kopuk" durumunu görmek için
flutter test                                   # birim + widget testleri
flutter analyze
```

Ekran görüntülerini yeniden almak için:

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/ekran_goruntuleri_test.dart -d "iPhone 17 Pro"
```

## Yapı

```
lib/
  tema/        renk token'ları, ölçüler, yazı stilleri, ThemeData
  veri/        modeller, EtkinlikDeposu (veriye tek erişim noktası) → SahteDepo | SunucuDeposu,
               sunucu istemcisi (dart:io, SSE), /state ayrıştırma, sunucu adresi ayarı
  mantik/      saf Dart: biçimleme, süzme, yerleşim, rapor hesapları
  bilesenler/  ortak parçalar: hap düğme, çip, bölmeli anahtar, rol şekli…
  ekranlar/    kabuk, pano/, kisi_detayi/, kart_ver/, kurulum/, rapor/
test/          mantik/ ve veri/ (birim), bilesenler/ ve ekranlar/ (widget), mimari_test
```

Kurallar (`test/mimari_test.dart` denetler):
- Renk sabiti yalnız `lib/tema/` altında yazılır.
- `lib/mantik/` Flutter içe aktarmaz.
- Sahte veriye yalnız `lib/veri/` erişir; ekranlar sahte mi sunucu mu bilmez.
- Yeşil yalnız "şu an birlikte" demektir.

## Belgeler

- Tasarım kaynağı: `docs/tasarim/` (README + HTML prototip)
- Şartname: `docs/superpowers/specs/2026-10-03-yakinlik-mobil-design.md`
- Uygulama planı: `docs/superpowers/plans/2026-10-03-yakinlik-mobil.md`
- Sunucuya bağlanma ve web ile eşitleme planı (06.10.2026): `docs/superpowers/plans/2026-10-06-web-esitleme-plani.md`
- Teslim notu ve ekran görüntüleri: `docs/teslim/`

## Bu sürümde olmayanlar

Web 3 Ekim'den sonra değişti; mobilde henüz yok: salon görünümü (figürler), uyarı kuralları ve açılır uyarı,
kişi profili ve kişiye özel rapor, "boşta · N dk", Pil kaldırılması. Sırası ve kapsamı eşitleme planında.

Sunucu bağlantısı · kişi düzenleme, kalibrasyon, PDF/CSV dışa aktarma (düğmeleri görünür ama işlevsiz) ·
koyu tema · 1b (Sade) varyantı · uygulama ikonu.
