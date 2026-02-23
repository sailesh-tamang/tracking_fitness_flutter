
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/features/bottom_screen/presentation/pages/excerise_plan.dart';

void main() {
  bool richTextContainsLabel(Widget widget, String label) {
    if (widget is RichText) {
      final span = widget.text as TextSpan;
      return span.toPlainText().contains(label);
    }
    return false;
  }

  testWidgets('ExcerisePlan displays all sections and tips', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExcerisePlan(),
      ),
    );

    // Title
    expect(find.text('Exercise'), findsOneWidget);
    // Tips header
    expect(find.text('Excerise Tips'), findsOneWidget);
    // Middle text
    expect(find.text('Fitness Goal ,Strength, TrainingCardio'), findsOneWidget);
    expect(find.textContaining('According To This'), findsOneWidget);
    // Tips (RichText)
    expect(find.byWidgetPredicate((w) => richTextContainsLabel(w, 'General Health:')), findsOneWidget);
    expect(find.byWidgetPredicate((w) => richTextContainsLabel(w, 'Weight Loss:')), findsOneWidget);
    expect(find.byWidgetPredicate((w) => richTextContainsLabel(w, 'Muscle Gain:')), findsOneWidget);
  });
}