# Plan: Mobil uygulamayı sunucuya bağlama ve web ile eşitleme (06.10.2026)

Durum: 1a (Liste) varyantı sahte veriyle yazıldı (209 test). Web (SaasBridge `faz-0-altyapi`) ve sunucu
(saasBridgeBackend `main`) 3 Ekim'den sonra çok değişti. Bu plan mobili önce gerçek sunucuya bağlar, sonra
web'deki yenilikleri taşır. Her aşama web'deki gibi: test → taslak ekran görüntüsü → Şevval onayı → PR.

Sözleşme: `SaasBridge/SUNUCUDAN_ISTENENLER.md` (sunucu uçları), `saasBridgeBackend/docs/` (davranış).

## M1 — Sunucu bağlantısı (sahte veri kalkar) — ✅ M1a okuma (PR #2), M1b yazma (PR #5)
- Sunucu adresi ayarı (ilk açılışta sorulur, Kurulum'da değiştirilir; `http://<ip>:8002`).
- `/state?grafik=0` anlık durum + `/events` SSE canlı akış; kopunca sarı bant, son veri kalır, yeniden bağlanır.
- Yazma uçları gerçek: `POST /api/assign`, `/api/unassign`, Geri al, Sıfırla (onaylı), eşik `PATCH`.
- `veri/` katmanı: `EtkinlikDeposu` arkasında `SunucuDeposu`; sahte veri yalnız testlerde ve `--dart-define=SAHTE=1` ile.
- Mock: web'deki `mock-server/mock.js` ile geliştirme; aynı sözleşme.
- Çıkış ölçütü: gerçek sunucuya bağlı telefonda Pano canlı akar, kart verilir ve iade alınır.

## M2 — Pano'yu web'e eşitleme — ✅ (PR #3, #4)
- "Ağ" bölümü → **salon görünümü**: küçük karikatür figürler, kümeler (arka + ön sıra), süre renkleri
  gri → sarı → turuncu → kırmızı, boştakiler kenarda soluk; telefona dikey sığacak biçimde (yatay kaydırma yok).
- Kişi satırında "boşta · N dk'dır", 1 dk giriş / 15 sn çıkış kuralı sunucudan (arayüz bekletmez).
- Açılır uyarı (kural tetiklenince) ve bildirimlerde "Kural" süzgeci.
- "Gün boyu" (ego) görünümü: seçili kişinin gün boyu görüştükleri.
- Kişi detayından **Pil %** kaldırılır (web kararı 05.10.2026).

## M3 — Kart Ver'i web'e eşitleme — ✅ (PR #7; inceleme düzeltmeleri PR #6)
- Kişi düzenleme ve ekleme: profil alanları (sektör, aşama, tanıtım, web, e-posta, paylaşım izni).
- **Uyarılar** sekmesi: kural listesi, ekle / düzenle / aç-kapat / sil (`/api/rules`), önizleme cümlesi.
- Kontrol adımından Pil kaldırılır; "Kart değiştir" akışı.

## M4 — Kurulum ve Rapor — ✅ (PR #8)
- Kalibrasyon sihirbazı (çift seçimi gerçek listeden).
- Rapor: KPI'lar ve girişimci satırları sunucu verisinden; kişiye özel rapor sayfası (yalnız o kişinin görüşmeleri).
- Dışa aktarma: telefonda "Paylaş" (CSV sistem paylaşım sayfasına; PDF yok, kişiye özel rapor metin olarak).

## M5 — Cila ve dağıtım
- Koyu tema (web token'larının koyu sürümü), uygulama ikonu, açılış ekranı.
- Gerçek cihaz denemesi: iPhone + Android telefon, salon Wi-Fi'ında sunucuya bağlı.
- TestFlight / Android APK dağıtımı için hazırlık.

## Sonraya kalanlar
- 1b (Sade) varyantı — karar: 1a ile gidiliyor.
- Rapor 3. adım (QR / e-posta ile dağıtım) web'de kararlaştırılınca mobile taşınır.
- B8 (gerçek alıcı) sunucu tarafında; mobil etkilenmez.
