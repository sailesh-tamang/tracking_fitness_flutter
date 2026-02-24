import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/usecases/app_usecase.dart';
import 'package:fitness_tracker/features/steps/data/repositories/steps_repository.dart';
import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';
import 'package:fitness_tracker/features/steps/domain/repositories/steps_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncStepsParams extends Equatable {
  final String date;
  final int steps;

  const SyncStepsParams({
    required this.date,
    required this.steps,
  });

  @override
  List<Object?> get props => [date, steps];
}

final syncTodayStepsUsecaseProvider = Provider<SyncTodayStepsUsecase>((ref) {
  final stepsRepository = ref.read(stepsRepositoryProvider);
  return SyncTodayStepsUsecase(stepsRepository: stepsRepository);
});

class SyncTodayStepsUsecase implements UsecaseWithParms<StepsEntity, SyncStepsParams> {
  final IStepsRepository _stepsRepository;

  SyncTodayStepsUsecase({required IStepsRepository stepsRepository})
      : _stepsRepository = stepsRepository;

  @override
  Future<Either<Failure, StepsEntity>> call(SyncStepsParams params) {
    return _stepsRepository.syncTodaySteps(params.date, params.steps);
  }
}
