import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/features/steps/data/datasources/remote/steps_remote_datasource.dart';
import 'package:fitness_tracker/features/steps/data/datasources/sensor/steps_sensor_datasource.dart';
import 'package:fitness_tracker/features/steps/data/datasources/steps_datasource.dart';
import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';
import 'package:fitness_tracker/features/steps/domain/repositories/steps_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stepsRepositoryProvider = Provider<IStepsRepository>((ref) {
  final stepsRemoteDatasource = ref.read(stepsRemoteDatasourceProvider);
  final stepsSensorDatasource = ref.read(stepsSensorDatasourceProvider);
  return StepsRepository(
    stepsRemoteDataSource: stepsRemoteDatasource,
    stepsSensorDataSource: stepsSensorDatasource,
  );
});

class StepsRepository implements IStepsRepository {
  final IStepsRemoteDataSource _stepsRemoteDataSource;
  final StepsSensorDatasource _stepsSensorDataSource;

  StepsRepository({
    required IStepsRemoteDataSource stepsRemoteDataSource,
    required StepsSensorDatasource stepsSensorDataSource,
  })  : _stepsRemoteDataSource = stepsRemoteDataSource,
        _stepsSensorDataSource = stepsSensorDataSource;

  @override
  Future<Either<Failure, StepsEntity>> fetchTodaySteps() async {
    try {
      final apiModel = await _stepsRemoteDataSource.fetchTodaySteps();
      if (apiModel != null) {
        final entity = apiModel.toEntity();
        return Right(entity);
      }
      return const Left(ApiFailure(message: "Failed to fetch today's steps"));
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data?['message'] ?? 'Failed to fetch steps',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StepsEntity>> syncTodaySteps(
      String date, int steps) async {
    try {
      final apiModel = await _stepsRemoteDataSource.syncTodaySteps(date, steps);
      if (apiModel != null) {
        final entity = apiModel.toEntity();
        return Right(entity);
      }
      return const Left(ApiFailure(message: "Failed to sync steps"));
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data?['message'] ?? 'Failed to sync steps',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Stream<int> watchSensorSteps() {
    return _stepsSensorDataSource.watchSensorSteps();
  }
}
