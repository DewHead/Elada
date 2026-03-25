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
  String _selectedCurrency = '€';
  List<Invoice> _history = [];
  List<Invoice> _drafts = [];

  InvoiceProvider(this._repository, this._pdfService) {
    _initInvoiceNumber();
    _loadHistoryAndDrafts();
  }

  String get description => _description;
  double get total => _total;
  String get invoiceNumber => _invoiceNumber;
  String get selectedCurrency => _selectedCurrency;
  List<Invoice> get history => _history;
  List<Invoice> get drafts => _drafts;

  void _initInvoiceNumber() {
    final lastNumber = _repository.getLastInvoiceNumber();
    _invoiceNumber = _incrementStringNumber(lastNumber);
  }

  void _loadHistoryAndDrafts() {
    _history = _repository.getInvoices();
    _drafts = _repository.getDrafts();
    notifyListeners();
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

  void updateCurrency(String value) {
    _selectedCurrency = value;
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

  Future<void> saveDraft() async {
    final draft = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: DateTime.now(),
      currency: _selectedCurrency,
      isDraft: true,
    );
    await _repository.saveDraft(draft);
    _loadHistoryAndDrafts();
  }

  void loadDraft(Invoice draft) {
    _invoiceNumber = draft.invoiceNumber;
    _description = draft.description;
    _total = draft.total;
    _selectedCurrency = draft.currency;
    notifyListeners();
  }

  Future<Uint8List> generateInvoice(Uint8List templateBytes) async {
    final bytes = await _pdfService.generateInvoice(
      description: _description,
      total: _total,
      invoiceNumber: _invoiceNumber,
      templateBytes: templateBytes,
      currency: _selectedCurrency,
    );

    // Save history
    final invoice = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: DateTime.now(),
      currency: _selectedCurrency,
    );
    await _repository.saveInvoice(invoice);
    _loadHistoryAndDrafts();

    return bytes;
  }
}
