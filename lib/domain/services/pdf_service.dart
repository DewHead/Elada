import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

    // Get the form from the PDF document
    final PdfForm form = document.form;

    // Map and fill fields (Try multiple possible names for robustness)
    _tryFillField(form, ['INVOICE NO.', 'Invoice No.', 'Invoice Number', 'Number'], invoiceNumber);
    _tryFillField(form, ['Description', 'Item Description', 'Details'], description);
    
    // Format date as DD/MM/YYYY for the PDF content
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    _tryFillField(form, ['Date', 'Invoice Date', 'Issued Date'], formattedDate);
    
    final formattedTotal = '$currency ${total.toStringAsFixed(2)}';
    _tryFillField(form, ['Total', 'Amount', 'Invoice Total'], formattedTotal);
    _tryFillField(form, ['Balance Due', 'Balance'], formattedTotal);

    // Save the document as bytes
    final List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }

  void _tryFillField(PdfForm form, List<String> fieldNames, String value) {
    try {
      PdfField? foundField;
      
      // Try to find by exact name first
      for (final name in fieldNames) {
        for (int i = 0; i < form.fields.count; i++) {
          if (form.fields[i].name == name) {
            foundField = form.fields[i];
            break;
          }
        }
        if (foundField != null) break;
      }

      // If not found, try case-insensitive partial match
      if (foundField == null) {
        for (final name in fieldNames) {
          final lowerName = name.toLowerCase();
          for (int i = 0; i < form.fields.count; i++) {
            final fieldName = form.fields[i].name?.toLowerCase() ?? '';
            if (fieldName == lowerName || fieldName.contains(lowerName)) {
              foundField = form.fields[i];
              break;
            }
          }
          if (foundField != null) break;
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
