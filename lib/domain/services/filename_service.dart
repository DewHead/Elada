import 'package:elada/data/models/invoice.dart';

class FilenameService {
  /// Generates a filename based on the invoice number and date.
  /// Format: [InvoiceNumber]_[InvoiceDate].pdf
  /// Date format: DD-MM-YYYY
  String generateFileName(Invoice invoice) {
    String number = invoice.invoiceNumber.trim();
    if (number.isEmpty) {
      number = 'invoice';
    } else {
      // Sanitize illegal characters for filesystems: / \ : * ? " < > |
      final illegalChars = RegExp(r'[\\/:*?"<>|]');
      number = number.replaceAll(illegalChars, '-');
    }

    final date = invoice.effectiveDate;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final formattedDate = '$day-$month-$year';

    return '${number}_$formattedDate.pdf';
  }
}
