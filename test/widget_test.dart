import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/main.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';

@GenerateMocks([
  InvoiceRepository,
  PdfService,
  FilenameService,
  FileExportService,
])
import 'widget_test.mocks.dart';

void main() {
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;
  late MockFilenameService mockFilenameService;
  late MockFileExportService mockFileExportService;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    mockFilenameService = MockFilenameService();
    mockFileExportService = MockFileExportService();

    when(mockRepository.getLastInvoiceNumber()).thenReturn('9417');
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
  });

  testWidgets('Initial screen shows app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => InvoiceProvider(
              mockRepository,
              mockPdfService,
              mockFilenameService,
              mockFileExportService,
            ),
          ),
        ],
        child: const EladaApp(),
      ),
    );

    // Verify that the app title is shown.
    expect(find.text('Elada Invoice'), findsOneWidget);
  });
}
