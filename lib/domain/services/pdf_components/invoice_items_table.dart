import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:elada/data/models/invoice_item.dart';

/// Component responsible for drawing the items table.
class InvoiceItemsTable {
  final InvoiceTheme theme;

  InvoiceItemsTable(this.theme);

  /// Draws the items table on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    required String description,
    required double total,
    List<InvoiceItem> items = const [],
    String currency = '€',
    double yOffset = 460,
    bool loadAndFill = false,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush headerBrush = PdfSolidBrush(theme.brandBlue);
    final PdfBrush headerTextBrush = PdfSolidBrush(theme.white);
    final PdfFont headerFont = theme.boldFont;
    final PdfFont dataFont = theme.defaultFont;
    final PdfPen gridPen = PdfPen(theme.borderGrey, width: 0.5);

    const double headerHeight = 22;
    // Use consistent margins and widths
    final double rowHeight = loadAndFill ? 31.0 : 32;
    final double startY = loadAndFill ? 508 : yOffset;
    final double effectiveMargin = theme.margin;
    final double effectiveContentWidth = theme.contentWidth;

    final List<double> columnWidths = [
      effectiveContentWidth * 0.58, // DESCRIPTION
      effectiveContentWidth * 0.12, // QTY
      effectiveContentWidth * 0.15, // UNIT PRICE
      effectiveContentWidth * 0.15, // TOTAL
    ];

    if (!loadAndFill) {
      // 1. Draw Table Header
      graphics.drawRectangle(
        brush: headerBrush,
        bounds: Rect.fromLTWH(
          theme.margin,
          startY,
          theme.contentWidth,
          headerHeight,
        ),
      );

      final List<String> headers = [
        'DESCRIPTION',
        'QTY',
        'UNIT PRICE',
        'TOTAL',
      ];
      double currentX = theme.margin;
      for (int i = 0; i < headers.length; i++) {
        graphics.drawString(
          headers[i],
          headerFont,
          brush: headerTextBrush,
          bounds: Rect.fromLTWH(
            currentX + (i == 3 ? -75 : (i == 0 ? 68 : 5)),
            startY + (i == 0 ? -96 : (i == 3 ? -75 : 5)),
            columnWidths[i] - 10,
            headerHeight - 10,
          ),
          format: i > 0
              ? PdfStringFormat(alignment: PdfTextAlignment.center)
              : null,
        );

        // Vertical white separator lines in header
        if (i < headers.length - 1) {
          graphics.drawLine(
            PdfPen(theme.white, width: 0.8),
            Offset(currentX + columnWidths[i], startY),
            Offset(currentX + columnWidths[i], startY + headerHeight),
          );
        }
        currentX += columnWidths[i];
      }
    }

    // 2. Draw 4 Data Rows
    double currentRowY = loadAndFill ? startY : startY + headerHeight;

    final formatter = NumberFormat('#,##0.00', 'en_US');

    for (int i = 0; i < 4; i++) {
      String desc = '';
      String qty = '';
      String priceVal = '';
      String totalVal = '';

      if (i == 0) {
        desc = description;
        qty = '1';
        priceVal = formatter.format(total);
        totalVal = currency;
      } else {
        desc = '';
        qty = '';
        priceVal = '';
        totalVal = '0.00';
      }

      _drawGridRow(
        graphics: graphics,
        description: desc,
        qty: qty,
        unitPrice: priceVal,
        rowTotal: totalVal,
        totalAmount: i == 0 ? formatter.format(total) : null,
        currency: currency,
        y: currentRowY,
        columnWidths: columnWidths,
        dataFont: dataFont,
        brush: brush,
        gridPen: gridPen,
        isFirstRow: i == 0,
        actualRowHeight: rowHeight,
        loadAndFill: loadAndFill,
        effectiveMargin: effectiveMargin,
      );
      currentRowY += rowHeight;
    }
  }

  void _drawGridRow({
    required PdfGraphics graphics,
    required String description,
    required String qty,
    required String unitPrice,
    required String rowTotal,
    String? totalAmount,
    String currency = '€',
    required double y,
    required List<double> columnWidths,
    required PdfFont dataFont,
    required PdfBrush brush,
    required PdfPen gridPen,
    required bool isFirstRow,
    required double actualRowHeight,
    bool loadAndFill = false,
    required double effectiveMargin,
  }) {
    if (!loadAndFill) {
      // Draw row outer rectangle
      graphics.drawRectangle(
        pen: gridPen,
        bounds: Rect.fromLTWH(
          theme.margin,
          y,
          theme.contentWidth,
          actualRowHeight,
        ),
      );

      // Vertical grid lines
      double x = theme.margin;
      for (int i = 0; i < columnWidths.length - 1; i++) {
        x += columnWidths[i];
        graphics.drawLine(
          gridPen,
          Offset(x, y),
          Offset(x, y + actualRowHeight),
        );
      }
    }

    // Description Column
    final wrappedDescription = _wrapText(description, 42);
    graphics.drawString(
      wrappedDescription,
      isFirstRow ? theme.boldFont : dataFont,
      brush: brush,
      bounds: Rect.fromLTWH(
        effectiveMargin + 68,
        y + (actualRowHeight - 212) / 2,
        columnWidths[0] - 10,
        30, // Increased height for wrapped text
      ),
    );

    // QTY Column
    if (!loadAndFill) {
      graphics.drawString(
        qty,
        dataFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          effectiveMargin + columnWidths[0],
          y + (actualRowHeight - 10) / 2,
          columnWidths[1],
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }

    // UNIT PRICE Column
    if (!loadAndFill) {
      graphics.drawString(
        unitPrice,
        dataFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          effectiveMargin + columnWidths[0] + columnWidths[1] + 5,
          y + (actualRowHeight - 10) / 2,
          columnWidths[2] - 10,
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }

    // TOTAL Column
    final double totalX =
        effectiveMargin + columnWidths[0] + columnWidths[1] + columnWidths[2];

    if (isFirstRow && totalAmount != null) {
      // Draw Currency on the left of the cell - only if not Euro
      if (currency != '€') {
        graphics.drawString(
          currency,
          theme.boldFont,
          brush: brush,
          bounds: Rect.fromLTWH(
            totalX - 75,
            y + (actualRowHeight - 10) / 2 - 80,
            columnWidths[3] - 10,
            15,
          ),
          format: PdfStringFormat(alignment: PdfTextAlignment.left),
        );
      }

      // Draw Amount on the right of the cell
      String displayText = totalAmount;
      graphics.drawString(
        displayText,
        theme.boldFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          totalX - 75,
          y + (actualRowHeight - 10) / 2 - 80,
          columnWidths[3] - 10,
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    } else if (!loadAndFill) {
      // "0.00" in rows 2-4, right-aligned
      graphics.drawString(
        rowTotal,
        dataFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          totalX - 75,
          y + (actualRowHeight - 10) / 2 - 80,
          columnWidths[3] - 10,
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }
  }

  String _wrapText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    final List<String> words = text.split(' ');
    final StringBuffer buffer = StringBuffer();
    String currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= maxLength) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) {
          buffer.writeln(currentLine);
        }
        currentLine = word;
      }
    }
    buffer.write(currentLine);
    return buffer.toString();
  }
}
