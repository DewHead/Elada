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
        child: const InvoiceScreen(),
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
      await tester.pump();

      // Should find InvoicePreview widget showing a loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Add some details
      final previewBytes = Uint8List(20);

      when(
        mockPdfService.generateInvoice(
          description: anyNamed('description'),
          total: anyNamed('total'),
          invoiceNumber: anyNamed('invoiceNumber'),
          date: anyNamed('date'),
          billTo: anyNamed('billTo'),
          shipTo: anyNamed('shipTo'),
          currency: anyNamed('currency'),
        ),
      ).thenAnswer((_) async => previewBytes);

      provider.updateDescription('Test');

      // Wait for debounce and any other internal timers
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(SfPdfViewer), findsOneWidget);

      provider.dispose();
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('should show preview FAB on mobile', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(provider));
      await tester.pump();

      // Should find Preview FAB
      expect(find.text('Preview'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Should NOT find InvoicePreview directly in the body
      expect(find.text('Enter details to see preview'), findsNothing);

      // We still need to wait for the initial template loading timer to finish
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      provider.dispose();
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
