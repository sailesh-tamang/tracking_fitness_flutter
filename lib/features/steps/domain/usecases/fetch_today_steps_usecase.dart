import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/usecases/app_usecase.dart';
import 'package:fitness_tracker/features/steps/data/repositories/steps_repository.dart';
import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';
import 'package:fitness_tracker/features/steps/domain/repositories/steps_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fetchTodayStepsUsecaseProvider = Provider<FetchTodayStepsUsecase>((ref) {
  final stepsRepository = ref.read(stepsRepositoryProvider);
  return FetchTodayStepsUsecase(stepsRepository: stepsRepository);
});

class FetchTodayStepsUsecase implements UsecaseWithoutParms<StepsEntity> {
  final IStepsRepository _stepsRepository;

  FetchTodayStepsUsecase({required IStepsRepository stepsRepository})
      : _stepsRepository = stepsRepository;

  @override
  Future<Either<Failure, StepsEntity>> call() {
    return _stepsRepository.fetchTodaySteps();
  }
}
