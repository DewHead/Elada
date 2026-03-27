import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/domain/services/pdf_components/invoice_header.dart';
import 'package:elada/domain/services/invoice_theme.dart';

import 'decoration_component_test.mocks.dart';

void main() {
  late MockPdfGraphics mockGraphics;
  late InvoiceTheme theme;
  late InvoiceHeader component;

  setUp(() {
    mockGraphics = MockPdfGraphics();
    theme = InvoiceTheme();
    component = InvoiceHeader(theme);
  });

  group('InvoiceHeader', () {
    test('draw should call drawString for key header elements', () {
      component.draw(
        graphics: mockGraphics,
        invoiceNumber: '9417',
        date: DateTime(2026, 3, 25),
      );

      // Verify at least these are called:
      // 1. Company Name
      // 2. "ב\"ה"
      // 3. "INVOICE"
      // 4. Date
      // 5. Invoice Number

      verify(
        mockGraphics.drawString(
          any,
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(greaterThanOrEqualTo(5));
    });
  });
}
