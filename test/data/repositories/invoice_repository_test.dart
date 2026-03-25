import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/repositories/invoice_repository.dart';

void main() {
  late InvoiceRepository repository;
  late Box<Invoice> invoiceBox;
  late Box<dynamic> settingsBox;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
  });

  setUp(() async {
    invoiceBox = await Hive.openBox<Invoice>('invoices');
    settingsBox = await Hive.openBox('settings');
    repository = InvoiceRepository(invoiceBox, settingsBox);
  });

  tearDown(() async {
    await invoiceBox.clear();
    await settingsBox.clear();
    await invoiceBox.close();
    await settingsBox.close();
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('InvoiceRepository', () {
    test('should save and get invoices', () async {
      final invoice = Invoice(
        invoiceNumber: '9418',
        description: 'Test',
        total: 100.0,
        date: DateTime.now(),
      );

      await repository.saveInvoice(invoice);
      final invoices = repository.getInvoices();

      expect(invoices.length, 1);
      expect(invoices.first.invoiceNumber, '9418');
    });

    test('should save and get last invoice number', () async {
      await repository.saveLastInvoiceNumber('9419');
      final lastNumber = repository.getLastInvoiceNumber();

      expect(lastNumber, '9419');
    });

    test('should return default invoice number if none saved', () {
      final lastNumber = repository.getLastInvoiceNumber();
      expect(lastNumber, '9417'); // Starting point from OCR
    });
  });
}
