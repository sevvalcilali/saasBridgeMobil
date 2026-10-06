import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/sse.dart';

Stream<List<int>> parcalar(List<String> p) => Stream.fromIterable(p.map(utf8.encode));

void main() {
  test('her boş satırla biten blokun data: satırları birleştirilir', () async {
    final veriler = await sseVerileri(parcalar(['data: {"a":1}\n\n', 'data: {"b":\ndata: 2}\n\n'])).toList();
    expect(veriler, ['{"a":1}', '{"b":2}']);
  });

  test('parça sınırı mesajın ortasına düşebilir; \\r\\n ve \\r da satır sonudur', () async {
    final veriler = await sseVerileri(parcalar(['data: {"a"', ':1}\r\n\r\ndata: {"b":2}\r', '\r', 'data: {"c":3}\n\n'])).toList();
    expect(veriler, ['{"a":1}', '{"b":2}', '{"c":3}']);
  });

  test('yorum, event: ve data: olmayan bloklar atlanır; UTF-8 çok baytlı karakter parçalanabilir', () async {
    final bayt = utf8.encode('data: "Şevval"\n\n');
    final veriler = await sseVerileri(Stream.fromIterable([
      utf8.encode(': ping\n\nevent: x\n\n'),
      bayt.sublist(0, 8), bayt.sublist(8),
    ])).toList();
    expect(veriler, ['"Şevval"']);
  });
}
