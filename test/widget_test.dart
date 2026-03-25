import 'package:flutter_test/flutter_test.dart';
import 'package:elada/main.dart';

void main() {
  testWidgets('Initial screen shows app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EladaApp());

    // Verify that the app title is shown.
    expect(find.text('Elada Invoice Generator'), findsOneWidget);
  });
}
