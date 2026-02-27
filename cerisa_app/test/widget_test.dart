import 'package:flutter_test/flutter_test.dart';
import 'package:cerisa_app/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CerisaApp());
    expect(find.text('Cerisa'), findsOneWidget);
  });
}
