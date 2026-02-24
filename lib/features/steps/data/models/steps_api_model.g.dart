// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepsApiModel _$StepsApiModelFromJson(Map<String, dynamic> json) =>
    StepsApiModel(
      date: json['date'] as String,
      steps: (json['steps'] as num).toInt(),
    );

Map<String, dynamic> _$StepsApiModelToJson(StepsApiModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'steps': instance.steps,
    };
