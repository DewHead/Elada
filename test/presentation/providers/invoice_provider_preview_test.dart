import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'dart:typed_data';

import 'invoice_provider_preview_test.mocks.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
void main() {
  late InvoiceProvider provider;
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;
  late MockFilenameService mockFilenameService;
  late MockFileExportService mockFileExportService;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    mockFilenameService = MockFilenameService();
    mockFileExportService = MockFileExportService();

    when(mockRepository.getLastInvoiceNumber()).thenReturn('9417');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  test('should generate preview when data changes', () async {
    final pdfBytes = Uint8List(100);
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
    ).thenAnswer((_) async => pdfBytes);

    provider.updateDescription('Test');

    // Wait for debounce timer (500ms)
    await Future.delayed(const Duration(milliseconds: 600));

    expect(provider.previewBytes, equals(pdfBytes));
    verify(
      mockPdfService.generateInvoice(
        description: 'Test',
        total: 0.0,
        invoiceNumber: '9418',
        date: anyNamed('date'),
        billTo: '',
        shipTo: '',
        currency: '€',
      ),
    ).called(1);
  });

  test('should set isPreviewLoading to true immediately when data changes', () {
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
    ).thenAnswer((_) async => Uint8List(0));

    provider.updateDescription('Test');

    expect(provider.isPreviewLoading, isTrue);
  });
}
