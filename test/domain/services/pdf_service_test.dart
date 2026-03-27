import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  group('PdfService', () {
    test('should inject data into PDF document', () async {
      final pdfService = PdfService();

      // Create a dummy PDF with fields to test our service
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfForm form = document.form;

      form.fields.add(
        PdfTextBoxField(
          page,
          'INVOICE NO.',
          const Rect.fromLTWH(0, 0, 100, 20),
        ),
      );
      form.fields.add(
        PdfTextBoxField(
          page,
          'Description',
          const Rect.fromLTWH(0, 30, 100, 20),
        ),
      );
      form.fields.add(
        PdfTextBoxField(page, 'Total', const Rect.fromLTWH(0, 60, 100, 20)),
      );
      form.fields.add(
        PdfTextBoxField(
          page,
          'Balance Due',
          const Rect.fromLTWH(0, 90, 100, 20),
        ),
      );

      final Uint8List templateBytes = Uint8List.fromList(await document.save());
      document.dispose();

      final result = await pdfService.generateInvoice(
        description: 'Test Description',
        total: 1500.0,
        invoiceNumber: '9418',
        templateBytes: templateBytes,
        date: DateTime(2026, 3, 26),
      );

      expect(result, isNotNull);
      expect(result.length, isPositive);
    });
  });
}
