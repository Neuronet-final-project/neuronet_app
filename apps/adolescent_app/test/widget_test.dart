import 'package:flutter_test/flutter_test.dart';
import 'package:adolescent_app/main.dart';

void main() {
  testWidgets('AdolescentApp builds without crashing', (tester) async {
    // Basic smoke test: the app widget constructs
    await tester.pumpWidget(const AdolescentApp());
    expect(find.byType(AdolescentApp), findsOneWidget);
  });
}
