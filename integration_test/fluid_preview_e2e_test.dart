import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:elada/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluid Preview E2E Test', () {
    testWidgets('Rapid typing maintains focus and updates preview fluently', (
      WidgetTester tester,
    ) async {
      // 1. Start the application
      await app.main();
      await tester.pumpAndSettle();

      // 2. Find the description field
      final descriptionField = find.widgetWithText(
        TextField,
        'Item Description',
      );
      expect(descriptionField, findsOneWidget);

      // 3. Focus the field
      await tester.tap(descriptionField);
      await tester.pumpAndSettle();

      // 4. Simulate rapid typing
      const String textToType = 'Fluid Real-time Preview is working!';
      for (int i = 0; i < textToType.length; i++) {
        await tester.enterText(descriptionField, textToType.substring(0, i + 1));
        await tester.pump(const Duration(milliseconds: 20)); // High frequency
      }

      // 5. Verify focus is still there
      final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus, isNotNull);
      
      // 6. Wait for preview to generate (50ms debounce + generation time)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // 7. Verify PDF viewer is present and visible
      expect(find.byType(SfPdfViewer), findsAtLeastNWidgets(1));
      
      // 8. Change another field rapidly
      final totalField = find.widgetWithText(TextField, 'Total Amount');
      await tester.tap(totalField);
      await tester.pumpAndSettle();
      
      await tester.enterText(totalField, '999');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.enterText(totalField, '999.99');
      await tester.pump(const Duration(milliseconds: 20));

      // Check focus again
      expect(FocusManager.instance.primaryFocus, isNotNull);
    });
  });
}
