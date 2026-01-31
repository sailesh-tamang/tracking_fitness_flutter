import 'package:fitness_tracker/core/widgets/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('MyButton shows text and calls onPressed', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Press me',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Press me'), findsOneWidget);

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    final Color? bg = button.style?.backgroundColor?.resolve(<MaterialState>{});
    expect(bg, Colors.blueAccent);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('MyButton shows disabled style when onPressed is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Disabled',
            onPressed: null,
          ),
        ),
      ),
    );

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    final Color? bg = button.style?.backgroundColor?.resolve(<MaterialState>{});
    expect(bg, Colors.grey);

    // Tapping should do nothing and not throw
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}
