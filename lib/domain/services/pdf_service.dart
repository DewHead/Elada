import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:ui';

class PdfService {
  Future<Uint8List> generateInvoice({
    required String description,
    required double total,
    required String invoiceNumber,
    required Uint8List templateBytes,
    required DateTime date,
    String currency = '€',
  }) async {
    // Load the PDF document
    final PdfDocument document = PdfDocument(inputBytes: templateBytes);
    final PdfPage page = document.pages[0];
    final PdfGraphics graphics = page.graphics;

    // Use a standard font
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfFont boldFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    final PdfBrush brush = PdfBrushes.black;
    final PdfBrush whiteBrush = PdfBrushes.white;

    // 1. Update Date
    // Original: "25.03.2026", Bounds: Rect.fromLTRB(427.5, 139.1, 474.0, 148.1)
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    graphics.drawRectangle(
      brush: whiteBrush,
      bounds: const Rect.fromLTRB(420, 135, 500, 155),
    );
    graphics.drawString(
      formattedDate,
      font,
      brush: brush,
      bounds: const Rect.fromLTRB(427.5, 139.1, 500, 155),
    );

    // 2. Update Invoice Number
    // Original: "9417", Bounds: Rect.fromLTRB(440.4, 210.1, 461.1, 219.1)
    graphics.drawRectangle(
      brush: whiteBrush,
      bounds: const Rect.fromLTRB(430, 208, 500, 225),
    );
    graphics.drawString(
      invoiceNumber,
      font,
      brush: brush,
      bounds: const Rect.fromLTRB(440.4, 210.1, 500, 225),
    );

    // 3. Update Description
    // Original starts at: Text: "HOTEL AND FLIGHTS FOR 1 ", Bounds: Rect.fromLTRB(98.2, 431.8, 252.2, 442.8)
    // We clear a larger area for the table content
    graphics.drawRectangle(
      brush: whiteBrush,
      bounds: const Rect.fromLTRB(95, 430, 350, 530),
    );
    graphics.drawString(
      description,
      font,
      brush: brush,
      bounds: const Rect.fromLTRB(98.2, 431.8, 340, 530),
    );

    // 4. Update Total and Currency
    // Original Total: "1200", Bounds: Rect.fromLTRB(424.1, 439.4, 448.5, 450.4)
    // Original Currency: "€", Bounds: Rect.fromLTRB(414.7, 438.6, 421.4, 450.6)
    final totalText = total.toStringAsFixed(2);

    // Clear item total
    graphics.drawRectangle(
      brush: whiteBrush,
      bounds: const Rect.fromLTRB(410, 435, 480, 455),
    );
    graphics.drawString(
      '$currency $totalText',
      font,
      brush: brush,
      bounds: const Rect.fromLTRB(414.7, 439.4, 480, 455),
    );

    // Update Balance Due (at the bottom)
    // Original: "1200", Bounds: Rect.fromLTRB(424.1, 687.3, 448.5, 698.3)
    graphics.drawRectangle(
      brush: whiteBrush,
      bounds: const Rect.fromLTRB(410, 685, 480, 705),
    );
    graphics.drawString(
      '$currency $totalText',
      boldFont,
      brush: brush,
      bounds: const Rect.fromLTRB(414.7, 687.3, 480, 705),
    );

    // Save the document as bytes
    final List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }
}
