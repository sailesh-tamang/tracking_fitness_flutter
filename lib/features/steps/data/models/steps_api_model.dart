import 'package:fitness_tracker/features/steps/domain/entities/steps_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'steps_api_model.g.dart';

@JsonSerializable()
class StepsApiModel {
  final String date;
  final int steps;

  StepsApiModel({
    required this.date,
    required this.steps,
  });

  factory StepsApiModel.fromJson(Map<String, dynamic> json) =>
      _$StepsApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepsApiModelToJson(this);

  StepsEntity toEntity() {
    return StepsEntity(
      date: date,
      steps: steps,
    );
  }

  factory StepsApiModel.fromEntity(StepsEntity entity) {
    return StepsApiModel(
      date: entity.date,
      steps: entity.steps,
    );
  }
}
