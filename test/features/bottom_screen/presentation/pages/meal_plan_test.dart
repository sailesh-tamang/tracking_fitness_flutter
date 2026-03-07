import 'package:fitness_tracker/features/bottom_screen/presentation/pages/meal_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealPlan Tests', () {
    testWidgets('MealPlan displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MealPlan(),
          ),
        ),
      );

      // Check that meal plan content is displayed
      expect(find.byType(MealPlan), findsOneWidget);
    });

    testWidgets('MealPlan displays meal options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MealPlan(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for meal plan titles
      expect(find.text('Weight Loss'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Muscle Gain'), findsOneWidget);
    });

    testWidgets('MealPlan displays meal descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MealPlan(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for meal plan descriptions
      expect(find.text('High protein, lower sugar, and portion control'),
          findsOneWidget);
      expect(find.text('Balanced calories with whole foods'), findsOneWidget);
      expect(find.text('Calorie surplus with protein each meal'), findsOneWidget);
    });

    testWidgets('MealPlan has scrollable content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MealPlan(),
          ),
        ),
      );

      // Find scrollable content
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('MealPlan displays tag chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MealPlan(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for tag content
      final tagFinder = find.byType(DecoratedBox);
      expect(tagFinder, findsWidgets);
    });
  });
}
