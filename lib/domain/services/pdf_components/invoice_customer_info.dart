import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

/// Component responsible for drawing the customer information (Bill To / Ship To).
class InvoiceCustomerInfo {
  final InvoiceTheme theme;

  InvoiceCustomerInfo(this.theme);

  /// Draws the customer info section on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    required String billTo,
    required String shipTo,
    double yOffset = 270,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush greyBrush = PdfSolidBrush(theme.grey);
    final PdfFont headerFont = theme.boldFont;
    final PdfFont dataFont = theme.defaultFont;

    final double columnWidth = theme.contentWidth / 2;

    // 1. Bill To Section
    graphics.drawString(
      'Bill To',
      headerFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, yOffset, columnWidth, 20),
    );
    graphics.drawString(
      billTo,
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, yOffset + 20, columnWidth - 20, 100),
    );

    // 2. Ship To Section
    graphics.drawString(
      'Ship To',
      headerFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin + columnWidth, yOffset, columnWidth, 20),
    );
    graphics.drawString(
      shipTo,
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin + columnWidth, yOffset + 20, columnWidth - 20, 100),
    );
  }
}
