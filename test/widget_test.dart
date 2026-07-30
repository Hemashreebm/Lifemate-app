import 'package:flutter_test/flutter_test.dart';
import 'package:lifemate/app.dart';

void main() {
  testWidgets('Lifemate app launches without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const LifemateApp());

    // Verify the app title text appears
    expect(find.text('Lifemate'), findsWidgets);
  });
}
