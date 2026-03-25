import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/data/models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceRepository _repository;
  final PdfService _pdfService;

  String _description = '';
  double _total = 0.0;
  String _invoiceNumber = '';

  InvoiceProvider(this._repository, this._pdfService) {
    _initInvoiceNumber();
  }

  String get description => _description;
  double get total => _total;
  String get invoiceNumber => _invoiceNumber;

  void _initInvoiceNumber() {
    final lastNumber = _repository.getLastInvoiceNumber();
    _invoiceNumber = _incrementStringNumber(lastNumber);
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateTotal(double value) {
    _total = value;
    notifyListeners();
  }

  void updateInvoiceNumber(String value) {
    _invoiceNumber = value;
    notifyListeners();
  }

  void incrementInvoiceNumber() {
    _invoiceNumber = _incrementStringNumber(_invoiceNumber);
    notifyListeners();
  }

  String _incrementStringNumber(String number) {
    final intVal = int.tryParse(number) ?? 0;
    return (intVal + 1).toString();
  }

  Future<Uint8List> generateInvoice(Uint8List templateBytes) async {
    final bytes = await _pdfService.generateInvoice(
      description: _description,
      total: _total,
      invoiceNumber: _invoiceNumber,
      templateBytes: templateBytes,
    );

    // Save history
    final invoice = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: DateTime.now(),
    );
    await _repository.saveInvoice(invoice);

    return bytes;
  }
}
