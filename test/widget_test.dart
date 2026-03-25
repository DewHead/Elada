import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/main.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';

@GenerateMocks([InvoiceRepository, PdfService])
import 'widget_test.mocks.dart';

void main() {
  late MockInvoiceRepository mockRepository;
  late MockPdfService mockPdfService;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    mockPdfService = MockPdfService();
    
    when(mockRepository.getLastInvoiceNumber()).thenReturn('9417');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
  });

  testWidgets('Initial screen shows app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => InvoiceProvider(mockRepository, mockPdfService),
          ),
        ],
        child: const EladaApp(),
      ),
    );

    // Verify that the app title is shown.
    expect(find.text('Elada Invoice'), findsOneWidget);
  });
}
