import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:mockito/annotations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
import 'invoice_preview_integration_test.mocks.dart';

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

    when(mockRepository.getLastInvoiceNumber()).thenReturn('100');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);

    // Stub PdfService to avoid MissingStubError during initialization
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
        invoiceNumber: anyNamed('invoiceNumber'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
        items: anyNamed('items'),
      ),
    ).thenAnswer((_) async => Uint8List(0));

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  Widget createWidgetUnderTest(InvoiceProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: provider,
        child: const InvoiceScreen(testing: true),
      ),
    );
  }

  group('InvoiceScreen Preview Integration', () {
    testWidgets('should show preview widget when on desktop (wide screen)', (
      tester,
    ) async {
      // Set a wide screen size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(provider));

      // Wait for initial async generation (500ms debounce)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(); // Handle setState from listener

      // Add some details to trigger a NEW preview
      final previewBytes = Uint8List(20);

      when(
        mockPdfService.generateInvoice(
          description: anyNamed('description'),
          total: anyNamed('total'),
          invoiceNumber: anyNamed('invoiceNumber'),
          date: anyNamed('date'),
          currency: anyNamed('currency'),
          items: anyNamed('items'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return previewBytes;
      });

      provider.updateDescription('Test');
      await tester.pump(); // Start debounce

      // Wait for debounce (500ms) + loading delay (100ms) + mock delay (100ms)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(); // Handle setState from bytes update
      await tester.pump(); // additional pump for animations

      expect(find.text('Enter details to see preview'), findsNothing);
      expect(find.byType(SfPdfViewer), findsAtLeastNWidgets(1));

      // Add a longer pump to clear SfPdfViewer internal timers
      await tester.pump(const Duration(seconds: 2));
      provider.dispose();
    });

    testWidgets('should show preview FAB on mobile', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(provider));
      await tester.pump();

      // Should find Preview FAB
      expect(find.text('Preview'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Should NOT find placeholder text directly
      expect(find.text('Enter details to see preview'), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      provider.dispose();
    });
  });
}
