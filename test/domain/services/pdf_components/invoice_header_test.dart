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

      // 1. "ב\"ה" (Expect reversed for LTR rendering)
      verify(
        mockGraphics.drawString(
          'ה"ב',
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);

      // 2. Company Name
      verify(
        mockGraphics.drawString(
          argThat(contains('YONIK KOSHER')),
          any,
          brush: anyNamed('brush'),
          bounds: anyNamed('bounds'),
          format: anyNamed('format'),
        ),
      ).called(1);
    });
  });
}
