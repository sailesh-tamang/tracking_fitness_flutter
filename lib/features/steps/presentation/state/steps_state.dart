import 'package:equatable/equatable.dart';

enum StepsStatus {
  initial,
  loading,
  loaded,
  syncing,
  syncSuccess,
  syncFailed,
  error,
}

class StepsState extends Equatable {
  final StepsStatus status;
  final int steps;
  final bool trackingAvailable;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const StepsState({
    this.status = StepsStatus.initial,
    this.steps = 0,
    this.trackingAvailable = true,
    this.errorMessage,
    this.lastSyncTime,
  });

  // Average human step length in meters (0.762m or 2.5 feet)
  static const double _stepLengthMeters = 0.762;
  // Average calories burned per step (for 70kg person)
  static const double _caloriesPerStep = 0.04;

  // Calculate distance in meters
  double get distanceInMeters => steps * _stepLengthMeters;

  // Calculate distance in kilometers
  double get distanceInKilometers => distanceInMeters / 1000;

  // Calculate calories burned
  double get caloriesBurned => steps * _caloriesPerStep;

  StepsState copyWith({
    StepsStatus? status,
    int? steps,
    bool? trackingAvailable,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return StepsState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      trackingAvailable: trackingAvailable ?? this.trackingAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  // Format distance for display
  String get formattedDistance {
    if (distanceInKilometers >= 1.0) {
      return '${distanceInKilometers.toStringAsFixed(2)} km';
    } else {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    }
  }

  // Format calories for display
  String get formattedCalories {
    return '${caloriesBurned.toStringAsFixed(1)} cal';
  }

  @override
  List<Object?> get props =>
      [status, steps, trackingAvailable, errorMessage, lastSyncTime];
}
