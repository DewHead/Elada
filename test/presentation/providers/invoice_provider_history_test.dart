import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/data/models/invoice.dart';

@GenerateMocks([InvoiceRepository, PdfService])
import 'invoice_provider_history_test.mocks.dart';

void main() {
  late InvoiceProvider provider;
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    
    when(mockRepository.getLastInvoiceNumber()).thenReturn('9417');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
    
    provider = InvoiceProvider(mockRepository, mockPdfService);
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

      // Re-init to trigger loading logic in constructor if we put it there, 
      // or call a load method if we prefer. The plan says "Implement history and drafts lists".
      provider = InvoiceProvider(mockRepository, mockPdfService);

      expect(provider.history, history);
      expect(provider.drafts, drafts);
    });

    test('should save and refresh history after generation', () async {
      final templateBytes = Uint8List(10);
      when(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
      )).thenAnswer((_) async => Uint8List(10));

      final invoice = Invoice(invoiceNumber: '9418', description: 'Test', total: 100, date: DateTime.now());
      when(mockRepository.getInvoices()).thenReturn([invoice]);

      await provider.generateInvoice(templateBytes);

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
