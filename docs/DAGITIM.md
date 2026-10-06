# Mobil uygulama — dağıtım ve etkinlik günü

Sunucu tarafı için `saasBridgeBackend/docs/DAGITIM.md`. Bu belge telefon uygulamasını (Flutter, iOS + Android)
kurmak ve etkinlik günü kullanmak içindir.

## 1. Etkinlikten önce

1. Sunucu bilgisayarı ve telefonlar **aynı Wi-Fi**'da olmalı. Sunucunun adresi: `http://<bilgisayarın-yerel-ip>:8002`
   (bilgisayarda `ipconfig getifaddr en0` / Windows `ipconfig`).
2. Uygulamayı telefona kurun (aşağıda). İlk açılışta **Kurulum → Sunucu**'ya bilgisayarın IP'sini yazıp **Bağlan**;
   "● Bağlı" görünmeli. Adres telefonda kalır.
3. iOS ilk bağlantıda "yerel ağdaki cihazları bulmak istiyor" diye sorar: **İzin ver**.
4. Kurulum → Görünüm: salonda koyu tema (Sistem / Açık / Koyu).
5. Prova: Pano'da kişiler ve Salon akıyor mu; Kart Ver'de bir kişiye kart verip Geri al; Kurulum'da kalibrasyon.

## 2. Telefona kurma

**iPhone (geliştirici hesabıyla, kabloyla):**
```bash
cd saasBridgeMobil
flutter devices                  # telefon listede olmalı (Xcode'da güvenilen cihaz)
flutter run --release -d <telefon-id>
```
Mağaza dışı dağıtım için TestFlight: `flutter build ipa` → Xcode → Organizer → App Store Connect'e yükle → TestFlight'tan
davet. Apple Developer hesabı ve `ios/Runner.xcodeproj`'de takım (Signing & Capabilities) gerekir.

**Android (APK, mağazasız):**
```bash
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```
APK'yı telefona gönderin (AirDrop/Drive), "bilinmeyen kaynaklardan kurulum"a izin verip açın. Emülatörde sunucu
adresi `10.0.2.2:8002`'dir (gerçek telefonda bilgisayarın IP'si).

Sürüm: `pubspec.yaml` → `version: 1.0.0+1` (mağaza için her yüklemede `+N` artar).

## 3. Etkinlik sırasında

- Üstte **sarı bant** "Sunucuya bağlanılamıyor": Wi-Fi'ı ve sunucuyu kontrol edin; uygulama kendiliğinden
  yeniden bağlanır, son veri ekranda kalır.
- "Alıcı yok": alıcının USB kablosu (sunucu tarafı).
- Telefon uyuyunca bağlantı kapanır, açılınca saniyeler içinde sürer. Masa telefonunda ekranı açık tutun.
- Uyarı kuralları Kart Ver → Uyarılar'dan; açılır uyarı Pano'nun üstünde çıkar, "Tamam" ile kapanır.
- Rapor: ⤴ Katılımcılar / Görüşmeler (CSV) paylaşım sayfasına; kişiye özel rapor satıra dokununca, ⤴ Paylaş.

## 4. Sorun giderme

| Belirti | Çözüm |
|---|---|
| "Bağlı değil, deneniyor…" | Adres yanlış ya da farklı ağ. Telefonun tarayıcısında `http://<ip>:8002` açılıyor mu? |
| iOS'ta hiç bağlanmıyor | Ayarlar → Yakınlık Panosu → Yerel Ağ izni açık mı? |
| Kart Ver'de kart "Şu an açık kartlar"da çıkmıyor | Numara yine yazılabilir; kartın açık olduğuna ve alıcının onu duyduğuna Kurulum → Kart sağlığı'ndan bakın. Başka kişide olan kart önce iade alınmalı |
| Grafik boş | Kurulum açıkken 2 sn içinde dolar; sunucu geçmişi yalnız bu sekmede istenir |
