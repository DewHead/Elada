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

  final ValueNotifier<Uint8List?> previewBytesNotifier = ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> isPreviewLoadingNotifier = ValueNotifier<bool>(false);
  
  bool _isGenerating = false;
  Timer? _debounceTimer;

  InvoiceProvider(
    this._repository,
    this._pdfService,
    this._filenameService,
    this._fileExportService,
  ) {
    _initInvoiceNumber();
    _loadHistoryAndDrafts();
    _initFontsAndPreview();
  }

  Future<void> _initFontsAndPreview() async {
    await _pdfService.loadFonts(
      regularPath: 'assets/fonts/LiberationSans-Regular.ttf',
      boldPath: 'assets/fonts/LiberationSans-Bold.ttf',
    );
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

  Uint8List? get previewBytes => previewBytesNotifier.value;
  bool get isPreviewLoading => isPreviewLoadingNotifier.value;
  bool get isGenerating => _isGenerating;

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

  void updateBillTo(String value) {
    _billTo = value;
    notifyListeners();
    _generatePreview();
  }

  void updateShipTo(String value) {
    _shipTo = value;
    notifyListeners();
    _generatePreview();
  }

  void _generatePreview() {
    if (_isGenerating) return; // Don't generate preview if final PDF is being generated

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () async {
      if (_isGenerating) return; // Double check after debounce
      
      // Only set loading to true if it takes longer than 100ms to generate
      // This prevents the loading indicator from flashing for fast generations
      final loadingTimer = Timer(const Duration(milliseconds: 100), () {
        if (!isPreviewLoadingNotifier.value) {
          isPreviewLoadingNotifier.value = true;
        }
      });

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
        previewBytesNotifier.value = bytes;
      } catch (e, st) {
        debugPrint('=== PDF PREVIEW GENERATION ERROR ===');
        debugPrint(e.toString());
        debugPrint(st.toString());
        debugPrint('============================');
      } finally {
        loadingTimer.cancel();
        isPreviewLoadingNotifier.value = false;
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
    previewBytesNotifier.dispose();
    isPreviewLoadingNotifier.dispose();
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
    if (_isGenerating) {
      throw Exception('PDF generation already in progress');
    }

    _debounceTimer?.cancel(); // Cancel any pending preview generation
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. Generate bytes
      final bytes = await _pdfService.generateInvoice(
        description: _description.isNotEmpty ? _description : 'Invoice',
        total: _total,
        invoiceNumber: _invoiceNumber.isNotEmpty ? _invoiceNumber : '0000',
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
    } catch (e, st) {
      throw Exception('ERROR: $e\nSTACKTRACE: $st');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
