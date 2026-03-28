import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/invoice_theme.dart';
import 'package:elada/domain/services/pdf_code_generator.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

void main() {
  test('tests provider generateAndSaveInvoice', () async {
    await Hive.initFlutter();
    Hive.registerAdapter(InvoiceAdapter());

    final invoiceBox = await Hive.openBox<Invoice>('test_invoices');
    final draftsBox = await Hive.openBox<Invoice>('test_drafts');
    final settingsBox = await Hive.openBox('test_settings');

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

    provider.updateDescription('Car');
    provider.updateTotal(100000.0);
    provider.updateInvoiceNumber('9422');
    provider.updateBillTo('Elad Avital');

    try {
      final path = await provider.generateAndSaveInvoice();
      print('Saved to: \$path');
    } catch (e, st) {
      print('ERROR: \$e');
      print(st);
      rethrow;
    }
  });
}
