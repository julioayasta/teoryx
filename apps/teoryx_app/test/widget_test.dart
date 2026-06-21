import 'package:flutter_test/flutter_test.dart';
import 'package:teoryx_app/app/app_bootstrap.dart';

void main() {
  testWidgets('renders the Sprint 01 foundation shell', (tester) async {
    await tester.pumpWidget(buildTeoryXApp());
    await tester.pumpAndSettle();

    expect(find.text('TeoryX'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
