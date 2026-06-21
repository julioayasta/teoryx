import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teoryx_app/app/app_bootstrap.dart';

void main() {
  testWidgets('navigates through the Sprint 02 student vertical slice', (
    tester,
  ) async {
    await tester.pumpWidget(buildTeoryXApp());
    await tester.pumpAndSettle();

    expect(find.text('Knowledge for Success'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    expect(find.text('Continue as Student'), findsNothing);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Sofia'), findsWidgets);
    expect(find.text('Continue Studying'), findsOneWidget);
    expect(find.text('Grade 4 Math'), findsOneWidget);
    expect(find.text('Current Lesson:'), findsOneWidget);
    expect(find.text('Comparing Fractions'), findsOneWidget);
    expect(find.text('Lesson 2 of 8'), findsOneWidget);
    expect(find.byIcon(Icons.grade_outlined), findsNothing);
    expect(find.byIcon(Icons.calculate_outlined), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to Lessons'), findsOneWidget);
    expect(find.text('Two Tables, Two Pizzas'), findsOneWidget);
    expect(find.byTooltip('Student Dashboard'), findsOneWidget);

    await tester.tap(find.byTooltip('Student Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Sofia'), findsWidgets);

    await tester.tap(find.text('New Course from Catalog'));
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
  });
}
