import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/domain/services/pdf_components/invoice_customer_info.dart';
import 'package:elada/domain/services/invoice_theme.dart';

import 'decoration_component_test.mocks.dart';

void main() {
  late MockPdfGraphics mockGraphics;
  late InvoiceTheme theme;
  late InvoiceCustomerInfo component;

  setUp(() {
    mockGraphics = MockPdfGraphics();
    theme = InvoiceTheme();
    component = InvoiceCustomerInfo(theme);
  });

  group('InvoiceCustomerInfo', () {
    test('draw should not draw anything if Ship To is removed', () {
      component.draw(graphics: mockGraphics);

      // Verify no drawString is called (since we removed Ship To)
      verifyNever(
        mockGraphics.drawString(
          any,
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      );
    });
  });
}
