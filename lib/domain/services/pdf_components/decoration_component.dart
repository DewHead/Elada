import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

/// Component responsible for drawing the blue bars and other decorative elements.
class DecorationComponent {
  final InvoiceTheme theme;

  DecorationComponent(this.theme);

  /// Draws the blue brand bar at the top of the page.
  void drawHeaderBar(PdfGraphics graphics) {
    graphics.drawRectangle(
      brush: PdfSolidBrush(theme.brandBlue),
      bounds: Rect.fromLTWH(0, 0, theme.pageWidth, 45),
    );
  }

  /// Draws the blue brand bar at the bottom of the page.
  void drawFooterBar(PdfGraphics graphics) {
    graphics.drawRectangle(
      brush: PdfSolidBrush(theme.brandBlue),
      bounds: Rect.fromLTWH(0, theme.pageHeight - 25, theme.pageWidth, 25),
    );
  }
}
