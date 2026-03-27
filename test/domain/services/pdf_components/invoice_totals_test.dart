import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
    test('draw should call drawString for Subtotal, VAT, and Balance Due', () {
      component.draw(
        graphics: mockGraphics,
        subtotal: 100.0,
        vat: 20.0,
        total: 120.0,
        currency: '€',
      );

      // Verify labels are drawn
      verify(
        mockGraphics.drawString(
          argThat(contains('Subtotal')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      verify(
        mockGraphics.drawString(
          argThat(contains('VAT')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      verify(
        mockGraphics.drawString(
          argThat(contains('Balance Due')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);
    });
  });
}
