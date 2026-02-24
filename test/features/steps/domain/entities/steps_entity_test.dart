import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StepsEntity', () {
    test('creates entity with correct values', () {
      final entity = StepsEntity(
        date: '2024-01-15',
        steps: 5000,
      );

      expect(entity.date, '2024-01-15');
      expect(entity.steps, 5000);
    });

    test('equality works correctly', () {
      final entity1 = StepsEntity(date: '2024-01-15', steps: 5000);
      final entity2 = StepsEntity(date: '2024-01-15', steps: 5000);
      final entity3 = StepsEntity(date: '2024-01-16', steps: 5000);

      expect(entity1, entity2);
      expect(entity1, isNot(entity3));
    });

    test('props includes all fields', () {
      final entity = StepsEntity(date: '2024-01-15', steps: 5000);
      
      expect(entity.props, ['2024-01-15', 5000]);
      expect(entity.props.length, 2);
    });
  });
}
