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

    await tester.tap(find.text('Choose course'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Course'), findsOneWidget);
    expect(find.text('Grade 4 Math'), findsOneWidget);

    await tester.tap(find.text('Grade 4 Math'));
    await tester.pumpAndSettle();
    expect(find.text('Back to Courses'), findsOneWidget);
    expect(find.text('Fractions as Parts of a Whole'), findsWidgets);

    await tester.tap(find.text('Fractions as Parts of a Whole'));
    await tester.pumpAndSettle();
    expect(find.text('Back to Lessons'), findsOneWidget);
    expect(find.text('You Missed The Pizza Lesson'), findsOneWidget);
    expect(find.text('Big Idea'), findsNothing);

    await tester.tap(find.text('Ask Tutor'));
    await tester.pumpAndSettle();
    expect(find.text('Tutor Chat'), findsOneWidget);
    expect(find.textContaining('Let us reason'), findsOneWidget);
    expect(find.text('Fractions as Parts of a Whole'), findsWidgets);

    await tester.tap(find.byTooltip('Close tutor chat'));
    await tester.pumpAndSettle();
    expect(find.text('Tutor Chat'), findsNothing);
    expect(find.text('Fractions as Parts of a Whole'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Learning details'), 300);
    expect(find.text('Learning details'), findsOneWidget);
    await tester.tap(find.text('Learning details'));
    await tester.pumpAndSettle();
    expect(find.text('Big Idea'), findsOneWidget);
  });
}
