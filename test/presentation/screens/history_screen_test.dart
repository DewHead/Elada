import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/history_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/models/invoice_item.dart';

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

    testWidgets('should show first item description in history subtitle', (
      WidgetTester tester,
    ) async {
      final history = [
        Invoice(
          invoiceNumber: 'INV-1',
          description: 'Project A',
          total: 1500,
          date: DateTime(2026, 3, 28),
          items: [
            InvoiceItem(description: 'Initial Item', price: 1000),
            InvoiceItem(description: 'Second Item', price: 500),
          ],
        ),
      ];

      when(mockProvider.history).thenReturn(history);
      when(mockProvider.drafts).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Initial Item'), findsOneWidget);
      expect(find.text('Project A'), findsOneWidget);
    });

    testWidgets('should not show item description when history has no items', (
      WidgetTester tester,
    ) async {
      final history = [
        Invoice(
          invoiceNumber: 'INV-2',
          description: 'Project B',
          total: 0,
          date: DateTime(2026, 3, 28),
          items: [],
        ),
      ];

      when(mockProvider.history).thenReturn(history);
      when(mockProvider.drafts).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Project B'), findsOneWidget);
    });

    testWidgets('should show clear all button when history exists', (
      WidgetTester tester,
    ) async {
      when(mockProvider.history).thenReturn([
        Invoice(
          invoiceNumber: '1',
          description: 'H1',
          total: 10,
          date: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
    });

    testWidgets(
      'should call deleteHistoryEntry when history delete icon is tapped',
      (WidgetTester tester) async {
        when(mockProvider.history).thenReturn([
          Invoice(
            invoiceNumber: '1',
            description: 'H1',
            total: 10,
            date: DateTime.now(),
          ),
        ]);

        await tester.pumpWidget(createWidgetUnderTest());

        final deleteIcon = find.byTooltip('Delete History Entry');
        await tester.tap(deleteIcon);
        await tester.pumpAndSettle();

        // Tap on confirmation Delete
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        verify(mockProvider.deleteHistoryEntry(any)).called(1);
      },
    );

    testWidgets(
      'should call clearAllHistoryAndDrafts when clear all icon is tapped',
      (WidgetTester tester) async {
        when(mockProvider.history).thenReturn([
          Invoice(
            invoiceNumber: '1',
            description: 'H1',
            total: 10,
            date: DateTime.now(),
          ),
        ]);

        await tester.pumpWidget(createWidgetUnderTest());

        final clearIcon = find.byIcon(Icons.delete_sweep_outlined);
        await tester.tap(clearIcon);
        await tester.pumpAndSettle();

        // Tap on confirmation Clear All button (avoiding dialog title)
        await tester.tap(find.widgetWithText(TextButton, 'Clear All'));
        await tester.pumpAndSettle();

        verify(mockProvider.clearAllHistoryAndDrafts()).called(1);
      },
    );
  });
}
