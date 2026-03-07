import 'package:fitness_tracker/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'test_utils.dart';

void main() {
  testWidgets('DashboardScreen bottom navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(FakeUserSessionService()),
          sharedPreferencesProvider.overrideWithValue(FakeSharedPreferences()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Home tab is default
    expect(find.text('Dashboard'), findsOneWidget);

    // Tap Meal Plan
    await tester.tap(find.text('meal plan'));
    await tester.pumpAndSettle();
    expect(find.text('Meal Plan'), findsOneWidget);

    // Tap Excerises
    await tester.tap(find.text('excerises'));
    await tester.pumpAndSettle();
    expect(find.text('Exercise'), findsOneWidget);

    // Tap Profile
    await tester.tap(find.text('profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@gmail.com'), findsOneWidget);
  });
}
