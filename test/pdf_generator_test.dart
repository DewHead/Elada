import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/invoice_theme.dart';

void main() {
  test('generates pdf without error', () async {
    final generator = PdfCodeGenerator(InvoiceTheme());
    await generator.generate(
      description: 'Test',
      total: 100,
      invoiceNumber: '123',
      date: DateTime.now(),
      currency: '€',
    );
  });
}
