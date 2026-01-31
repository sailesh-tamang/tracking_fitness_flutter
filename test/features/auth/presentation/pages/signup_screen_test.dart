import 'package:fitness_tracker/features/auth/presentation/utils/signup_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Signup: name validation', () {
    test('returns error when name is empty', () {
      expect(SignupValidators.name(''), 'Please enter your name');
    });

    test('returns error when name is too short', () {
      expect(SignupValidators.name('ab'), 'Name must be at least 3 characters');
    });

    test('returns null when name is valid', () {
      expect(SignupValidators.name('Alex'), isNull);
    });
  });

  group('Signup: email validation', () {
    test('returns error when email is empty', () {
      expect(SignupValidators.email(''), 'Please enter an email');
    });

    test('returns error when email is invalid', () {
      expect(SignupValidators.email('abc'), 'Please enter a valid email');
    });

    test('returns null when email is valid', () {
      expect(SignupValidators.email('test@gmail.com'), isNull);
    });
  });

  group('Signup: phone validation', () {
    test('returns error when phone is empty', () {
      expect(SignupValidators.phone(''), 'Please enter a phone number');
    });

    test('returns error when phone is too short', () {
      expect(SignupValidators.phone('12345'), 'Phone number must be at least 10 digits');
    });

    test('returns null when phone is valid', () {
      expect(SignupValidators.phone('9812345678'), isNull);
    });
  });

  group('Signup: password validation', () {
    test('returns error when password is empty', () {
      expect(SignupValidators.password(''), 'Please enter a password');
    });

    test('returns error when password is too short', () {
      expect(SignupValidators.password('1234567'), 'Password must be at least 8 characters');
    });

    test('returns null when password is valid', () {
      expect(SignupValidators.password('password123'), isNull);
    });
  });
}
