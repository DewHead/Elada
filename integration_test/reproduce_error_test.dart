import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elada/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Reproduce null check error', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    // Find text fields
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Description (Items)
    await tester.enterText(
      find.widgetWithText(TextField, 'Item Description'),
      'Car',
    );
    // Price (Items)
    await tester.enterText(
      find.widgetWithText(TextField, 'Total Amount'),
      '100000',
    );

    await tester.pumpAndSettle();

    // Click Generate PDF
    final generateButton = find.text('Generate');
    if (generateButton.evaluate().isEmpty) {
      // maybe it's "Generate PDF"
      await tester.tap(find.text('Generate PDF'));
    } else {
      await tester.tap(generateButton);
    }

    await tester.pumpAndSettle();

    // Wait a bit to see if snackbar appears
    await tester.pump(const Duration(seconds: 2));

    // Check if error snackbar is there
    final errorFinder = find.textContaining('Error generating PDF');
    if (errorFinder.evaluate().isNotEmpty) {
      print('FOUND ERROR SNACKBAR');
    }
  });
}
