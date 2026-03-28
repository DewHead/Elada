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
  }) {
    final PdfBrush brush = PdfSolidBrush(theme.black);
    final PdfBrush brandBrush = PdfSolidBrush(theme.brandBlue);

    // 1. "ב\"ה" - Top Right (Reversed for correct visual display in LTR)
    graphics.drawString(
      'ה"ב',
      theme.defaultFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.pageWidth - 60, 50, 40, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    double currentY = 70;

    // 5. "INVOICE" Label
    final titleLabelFont = theme.boldFontData != null
        ? PdfTrueTypeFont(theme.boldFontData!, 24)
        : PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);

    graphics.drawString(
      'INVOICE',
      titleLabelFont,
      brush: PdfSolidBrush(theme.grey),
      bounds: Rect.fromLTWH(theme.margin, currentY, 200, 40),
    );
    currentY += 45;

    // 2. Company Name - Top Left
    graphics.drawString(
      'YONIK KOSHER',
      theme.titleFont,
      brush: brandBrush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 25),
    );
    currentY += 22;

    graphics.drawString(
      'LIFESTYLE LTD',
      theme.titleFont,
      brush: brandBrush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 25),
    );
    currentY += 28;

    // 3. Company Address
    graphics.drawString(
      'DIMOKRATIAS 36 TALA',
      theme.defaultFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 15),
    );
    currentY += 14;

    graphics.drawString(
      'PAPHOS 8577 CYPRUS',
      theme.defaultFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 15),
    );
    currentY += 14;

    // 4. Contact Details
    graphics.drawString(
      '+357-22009-770',
      theme.boldFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 15),
    );
    currentY += 14;

    graphics.drawString(
      'www.yonik.style',
      theme.boldFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, currentY, theme.contentWidth, 15),
    );

    // 6. Date and Invoice Number (Using adjusted coordinates)
    final labelFont = theme.boldFont;
    final valueFont = theme.defaultFont;
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    // Date Label & Value
    graphics.drawString(
      'Date:',
      labelFont,
      brush: brush,
      bounds: const Rect.fromLTWH(380, 155, 50, 20),
    );
    graphics.drawString(
      formattedDate,
      valueFont,
      brush: brush,
      bounds: const Rect.fromLTWH(427, 155, 100, 20),
    );

    // Invoice No Label & Value
    graphics.drawString(
      'Invoice No:',
      labelFont,
      brush: brush,
      bounds: const Rect.fromLTWH(380, 205, 60, 20),
    );
    graphics.drawString(
      invoiceNumber,
      valueFont,
      brush: brush,
      bounds: const Rect.fromLTWH(440, 205, 100, 20),
    );

    // Horizontal Separator after header
    graphics.drawLine(
      PdfPen(theme.brandBlue, width: 2),
      Offset(theme.margin, 250),
      Offset(theme.pageWidth - theme.margin, 250),
    );
  }
}
