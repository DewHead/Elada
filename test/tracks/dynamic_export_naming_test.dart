import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
import 'dynamic_export_naming_test.mocks.dart';

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

  group('InvoiceProvider Date Field', () {
    test('should have a date property initialized to today', () {
      final now = DateTime.now();
      expect(provider.date.year, now.year);
      expect(provider.date.month, now.month);
      expect(provider.date.day, now.day);
    });

    test('should update date and notify listeners', () {
      final newDate = DateTime(2026, 3, 26);
      provider.updateDate(newDate);
      expect(provider.date, newDate);
    });
  });

  group('PdfService Date Field', () {
    test('should accept date and generate PDF', () async {
      final theme = InvoiceTheme();
      final generator = PdfCodeGenerator(theme);
      final pdfService = PdfService(generator);

      final result = await pdfService.generateInvoice(
        description: 'Test Description',
        total: 1500.0,
        invoiceNumber: '9418',
        date: DateTime(2026, 3, 26),
      );

      expect(result, isNotNull);
      expect(result.length, isPositive);
    });
  });

  group('InvoiceProvider dynamic naming export', () {
    test('should generate and save invoice with dynamic name', () async {
      final templateBytes = Uint8List(10);
      final pdfBytes = Uint8List(20);

      when(
        mockPdfService.generateInvoice(
          description: anyNamed('description'),
          total: anyNamed('total'),
          invoiceNumber: anyNamed('invoiceNumber'),
          date: anyNamed('date'),
          billTo: anyNamed('billTo'),
          shipTo: anyNamed('shipTo'),
          currency: anyNamed('currency'),
          templateBytes: anyNamed('templateBytes'),
        ),
      ).thenAnswer((_) async => pdfBytes);

      when(
        mockFilenameService.generateFileName(any),
      ).thenReturn('123_26-03-2026.pdf');
      when(
        mockFileExportService.saveFile(
          bytes: anyNamed('bytes'),
          fileName: anyNamed('fileName'),
        ),
      ).thenAnswer((_) async => '/downloads/123_26-03-2026.pdf');

      provider.updateInvoiceNumber('123');
      provider.updateDate(DateTime(2026, 3, 26));

      final result = await provider.generateAndSaveInvoice(templateBytes);

      expect(result, '/downloads/123_26-03-2026.pdf');
      verify(
        mockFilenameService.generateFileName(
          argThat(predicate<Invoice>((inv) => inv.invoiceNumber == '123')),
        ),
      ).called(1);
      verify(
        mockFileExportService.saveFile(
          bytes: pdfBytes,
          fileName: '123_26-03-2026.pdf',
        ),
      ).called(1);
    });
  });
}
