import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/widgets/invoice_preview.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

@GenerateMocks([InvoiceProvider])
import 'invoice_preview_test.mocks.dart';

void main() {
  late MockInvoiceProvider mockProvider;

  setUp(() {
    mockProvider = MockInvoiceProvider();

    when(mockProvider.previewBytes).thenReturn(null);
    when(mockProvider.isPreviewLoading).thenReturn(false);
    
    // Stub addListener/removeListener for ChangeNotifierProvider
    when(mockProvider.addListener(any)).thenReturn(null);
    when(mockProvider.removeListener(any)).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: mockProvider,
        child: const Scaffold(body: InvoicePreview()),
      ),
    );
  }

  group('InvoicePreview Widget', () {
    testWidgets('should show loading spinner when isPreviewLoading is true',
        (WidgetTester tester) async {
      when(mockProvider.isPreviewLoading).thenReturn(true);
      when(mockProvider.previewBytes).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show PDF viewer when previewBytes is available',
        (WidgetTester tester) async {
      final bytes = Uint8List(10);
      when(mockProvider.previewBytes).thenReturn(bytes);
      when(mockProvider.isPreviewLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SfPdfViewer), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should show overlay spinner when loading and preview exists',
        (WidgetTester tester) async {
      final bytes = Uint8List(10);
      when(mockProvider.previewBytes).thenReturn(bytes);
      when(mockProvider.isPreviewLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SfPdfViewer), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
