import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Lifemate basic widget rendering test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Lifemate Smart Personal Companion'),
          ),
        ),
      ),
    );

    expect(find.text('Lifemate Smart Personal Companion'), findsOneWidget);
  });
}
