import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  group('InvoiceTheme', () {
    test('should have correct default branding constants', () {
      final theme = InvoiceTheme();
      // Brand Blue: 0xFF005696 -> (0, 86, 150)
      expect(theme.brandBlue.r, equals(0));
      expect(theme.brandBlue.g, equals(86));
      expect(theme.brandBlue.b, equals(150));

      // Accent Blue: 0xFFE1F5FE -> (225, 245, 254)
      expect(theme.accentBlue.r, equals(225));
      expect(theme.accentBlue.g, equals(245));
      expect(theme.accentBlue.b, equals(254));
    });

    test('should provide correct fonts', () {
      final theme = InvoiceTheme();
      expect(theme.defaultFont, isA<PdfFont>());
      expect(theme.boldFont, isA<PdfFont>());
      expect(theme.defaultFontSize, equals(9.0));
    });

    test('should have correct page dimensions', () {
      final theme = InvoiceTheme();
      expect(theme.margin, equals(40.0));
      expect(theme.contentWidth, equals(595.275590551181 - (2 * 40.0)));
    });
  });
}
