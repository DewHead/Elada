import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:elada/domain/services/pdf_components/decoration_component.dart';
import 'package:elada/domain/services/invoice_theme.dart';

import 'decoration_component_test.mocks.dart';

@GenerateMocks([PdfGraphics])
void main() {
  late MockPdfGraphics mockGraphics;
  late InvoiceTheme theme;
  late DecorationComponent component;

  setUp(() {
    mockGraphics = MockPdfGraphics();
    theme = InvoiceTheme();
    component = DecorationComponent(theme);
  });

  group('DecorationComponent', () {
    test(
      'drawHeaderBar should call drawRectangle with correct bounds and color',
      () {
        component.drawHeaderBar(mockGraphics);

        verify(
          mockGraphics.drawRectangle(
            brush: anyNamed('brush'),
            bounds: anyNamed('bounds'),
          ),
        ).called(1);
      },
    );

    test(
      'drawFooterBar should call drawRectangle with correct bounds and color',
      () {
        component.drawFooterBar(mockGraphics);

        verify(
          mockGraphics.drawRectangle(
            brush: anyNamed('brush'),
            bounds: anyNamed('bounds'),
          ),
        ).called(1);
      },
    );
  });
}
