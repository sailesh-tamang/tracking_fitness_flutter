import 'package:fitness_tracker/features/auth/presentation/utils/login_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login email validation', () {
    test('returns error when email is empty', () {
      expect(
        LoginValidators.email(''),
        'Please enter an email',
      );
    });

    test('returns error when email is invalid', () {
      expect(
        LoginValidators.email('not-an-email'),
        'Please enter a valid email',
      );
    });

    test('returns null when email is valid', () {
      expect(
        LoginValidators.email('test@gmail.com'),
        isNull,
      );
    });
  });

  group('Login password validation', () {
    test('returns error when password is empty', () {
      expect(
        LoginValidators.password(''),
        'Please enter a password',
      );
    });

    test('returns error when password is too short', () {
      expect(
        LoginValidators.password('12345'),
        'Password must be at least 8 characters',
      );
    });

    test('returns null when password is valid', () {
      expect(
        LoginValidators.password('password123'),
        isNull,
      );
    });
  });
}
