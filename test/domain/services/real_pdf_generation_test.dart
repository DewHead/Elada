import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:typed_data';

void main() {
  test('PdfService should generate real PDF without crashing', () async {
    final theme = InvoiceTheme();
    final generator = PdfCodeGenerator(theme);
    final service = PdfService(generator);

    final bytes = await service.generateInvoice(
      description: 'Test Description',
      total: 100.0,
      invoiceNumber: '123',
      date: DateTime.now(),
      billTo: 'Bill To Test',
      shipTo: 'Ship To Test',
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
  });
}
