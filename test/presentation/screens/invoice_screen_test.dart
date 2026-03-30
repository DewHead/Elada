import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'invoice_screen_test.mocks.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
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

    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
    when(mockRepository.getLastInvoiceNumber()).thenReturn('1');

    when(
      mockPdfService.loadFonts(
        regularPath: anyNamed('regularPath'),
        boldPath: anyNamed('boldPath'),
      ),
    ).thenAnswer((_) async {});

    when(
      mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        items: anyNamed('items'),
        invoiceNumber: anyNamed('invoiceNumber'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      ),
    ).thenAnswer((_) async => Uint8List(0));

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: provider,
        child: const InvoiceScreen(testing: true),
      ),
    );
  }

  testWidgets(
    'InvoiceScreen should show all input fields and generate button',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Generate New Invoice'), findsOneWidget);
      expect(find.text('Invoice Number'), findsOneWidget);
      expect(find.text('Item Description'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Generate PDF'), findsOneWidget);
    },
  );

  testWidgets(
    'InvoiceScreen should trigger PDF generation when Generate PDF is tapped',
    (tester) async {
      await tester.runAsync(() async {
        tester.view.physicalSize = const Size(800, 1200);
        addTearDown(tester.view.resetPhysicalSize);

        when(
          mockFilenameService.generateFileName(any),
        ).thenReturn('invoice.pdf');
        when(
          mockFileExportService.saveFile(
            bytes: anyNamed('bytes'),
            fileName: anyNamed('fileName'),
          ),
        ).thenAnswer((_) async => '/path/to/invoice.pdf');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Enter some data to make it valid
        final invNumField = find.widgetWithText(TextField, 'Invoice Number');
        await tester.ensureVisible(invNumField);
        await tester.enterText(invNumField, '1234');

        final descField = find.widgetWithText(TextField, 'Item Description');
        await tester.ensureVisible(descField);
        await tester.enterText(descField, 'Test');

        // Unfocus to trigger focus loss and update provider
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(
          const Duration(milliseconds: 600),
        ); // wait for debounce
        await tester.pumpAndSettle();

        final genButton = find.text('Generate PDF');
        await tester.ensureVisible(genButton);
        await tester.tap(genButton);
        await Future.delayed(
          const Duration(milliseconds: 600),
        ); // wait for generation
        await tester.pumpAndSettle();

        verify(
          mockPdfService.generateInvoice(
            description: anyNamed('description'),
            total: anyNamed('total'),
            items: anyNamed('items'),
            invoiceNumber: '1234',
            date: anyNamed('date'),
            currency: anyNamed('currency'),
          ),
        ).called(greaterThanOrEqualTo(1));
      });
    },
  );

  testWidgets(
    'InvoiceScreen should show preview in mobile view when FAB is tapped',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // FAB should be present
      final fab = find.byType(FloatingActionButton);
      await tester.ensureVisible(fab);
      expect(fab, findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      // Tap to show modal
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Preview should be visible in modal
      expect(find.text('Invoice Preview'), findsOneWidget);
    },
  );

  testWidgets('InvoiceScreen should clear form and increment invoice number', (
    tester,
  ) async {
    await tester.runAsync(() async {
      tester.view.physicalSize = const Size(1200, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initial state
      expect(provider.invoiceNumber, '2');

      // Change some data
      // Use find.descendant to hit the item description specifically if needed,
      // but find.widgetWithText should work if it's the only one for now.
      final descField = find.widgetWithText(TextField, 'Item Description');
      await tester.ensureVisible(descField);
      await tester.enterText(
        descField,
        '${InvoiceProvider.itemPrefix}Old Task',
      );

      // Unfocus to update
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        provider.items[0].description,
        '${InvoiceProvider.itemPrefix}Old Task',
      );

      // Tap Clear Form
      final clearButton = find.text('Clear Form');
      await tester.ensureVisible(clearButton);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Verify state
      expect(provider.description, InvoiceProvider.itemPrefix);
      expect(provider.total, 0.0);
      expect(provider.invoiceNumber, '3'); // Incremented from 2
      expect(provider.items[0].description, InvoiceProvider.itemPrefix);
    });
  });
}
