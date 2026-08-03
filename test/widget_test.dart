import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axyz/main.dart';

void main() {
  testWidgets('AXYZ App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AxyzApp(),
      ),
    );
    expect(find.text('AXYZ'), findsOneWidget);
  });
}
