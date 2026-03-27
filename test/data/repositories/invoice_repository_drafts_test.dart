import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/repositories/invoice_repository.dart';

void main() {
  late InvoiceRepository repository;
  late Box<Invoice> invoiceBox;
  late Box<Invoice> draftBox;
  late Box<dynamic> settingsBox;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_draft_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
  });

  setUp(() async {
    invoiceBox = await Hive.openBox<Invoice>('invoices');
    draftBox = await Hive.openBox<Invoice>('drafts');
    settingsBox = await Hive.openBox('settings');
    repository = InvoiceRepository(invoiceBox, settingsBox, draftBox: draftBox);
  });

  tearDown(() async {
    await invoiceBox.clear();
    await draftBox.clear();
    await settingsBox.clear();
    await invoiceBox.close();
    await draftBox.close();
    await settingsBox.close();
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('InvoiceRepository Drafts', () {
    test('should save and get drafts', () async {
      final draft = Invoice(
        invoiceNumber: 'DRAFT-001',
        description: 'Draft Test',
        total: 50.0,
        date: DateTime.now(),
        isDraft: true,
      );

      await repository.saveDraft(draft);
      final drafts = repository.getDrafts();

      expect(drafts.length, 1);
      expect(drafts.first.invoiceNumber, 'DRAFT-001');
      expect(drafts.first.isDraft, true);
    });

    test('should delete drafts', () async {
      final draft = Invoice(
        invoiceNumber: 'DRAFT-001',
        description: 'Draft Test',
        total: 50.0,
        date: DateTime.now(),
        isDraft: true,
      );

      await repository.saveDraft(draft);
      expect(repository.getDrafts().length, 1);

      await repository.deleteDraft(0); // Assuming Hive index or similar
      expect(repository.getDrafts().length, 0);
    });

    test('should update drafts', () async {
      final draft = Invoice(
        invoiceNumber: 'DRAFT-001',
        description: 'Draft Test',
        total: 50.0,
        date: DateTime.now(),
        isDraft: true,
      );

      await repository.saveDraft(draft);

      final updatedDraft = Invoice(
        invoiceNumber: 'DRAFT-001-UPDATED',
        description: 'Draft Test Updated',
        total: 75.0,
        date: draft.date,
        isDraft: true,
      );

      await repository.updateDraft(0, updatedDraft);
      final drafts = repository.getDrafts();

      expect(drafts.length, 1);
      expect(drafts.first.invoiceNumber, 'DRAFT-001-UPDATED');
      expect(drafts.first.total, 75.0);
    });
  });
}
