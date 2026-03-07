import 'package:flutter_test/flutter_test.dart';
import '../../../helpers.dart';

void main() {
  group('UserSessionService Tests', () {
    testWidgets('FakeUserSessionService returns correct user data',
        (WidgetTester tester) async {
      final userService = FakeUserSessionService();

      expect(userService.getCurrentUserFullName(), 'Test User');
      expect(userService.getCurrentUserEmail(), 'test@gmail.com');
      expect(userService.getCurrentUserId(), 'test_id_123');
      expect(userService.getCurrentUserPhoneNumber(), '1234567890');
      expect(userService.isLoggedIn(), true);
    });

    testWidgets('FakeUserSessionService can customize user data',
        (WidgetTester tester) async {
      final userService = FakeUserSessionService(
        fullName: 'Custom User',
        email: 'custom@example.com',
        userId: 'custom_id',
        phoneNumber: '9876543210',
        loggedIn: true,
      );

      expect(userService.getCurrentUserFullName(), 'Custom User');
      expect(userService.getCurrentUserEmail(), 'custom@example.com');
      expect(userService.getCurrentUserId(), 'custom_id');
    });

    testWidgets('FakeUserSessionService handles logout state',
        (WidgetTester tester) async {
      final userService = FakeUserSessionService(loggedIn: false);

      expect(userService.isLoggedIn(), false);
    });

    testWidgets('FakeSharedPreferences stores and retrieves data',
        (WidgetTester tester) async {
      final prefs = FakeSharedPreferences();

      // Test string
      await prefs.setString('test_key', 'test_value');
      expect(prefs.getString('test_key'), 'test_value');

      // Test int
      await prefs.setInt('int_key', 42);
      expect(prefs.getInt('int_key'), 42);

      // Test bool
      await prefs.setBool('bool_key', true);
      expect(prefs.getBool('bool_key'), true);

      // Test removal
      await prefs.remove('test_key');
      expect(prefs.getString('test_key'), null);
    });

    testWidgets('FakeSharedPreferences clears all data',
        (WidgetTester tester) async {
      final prefs = FakeSharedPreferences();

      await prefs.setString('key1', 'value1');
      await prefs.setInt('key2', 100);

      await prefs.clear();

      expect(prefs.getString('key1'), null);
      expect(prefs.getInt('key2'), null);
    });
  });
}
