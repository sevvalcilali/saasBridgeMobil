import 'kurulum.dart';

// Kalibrasyon sihirbazı (web `kalibrasyon.js`): yüz yüze ve sırt sırta ölçümlerinin ortası eşik olarak önerilir.
// Ölçüm = sunucunun `signals[].value`'su (son 10 sn ortancası): 10 sn tutulunca tam o pencere. Saf Dart.

const int kalibrasyonSn = 10;

/// İki ölçüm bundan yakınsa eşik ikisini güvenilir ayıramaz.
const double enAzFarkDb = 6;

enum KalibrasyonUyarisi { kucuk, ters }

class EsikOnerisi {
  const EsikOnerisi({required this.deger, required this.fark, required this.uyari});

  /// Önerilen eşik (dBm); `ters`te null.
  final int? deger;
  final double fark;
  final KalibrasyonUyarisi? uyari;
}

/// `ters`: sırt sırta ölçümü yüz yüzeden güçlü (ölçümler karışmış) — öneri yok.
EsikOnerisi? onerilenEsik(double? yuzyuze, double? sirtsirta) {
  if (yuzyuze == null || sirtsirta == null) return null;
  final fark = ((yuzyuze - sirtsirta) * 10).round() / 10;
  if (fark <= 0) return EsikOnerisi(deger: null, fark: fark, uyari: KalibrasyonUyarisi.ters);
  return EsikOnerisi(
    deger: esikSinirla((yuzyuze + sirtsirta) / 2),
    fark: fark,
    uyari: fark < enAzFarkDb ? KalibrasyonUyarisi.kucuk : null,
  );
}

/// Geri sayım: başlangıç ve şimdi (ms) → kalan tam saniye (0'da biter).
int kalanSaniye(int baslangicMs, int simdiMs, {int sure = kalibrasyonSn}) {
  final kalan = (sure - (simdiMs - baslangicMs) / 1000).ceil();
  return kalan < 0 ? 0 : kalan;
}
