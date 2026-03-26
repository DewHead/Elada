import 'dart:async';
import 'dart:typed_data';
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
  List<Invoice> _history = [];
  List<Invoice> _drafts = [];

  Uint8List? _templateBytes;
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
  }

  String get description => _description;
  double get total => _total;
  String get invoiceNumber => _invoiceNumber;
  DateTime get date => _date;
  String get selectedCurrency => _selectedCurrency;
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

  void updateTemplateBytes(Uint8List bytes) {
    _templateBytes = bytes;
    _generatePreview();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
    _generatePreview();
  }

  void updateTotal(double value) {
    _total = value;
    notifyListeners();
    _generatePreview();
  }

  void updateInvoiceNumber(String value) {
    _invoiceNumber = value;
    notifyListeners();
    _generatePreview();
  }

  void updateDate(DateTime value) {
    _date = value;
    notifyListeners();
    _generatePreview();
  }

  void updateCurrency(String value) {
    _selectedCurrency = value;
    notifyListeners();
    _generatePreview();
  }

  void _generatePreview() {
    if (_templateBytes == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      _isPreviewLoading = true;
      notifyListeners();

      try {
        _previewBytes = await _pdfService.generateInvoice(
          description: _description,
          total: _total,
          invoiceNumber: _invoiceNumber,
          templateBytes: _templateBytes!,
          date: _date,
          currency: _selectedCurrency,
        );
      } catch (e) {
        // Log error
      } finally {
        _isPreviewLoading = false;
        notifyListeners();
      }
    });
  }

  void incrementInvoiceNumber() {
    _invoiceNumber = _incrementStringNumber(_invoiceNumber);
    notifyListeners();
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
    );
    await _repository.saveDraft(draft);
    _loadHistoryAndDrafts();
  }

  void loadDraft(Invoice draft) {
    _invoiceNumber = draft.invoiceNumber;
    _description = draft.description;
    _total = draft.total;
    _date = draft.date;
    _selectedCurrency = draft.currency;
    notifyListeners();
    _generatePreview();
  }

  Future<void> deleteDraft(int index) async {
    await _repository.deleteDraft(index);
    _loadHistoryAndDrafts();
  }

  /// Generates the invoice and saves it to the device's downloads folder.
  /// Returns the path to the saved file.
  Future<String> generateAndSaveInvoice(Uint8List templateBytes) async {
    // 1. Generate bytes
    final bytes = await _pdfService.generateInvoice(
      description: _description,
      total: _total,
      invoiceNumber: _invoiceNumber,
      templateBytes: templateBytes,
      date: _date,
      currency: _selectedCurrency,
    );

    // 2. Create Invoice object for history
    final invoice = Invoice(
      invoiceNumber: _invoiceNumber,
      description: _description,
      total: _total,
      date: _date,
      currency: _selectedCurrency,
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
  
  @Deprecated('Use generateAndSaveInvoice instead')
  Future<Uint8List> generateInvoice(Uint8List templateBytes) async {
     return await _pdfService.generateInvoice(
      description: _description,
      total: _total,
      invoiceNumber: _invoiceNumber,
      templateBytes: templateBytes,
      date: _date,
      currency: _selectedCurrency,
    );
  }
}
