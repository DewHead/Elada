import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:ui';

void main() {
  test('test euro symbol support in Helvetica', () async {
    final document = PdfDocument();
    final page = document.pages.add();
    final font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    try {
      page.graphics.drawString(
        '€ 100', // Euro symbol
        font,
        bounds: const Rect.fromLTWH(0, 0, 100, 20),
      );
      print('Drew euro symbol successfully');
    } catch (e) {
      print('ERROR CAUGHT: $e');
      rethrow;
    }
  });

  test('test shekel symbol (₪) in Helvetica - EXPECT FAILURE', () async {
    final document = PdfDocument();
    final page = document.pages.add();
    final font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    try {
      page.graphics.drawString(
        '₪ 100', // Shekel symbol (NOT in Helvetica standard)
        font,
        bounds: const Rect.fromLTWH(0, 50, 100, 20),
      );
      print('Drew shekel symbol successfully (unexpectedly)');
    } catch (e) {
      print('ERROR CAUGHT (Expected for Shekel): $e');
    }
  });
}
