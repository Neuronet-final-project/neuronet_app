import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_app/main.dart';

void main() {
  testWidgets('GuardianApp builds without crashing', (tester) async {
    // Basic smoke test: the app widget constructs
    await tester.pumpWidget(const GuardianApp());
    expect(find.byType(GuardianApp), findsOneWidget);
  });
}
