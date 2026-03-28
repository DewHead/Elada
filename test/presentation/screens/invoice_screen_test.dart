import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

@GenerateMocks([InvoiceProvider])
import 'invoice_screen_test.mocks.dart';

void main() {
  late MockInvoiceProvider mockProvider;

  setUp(() {
    mockProvider = MockInvoiceProvider();

    when(mockProvider.description).thenReturn('');
    when(mockProvider.total).thenReturn(0.0);
    when(mockProvider.invoiceNumber).thenReturn('9418');
    when(mockProvider.date).thenReturn(DateTime(2026, 3, 26));
    when(mockProvider.selectedCurrency).thenReturn('€');
    when(mockProvider.billTo).thenReturn('');
    when(mockProvider.shipTo).thenReturn('');
    when(mockProvider.previewBytes).thenReturn(null);
    when(mockProvider.isPreviewLoading).thenReturn(false);
    when(mockProvider.isGenerating).thenReturn(false);

    // Add dummy listener handling
    when(mockProvider.addListener(any)).thenReturn(null);
    when(mockProvider.removeListener(any)).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: mockProvider,
        child: const InvoiceScreen(),
      ),
    );
  }

  group('InvoiceScreen', () {
    testWidgets('should show all input fields and generate button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invoice Number'), findsOneWidget);
      expect(find.text('Invoice Date'), findsOneWidget);
      expect(find.text('Bill To'), findsOneWidget);
      expect(find.text('Ship To'), findsOneWidget);
      expect(find.text('Item Description'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Generate PDF'), findsOneWidget);
    });

    testWidgets('should show currency selector with options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('€'), findsOneWidget);
      expect(find.text('\$'), findsOneWidget);
      expect(find.text('£'), findsOneWidget);
    });

    testWidgets('should show Save as Draft button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Save as Draft'), findsOneWidget);
    });

    testWidgets('should trigger PDF generation when Generate PDF is tapped', (
      WidgetTester tester,
    ) async {
      // Set a larger screen size to ensure button is visible
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        mockProvider.generateAndSaveInvoice(),
      ).thenAnswer((_) async => '/path/to/invoice.pdf');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Ensure init complete

      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();

      verify(mockProvider.generateAndSaveInvoice()).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Invoice saved to: /path/to/invoice.pdf'),
        findsOneWidget,
      );
    });

    testWidgets(
      'should show error when Generate PDF is tapped with empty invoice number',
      (WidgetTester tester) async {
        when(mockProvider.invoiceNumber).thenReturn('');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Generate PDF'));
        await tester.pump();

        expect(find.text('Please enter an Invoice Number'), findsOneWidget);
        verifyNever(mockProvider.generateAndSaveInvoice());
      },
    );

    testWidgets('should show date picker when Invoice Date is tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final dateField = find.ancestor(
        of: find.text('Invoice Date'),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(dateField);
      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Should find the DatePicker (Material 3)
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
