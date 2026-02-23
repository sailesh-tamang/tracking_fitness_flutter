import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/bottom_screen/presentation/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  testWidgets('ProfileScreen shows user info and logout dialog', (tester) async {
    // Prepare fake SharedPreferences values matching UserSessionService keys
    SharedPreferences.setMockInitialValues({
      'user_full_name': 'Alice Wonderland',
      'user_email': 'alice@example.com',
      'user_profile_picture': '',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Verify header and user info
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Alice Wonderland'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);

    // Menu items exist
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Tap Logout menu and check dialog appears, then cancel
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.text('Are you sure you want to logout?'), findsNothing);
  });
}