import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
import 'invoice_screen_test.mocks.dart';

void main() {
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;
  late MockFilenameService mockFilenameService;
  late MockFileExportService mockFileExportService;
  late InvoiceProvider provider;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    mockFilenameService = MockFilenameService();
    mockFileExportService = MockFileExportService();

    when(mockRepository.getLastInvoiceNumber()).thenReturn('9418');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
    
    when(mockPdfService.loadFonts(
      regularPath: anyNamed('regularPath'),
      boldPath: anyNamed('boldPath'),
    )).thenAnswer((_) async {});
    
    when(mockPdfService.generateInvoice(
      description: anyNamed('description'),
      total: anyNamed('total'),
      invoiceNumber: anyNamed('invoiceNumber'),
      date: anyNamed('date'),
      billTo: anyNamed('billTo'),
      shipTo: anyNamed('shipTo'),
      currency: anyNamed('currency'),
    )).thenAnswer((_) async => Uint8List(0));

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  tearDown(() async {
    // Standard Flutter test runners don't automatically clear all timers from 3rd party widgets
    // This ensures we wait out any internal timers (like SfPdfViewer's 500ms debounce)
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: provider,
        child: const InvoiceScreen(),
      ),
    );
  }

  group('InvoiceScreen', () {
    testWidgets('should show all input fields and generate button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow provider init

      expect(find.text('Invoice Number'), findsOneWidget);
      expect(find.text('Invoice Date'), findsOneWidget);
      expect(find.text('Bill To'), findsOneWidget);
      expect(find.text('Ship To'), findsOneWidget);
      expect(find.text('Item Description'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Generate PDF'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should show currency selector with options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('€'), findsOneWidget);
      expect(find.text('\$'), findsOneWidget);
      expect(find.text('£'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should show Save as Draft button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Save as Draft'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should trigger PDF generation when Generate PDF is tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(mockFilenameService.generateFileName(any)).thenReturn('invoice.pdf');
      when(mockFileExportService.saveFile(
        bytes: anyNamed('bytes'),
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => '/path/to/invoice.pdf');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Enter some data to make it valid
      await tester.enterText(find.widgetWithText(TextField, 'Invoice Number'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Item Description'), 'Test');
      await tester.enterText(find.widgetWithText(TextField, 'Total Amount'), '100');
      await tester.pump();

      await tester.tap(find.text('Generate PDF'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        date: anyNamed('date'),
        billTo: anyNamed('billTo'),
        shipTo: anyNamed('shipTo'),
        currency: anyNamed('currency'),
      )).called(greaterThan(0));
      
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Invoice saved to: /path/to/invoice.pdf'),
        findsOneWidget,
      );
    });

    testWidgets(
      'should show error when Generate PDF is tapped with empty invoice number',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Clear invoice number
        await tester.enterText(find.widgetWithText(TextField, 'Invoice Number'), '');
        await tester.pump();

        await tester.tap(find.text('Generate PDF'));
        await tester.pump();

        expect(find.text('Please enter an Invoice Number'), findsOneWidget);
        verifyNever(mockFileExportService.saveFile(
          bytes: anyNamed('bytes'),
          fileName: anyNamed('fileName'),
        ));
        
        await tester.pump(const Duration(seconds: 1));
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DatePickerDialog), findsOneWidget);
      
      // Clear any pending debounce timers from updateInvoiceNumber or others
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
