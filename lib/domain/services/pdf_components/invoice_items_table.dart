import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

/// Component responsible for drawing the items table.
class InvoiceItemsTable {
  final InvoiceTheme theme;

  InvoiceItemsTable(this.theme);

  /// Draws the items table on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    required String description,
    required double total,
    String currency = '€',
    double yOffset = 400,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush headerBrush = PdfSolidBrush(theme.brandBlue);
    final PdfBrush headerTextBrush = PdfSolidBrush(theme.white);
    final PdfBrush rowAccentBrush = PdfSolidBrush(theme.accentBlue);
    final PdfFont headerFont = theme.boldFont;
    final PdfFont dataFont = theme.defaultFont;

    const double headerHeight = 25;
    const double rowHeight = 25;
    
    final List<double> columnWidths = [
      theme.contentWidth * 0.5, // Description
      theme.contentWidth * 0.1, // Qty
      theme.contentWidth * 0.2, // Unit Price
      theme.contentWidth * 0.2, // Total
    ];

    // 1. Draw Table Header
    graphics.drawRectangle(
      brush: headerBrush,
      bounds: Rect.fromLTWH(theme.margin, yOffset, theme.contentWidth, headerHeight),
    );

    final List<String> headers = ['Description', 'Qty', 'Unit Price', 'Total'];
    double currentX = theme.margin;
    for (int i = 0; i < headers.length; i++) {
      graphics.drawString(
        headers[i],
        headerFont,
        brush: headerTextBrush,
        bounds: Rect.fromLTWH(currentX + 5, yOffset + 5, columnWidths[i] - 10, headerHeight - 10),
        format: i > 0 ? PdfStringFormat(alignment: PdfTextAlignment.center) : null,
      );
      currentX += columnWidths[i];
    }

    // 2. Draw Data Row (Simplified for now, as we only have one main item)
    final double rowY = yOffset + headerHeight;
    graphics.drawRectangle(
      brush: rowAccentBrush,
      bounds: Rect.fromLTWH(theme.margin, rowY, theme.contentWidth, rowHeight),
    );

    currentX = theme.margin;
    // Description
    graphics.drawString(
      description,
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(currentX + 5, rowY + 5, columnWidths[0] - 10, rowHeight - 10),
    );
    currentX += columnWidths[0];

    // Qty (Placeholder 1)
    graphics.drawString(
      '1',
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(currentX + 5, rowY + 5, columnWidths[1] - 10, rowHeight - 10),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentX += columnWidths[1];

    // Unit Price (Same as total for 1 qty)
    final currencyText = currency == '€' ? 'EUR' : currency;
    graphics.drawString(
      '$currencyText ${total.toStringAsFixed(2)}',
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(currentX + 5, rowY + 5, columnWidths[2] - 10, rowHeight - 10),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentX += columnWidths[2];

    // Total
    graphics.drawString(
      '$currencyText ${total.toStringAsFixed(2)}',
      dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(currentX + 5, rowY + 5, columnWidths[3] - 10, rowHeight - 10),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // 3. Draw Table Grid Lines (Vertical)
    currentX = theme.margin;
    final PdfPen gridPen = PdfPen(theme.grey, width: 0.5);
    graphics.drawLine(gridPen, Offset(currentX, yOffset), Offset(currentX, rowY + rowHeight));
    for (var width in columnWidths) {
      currentX += width;
      graphics.drawLine(gridPen, Offset(currentX, yOffset), Offset(currentX, rowY + rowHeight));
    }
    // Horizontal bottom line
    graphics.drawLine(gridPen, Offset(theme.margin, rowY + rowHeight), Offset(theme.pageWidth - theme.margin, rowY + rowHeight));
  }
}
