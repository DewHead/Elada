import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

/// Component responsible for drawing the invoice header.
class InvoiceHeader {
  final InvoiceTheme theme;

  InvoiceHeader(this.theme);

  /// Draws the header section on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    required String invoiceNumber,
    required DateTime date,
    bool loadAndFill = false,
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush brandBrush = PdfSolidBrush(theme.brandBlue);
    final PdfBrush lightGreyBrush = PdfSolidBrush(theme.lightGrey);
    final PdfPen thinGreyPen = PdfPen(theme.borderGrey, width: 0.5);

    final double effectiveMargin = loadAndFill
        ? theme.margin + 30
        : theme.margin;

    if (!loadAndFill) {
      double currentY = 75;

      // 1. "INVOICE" Title - Very Large, Light Grey
      final titleFont = theme.boldFontData != null
          ? PdfTrueTypeFont(theme.boldFontData!, 28)
          : PdfStandardFont(
              PdfFontFamily.helvetica,
              28,
              style: PdfFontStyle.bold,
            );

      graphics.drawString(
        'INVOICE',
        titleFont,
        brush: lightGreyBrush,
        bounds: Rect.fromLTWH(theme.margin, currentY, 200, 40),
      );

      // 2. "ב\"ה" - Top Right
      graphics.drawString(
        'ב"ה',
        theme.defaultFont,
        brush: brush,
        bounds: Rect.fromLTWH(
          theme.pageWidth - theme.margin - 40,
          currentY + 15,
          40,
          20,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      currentY += 85;

      // 3. Company Name & Info
      graphics.drawString(
        'YONIK KOSHER',
        theme.titleFont,
        brush: brandBrush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 22),
      );
      currentY += 22;

      graphics.drawString(
        'LIFESTYLE LTD',
        theme.titleFont,
        brush: brandBrush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 22),
      );
      currentY += 25;

      graphics.drawString(
        'DIMOKRATIAS 36 TALA',
        theme.defaultFont,
        brush: brush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 14),
      );
      currentY += 14;

      graphics.drawString(
        'PAPHOS 8577 CYPRUS',
        theme.defaultFont,
        brush: brush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 14),
      );
      currentY += 14;

      graphics.drawString(
        '+357-22009-770',
        theme.boldFont,
        brush: brush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 14),
      );
      currentY += 14;

      graphics.drawString(
        'www.yonik.style',
        theme.boldFont,
        brush: brush,
        bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 14),
      );
    }

    // 4. Date and Invoice No block on the right
    final double rightBlockX = theme.pageWidth - effectiveMargin - 110 - 17;
    final double rightBlockWidth = 110;

    // Calibrated for Template lines
    double blockY = (loadAndFill ? 210 : 190) - 60;

    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    // Date Text
    graphics.drawString(
      formattedDate,
      theme.boldFont,
      brush: brush,
      bounds: Rect.fromLTWH(rightBlockX - 1, blockY, rightBlockWidth, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    if (!loadAndFill) {
      blockY += 18;
      // Thin line under Date
      graphics.drawLine(
        thinGreyPen,
        Offset(rightBlockX + 10, blockY),
        Offset(rightBlockX + rightBlockWidth - 10, blockY),
      );
      blockY += 35;

      // INVOICE NO. Label (Blue)
      graphics.drawString(
        'INVOICE NO.',
        theme.boldFont,
        brush: brandBrush,
        bounds: Rect.fromLTWH(rightBlockX, blockY, rightBlockWidth, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      blockY += 16;
    } else {
      blockY = 208; // Calibrated for Invoice Number position in template
    }

    // Actual Invoice Number
    graphics.drawString(
      invoiceNumber,
      theme.boldFont,
      brush: brush,
      bounds: Rect.fromLTWH(
        loadAndFill ? rightBlockX - 2 : rightBlockX,
        blockY,
        rightBlockWidth,
        15,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    if (!loadAndFill) {
      blockY += 18;
      // Thin line under Invoice Number
      graphics.drawLine(
        thinGreyPen,
        Offset(rightBlockX + 10, blockY),
        Offset(rightBlockX + rightBlockWidth - 10, blockY),
      );
    }
  }
}
