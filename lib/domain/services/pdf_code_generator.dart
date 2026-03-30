import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_components/decoration_component.dart';
import 'package:elada/domain/services/pdf_components/invoice_header.dart';
import 'package:elada/domain/services/pdf_components/invoice_customer_info.dart';
import 'package:elada/domain/services/pdf_components/invoice_items_table.dart';
import 'package:elada/domain/services/pdf_components/invoice_totals.dart';

import 'package:elada/data/models/invoice_item.dart';

/// Service responsible for generating the final invoice PDF by coordinating all layout components.
class PdfCodeGenerator {
  final InvoiceTheme theme;
  InvoiceTheme? _cachedTheme;
  DecorationComponent? _decoration;
  InvoiceHeader? _header;
  InvoiceCustomerInfo? _customerInfo;
  InvoiceItemsTable? _itemsTable;
  InvoiceTotals? _totals;

  PdfCodeGenerator(this.theme);

  /// Generates the complete PDF invoice as bytes.
  Future<Uint8List> generate({
    required String description,
    required double total,
    required String invoiceNumber,
    required DateTime date,
    List<InvoiceItem> items = const [],
    String currency = '€',
    Uint8List? fontData,
    Uint8List? boldFontData,
    Uint8List? templateBytes,
  }) async {
    // 1. Create a new PDF document or load from template
    final PdfDocument document = templateBytes != null
        ? PdfDocument(inputBytes: templateBytes)
        : PdfDocument();

    try {
      if (templateBytes != null) {
        // Flatten existing form fields to prevent duplicate ghost text
        document.form.flattenAllFields();
      }

      // Set Page Settings
      if (templateBytes == null) {
        document.pageSettings.size = PdfPageSize.a4;
      }
      document.pageSettings.margins.all = 0;

      // 2. Get or add a page
      final PdfPage page = document.pages.count > 0
          ? document.pages[0]
          : document.pages.add();
      final PdfGraphics graphics = page.graphics;

      // 3. Create or reuse Components
      if (_cachedTheme == null ||
          _cachedTheme!.fontData != fontData ||
          _cachedTheme!.boldFontData != boldFontData) {
        _cachedTheme = InvoiceTheme(
          fontData: fontData,
          boldFontData: boldFontData,
        );
        _decoration = DecorationComponent(_cachedTheme!);
        _header = InvoiceHeader(_cachedTheme!);
        _customerInfo = InvoiceCustomerInfo(_cachedTheme!);
        _itemsTable = InvoiceItemsTable(_cachedTheme!);
        _totals = InvoiceTotals(_cachedTheme!);
      }

      // 4. Draw Components
      final bool loadAndFill = templateBytes != null;

      if (!loadAndFill) {
        _decoration!.drawHeaderBar(graphics);
        _decoration!.drawFooterBar(graphics);
      }

      _header!.draw(
        graphics: graphics,
        invoiceNumber: invoiceNumber,
        date: date,
        loadAndFill: loadAndFill,
      );

      _customerInfo!.draw(
        graphics: graphics,
        loadAndFill: loadAndFill,
      );

      _itemsTable!.draw(
        graphics: graphics,
        description: description,
        total: total,
        items: items,
        currency: currency,
        loadAndFill: loadAndFill,
      );

      _totals!.draw(
        graphics: graphics,
        subtotal: total,
        vat: 0.0,
        total: total,
        currency: currency,
        loadAndFill: loadAndFill,
      );

      // 5. Save and return the document
      final List<int> bytes = await document.save();
      return Uint8List.fromList(bytes);
    } finally {
      document.dispose();
    }
  }
}
