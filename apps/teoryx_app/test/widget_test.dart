import 'package:flutter_test/flutter_test.dart';
import 'package:teoryx_app/app/app_bootstrap.dart';

void main() {
  testWidgets('navigates through the Sprint 02 student vertical slice', (
    tester,
  ) async {
    await tester.pumpWidget(buildTeoryXApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to TeoryX'), findsOneWidget);

    await tester.tap(find.text('Continue as Student'));
    await tester.pumpAndSettle();
    expect(find.text('Student Dashboard'), findsOneWidget);

    await tester.tap(find.text('View all lessons'));
    await tester.pumpAndSettle();
    expect(find.text('Fractions as Parts of a Whole'), findsOneWidget);

    await tester.tap(find.text('Fractions as Parts of a Whole'));
    await tester.pumpAndSettle();
    expect(find.text('Big Idea'), findsOneWidget);
    expect(find.text('Learning Objective'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Ask Tutor'), 300);
    await tester.tap(find.text('Ask Tutor'));
    await tester.pumpAndSettle();
    expect(find.text('Tutor Chat'), findsOneWidget);
    expect(find.textContaining('Let us reason'), findsOneWidget);
  });
}
