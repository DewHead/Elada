import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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

      // Wait for initial preview generation to complete
      // (The initial call in constructor triggers it)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // 3. Find the description field
      final descriptionField = find.widgetWithText(
        TextField,
        'Item Description',
      );
      expect(descriptionField, findsOneWidget);

      // 4. Enter text and verify immediate loading spinner
      await tester.enterText(descriptionField, 'Test Invoice Item');
      await tester.pump(); // Immediate rebuild

      // Should show CircularProgressIndicator in the preview area
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 5. Wait for debounce period (500ms)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // 6. Verify PDF viewer is present (indicating preview loaded)
      // Note: SfPdfViewer might take a moment to mount
      expect(find.byType(SfPdfViewer), findsOneWidget);

      // 7. Change another field (Total) and verify loading again
      final totalField = find.widgetWithText(TextField, 'Total Amount');
      await tester.enterText(totalField, '150.50');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(find.byType(SfPdfViewer), findsOneWidget);
    });
  });
}
