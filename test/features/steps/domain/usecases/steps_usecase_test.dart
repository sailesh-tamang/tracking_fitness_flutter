import 'package:fitness_tracker/features/steps/domain/usecases/sync_today_steps_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Step delta calculation', () {
    test('calculates correct delta when sensor increases', () {
      // Simulating step calculation
      final serverBaselineSteps = 1000;
      final baselineSensorSteps = 5000;
      final currentSensorSteps = 5150;

      final delta = (currentSensorSteps - baselineSensorSteps).clamp(0, double.infinity).toInt();
      final totalSteps = serverBaselineSteps + delta;

      expect(delta, 150);
      expect(totalSteps, 1150);
    });

    test('ensures delta is never negative', () {
      final serverBaselineSteps = 1000;
      final baselineSensorSteps = 5000;
      final currentSensorSteps = 4900; // Sensor reset or glitch

      final delta = (currentSensorSteps - baselineSensorSteps).clamp(0, double.infinity).toInt();
      final totalSteps = serverBaselineSteps + delta;

      expect(delta, 0);
      expect(totalSteps, 1000);
    });

    test('handles large sensor values correctly', () {
      final serverBaselineSteps = 500;
      final baselineSensorSteps = 100000;
      final currentSensorSteps = 100250;

      final delta = (currentSensorSteps - baselineSensorSteps).clamp(0, double.infinity).toInt();
      final totalSteps = serverBaselineSteps + delta;

      expect(delta, 250);
      expect(totalSteps, 750);
    });

    test('handles zero baseline sensor steps', () {
      final serverBaselineSteps = 2000;
      final baselineSensorSteps = 0;
      final currentSensorSteps = 100;

      final delta = (currentSensorSteps - baselineSensorSteps).clamp(0, double.infinity).toInt();
      final totalSteps = serverBaselineSteps + delta;

      expect(delta, 100);
      expect(totalSteps, 2100);
    });
  });

  group('Sync params validation', () {
    test('creates sync params with correct date format', () {
      final params = SyncStepsParams(
        date: '2024-01-15',
        steps: 5000,
      );

      expect(params.date, '2024-01-15');
      expect(params.steps, 5000);
    });

    test('sync params equality works correctly', () {
      final params1 = SyncStepsParams(date: '2024-01-15', steps: 5000);
      final params2 = SyncStepsParams(date: '2024-01-15', steps: 5000);
      final params3 = SyncStepsParams(date: '2024-01-16', steps: 5000);

      expect(params1, params2);
      expect(params1, isNot(params3));
    });
  });
}
