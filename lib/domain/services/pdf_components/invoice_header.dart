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

    // 1. "B\"H" - Top Right (Latin characters to avoid font issues)
    graphics.drawString(
      'B"H',
      theme.defaultFont,
      brush: brush,
      bounds: Rect.fromLTWH(theme.pageWidth - 60, 50, 40, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    // 2. Company Name / Logo - Top Left
    graphics.drawString(
      'YONIK KOSHER LIFESTYLE LTD',
      theme.titleFont,
      brush: brandBrush,
      bounds: Rect.fromLTWH(theme.margin, 60, theme.contentWidth, 30),
    );

    // 3. Company Address (Minimalist Placeholder based on typical invoice headers)
    final addressFont = theme.smallFont;
    graphics.drawString(
      '27 Old Gloucester Street, London, WC1N 3AX\nEmail: info@yonik.co.uk | Phone: +44 20 1234 5678',
      addressFont,
      brush: PdfSolidBrush(theme.grey),
      bounds: Rect.fromLTWH(theme.margin, 95, theme.contentWidth, 30),
    );

    // 4. "INVOICE" Label
    graphics.drawString(
      'INVOICE',
      PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold),
      brush: brush,
      bounds: Rect.fromLTWH(theme.margin, 150, 200, 40),
    );

    // 5. Date and Invoice Number (Using approximate coordinates from template research)
    final labelFont = theme.boldFont;
    final valueFont = theme.defaultFont;
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    // Date Label & Value
    graphics.drawString('Date:', labelFont, brush: brush, bounds: const Rect.fromLTWH(380, 139, 50, 20));
    graphics.drawString(formattedDate, valueFont, brush: brush, bounds: const Rect.fromLTWH(427, 139, 100, 20));

    // Invoice No Label & Value
    graphics.drawString('Invoice No:', labelFont, brush: brush, bounds: const Rect.fromLTWH(380, 210, 60, 20));
    graphics.drawString(invoiceNumber, valueFont, brush: brush, bounds: const Rect.fromLTWH(440, 210, 100, 20));
    
    // Horizontal Separator after header
    graphics.drawLine(
      PdfPen(theme.brandBlue, width: 2),
      Offset(theme.margin, 250),
      Offset(theme.pageWidth - theme.margin, 250),
    );
  }
}
