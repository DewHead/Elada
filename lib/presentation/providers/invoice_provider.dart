import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/models/invoice_item.dart';

class InvoiceProvider with ChangeNotifier {
  static const String itemPrefix = 'HOTEL AND FLIGHTS FOR ';
  final InvoiceRepository _repository;
  final PdfService _pdfService;
  final FilenameService _filenameService;
  final FileExportService _fileExportService;

  double _total = 0.0;
  List<InvoiceItem> _items = [InvoiceItem(description: itemPrefix, price: 0.0)];
  String _invoiceNumber = '';
  DateTime _date = DateTime.now();
  String _selectedCurrency = '€';
  List<Invoice> _history = [];
  List<Invoice> _drafts = [];

  final ValueNotifier<Uint8List?> previewBytesNotifier =
      ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> isPreviewLoadingNotifier = ValueNotifier<bool>(
    false,
  );

  bool _isGenerating = false;
  bool _disposed = false;
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
    await _pdfService.loadTemplate('assets/template.pdf');
    _generatePreview(); // Generate initial preview
  }

  String get description => _items.isNotEmpty ? _items.first.description : '';
  double get total {
    if (_items.any((item) => item.price != 0)) {
      return _items.fold(0.0, (sum, item) => sum + item.price);
    }
    return _total;
  }

  bool get hasItems => _items.any((item) => item.price != 0);

  List<InvoiceItem> get items => _items;
  String get invoiceNumber => _invoiceNumber;
  DateTime get date => _date;
  String get selectedCurrency => _selectedCurrency;
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
    // Sort history from newest to oldest
    _history.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));

    _drafts = _repository.getDrafts();
    // Sort drafts from newest to oldest as well
    _drafts.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));

    notifyListeners();
  }

  void updateDescription(String value) {
    if (_items.isNotEmpty) {
      updateItemDescription(0, value);
    } else {
      _items = [InvoiceItem(description: value, price: 0.0)];
      notifyListeners();
      _generatePreview();
    }
  }

  void updateTotal(double value) {
    _total = value;
    notifyListeners();
    _generatePreview();
  }

  void clearItems() {
    _items = [InvoiceItem(description: itemPrefix, price: 0.0)];
    _total = 0.0;
    notifyListeners();
    _generatePreview();
  }

  void updateItemDescription(int index, String value) {
    if (index >= 0 && index < _items.length) {
      String userPart = value;
      if (value.startsWith(itemPrefix)) {
        userPart = value.substring(itemPrefix.length);
      } else {
        final trimmedPrefix = itemPrefix.trimRight();
        if (value.startsWith(trimmedPrefix)) {
          userPart = value.substring(trimmedPrefix.length).trimLeft();
        } else if (trimmedPrefix.startsWith(value)) {
          userPart = "";
        }
      }

      final finalValue = itemPrefix + userPart;

      _items[index] = InvoiceItem(
        description: finalValue,
        price: _items[index].price,
      );
      notifyListeners();
      _generatePreview();
    }
  }

  void updateItemPrice(int index, double value) {
    if (index >= 0 && index < _items.length) {
      _items[index] = InvoiceItem(
        description: _items[index].description,
        price: value,
      );
      notifyListeners();
      _generatePreview();
    }
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
    if (_isGenerating || _disposed) {
      return; // Don't generate preview if final PDF is being generated or disposed
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_isGenerating || _disposed) return; // Double check after debounce

      // Only set loading to true if it takes longer than 100ms to generate
      // This prevents the loading indicator from flashing for fast generations
      final loadingTimer = Timer(const Duration(milliseconds: 100), () {
        if (!_disposed && !isPreviewLoadingNotifier.value) {
          isPreviewLoadingNotifier.value = true;
        }
      });

      try {
        final filteredItems = _items;

        final bytes = await _pdfService.generateInvoice(
          description: description,
          total: total,
          items: filteredItems,
          invoiceNumber: _invoiceNumber,
          date: _date,
          currency: _selectedCurrency,
        );
        if (!_disposed) {
          previewBytesNotifier.value = bytes;
        }
      } catch (e, st) {
        if (!_disposed) {
          debugPrint('=== PDF PREVIEW GENERATION ERROR ===');
          debugPrint(e.toString());
          debugPrint(st.toString());
          debugPrint('============================');
        }
      } finally {
        loadingTimer.cancel();
        if (!_disposed) {
          isPreviewLoadingNotifier.value = false;
        }
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
    _disposed = true;
    _debounceTimer?.cancel();
    previewBytesNotifier.dispose();
    isPreviewLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> saveDraft() async {
    final draft = Invoice(
      invoiceNumber: _invoiceNumber,
      description: description,
      total: total,
      items: _items,
      date: _date,
      currency: _selectedCurrency,
      isDraft: true,
    );
    await _repository.saveDraft(draft);
    _loadHistoryAndDrafts();
  }

  void loadInvoice(Invoice invoice) {
    _invoiceNumber = invoice.invoiceNumber;
    _total = invoice.total;
    _items = List.from(invoice.items ?? []);
    if (_items.isEmpty) {
      // If it's an old invoice with only top-level description, use it for the first item
      _items = [
        InvoiceItem(description: invoice.description, price: invoice.total),
      ];
    }
    _date = invoice.effectiveDate;
    _selectedCurrency = invoice.currency;
    _generatePreview();
    notifyListeners();
  }

  Future<void> deleteDraft(Invoice draft) async {
    await _repository.deleteDraft(draft.key);
    _loadHistoryAndDrafts();
  }

  Future<void> deleteHistoryEntry(Invoice invoice) async {
    await _repository.deleteInvoice(invoice.key);
    _loadHistoryAndDrafts();
  }

  Future<void> clearAllHistoryAndDrafts() async {
    await _repository.clearAll();
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
        description: description.isNotEmpty ? description : 'Invoice',
        total: total,
        items: _items,
        invoiceNumber: _invoiceNumber.isNotEmpty ? _invoiceNumber : '0000',
        date: _date,
        currency: _selectedCurrency,
      );

      // 2. Create Invoice object for history
      final invoice = Invoice(
        invoiceNumber: _invoiceNumber,
        description: description,
        total: total,
        items: _items,
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
    } catch (e, st) {
      throw Exception('ERROR: $e\nSTACKTRACE: $st');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
