import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/main_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

@GenerateMocks([InvoiceProvider])
import 'main_screen_test.mocks.dart';

void main() {
  late MockInvoiceProvider mockProvider;

  setUp(() {
    mockProvider = MockInvoiceProvider();

    when(mockProvider.invoiceNumber).thenReturn('9418');
    when(mockProvider.date).thenReturn(DateTime(2026, 3, 26));
    when(mockProvider.description).thenReturn('');
    when(mockProvider.total).thenReturn(0.0);
    when(mockProvider.billTo).thenReturn('');
    when(mockProvider.shipTo).thenReturn('');
    when(mockProvider.selectedCurrency).thenReturn('€');
    when(mockProvider.history).thenReturn([]);
    when(mockProvider.drafts).thenReturn([]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: mockProvider,
        child: const MainScreen(),
      ),
    );
  }

  group('MainScreen Navigation', () {
    testWidgets('should show NavigationBar with Generate and History', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Generate'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should switch between Generate and History tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial tab should be Generate (which contains InvoiceScreen parts)
      expect(find.text('Item Description'), findsOneWidget);

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should show History placeholder
      expect(find.text('Invoice History'), findsOneWidget);
      expect(find.text('Item Description'), findsNothing);
    });
  });
}
