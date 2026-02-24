import 'package:fitness_tracker/features/steps/presentation/state/steps_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StepsState', () {
    test('creates initial state with default values', () {
      const state = StepsState();

      expect(state.status, StepsStatus.initial);
      expect(state.steps, 0);
      expect(state.trackingAvailable, true);
      expect(state.errorMessage, isNull);
      expect(state.lastSyncTime, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = StepsState();
      final newState = state.copyWith(
        status: StepsStatus.loaded,
        steps: 100,
      );

      expect(newState.status, StepsStatus.loaded);
      expect(newState.steps, 100);
      expect(newState.trackingAvailable, true); // Unchanged
    });

    test('copyWith preserves unchanged values', () {
      final now = DateTime.now();
      final state = StepsState(
        status: StepsStatus.loaded,
        steps: 500,
        lastSyncTime: now,
      );

      final newState = state.copyWith(steps: 600);

      expect(newState.status, StepsStatus.loaded);
      expect(newState.steps, 600);
      expect(newState.lastSyncTime, now);
    });

    test('equality works correctly', () {
      const state1 = StepsState(status: StepsStatus.loaded, steps: 100);
      const state2 = StepsState(status: StepsStatus.loaded, steps: 100);
      const state3 = StepsState(status: StepsStatus.loaded, steps: 200);

      expect(state1, state2);
      expect(state1, isNot(state3));
    });

    test('handles error state correctly', () {
      const state = StepsState(
        status: StepsStatus.error,
        trackingAvailable: false,
        errorMessage: 'Permission denied',
      );

      expect(state.status, StepsStatus.error);
      expect(state.trackingAvailable, false);
      expect(state.errorMessage, 'Permission denied');
    });
  });
}
