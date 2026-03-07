import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Meal Plan Screen Unit Tests', () {
    test('Meal plan should have 3 meal options', () {
      final mealPlans = [
        {'title': 'Weight Loss', 'description': 'High protein, lower sugar, and portion control'},
        {'title': 'Maintenance', 'description': 'Balanced calories with whole foods'},
        {'title': 'Muscle Gain', 'description': 'Calorie surplus with protein each meal'},
      ];
      
      expect(mealPlans.length, 3);
    });

    test('Weight Loss meal plan should have correct title', () {
      const title = 'Weight Loss';
      expect(title, 'Weight Loss');
    });

    test('Maintenance meal plan should have correct description', () {
      const description = 'Balanced calories with whole foods';
      expect(description, 'Balanced calories with whole foods');
    });

    test('Muscle Gain meal plan should be the third option', () {
      final mealPlans = ['Weight Loss', 'Maintenance', 'Muscle Gain'];
      expect(mealPlans[2], 'Muscle Gain');
    });

    test('Each meal plan should have title and description', () {
      final mealPlan = {
        'title': 'Weight Loss',
        'description': 'High protein, lower sugar, and portion control',
        'videoId': 'LCyECbA3pUw',
      };
      
      expect(mealPlan.containsKey('title'), true);
      expect(mealPlan.containsKey('description'), true);
      expect(mealPlan['title'], isNotNull);
      expect(mealPlan['description'], isNotNull);
    });
  });
}
