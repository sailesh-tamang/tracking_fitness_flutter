import 'package:fitness_tracker/features/steps/data/models/steps_api_model.dart';

abstract interface class IStepsRemoteDataSource {
  Future<StepsApiModel?> fetchTodaySteps();
  Future<StepsApiModel?> syncTodaySteps(String date, int steps);
}
