import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_components/decoration_component.dart';
import 'package:elada/domain/services/pdf_components/invoice_header.dart';
import 'package:elada/domain/services/pdf_components/invoice_customer_info.dart';
import 'package:elada/domain/services/pdf_components/invoice_items_table.dart';
import 'package:elada/domain/services/pdf_components/invoice_totals.dart';

/// Service responsible for generating the final invoice PDF by coordinating all layout components.
class PdfCodeGenerator {
  final InvoiceTheme theme;
  final DecorationComponent _decoration;
  final InvoiceHeader _header;
  final InvoiceCustomerInfo _customerInfo;
  final InvoiceItemsTable _itemsTable;
  final InvoiceTotals _totals;

  PdfCodeGenerator(this.theme)
      : _decoration = DecorationComponent(theme),
        _header = InvoiceHeader(theme),
        _customerInfo = InvoiceCustomerInfo(theme),
        _itemsTable = InvoiceItemsTable(theme),
        _totals = InvoiceTotals(theme);

  /// Generates the complete PDF invoice as bytes.
  Future<Uint8List> generate({
    required String description,
    required double total,
    required String invoiceNumber,
    required DateTime date,
    required String billTo,
    required String shipTo,
    String currency = '€',
  }) async {
    // 1. Create a new PDF document
    final PdfDocument document = PdfDocument();
    
    // Set Page Settings
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0; // Component handle their own internal margins if needed

    // 2. Add a page
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;

    // 3. Draw Components
    // 3.1 Decorations (Header and Footer Bars)
    _decoration.drawHeaderBar(graphics);
    _decoration.drawFooterBar(graphics);

    // 3.2 Header
    _header.draw(
      graphics: graphics,
      invoiceNumber: invoiceNumber,
      date: date,
    );

    // 3.3 Customer Info
    _customerInfo.draw(
      graphics: graphics,
      billTo: billTo,
      shipTo: shipTo,
    );

    // 3.4 Items Table
    _itemsTable.draw(
      graphics: graphics,
      description: description,
      total: total,
      currency: currency,
    );

    // 3.5 Totals
    _totals.draw(
      graphics: graphics,
      subtotal: total, // For now, assume total is subtotal if no taxes/discounts
      vat: 0.0,
      total: total,
      currency: currency,
    );

    // 4. Save and return the document
    final List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }
}
