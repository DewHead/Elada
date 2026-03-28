import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/widgets/invoice_preview.dart';
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
import 'reproduce_focus_loss_test.mocks.dart';

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

    when(mockRepository.getLastInvoiceNumber()).thenReturn('1000');
    when(mockRepository.getInvoices()).thenReturn([]);
    when(mockRepository.getDrafts()).thenReturn([]);
    when(mockPdfService.loadFonts(
      regularPath: anyNamed('regularPath'),
      boldPath: anyNamed('boldPath'),
    )).thenAnswer((_) async {});
    when(mockPdfService.generateInvoice(
      description: anyNamed('description'),
      total: anyNamed('total'),
      invoiceNumber: anyNamed('invoiceNumber'),
      date: anyNamed('date'),
      billTo: anyNamed('billTo'),
      shipTo: anyNamed('shipTo'),
      currency: anyNamed('currency'),
    )).thenAnswer((_) async => Uint8List(0));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>(
        create: (_) => InvoiceProvider(
          mockRepository,
          mockPdfService,
          mockFilenameService,
          mockFileExportService,
        ),
        child: const InvoiceScreen(testing: true),
      ),
    );
  }

  testWidgets('Description field should NOT lose focus after typing on mobile', (WidgetTester tester) async {
    // Set mobile size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 1000));

    final descFieldFinder = find.ancestor(
      of: find.text('Item Description'),
      matching: find.byType(TextField),
    );

    // Ensure visible and focus
    await tester.ensureVisible(descFieldFinder);
    await tester.tap(descFieldFinder);
    await tester.pump();

    // Verify it has focus
    bool hasFocus() {
      final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;
      if (primaryFocus == null) return false;
      
      final Element element = tester.element(descFieldFinder);
      bool isDescendant = false;
      primaryFocus.context?.visitAncestorElements((ancestor) {
        if (ancestor == element) {
          isDescendant = true;
          return false;
        }
        return true;
      });
      return isDescendant;
    }
    
    expect(hasFocus(), isTrue, reason: 'Field should have focus after tap');

    final State initialDescState = tester.state(descFieldFinder);

    // Type something
    await tester.enterText(descFieldFinder, 'Test Description');
    await tester.pump(); // Immediate notifyListeners

    final State afterTypeDescState = tester.state(descFieldFinder);
    expect(afterTypeDescState, same(initialDescState), 
        reason: 'TextField state was recreated after typing (rebuild caused unmount)');

    // Wait for debounce and async generatePreview
    await tester.pump(const Duration(milliseconds: 600)); 
    await tester.pump(); // This should trigger the finally block notifyListeners

    final State finalDescState = tester.state(descFieldFinder);
    expect(finalDescState, same(initialDescState), 
        reason: 'TextField state was recreated after preview finished (rebuild caused unmount)');
    
    // Check focus again
    final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;
    final bool fieldHasFocus = hasFocus();
    
    print('Focus after typing: ${primaryFocus?.context?.widget}');
    
    expect(fieldHasFocus, isTrue, 
        reason: 'Focus lost after typing in Description field and preview generated. Primary focus is on: ${primaryFocus?.context?.widget}');
    
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('SfPdfViewer should NOT be recreated during typing (Zero-Flicker)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 1000));

    // Initial state
    final previewFinder = find.byType(InvoicePreview);
    await tester.ensureVisible(previewFinder);
    
    // We need to wait for the first preview to be generated so we have a SfPdfViewer
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    
    final sfPdfViewerFinder = find.byWidgetPredicate((widget) => widget.runtimeType.toString().contains('SfPdfViewer'));
    
    expect(sfPdfViewerFinder, findsAtLeastNWidgets(1));
    
    // Type something to trigger preview update
    final descFieldFinder = find.ancestor(
      of: find.text('Item Description'),
      matching: find.byType(TextField),
    );
    await tester.enterText(descFieldFinder, 'Update');
    await tester.pump(); // notifyListeners
    
    // Wait for preview update
    await tester.pump(const Duration(milliseconds: 100)); // Debounce
    await tester.pump(const Duration(milliseconds: 100)); // Start loading

    // Verify at least one viewer is in the stack during loading
    final viewers = find.byWidgetPredicate((widget) => widget.runtimeType.toString().contains('SfPdfViewer'));
    expect(viewers, findsAtLeastNWidgets(1), reason: 'At least one viewer should be visible during update to avoid flicker');
    
    // Final wait
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();

    final sfPdfViewerFinderAfter = find.byWidgetPredicate((widget) => widget.runtimeType.toString().contains('SfPdfViewer'));
    expect(sfPdfViewerFinderAfter, findsAtLeastNWidgets(1));

    await tester.pump(const Duration(seconds: 1));
  });
}
