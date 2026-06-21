import 'package:flutter/material.dart';
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
    expect(find.text('Continue learning'), findsOneWidget);
    expect(find.text('Grade 4 Math'), findsOneWidget);
    expect(find.text('Current Lesson:'), findsOneWidget);
    expect(find.text('Comparing Fractions'), findsOneWidget);
    expect(find.text('Lesson 2 of 8'), findsOneWidget);
    expect(find.text('Weekly Goal'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose New Course').last);
    await tester.pumpAndSettle();
    expect(find.text('Choose Grade'), findsOneWidget);

    await tester.tap(find.text('Grade 4'));
    await tester.pumpAndSettle();
    expect(find.text('Grade 4 Math'), findsOneWidget);

    await tester.tap(find.text('Grade 4 Math'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to Courses'), findsOneWidget);
    expect(find.text('Fractions as Parts of a Whole'), findsWidgets);

    await tester.tap(find.text('Fractions as Parts of a Whole'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to Lessons'), findsOneWidget);
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

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ES').last);
    await tester.pumpAndSettle();

    expect(find.text('Fracciones como partes de un entero'), findsWidgets);
    expect(find.text('Te perdiste la leccion de pizza'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Detalles de aprendizaje'), 300);
    expect(find.text('Detalles de aprendizaje'), findsOneWidget);
    await tester.tap(find.text('Detalles de aprendizaje'));
    await tester.pumpAndSettle();
    expect(find.text('Gran idea'), findsOneWidget);
  });
}
