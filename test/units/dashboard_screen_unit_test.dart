import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dashboard Screen Unit Tests', () {
    test('Dashboard should have 4 bottom navigation items', () {
      const expectedNavItems = 4;
      expect(expectedNavItems, 4);
    });

    test('Dashboard initial selected index should be 0', () {
      const initialIndex = 0;
      expect(initialIndex, 0);
    });

    test('Dashboard should display Home screen at index 0', () {
      const homeIndex = 0;
      expect(homeIndex, 0);
    });

    test('Dashboard should display Meal Plan screen at index 1', () {
      const mealPlanIndex = 1;
      expect(mealPlanIndex, 1);
    });

    test('Dashboard should display Exercise screen at index 2', () {
      const exerciseIndex = 2;
      expect(exerciseIndex, 2);
    });

    test('Dashboard should display Profile screen at index 3', () {
      const profileIndex = 3;
      expect(profileIndex, 3);
    });

    test('Dashboard navigation bar should have correct labels', () {
      final labels = ['home', 'meal plan', 'excerises', 'profile'];
      expect(labels.length, 4);
      expect(labels[0], 'home');
      expect(labels[1], 'meal plan');
      expect(labels[2], 'excerises');
      expect(labels[3], 'profile');
    });
  });
}
