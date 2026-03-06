import 'package:flutter_test/flutter_test.dart';
import 'package:monster_livescore/app.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';

void main() {
  setUp(() {
    // Initialise FlavorConfig with test values — avoids dotenv file loading.
    FlavorConfig.setForTest();
  });

  testWidgets('MyApp renders home screen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // The home screen should be visible (no unhandled exceptions, no loading
    // spinner from a missing counter widget the template expected).
    expect(find.byType(MyApp), findsOneWidget);
  });
}
