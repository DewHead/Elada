import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

/// Component responsible for drawing the invoice totals.
class InvoiceTotals {
  final InvoiceTheme theme;

  InvoiceTotals(this.theme);

  /// Draws the totals section on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    required double subtotal,
    required double vat,
    required double total,
    String currency = '€',
    double yOffset = 550,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush brandBrush = PdfSolidBrush(theme.brandBlue);
    final PdfFont labelFont = theme.defaultFont;
    final PdfFont boldFont = theme.boldFont;

    final double labelX = theme.pageWidth - 250;
    final double valueX = theme.pageWidth - 160;
    final double rowHeight = 20;
    final double valueWidth = 120; // Increased width to fit large amounts

    final rightFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
    final currencyText = currency;

    // 1. Subtotal
    graphics.drawString(
      'Subtotal',
      labelFont,
      brush: brush,
      bounds: Rect.fromLTWH(labelX, yOffset, 100, rowHeight),
    );
    graphics.drawString(
      '$currencyText ${subtotal.toStringAsFixed(2)}',
      labelFont,
      brush: brush,
      bounds: Rect.fromLTWH(valueX, yOffset, valueWidth, rowHeight),
      format: rightFormat,
    );

    // 2. VAT (Placeholder 0% for now if not calculated)
    graphics.drawString(
      'VAT (0%)',
      labelFont,
      brush: brush,
      bounds: Rect.fromLTWH(labelX, yOffset + rowHeight, 100, rowHeight),
    );
    graphics.drawString(
      '$currencyText ${vat.toStringAsFixed(2)}',
      labelFont,
      brush: brush,
      bounds: Rect.fromLTWH(valueX, yOffset + rowHeight, valueWidth, rowHeight),
      format: rightFormat,
    );

    // 3. Horizontal line before Balance Due
    graphics.drawLine(
      PdfPen(theme.grey, width: 0.5),
      Offset(labelX, yOffset + (rowHeight * 2) + 5),
      Offset(theme.pageWidth - theme.margin, yOffset + (rowHeight * 2) + 5),
    );

    // 4. Balance Due (Prominent)
    final double balanceY = yOffset + (rowHeight * 2) + 15;
    graphics.drawString(
      'Balance Due',
      boldFont,
      brush: brandBrush,
      bounds: Rect.fromLTWH(labelX, balanceY, 100, rowHeight),
    );
    graphics.drawString(
      '$currencyText ${total.toStringAsFixed(2)}',
      boldFont,
      brush: brandBrush,
      bounds: Rect.fromLTWH(valueX, balanceY, valueWidth, rowHeight),
      format: rightFormat,
    );
  }
}
