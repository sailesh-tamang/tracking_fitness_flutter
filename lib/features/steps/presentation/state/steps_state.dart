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

  @override
  List<Object?> get props =>
      [status, steps, trackingAvailable, errorMessage, lastSyncTime];
}
