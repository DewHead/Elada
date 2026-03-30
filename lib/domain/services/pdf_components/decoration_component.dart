import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

/// Component responsible for drawing the blue bars and other decorative elements.
class DecorationComponent {
  final InvoiceTheme theme;

  DecorationComponent(this.theme);

  /// Draws the blue brand bar at the top of the page.
  void drawHeaderBar(PdfGraphics graphics) {
    final double x = theme.margin;
    final double width = theme.contentWidth;
    const double height = 15;
    const double y = 0; // Exactly at the top edge within horizontal margins

    graphics.drawRectangle(
      brush: PdfSolidBrush(theme.brandBlue),
      bounds: Rect.fromLTWH(x, y, width, height),
    );
  }

  /// Draws the blue brand bar at the bottom of the page.
  void drawFooterBar(PdfGraphics graphics) {
    final double x = theme.margin;
    final double width = theme.contentWidth;
    const double height = 15;
    final double y = theme.pageHeight - height; // Exactly at the bottom edge

    graphics.drawRectangle(
      brush: PdfSolidBrush(theme.brandBlue),
      bounds: Rect.fromLTWH(x, y, width, height),
    );
  }
}
