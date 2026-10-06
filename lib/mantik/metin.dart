// Dart'ın büyük/küçük harf çevirisi yerelsizdir: 'I'.toLowerCase() → 'i',
// 'i'.toUpperCase() → 'I'. Türkçede I ↔ ı ve İ ↔ i eşleşir.

/// Türkçe küçük harf (arama karşılaştırması için).
String trKucuk(String s) => s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Türkçe büyük harf (kicker başlıkları için).
String trBuyuk(String s) => s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
