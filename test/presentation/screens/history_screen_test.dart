import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/history_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/models/invoice.dart';

@GenerateMocks([InvoiceProvider])
import 'history_screen_test.mocks.dart';

void main() {
  late MockInvoiceProvider mockProvider;

  setUp(() {
    mockProvider = MockInvoiceProvider();

    when(mockProvider.history).thenReturn([]);
    when(mockProvider.drafts).thenReturn([]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: mockProvider,
        child: const HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen UI', () {
    testWidgets('should show empty state when no history or drafts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('should show lists when history and drafts exist', (
      WidgetTester tester,
    ) async {
      final history = [
        Invoice(
          invoiceNumber: '1',
          description: 'History 1',
          total: 100,
          date: DateTime.now(),
        ),
      ];
      final drafts = [
        Invoice(
          invoiceNumber: 'D1',
          description: 'Draft 1',
          total: 50,
          date: DateTime.now(),
          isDraft: true,
        ),
      ];

      when(mockProvider.history).thenReturn(history);
      when(mockProvider.drafts).thenReturn(drafts);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('History 1'), findsOneWidget);
      expect(find.text('Draft 1'), findsOneWidget);
    });
  });
}
