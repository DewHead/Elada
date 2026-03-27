import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  group('PdfService', () {
    test('should generate PDF document', () async {
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
}
