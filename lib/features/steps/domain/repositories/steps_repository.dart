import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';

abstract interface class IStepsRepository {
  Future<Either<Failure, StepsEntity>> fetchTodaySteps();
  Future<Either<Failure, StepsEntity>> syncTodaySteps(String date, int steps);
  Stream<int> watchSensorSteps();
}
