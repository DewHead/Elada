import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
import 'invoice_preview_test.mocks.dart';

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

    when(mockRepository.getLastInvoiceNumber()).thenReturn('100');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);

    provider = InvoiceProvider(
      mockRepository,
      mockPdfService,
      mockFilenameService,
      mockFileExportService,
    );
  });

  group('InvoiceProvider Preview Logic', () {
    test('should generate preview after debounce period', () async {
      final previewBytes = Uint8List(20);

      when(
        mockPdfService.generateInvoice(
          description: anyNamed('description'),
          total: anyNamed('total'),
          invoiceNumber: anyNamed('invoiceNumber'),
          date: anyNamed('date'),
          billTo: anyNamed('billTo'),
          shipTo: anyNamed('shipTo'),
          currency: anyNamed('currency'),
        ),
      ).thenAnswer((_) async => previewBytes);

      provider.updateDescription('Test Description');

      // Initially, previewBytes should be null because of debounce (except for the initial call in constructor which might have fired)
      // Actually, since I call it in constructor, it might already be loading.

      // Wait for debounce (500ms) + some buffer
      await Future.delayed(const Duration(milliseconds: 1200));

      expect(provider.previewBytes, equals(previewBytes));
      expect(provider.isPreviewLoading, isFalse);
    });

    test(
      'should only generate one preview when multiple updates happen rapidly',
      () async {
        final previewBytes = Uint8List(20);

        when(
          mockPdfService.generateInvoice(
            description: anyNamed('description'),
            total: anyNamed('total'),
            invoiceNumber: anyNamed('invoiceNumber'),
            date: anyNamed('date'),
            billTo: anyNamed('billTo'),
            shipTo: anyNamed('shipTo'),
            currency: anyNamed('currency'),
          ),
        ).thenAnswer((_) async => previewBytes);

        provider.updateDescription('Update 1');
        provider.updateDescription('Update 2');
        provider.updateDescription('Update 3');

        await Future.delayed(const Duration(milliseconds: 1200));

        expect(provider.previewBytes, equals(previewBytes));
      },
    );
  });
}
