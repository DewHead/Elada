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
        // DESCRIPTION header needs extra width offset to stay within its column
        final double headerWidth = i == 0 ? 200.0 : columnWidths[i] - 10;
        
        graphics.drawString(
          headers[i],
          headerFont,
          brush: headerTextBrush,
          bounds: Rect.fromLTWH(
            currentX + (i == 3 ? -75 : (i == 0 ? 56 : 5)),
            startY + (i == 0 ? -105 : (i == 3 ? -75 : 5)),
            headerWidth,
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

      double currentHeight = (i == 0 && !loadAndFill) ? 194.0 : rowHeight;

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
        actualRowHeight: currentHeight,
        loadAndFill: loadAndFill,
        effectiveMargin: effectiveMargin,
      );
      currentRowY += currentHeight;
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
    // Use conservative padding and absolute column boundaries to prevent overflow.
    const double horizontalPadding = 10.0;
    const double verticalPadding = 5.0;
    
    // The description starts at effectiveMargin, but we apply a 56pt indent for this specific layout.
    final double textLeft = effectiveMargin + 56 + horizontalPadding;
    // Ensure the text width is constrained by the actual column width and set to 200pt.
    final double colRightEdge = effectiveMargin + columnWidths[0];
    final double maxPossibleWidth = colRightEdge - textLeft - horizontalPadding;
    final double availableWidth = maxPossibleWidth > 200.0 ? 200.0 : maxPossibleWidth;
    
    // Use a larger height constraint for the first row to prevent premature font shrinking,
    // especially in template mode where the standard row height is small.
    final double availableHeight = isFirstRow 
        ? 65.0 
        : (actualRowHeight - (verticalPadding * 2));

    final Rect descriptionBounds = Rect.fromLTWH(
      textLeft,
      y - 99 + verticalPadding, 
      availableWidth,
      availableHeight,
    );

    double currentFontSize = isFirstRow ? 40.0 : theme.defaultFontSize;
    PdfFont currentFont = theme.getFont(currentFontSize, isBold: isFirstRow);

    if (description.isNotEmpty) {
      // Scale down font size only if the text truly doesn't fit the box.
      // This allows it to "enlarge" if we start from a larger size.
      while (currentFontSize > 4.0) {
        final Size measuredSize = currentFont.measureString(
          description,
          layoutArea: Size(descriptionBounds.width, 0),
          format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
        );

        if (measuredSize.height <= descriptionBounds.height) {
          break;
        }

        currentFontSize -= 0.5;
        currentFont = theme.getFont(currentFontSize, isBold: isFirstRow);
      }
    }

    graphics.drawString(
      description,
      currentFont,
      brush: brush,
      bounds: descriptionBounds,
      format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
    );

    // QTY Column
    if (!loadAndFill) {
      graphics.drawString(
        qty,
        dataFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          effectiveMargin + columnWidths[0],
          y + 11, // Maintain original alignment: y + (32 - 10) / 2
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
          y + 11, // Maintain original alignment: y + (32 - 10) / 2
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
            y - 69, // Maintain original alignment: y + (32 - 10) / 2 - 80
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
          y - 69, // Maintain original alignment: y + (32 - 10) / 2 - 80
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
          y - 69, // Maintain original alignment: y + (32 - 10) / 2 - 80
          columnWidths[3] - 10,
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }
  }
}
