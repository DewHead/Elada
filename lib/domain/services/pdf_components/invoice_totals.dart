import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

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
    double yOffset = 620,
    bool loadAndFill = false,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfFont labelFont = theme.boldFontData != null
        ? PdfTrueTypeFont(theme.boldFontData!, 9)
        : PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    final PdfPen gridPen = PdfPen(theme.borderGrey, width: 0.5);

    final formatter = NumberFormat('#,##0.00', 'en_US');

    // Align with the last two columns of the items table
    final double tableContentWidth = theme.contentWidth;
    final double totalColumnWidth = tableContentWidth * 0.15;
    final double unitPriceColumnWidth = tableContentWidth * 0.15;

    final double effectiveMargin = theme.margin;
    final double blockWidth = unitPriceColumnWidth + totalColumnWidth;
    final double blockX = theme.pageWidth - effectiveMargin - blockWidth;

    final double labelWidth = unitPriceColumnWidth;
    final double valueWidth = totalColumnWidth;

    double currentY = loadAndFill ? 675 : yOffset;
    // Spacing for template alignment
    final double rowHeight = loadAndFill ? 15.5 : 16;

    final rightFormat = PdfStringFormat(alignment: PdfTextAlignment.right);

    void drawTotalRow(String label, String value, {bool isMultiLine = false}) {
      double actualRowHeight = isMultiLine ? rowHeight * 1.7 : rowHeight;

      if (!loadAndFill) {
        // Label in unit price column
        graphics.drawString(
          label,
          labelFont,
          brush: brush,
          bounds: Rect.fromLTWH(
            blockX,
            currentY + (actualRowHeight - rowHeight) / 2,
            labelWidth - 8,
            actualRowHeight,
          ),
          format: rightFormat,
        );
      }

      // Value in total column
      bool isStaticZeroField =
          label == 'DISCOUNT' ||
          label == 'Vat RATE' ||
          label == 'TOTAL vat' ||
          label.startsWith('SHIPPING');
      bool shouldDrawValue = !loadAndFill || !isStaticZeroField;

      if (shouldDrawValue) {
        graphics.drawString(
          value,
          theme.defaultFont,
          brush: brush,
          bounds: Rect.fromLTWH(
            blockX + labelWidth,
            currentY + (actualRowHeight - rowHeight) / 2,
            valueWidth - 5,
            actualRowHeight,
          ),
          format: rightFormat,
        );
      }

      currentY += actualRowHeight;
      if (!loadAndFill) {
        // Line under row
        graphics.drawLine(
          gridPen,
          Offset(blockX, currentY),
          Offset(theme.pageWidth - theme.margin, currentY),
        );
      }
    }

    // 1. SUBTOTAL removed

    // 2. DISCOUNT
    drawTotalRow('DISCOUNT', '0.00');

    // 3. SUBTOTAL LESS DISCOUNT removed

    // 4. Vat RATE
    drawTotalRow('Vat RATE', '0.00%');

    // 5. TOTAL vat
    drawTotalRow('TOTAL vat', '0');

    // 6. SHIPPING/HANDLING
    drawTotalRow('SHIPPING/HA\nNDLING', '0.00', isMultiLine: true);

    // 7. Total Value - without "Balance Due" label and box
    currentY += 44; // Move down 44px (adjusted from 42px)

    final String amountStr = formatter.format(total);
    final PdfFont balanceValueFont = theme.boldFontData != null
        ? PdfTrueTypeFont(theme.boldFontData!, 12)
        : PdfStandardFont(
            PdfFontFamily.helvetica,
            12,
            style: PdfFontStyle.bold,
          );

    // Thick black line before Total Value
    if (!loadAndFill) {
      graphics.drawLine(
        PdfPen(theme.black, width: 2.0),
        Offset(blockX - 10, currentY + 10),
        Offset(theme.pageWidth - theme.margin, currentY + 10),
      );
    }

    currentY = loadAndFill ? currentY + 22 : currentY + 25;

    // Position adjustments to match original layout but without the box
    final double valueX = blockX + labelWidth;
    final double valueY = loadAndFill ? currentY - 2 : currentY - 5;
    final double boxHeight = loadAndFill ? 32 : 35;

    // Currency on the left - only if not Euro
    if (currency != '€') {
      graphics.drawString(
        currency,
        balanceValueFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          valueX - 60,
          valueY + (boxHeight - 20) / 2 + 1 - 135,
          valueWidth - 10,
          25,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
    }

    // Amount on the right
    graphics.drawString(
      amountStr,
      balanceValueFont,
      brush: brush,
      bounds: Rect.fromLTWH(
        valueX - 60,
        valueY + (boxHeight - 20) / 2 + 1 - 135,
        valueWidth - 10,
        25,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }
}
