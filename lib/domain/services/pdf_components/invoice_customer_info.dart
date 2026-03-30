import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/invoice_theme.dart';

/// Component responsible for drawing the customer information.
class InvoiceCustomerInfo {
  final InvoiceTheme theme;

  InvoiceCustomerInfo(this.theme);

  /// Draws the customer info section on the provided [graphics].
  void draw({
    required PdfGraphics graphics,
    double yOffset = 360,
    bool loadAndFill = false,
  }) {
    // Component is empty because Bill To and Ship To fields are removed.
  }
}
