import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:elada/domain/services/pdf_code_generator.dart';

import 'package:elada/data/models/invoice_item.dart';

class PdfService {
  final PdfCodeGenerator _generator;
  Uint8List? _fontData;
  Uint8List? _boldFontData;
  Uint8List? _templateData;

  PdfService(this._generator);

  Future<void> loadFont(String path) async {
    try {
      _fontData = (await rootBundle.load(path)).buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading font: $e');
    }
  }

  Future<void> loadFonts({
    required String regularPath,
    required String boldPath,
  }) async {
    try {
      _fontData = (await rootBundle.load(regularPath)).buffer.asUint8List();
      _boldFontData = (await rootBundle.load(boldPath)).buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading fonts: $e');
    }
  }

  Future<void> loadTemplate(String path) async {
    try {
      _templateData = (await rootBundle.load(path)).buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading template: $e');
    }
  }

  Future<Uint8List> generateInvoice({
    required String description,
    required double total,
    required String invoiceNumber,
    required DateTime date,
    List<InvoiceItem> items = const [],
    String currency = '€',
  }) async {
    final Map<String, dynamic> params = {
      'generator': _generator,
      'description': description,
      'total': total,
      'items': items,
      'invoiceNumber': invoiceNumber,
      'date': date,
      'currency': currency,
      'fontData': _fontData,
      'boldFontData': _boldFontData,
      'templateData': _templateData,
    };

    if (kIsWeb) {
      return await _generateInvoiceInIsolate(params);
    }

    return compute(_generateInvoiceInIsolate, params);
  }
}

/// Top-level function for compute() to run in a separate isolate.
Future<Uint8List> _generateInvoiceInIsolate(Map<String, dynamic> params) async {
  final PdfCodeGenerator generator = params['generator'] as PdfCodeGenerator;
  return await generator.generate(
    description: params['description'] as String,
    total: params['total'] as double,
    items: params['items'] as List<InvoiceItem>,
    invoiceNumber: params['invoiceNumber'] as String,
    date: params['date'] as DateTime,
    currency: params['currency'] as String,
    fontData: params['fontData'] as Uint8List?,
    boldFontData: params['boldFontData'] as Uint8List?,
    templateBytes: params['templateData'] as Uint8List?,
  );
}
