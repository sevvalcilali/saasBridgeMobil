import 'dart:async';
import 'dart:convert';

/// Sunucunun `/events` akışını (text/event-stream) mesajlara böler: her boş satırla biten
/// blokun `data:` satırları birleştirilir. Yorum (`:`) ve `event:` satırları atlanır.
/// Satır sonu `\n`, `\r\n` ya da `\r` olabilir (Python sunucuları çoğu zaman `\r\n` yollar).
/// Parça sınırı mesajın ya da çok baytlı bir karakterin ortasına düşebilir; UTF-8 akış
/// çözücü bunu tamponlar. Saf Dart: Flutter'sız testte ve gerçek sokette aynı kod.
Stream<String> sseVerileri(Stream<List<int>> baytlar) async* {
  var tampon = '';
  await for (final parca in baytlar.transform(utf8.decoder)) {
    tampon += parca;
    // Parçanın sonundaki tek \r bekletilir: arkasından \n gelebilir.
    var islenebilir = tampon.endsWith('\r') ? tampon.substring(0, tampon.length - 1) : tampon;
    final kuyruk = tampon.length - islenebilir.length;
    islenebilir = islenebilir.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    var sinir = islenebilir.indexOf('\n\n');
    while (sinir >= 0) {
      final blok = islenebilir.substring(0, sinir);
      islenebilir = islenebilir.substring(sinir + 2);
      final veri = blok
          .split('\n')
          .where((s) => s.startsWith('data:'))
          .map((s) => s.substring(5).trimLeft())
          .join();
      if (veri.isNotEmpty) yield veri;
      sinir = islenebilir.indexOf('\n\n');
    }
    tampon = islenebilir + (kuyruk > 0 ? '\r' : '');
  }
}
