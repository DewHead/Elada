import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/pdf_components/invoice_customer_info.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

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
    test('draw should call drawString for Bill To and Ship To headers', () {
      component.draw(
        graphics: mockGraphics,
        billTo: 'John Doe\n123 Street\nLondon',
        shipTo: 'Jane Doe\n456 Road\nParis',
      );

      // Verify "Bill To" and "Ship To" labels are drawn
      verify(mockGraphics.drawString(
        argThat(contains('Bill To')),
        any,
        brush: anyNamed('brush'),
        bounds: anyNamed('bounds'),
      )).called(1);

      verify(mockGraphics.drawString(
        argThat(contains('Ship To')),
        any,
        brush: anyNamed('brush'),
        bounds: anyNamed('bounds'),
      )).called(1);
    });
  });
}
