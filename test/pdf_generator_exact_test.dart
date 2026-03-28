import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/invoice_theme.dart';

void main() {
  test('generates pdf with exact data', () async {
    final generator = PdfCodeGenerator(InvoiceTheme());
    try {
      await generator.generate(
        description: 'Car',
        total: 100000.0,
        invoiceNumber: '9422',
        date: DateTime(2026, 3, 28),
        billTo: 'Elad Avital',
        shipTo: '',
        currency: '€',
      );
    } catch (e, st) {
      print('ERROR: \$e');
      print(st);
      rethrow;
    }
  });
}
