import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  Future<Uint8List> generateInvoice({
    required String description,
    required double total,
    required String invoiceNumber,
    required Uint8List templateBytes,
    String currency = '€',
  }) async {
    // Load the PDF document
    final PdfDocument document = PdfDocument(inputBytes: templateBytes);

    // Get the form from the PDF document
    final PdfForm form = document.form;

    // Map and fill fields
    _tryFillField(form, 'INVOICE NO.', invoiceNumber);
    _tryFillField(form, 'Description', description);
    
    final formattedTotal = '$currency ${total.toStringAsFixed(2)}';
    _tryFillField(form, 'Total', formattedTotal);
    _tryFillField(form, 'Balance Due', formattedTotal);

    // Save the document as bytes
    final List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }

  void _tryFillField(PdfForm form, String fieldName, String value) {
    try {
      // Find field by name
      PdfField? foundField;
      for (int i = 0; i < form.fields.count; i++) {
        if (form.fields[i].name == fieldName) {
          foundField = form.fields[i];
          break;
        }
      }

      if (foundField is PdfTextBoxField) {
        foundField.text = value;
      }
    } catch (_) {
      // Silently fail for MVP or use proper logging
    }
  }
}
