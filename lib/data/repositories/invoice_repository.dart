import 'package:hive/hive.dart';
import 'package:elada/data/models/invoice.dart';

class InvoiceRepository {
  final Box<Invoice> _invoiceBox;
  final Box<dynamic> _settingsBox;
  final Box<Invoice>? _draftBox;

  static const String _lastInvoiceNumberKey = 'last_invoice_number';
  static const String _defaultInvoiceNumber = '9417';

  InvoiceRepository(
    this._invoiceBox,
    this._settingsBox, {
    Box<Invoice>? draftBox,
  }) : _draftBox = draftBox;

  Future<void> saveInvoice(Invoice invoice) async {
    await _invoiceBox.add(invoice);
    await saveLastInvoiceNumber(invoice.invoiceNumber);
  }

  List<Invoice> getInvoices() {
    return _invoiceBox.values.toList();
  }

  Future<void> saveDraft(Invoice draft) async {
    if (_draftBox != null) {
      await _draftBox.add(draft);
    }
  }

  List<Invoice> getDrafts() {
    return _draftBox?.values.toList() ?? [];
  }

  Future<void> deleteDraft(int index) async {
    if (_draftBox != null) {
      await _draftBox.deleteAt(index);
    }
  }

  Future<void> updateDraft(int index, Invoice draft) async {
    if (_draftBox != null) {
      await _draftBox.putAt(index, draft);
    }
  }

  String getLastInvoiceNumber() {
    return _settingsBox.get(
      _lastInvoiceNumberKey,
      defaultValue: _defaultInvoiceNumber,
    );
  }

  Future<void> saveLastInvoiceNumber(String number) async {
    await _settingsBox.put(_lastInvoiceNumberKey, number);
  }
}
