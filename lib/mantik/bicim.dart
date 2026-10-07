// Birim ve metin çevirileri. Ekranlar hesap yapmaz, buradan okur.

/// Saniye → "19 sn" / "2 dk" / "1 dk 14 sn" / "1 sa 16 dk".
/// (Web: src/api/format.js sureYazisi ile aynı kural.)
String sureYazisi(int saniye) {
  final toplam = saniye < 0 ? 0 : saniye;
  if (toplam >= 3600) {
    var sa = toplam ~/ 3600;
    var dk = ((toplam % 3600) / 60).round();
    if (dk == 60) {
      sa += 1;
      dk = 0;
    }
    return dk == 0 ? '$sa sa' : '$sa sa $dk dk';
  }
  final dk = toplam ~/ 60;
  final sn = toplam % 60;
  if (dk == 0) return '$sn sn';
  return sn == 0 ? '$dk dk' : '$dk dk $sn sn';
}

/// Özet yerleri için dakikaya yuvarlanmış süre: 0 → "—", 1 dk altı "<1 dk", "24 dk", "1 sa 13 dk" (web dkKisa).
String dakikaYazisi(int saniye) => saniye <= 0 ? '—' : saniye < 60 ? '<1 dk' : sureYazisi((saniye / 60).round() * 60);

String _iki(int n) => n.toString().padLeft(2, '0');

/// Günün saniyesi → "15:10:09". Gün içinde döner.
String saatYazisi(int saniye) {
  final s = saniye % 86400;
  return '${_iki(s ~/ 3600)}:${_iki((s % 3600) ~/ 60)}:${_iki(s % 60)}';
}

/// Günün saniyesi → "15:10".
String kisaSaatYazisi(int saniye) {
  final s = saniye % 86400;
  return '${_iki(s ~/ 3600)}:${_iki((s % 3600) ~/ 60)}';
}

/// dBm değeri gerçek eksi işaretiyle (U+2212): −72.
String dbmYazisi(int v) => v < 0 ? '−${-v}' : '$v';

/// Yatırımcı yıldızları: "★★★".
String yildizlar(int n) => '★' * n;
