import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/data/models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceRepository _repository;
  final PdfService _pdfService;
  final FilenameService _filenameService;
  final FileExportService _fileExportService;

  String _description = '';
  double _total = 0.0;
  String _invoiceNumber = '';
  DateTime _date = DateTime.now();
  String _selectedCurrency = '€';
  String _billTo = '';
  String _shipTo = '';
  List<Invoice> _history = [];
  List<Invoice> _drafts = [];

  Uint8List? _previewBytes;
  bool _isPreviewLoading = false;
  Timer? _debounceTimer;

  InvoiceProvider(
    this._repository,
    this._pdfService,
    this._filenameService,
    this._fileExportService,
  ) {
    _initInvoiceNumber();
    _loadHistoryAndDrafts();
    _generatePreview(); // Generate initial preview
  }

  String get description => _description;
  double get total => _total;
  String get invoiceNumber => _invoiceNumber;
  DateTime get date => _date;
  String get selectedCurrency => _selectedCurrency;
  String get billTo => _billTo;
  String get shipTo => _shipTo;
  List<Invoice> get history => _history;
  List<Invoice> get drafts => _drafts;

  Uint8List? get previewBytes => _previewBytes;
  bool get isPreviewLoading => _isPreviewLoading;

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
    _generatePreview();
  }

  void updateTotal(double value) {
    _total = value;
    _generatePreview();
  }

  void updateInvoiceNumber(String value) {
    _invoiceNumber = value;
    _generatePreview();
  }

  void updateDate(DateTime value) {
    _date = value;
    _generatePreview();
  }

  void updateCurrency(String value) {
    _selectedCurrency = value;
    _generatePreview();
  }

  void updateBillTo(String value) {
    _billTo = value;
    _generatePreview();
  }

  void updateShipTo(String value) {
    _shipTo = value;
    _generatePreview();
  }

  void _generatePreview() {
    _isPreviewLoading = true;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final bytes = await _pdfService.generateInvoice(
          description: _description,
          total: _total,
          invoiceNumber: _invoiceNumber,
          date: _date,
          billTo: _billTo,
          shipTo: _shipTo,
          currency: _selectedCurrency,
        );
        _previewBytes = bytes;
      } catch (e) {
        // Error handling
      } finally {
        _isPreviewLoading = false;
        notifyListeners();
      }
    });
  }

  void incrementInvoiceNumber() {
    _invoiceNumber = _incrementStringNumber(_invoiceNumber);
    _generatePreview();
  }

  String _incrementStringNumber(String number) {
    final intVal = int.tryParse(number) ?? 0;
    return (intVal + 1).toString();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> saveDraft() async {
    final draft = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: _date,
      currency: _selectedCurrency,
      isDraft: true,
      billTo: _billTo,
      shipTo: _shipTo,
    );
    await _repository.saveDraft(draft);
    _loadHistoryAndDrafts();
  }

  void loadDraft(Invoice draft) {
    _invoiceNumber = draft.invoiceNumber;
    _description = draft.description;
    _total = draft.total;
    _date = draft.effectiveDate;
    _selectedCurrency = draft.currency;
    _billTo = draft.billTo;
    _shipTo = draft.shipTo;
    _generatePreview();
  }

  Future<void> deleteDraft(int index) async {
    await _repository.deleteDraft(index);
    _loadHistoryAndDrafts();
  }

  /// Generates the invoice and saves it to the device's downloads folder.
  /// Returns the path to the saved file.
  Future<String> generateAndSaveInvoice() async {
    // 1. Generate bytes
    final bytes = await _pdfService.generateInvoice(
      description: _description,
      total: _total,
      invoiceNumber: _invoiceNumber,
      date: _date,
      billTo: _billTo,
      shipTo: _shipTo,
      currency: _selectedCurrency,
    );

    // 2. Create Invoice object for history
    final invoice = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: _date,
      currency: _selectedCurrency,
      billTo: _billTo,
      shipTo: _shipTo,
    );

    // 3. Generate Filename
    final fileName = _filenameService.generateFileName(invoice);

    // 4. Save to filesystem
    final savedPath = await _fileExportService.saveFile(
      bytes: bytes,
      fileName: fileName,
    );

    // 5. Save history
    await _repository.saveInvoice(invoice);
    _loadHistoryAndDrafts();

    return savedPath;
  }
}
