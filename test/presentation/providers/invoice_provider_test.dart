import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';

@GenerateMocks([InvoiceRepository, PdfService])
import 'invoice_provider_test.mocks.dart';

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

  group('InvoiceProvider', () {
    test('initial state should be correct', () {
      expect(provider.invoiceNumber, '9418'); // Incremented from 9417
      expect(provider.description, '');
      expect(provider.total, 0.0);
    });

    test('should update description and total', () {
      provider.updateDescription('New Task');
      provider.updateTotal(1200.0);

      expect(provider.description, 'New Task');
      expect(provider.total, 1200.0);
    });

    test('should increment invoice number correctly', () {
      expect(provider.invoiceNumber, '9418');
      
      when(mockRepository.getLastInvoiceNumber()).thenReturn('9418');
      provider.incrementInvoiceNumber();
      expect(provider.invoiceNumber, '9419');
    });

    test('should generate PDF and save invoice', () async {
      final templateBytes = Uint8List(10);
      final pdfBytes = Uint8List(20);

      when(mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        templateBytes: anyNamed('templateBytes'),
      )).thenAnswer((_) async => pdfBytes);

      provider.updateDescription('Work');
      provider.updateTotal(500.0);
      
      final result = await provider.generateInvoice(templateBytes);

      expect(result, pdfBytes);
      verify(mockRepository.saveInvoice(any)).called(1);
    });
  });
}
