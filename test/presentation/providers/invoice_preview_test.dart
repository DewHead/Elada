import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([InvoiceRepository, PdfService, FilenameService, FileExportService])
import 'invoice_preview_test.mocks.dart';

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

  group('InvoiceProvider Preview Logic', () {
    test('should generate preview after debounce period', () async {
      final templateBytes = Uint8List(10);
      final previewBytes = Uint8List(20);

      when(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      )).thenAnswer((_) async => previewBytes);

      provider.updateTemplateBytes(templateBytes);
      provider.updateDescription('Test Description');

      // Initially, previewBytes should be null because of debounce
      expect(provider.previewBytes, isNull);
      expect(provider.isPreviewLoading, isFalse);

      // Wait for debounce (500ms) + some buffer
      await Future.delayed(const Duration(milliseconds: 600));

      expect(provider.previewBytes, equals(previewBytes));
      expect(provider.isPreviewLoading, isFalse);
      verify(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      )).called(1);
    });

    test('should only generate one preview when multiple updates happen rapidly', () async {
      final templateBytes = Uint8List(10);
      final previewBytes = Uint8List(20);

      when(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      )).thenAnswer((_) async => previewBytes);

      provider.updateTemplateBytes(templateBytes);
      provider.updateDescription('Update 1');
      provider.updateDescription('Update 2');
      provider.updateDescription('Update 3');

      await Future.delayed(const Duration(milliseconds: 600));

      expect(provider.previewBytes, equals(previewBytes));
      // Should only be called once for 'Update 3'
      verify(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      )).called(1);
    });
  });
}
