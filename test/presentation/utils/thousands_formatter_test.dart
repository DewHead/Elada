import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elada/presentation/utils/thousands_formatter.dart';

void main() {
  testWidgets('ThousandsFormatter should add commas to large numbers', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            inputFormatters: [ThousandsFormatter()],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1000000');
    expect(controller.text, '1,000,000');

    await tester.enterText(find.byType(TextField), '1234567.89');
    expect(controller.text, '1,234,567.89');

    await tester.enterText(find.byType(TextField), '0.5');
    expect(controller.text, '0.5');

    await tester.enterText(find.byType(TextField), '.5');
    expect(controller.text, '.5');
  });

  testWidgets('ThousandsFormatter should handle leading zeros', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            inputFormatters: [ThousandsFormatter()],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '007');
    expect(controller.text, '7');
  });
}
