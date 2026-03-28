import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';

void main() {
  test('reproduce null check error with 2 items', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('elada_test_sort');
    Hive.init(tempDir.path);
    Hive.registerAdapter(InvoiceAdapter());

    final invoiceBox = await Hive.openBox<Invoice>('test_sort_invoices');
    final draftsBox = await Hive.openBox<Invoice>('test_sort_drafts');
    final settingsBox = await Hive.openBox('test_sort_settings');

    await invoiceBox.clear(); // Clear existing

    // 1. Add an old invoice with a NULL date (bypassing the constructor which sets a default)
    // We can simulate this by passing the date as null in json
    final oldInvoice = Invoice.fromJson({
      'invoice_number': '0001',
      'description': 'Old stuff',
      'total': 50.0,
      'date': null, // This simulates the old database state
    });

    await invoiceBox.add(oldInvoice);

    final repository = InvoiceRepository(
      invoiceBox,
      settingsBox,
      draftBox: draftsBox,
    );
    final theme = InvoiceTheme();
    final generator = PdfCodeGenerator(theme);
    final pdfService = PdfService(generator);
    final filenameService = FilenameService();
    final exportService = FileExportService();

    final provider = InvoiceProvider(
      repository,
      pdfService,
      filenameService,
      exportService,
    );

    // This should trigger _loadHistoryAndDrafts which contains the sorting logic!
    try {
      // 2. Generate a new invoice
      provider.updateDescription('Car');
      provider.updateTotal(100000.0);
      provider.updateInvoiceNumber('9422');

      await provider.generateAndSaveInvoice();
      print('Saved!');
    } catch (e) {
      print('ERROR CAUGHT: \$e');
      rethrow;
    }
  });
}
