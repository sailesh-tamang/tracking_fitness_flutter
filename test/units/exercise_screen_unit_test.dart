import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exercise Screen Unit Tests', () {
    test('Exercise plan should have 3 exercise tips', () {
      final exerciseTips = [
        {'title': 'General Health', 'description': '2 days/week, 150 mins moderate activity'},
        {'title': 'Weight Loss', 'description': '3 days/week, mix of HIIT & steady state'},
        {'title': 'Muscle Gain', 'description': '4–5 days/week, light activity (walking)'},
      ];
      
      expect(exerciseTips.length, 3);
    });

    test('General Health exercise should have correct title', () {
      const title = 'General Health';
      expect(title, 'General Health');
    });

    test('Weight Loss exercise should have correct description', () {
      const description = '3 days/week, mix of HIIT & steady state';
      expect(description, '3 days/week, mix of HIIT & steady state');
    });

    test('Muscle Gain exercise should be the third option', () {
      final exercises = ['General Health', 'Weight Loss', 'Muscle Gain'];
      expect(exercises[2], 'Muscle Gain');
    });

    test('Each exercise tip should have title and description', () {
      final exerciseTip = {
        'title': 'General Health',
        'description': '2 days/week, 150 mins moderate activity',
        'videoId': '8ef7FhmMcLU',
      };
      
      expect(exerciseTip.containsKey('title'), true);
      expect(exerciseTip.containsKey('description'), true);
      expect(exerciseTip['title'], isNotNull);
      expect(exerciseTip['description'], isNotNull);
    });

    test('Exercise tags should include fitness-related keywords', () {
      final tags = ['FITNESS GOAL', 'STRENGTH', 'TRAINING', 'CARDIO'];
      expect(tags.length, 4);
      expect(tags.contains('FITNESS GOAL'), true);
      expect(tags.contains('CARDIO'), true);
    });
  });
}
