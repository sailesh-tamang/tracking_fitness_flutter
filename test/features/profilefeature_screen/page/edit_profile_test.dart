import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/profilefeature_screen/page/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  testWidgets('EditProfile shows fields and opens media picker', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_full_name': 'Bob Builder',
      'user_email': 'bob@build.io',
      'user_phone_number': '+1234567890',
      'user_profile_picture': '',
    });

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: EditProfile(),
        ),
      ),
    );

    // Basic UI
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);

    // Values
    expect(find.text('Bob Builder'), findsOneWidget);
    expect(find.text('bob@build.io'), findsOneWidget);
    expect(find.text('+1234567890'), findsOneWidget);

    // Camera icon should be present; tapping it opens the bottom sheet
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    // Bottom sheet content should be visible
    expect(find.text('Open Camera'), findsOneWidget);
    expect(find.text('Open Gallery'), findsOneWidget);
  });
}