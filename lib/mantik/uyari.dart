import '../veri/modeller.dart';

// Açılır kural uyarısı (web `src/api/kurallar.js acilacakUyarilar` ile aynı): organizatörün kuralı tetiklenince
// Pano'nun üstünde pencere çıkar; "Tamam" ile kapanır, görülenler bir daha çıkmaz. Birden çok uyarı sıraya girer
// (en eski önce). Uygulama yeni açıldığında yalnız son 2 dakikanın uyarıları çıkar; eskiler sessizce
// görülmüş sayılır (sabah açılan panoda düne ait 40 pencere açılmasın).

/// İlk açılışta bu kadar saniyeden eski uyarılar açılmaz.
const int ilkAcilistaSn = 120;

/// Sunucu bildirimlerinde kimlik alanı yok: zaman + başlık + kişiler.
String uyariAnahtari(Bildirim b) => '${b.t}-${b.baslik}-${b.kisiler.join('.')}';

/// Açılacak kural uyarıları, en eski önce. `simdiT`: sunucu zamanı (sn).
List<Bildirim> acilacakUyarilar(List<Bildirim> bildirimler, Set<String> gorulen, double simdiT, {bool ilk = false}) {
  final liste = [
    for (final b in bildirimler)
      if (b.onem == Onem.kural && !gorulen.contains(uyariAnahtari(b)) && (!ilk || b.t >= simdiT - ilkAcilistaSn)) b,
  ]..sort((x, y) => x.t.compareTo(y.t));
  return liste;
}
