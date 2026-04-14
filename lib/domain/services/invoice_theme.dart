import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Defines the visual theme and branding constants for the invoice.
class InvoiceTheme {
  final Uint8List? fontData;
  final Uint8List? boldFontData;

  PdfFont? _cachedDefaultFont;
  PdfFont? _cachedBoldFont;
  PdfFont? _cachedSmallFont;
  PdfFont? _cachedTitleFont;

  InvoiceTheme({this.fontData, this.boldFontData});

  // Colors
  PdfColor get brandBlue => PdfColor(74, 126, 192); // #4A7EC0
  PdfColor get accentBlue => PdfColor(225, 245, 254);
  PdfColor get black => PdfColor(0, 0, 0);
  PdfColor get white => PdfColor(255, 255, 255);
  PdfColor get grey => PdfColor(128, 128, 128);
  PdfColor get lightGrey => PdfColor(160, 164, 168); // For "INVOICE" title
  PdfColor get borderGrey => PdfColor(200, 200, 200); // For table grid

  // Fonts
  PdfFont get defaultFont {
    if (_cachedDefaultFont != null) return _cachedDefaultFont!;
    _cachedDefaultFont = fontData != null
        ? PdfTrueTypeFont(fontData!, 9)
        : PdfStandardFont(PdfFontFamily.helvetica, 9);
    return _cachedDefaultFont!;
  }

  PdfFont get boldFont {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    if (boldFontData != null) {
      _cachedBoldFont = PdfTrueTypeFont(boldFontData!, 9);
    } else {
      _cachedBoldFont = fontData != null
          ? PdfTrueTypeFont(fontData!, 9, style: PdfFontStyle.bold)
          : PdfStandardFont(
              PdfFontFamily.helvetica,
              9,
              style: PdfFontStyle.bold,
            );
    }
    return _cachedBoldFont!;
  }

  PdfFont get smallFont {
    if (_cachedSmallFont != null) return _cachedSmallFont!;
    _cachedSmallFont = fontData != null
        ? PdfTrueTypeFont(fontData!, 8)
        : PdfStandardFont(PdfFontFamily.helvetica, 8);
    return _cachedSmallFont!;
  }

  PdfFont get titleFont {
    if (_cachedTitleFont != null) return _cachedTitleFont!;
    if (boldFontData != null) {
      _cachedTitleFont = PdfTrueTypeFont(boldFontData!, 18);
    } else {
      _cachedTitleFont = fontData != null
          ? PdfTrueTypeFont(fontData!, 18, style: PdfFontStyle.bold)
          : PdfStandardFont(
              PdfFontFamily.helvetica,
              18,
              style: PdfFontStyle.bold,
            );
    }
    return _cachedTitleFont!;
  }

  /// Returns a [PdfFont] with the specified [size] and [isBold] style.
  PdfFont getFont(double size, {bool isBold = false}) {
    if (isBold) {
      if (boldFontData != null) {
        return PdfTrueTypeFont(boldFontData!, size);
      } else {
        return fontData != null
            ? PdfTrueTypeFont(fontData!, size, style: PdfFontStyle.bold)
            : PdfStandardFont(
                PdfFontFamily.helvetica,
                size,
                style: PdfFontStyle.bold,
              );
      }
    } else {
      return fontData != null
          ? PdfTrueTypeFont(fontData!, size)
          : PdfStandardFont(PdfFontFamily.helvetica, size);
    }
  }

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
