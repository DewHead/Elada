import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/models/invoice_item.dart';

import 'invoice_items_test.mocks.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
void main() {
  late InvoiceProvider provider;
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;
  late MockFilenameService mockFilenameService;
  late MockFileExportService mockFileExportService;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    mockFilenameService = MockFilenameService();
    mockFileExportService = MockFileExportService();

    when(mockRepository.getLastInvoiceNumber()).thenReturn('0');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
    when(
      mockPdfService.loadFonts(
        regularPath: anyNamed('regularPath'),
        boldPath: anyNamed('boldPath'),
      ),
    ).thenAnswer((_) async {});

    when(
      mockPdfService.generateInvoice(
        description: anyNamed('description'),
        total: anyNamed('total'),
        invoiceNumber: anyNamed('invoiceNumber'),
        date: anyNamed('date'),
        items: anyNamed('items'),
        currency: anyNamed('currency'),
      ),
    ).thenAnswer((_) async => Uint8List(0));

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  test('Initial total should be 0', () {
    expect(provider.total, 0.0);
  });

  test('Initial item should have prefix', () {
    expect(provider.items.length, 1);
    expect(provider.items[0].description, InvoiceProvider.itemPrefix);
  });

  test('Updating item price should update the total correctly', () {
    provider.updateItemPrice(0, 150.0);
    expect(provider.total, 150.0);
    expect(provider.items.length, 1); // Still exactly one item
  });

  test('Updating item description should enforce prefix', () {
    provider.updateItemDescription(0, 'Some details');
    expect(
      provider.items[0].description,
      '${InvoiceProvider.itemPrefix}Some details',
    );

    // Attempting to delete the prefix should restore it
    provider.updateItemDescription(0, 'HOTEL');
    expect(provider.items[0].description, InvoiceProvider.itemPrefix);
  });

  test('Loading invoice with items should handle single item state', () {
    final invoice = Invoice(
      invoiceNumber: '123',
      description: 'Test',
      total: 200.0,
      items: [
        InvoiceItem(description: 'HOTEL AND FLIGHTS FOR Trip', price: 200.0),
      ],
    );

    provider.loadInvoice(invoice);
    expect(provider.items.length, 1);
    expect(provider.total, 200.0);
  });
}
