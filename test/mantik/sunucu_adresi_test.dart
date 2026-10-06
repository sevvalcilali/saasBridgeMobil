import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/sunucu_adresi.dart';

void main() {
  test('yalnız IP yazılırsa http:// ve 8002 eklenir; boşluklar ve sondaki / atılır', () {
    expect(sunucuAdresiDuzelt(' 192.168.1.10 '), 'http://192.168.1.10:8002');
    expect(sunucuAdresiDuzelt('192.168.1.10:8010/'), 'http://192.168.1.10:8010');
    expect(sunucuAdresiDuzelt('http://pano.local:8002/'), 'http://pano.local:8002');
    expect(sunucuAdresiDuzelt('https://ornek.com'), 'https://ornek.com:8002');
  });

  test('boş = sahte veri', () {
    expect(sunucuAdresiDuzelt(''), '');
    expect(sunucuAdresiDuzelt('   '), '');
  });
}
