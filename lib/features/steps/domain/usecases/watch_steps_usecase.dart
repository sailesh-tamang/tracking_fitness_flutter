import 'package:fitness_tracker/features/steps/data/repositories/steps_repository.dart';
import 'package:fitness_tracker/features/steps/domain/repositories/steps_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final watchStepsUsecaseProvider = Provider<WatchStepsUsecase>((ref) {
  final stepsRepository = ref.read(stepsRepositoryProvider);
  return WatchStepsUsecase(stepsRepository: stepsRepository);
});

class WatchStepsUsecase {
  final IStepsRepository _stepsRepository;

  WatchStepsUsecase({required IStepsRepository stepsRepository})
      : _stepsRepository = stepsRepository;

  Stream<int> call() {
    return _stepsRepository.watchSensorSteps();
  }
}
