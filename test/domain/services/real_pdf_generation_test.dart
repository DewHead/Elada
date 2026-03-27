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
      description: 'Car',
      total: 10000.0,
      invoiceNumber: '9421',
      date: DateTime(2026, 3, 26),
      billTo: 'Elad Avital',
      shipTo: '',
      currency: '€',
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
  });
}
