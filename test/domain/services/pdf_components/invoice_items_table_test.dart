import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/pdf_components/invoice_items_table.dart';
import 'package:elada/domain/services/invoice_theme.dart';

import 'decoration_component_test.mocks.dart';

void main() {
  late MockPdfGraphics mockGraphics;
  late InvoiceTheme theme;
  late InvoiceItemsTable component;

  setUp(() {
    mockGraphics = MockPdfGraphics();
    theme = InvoiceTheme();
    component = InvoiceItemsTable(theme);
  });

  group('InvoiceItemsTable', () {
    test('draw should call drawing methods for headers and at least one row', () {
      component.draw(
        graphics: mockGraphics,
        description: 'Test Item',
        total: 100.0,
        currency: '\$',
      );

      // Verify header background (accent blue)
      verify(
        mockGraphics.drawRectangle(
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
        ),
      ).called(greaterThanOrEqualTo(1));

      // Verify "DESCRIPTION" and "TOTAL" column headers
      verify(
        mockGraphics.drawString(
          argThat(contains('DESCRIPTION')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      verify(
        mockGraphics.drawString(
          argThat(contains('TOTAL')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      // Verify currency inside the box, left aligned
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

      // Verify amount inside the box, right aligned
      // It's called twice: once for UNIT PRICE and once for TOTAL in the first row
      verify(
        mockGraphics.drawString(
          argThat(equals('100.00')),
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
      ).called(2);
    });
  });
}
