import 'package:fitness_tracker/core/widgets/mytextfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyTextformfield displays label, hint and validates', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextformfield(
              labelText: 'Name',
              hintText: 'Enter name',
              controller: controller,
              errorMessage: 'Name required',
            ),
          ),
        ),
      ),
    );

    // Labels and hint
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Enter name'), findsOneWidget);

    // Initially invalid (empty)
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Name required'), findsOneWidget);

    // Fill and validate
    controller.text = 'Alice';
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Name required'), findsNothing);
  });

  testWidgets('MyTextformfield respects obscureText and keyboardType', (tester) async {
    final controller = TextEditingController(text: 'secret');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextformfield(
            labelText: 'Password',
            hintText: 'Enter',
            controller: controller,
            errorMessage: 'Required',
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
          ),
        ),
      ),
    );

    final EditableText editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
    expect(editable.keyboardType, TextInputType.visiblePassword);
  });
}
