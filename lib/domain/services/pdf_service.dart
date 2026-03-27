import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
  }) async {
    try {
      return await _generator.generate(
        description: description,
        total: total,
        invoiceNumber: invoiceNumber,
        date: date,
        billTo: billTo,
        shipTo: shipTo,
        currency: currency,
      );
    } catch (e) {
      rethrow;
    }
  }
}
