import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_components/invoice_items_table.dart';

void main() {
  test('InvoiceItemsTable handles extremely long description without crash', () {
    final theme = InvoiceTheme();
    final table = InvoiceItemsTable(theme);
    final document = PdfDocument();
    final page = document.pages.add();
    
    final longDescription = 'This is an extremely long description that should definitely ' * 50;
    
    expect(() {
      table.draw(
        graphics: page.graphics,
        description: longDescription,
        total: 100.0,
      );
    }, returnsNormally);
  });

  test('InvoiceItemsTable handles empty description without crash', () {
    final theme = InvoiceTheme();
    final table = InvoiceItemsTable(theme);
    final document = PdfDocument();
    final page = document.pages.add();
    
    expect(() {
      table.draw(
        graphics: page.graphics,
        description: '',
        total: 100.0,
      );
    }, returnsNormally);
  });
}
