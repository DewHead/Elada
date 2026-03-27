import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/pdf_components/invoice_items_table.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'dart:ui';

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
        currency: '€',
      );

      // Verify header background (accent blue)
      verify(mockGraphics.drawRectangle(
        brush: anyNamed('brush'),
        bounds: anyNamed('bounds'),
      )).called(greaterThanOrEqualTo(1));

      // Verify "Description" and "Total" column headers
      verify(mockGraphics.drawString(
        argThat(contains('Description')),
        any,
        brush: anyNamed('brush'),
        bounds: anyNamed('bounds'),
        format: anyNamed('format'),
      )).called(1);

      verify(mockGraphics.drawString(
        argThat(contains('Total')),
        any,
        brush: anyNamed('brush'),
        bounds: anyNamed('bounds'),
        format: anyNamed('format'),
      )).called(1);
    });
  });
}
