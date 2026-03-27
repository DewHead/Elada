import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Defines the visual theme and branding constants for the invoice.
class InvoiceTheme {
  // Colors
  final PdfColor brandBlue = PdfColor(0, 86, 150);
  final PdfColor accentBlue = PdfColor(225, 245, 254);
  final PdfColor black = PdfColor(0, 0, 0);
  final PdfColor white = PdfColor(255, 255, 255);
  final PdfColor grey = PdfColor(128, 128, 128);

  // Fonts
  final PdfFont defaultFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
  final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
  final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
  final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);

  // Font Sizes
  final double defaultFontSize = 9.0;
  final double smallFontSize = 8.0;
  final double titleFontSize = 18.0;

  // Page Dimensions (A4 at 72dpi: 595.27 x 841.89 points)
  final double pageWidth = 595.275590551181;
  final double pageHeight = 841.889763779528;
  final double margin = 40.0;

  double get contentWidth => pageWidth - (2 * margin);
}
