import 'dart:typed_data';
import 'package:elada/domain/services/pdf_code_generator.dart';

class PdfService {
  final PdfCodeGenerator _generator;

  PdfService(this._generator);

  Future<Uint8List> generateInvoice({
    required String description,
    required double total,
    required String invoiceNumber,
    required DateTime date,
    String billTo = '',
    String shipTo = '',
    String currency = '€',
    Uint8List? templateBytes, // Kept for backward compatibility but ignored
  }) async {
    return await _generator.generate(
      description: description,
      total: total,
      invoiceNumber: invoiceNumber,
      date: date,
      billTo: billTo,
      shipTo: shipTo,
      currency: currency,
    );
  }
}
