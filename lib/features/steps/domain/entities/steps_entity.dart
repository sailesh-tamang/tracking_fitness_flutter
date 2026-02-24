import 'package:equatable/equatable.dart';

class StepsEntity extends Equatable {
  final String date;
  final int steps;

  const StepsEntity({
    required this.date,
    required this.steps,
  });

  @override
  List<Object?> get props => [date, steps];
}
