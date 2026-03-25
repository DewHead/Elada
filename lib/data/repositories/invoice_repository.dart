import 'package:hive/hive.dart';
import 'package:elada/data/models/invoice.dart';

class InvoiceRepository {
  final Box<Invoice> _invoiceBox;
  final Box<dynamic> _settingsBox;

  static const String _lastInvoiceNumberKey = 'last_invoice_number';
  static const String _defaultInvoiceNumber = '9417';

  InvoiceRepository(this._invoiceBox, this._settingsBox);

  Future<void> saveInvoice(Invoice invoice) async {
    await _invoiceBox.add(invoice);
    await saveLastInvoiceNumber(invoice.invoiceNumber);
  }

  List<Invoice> getInvoices() {
    return _invoiceBox.values.toList();
  }

  String getLastInvoiceNumber() {
    return _settingsBox.get(_lastInvoiceNumberKey, defaultValue: _defaultInvoiceNumber);
  }

  Future<void> saveLastInvoiceNumber(String number) async {
    await _settingsBox.put(_lastInvoiceNumberKey, number);
  }
}
