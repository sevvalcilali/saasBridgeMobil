import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('testlerde gerçek yazı tipi (Roboto) yüklü', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Text('iiiiiiiiii', style: TextStyle(fontFamily: 'Roboto', fontSize: 10)),
        ),
      ),
    );
    // Kare yazı tipinde 10 harf × 10 px = 100 px olurdu.
    expect(tester.getSize(find.byType(Text)).width, lessThan(50));
  });
}
