import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/data/models/invoice.dart';

void main() {
  group('FilenameService', () {
    late FilenameService filenameService;

    setUp(() {
      filenameService = FilenameService();
    });

    test('should generate correct filename from invoice', () {
      final invoice = Invoice(
        invoiceNumber: '123',
        description: 'Test',
        total: 100.0,
        date: DateTime(2026, 3, 26),
      );

      final result = filenameService.generateFileName(invoice);
      expect(result, '123_26-03-2026.pdf');
    });

    test('should sanitize illegal filesystem characters in invoice number', () {
      final invoice = Invoice(
        invoiceNumber: '123/A:B*C',
        description: 'Sanitization Test',
        total: 50.0,
        date: DateTime(2026, 3, 26),
      );

      final result = filenameService.generateFileName(invoice);
      // Let's assume we replace illegal characters with hyphens
      expect(result, '123-A-B-C_26-03-2026.pdf');
    });

    test('should handle empty or weird invoice numbers safely', () {
      final invoice = Invoice(
        invoiceNumber: '',
        description: 'Empty Test',
        total: 0.0,
        date: DateTime(2026, 3, 26),
      );

      final result = filenameService.generateFileName(invoice);
      expect(result, 'invoice_26-03-2026.pdf');
    });
  });
}
