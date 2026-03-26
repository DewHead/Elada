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

@GenerateMocks([InvoiceRepository, PdfService, FilenameService, FileExportService])
import 'invoice_provider_history_test.mocks.dart';

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

  group('InvoiceProvider History & Drafts', () {
    test('should load history and drafts on initialization', () {
      final history = [
        Invoice(invoiceNumber: '1', description: 'Test 1', total: 100, date: DateTime.now())
      ];
      final drafts = [
        Invoice(invoiceNumber: 'D1', description: 'Draft 1', total: 50, date: DateTime.now(), isDraft: true)
      ];

      when(mockRepository.getInvoices()).thenReturn(history);
      when(mockRepository.getDrafts()).thenReturn(drafts);

      provider = InvoiceProvider(
        mockRepository,
        mockPdfService,
        mockFilenameService,
        mockFileExportService,
      );

      expect(provider.history, history);
      expect(provider.drafts, drafts);
    });

    test('should save and refresh history after generation', () async {
      final templateBytes = Uint8List(10);
      final pdfBytes = Uint8List(20);
      when(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
        date: anyNamed('date'),
        currency: anyNamed('currency'),
      )).thenAnswer((_) async => pdfBytes);
      
      when(mockFilenameService.generateFileName(any)).thenReturn('9418_26-03-2026.pdf');
      when(mockFileExportService.saveFile(
        bytes: anyNamed('bytes'),
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => 'path/to/9418_26-03-2026.pdf');

      final invoice = Invoice(invoiceNumber: '9418', description: 'Test', total: 100, date: DateTime.now());
      when(mockRepository.getInvoices()).thenReturn([invoice]);

      await provider.generateAndSaveInvoice(templateBytes);

      verify(mockRepository.saveInvoice(any)).called(1);
      expect(provider.history.length, 1);
      expect(provider.history.first.invoiceNumber, '9418');
    });

    test('should save draft and refresh drafts list', () async {
      final draft = Invoice(invoiceNumber: 'DRAFT-1', description: 'Draft', total: 100, date: DateTime.now(), isDraft: true);
      when(mockRepository.getDrafts()).thenReturn([draft]);

      provider.updateDescription('Draft');
      provider.updateTotal(100);
      provider.updateInvoiceNumber('DRAFT-1');

      await provider.saveDraft();

      verify(mockRepository.saveDraft(any)).called(1);
      expect(provider.drafts.length, 1);
      expect(provider.drafts.first.invoiceNumber, 'DRAFT-1');
    });

    test('should load a draft into the form', () {
      final draft = Invoice(
        invoiceNumber: 'DRAFT-1',
        description: 'Loaded Draft',
        total: 250,
        date: DateTime.now(),
        currency: '\$',
        isDraft: true,
      );

      provider.loadDraft(draft);

      expect(provider.description, 'Loaded Draft');
      expect(provider.total, 250);
      expect(provider.invoiceNumber, 'DRAFT-1');
      expect(provider.selectedCurrency, '\$');
    });

    test('should toggle currency', () {
      expect(provider.selectedCurrency, '€');
      
      provider.updateCurrency('\$');
      expect(provider.selectedCurrency, '\$');

      provider.updateCurrency('£');
      expect(provider.selectedCurrency, '£');
    });

    test('should delete draft and refresh list', () async {
      when(mockRepository.getDrafts()).thenReturn([]);

      await provider.deleteDraft(0);

      verify(mockRepository.deleteDraft(0)).called(1);
      expect(provider.drafts.length, 0);
    });
  });
}
