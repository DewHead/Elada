import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:typed_data';

void main() {
  group('PdfCodeGenerator', () {
    test('generate should return valid PDF bytes', () async {
      final theme = InvoiceTheme();
      final generator = PdfCodeGenerator(theme);
      
      final Uint8List pdfBytes = await generator.generate(
        description: 'Integration Test Service',
        total: 250.0,
        invoiceNumber: 'TEST-001',
        date: DateTime(2026, 3, 27),
        billTo: 'Customer Name\n123 Lane',
        shipTo: 'Customer Name\n123 Lane',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000)); // Basic sanity check for PDF size
    });
  });
}
