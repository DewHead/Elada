import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/pdf_components/invoice_totals.dart';
import 'package:elada/domain/services/invoice_theme.dart';

import 'decoration_component_test.mocks.dart';

void main() {
  late MockPdfGraphics mockGraphics;
  late InvoiceTheme theme;
  late InvoiceTotals component;

  setUp(() {
    mockGraphics = MockPdfGraphics();
    theme = InvoiceTheme();
    component = InvoiceTotals(theme);
  });

  group('InvoiceTotals', () {
    test('draw should call drawString for VAT and total value', () {
      component.draw(
        graphics: mockGraphics,
        subtotal: 100.0,
        vat: 20.0,
        total: 120.0,
        currency: '\$',
      );

      // Verify labels are drawn
      verify(
        mockGraphics.drawString(
          argThat(equals('TOTAL vat')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      // Verify currency drawn (for total value)
      verify(
        mockGraphics.drawString(
          argThat(equals('\$')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: argThat(
            predicate(
              (PdfStringFormat format) =>
                  format.alignment == PdfTextAlignment.left,
            ),
            named: 'format',
          ),
        ),
      ).called(1);

      // Verify amount drawn (for total value)
      verify(
        mockGraphics.drawString(
          argThat(equals('120.00')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: argThat(
            predicate(
              (PdfStringFormat format) =>
                  format.alignment == PdfTextAlignment.right,
            ),
            named: 'format',
          ),
        ),
      ).called(1);

      // Ensure "Balance Due" label is NOT drawn
      verifyNever(
        mockGraphics.drawString(
          argThat(contains('Balance')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      );

      // Ensure rectangle (box) is NOT drawn
      verifyNever(
        mockGraphics.drawRectangle(
          pen: anyNamed('pen'),
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
        ),
      );
    });
  });
}
