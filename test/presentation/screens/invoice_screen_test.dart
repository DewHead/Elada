import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:elada/presentation/screens/invoice_screen.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

@GenerateMocks([InvoiceProvider])
import 'invoice_screen_test.mocks.dart';

void main() {
  late MockInvoiceProvider mockProvider;

  setUp(() {
    mockProvider = MockInvoiceProvider();
    
    when(mockProvider.description).thenReturn('');
    when(mockProvider.total).thenReturn(0.0);
    when(mockProvider.invoiceNumber).thenReturn('9418');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InvoiceProvider>.value(
        value: mockProvider,
        child: const InvoiceScreen(),
      ),
    );
  }

  group('InvoiceScreen', () {
    testWidgets('should show all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invoice Number'), findsOneWidget);
      expect(find.text('Item Description'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
    });
  });
}
