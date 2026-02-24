import 'package:fitness_tracker/core/api/api_client.dart';
import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/features/steps/data/datasources/steps_datasource.dart';
import 'package:fitness_tracker/features/steps/data/models/steps_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stepsRemoteDatasourceProvider = Provider<IStepsRemoteDataSource>((ref) {
  return StepsRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class StepsRemoteDatasource implements IStepsRemoteDataSource {
  final ApiClient _apiClient;

  StepsRemoteDatasource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<StepsApiModel?> fetchTodaySteps() async {
    final response = await _apiClient.get(
      ApiEndpoints.stepsToday,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return StepsApiModel.fromJson(data);
    }

    return null;
  }

  @override
  Future<StepsApiModel?> syncTodaySteps(String date, int steps) async {
    final response = await _apiClient.post(
      ApiEndpoints.stepsSync,
      data: {
        'date': date,
        'steps': steps,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return StepsApiModel.fromJson(data);
    }

    return null;
  }
}
