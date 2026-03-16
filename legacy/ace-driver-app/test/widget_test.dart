import 'package:flutter_test/flutter_test.dart';
import 'package:ace_taxis/main.dart';

void main() {
  testWidgets('Splash screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp()); // ✅ Use the correct widget name

    // Check if splash screen text exists
    expect(find.text('Taxi Booking\nDriver'), findsOneWidget);
  });
}
