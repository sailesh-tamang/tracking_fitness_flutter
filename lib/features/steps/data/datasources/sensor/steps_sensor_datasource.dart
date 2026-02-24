import 'package:pedometer/pedometer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stepsSensorDatasourceProvider = Provider<StepsSensorDatasource>((ref) {
  return StepsSensorDatasource();
});

class StepsSensorDatasource {
  Stream<int> watchSensorSteps() {
    return Pedometer.stepCountStream.map((event) => event.steps);
  }
}
