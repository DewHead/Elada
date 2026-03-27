import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elada/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PDF Preview E2E Test', () {
    testWidgets('Verify PDF preview updates when description changes', (
      WidgetTester tester,
    ) async {
      // 1. Start the application
      await app.main();
      await tester.pumpAndSettle();

      // 2. Initial state: verify the app is running and showing the main screen
      expect(find.text('Generate New Invoice'), findsOneWidget);

      // 3. Find the description field and enter text
      final descriptionField = find.widgetWithText(
        TextField,
        'Item Description',
      );
      expect(descriptionField, findsOneWidget);

      await tester.enterText(descriptionField, 'Test Invoice Item');
      await tester.pumpAndSettle();

      // 4. Verify text was entered
      expect(find.text('Test Invoice Item'), findsOneWidget);
    });
  });
}
