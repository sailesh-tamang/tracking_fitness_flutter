import 'package:fitness_tracker/core/utils/mysnakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('showMySnackBar displays a SnackBar with message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showMySnackBar(context: context, message: 'Hello Snack');
                },
                child: const Text('Show'),
              ),
            ),
          );
        }),
      ),
    );

    expect(find.text('Hello Snack'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // let the snackbar animation complete
    await tester.pumpAndSettle();

    expect(find.text('Hello Snack'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('showMySnackBar applies provided background color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showMySnackBar(context: context, message: 'Colored', color: Colors.red);
                },
                child: const Text('Show'),
              ),
            ),
          );
        }),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.red);
  });
}
