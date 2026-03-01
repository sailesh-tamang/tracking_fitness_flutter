import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/features/steps/domain/usecases/fetch_today_steps_usecase.dart';
import 'package:fitness_tracker/features/steps/domain/usecases/sync_today_steps_usecase.dart';
import 'package:fitness_tracker/features/steps/domain/usecases/watch_steps_usecase.dart';
import 'package:fitness_tracker/features/steps/presentation/state/steps_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

final stepsViewModelProvider = NotifierProvider<StepsViewModel, StepsState>(
  StepsViewModel.new,
);

class StepsViewModel extends Notifier<StepsState> {
  late final FetchTodayStepsUsecase _fetchTodayStepsUsecase;
  late final SyncTodayStepsUsecase _syncTodayStepsUsecase;
  late final WatchStepsUsecase _watchStepsUsecase;

  StreamSubscription<int>? _sensorSubscription;
  Timer? _syncTimer;
  
  int _serverBaselineSteps = 0;
  int _baselineSensorSteps = 0;
  bool _isFirstSensorValue = true;

  @override
  StepsState build() {
    _fetchTodayStepsUsecase = ref.read(fetchTodayStepsUsecaseProvider);
    _syncTodayStepsUsecase = ref.read(syncTodayStepsUsecaseProvider);
    _watchStepsUsecase = ref.read(watchStepsUsecaseProvider);

    ref.onDispose(() {
      _sensorSubscription?.cancel();
      _syncTimer?.cancel();
    });

    return const StepsState();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: StepsStatus.loading);
    print('🔍 [Steps] Initializing step tracking...');

    // Check and request permissions
    final permissionGranted = await _requestPermissions();
    print('🔐 [Steps] Permission granted: $permissionGranted');
    
    if (!permissionGranted) {
      print('❌ [Steps] Activity recognition permission denied!');
      state = state.copyWith(
        status: StepsStatus.error,
        trackingAvailable: false,
        errorMessage: 'Activity recognition permission denied',
      );
      return;
    }

    // Fetch today's steps from server
    print('📥 [Steps] Fetching today steps from server...');
    await _fetchTodaySteps();

    // Start watching sensor
    print('👀 [Steps] Starting sensor stream subscription...');
    _startWatchingSensor();

    // Start periodic sync timer (every 30 seconds)
    print('⏱️ [Steps] Starting auto-sync timer (30s)...');
    _startPeriodicSync();
    
    print('✅ [Steps] Step tracking initialized successfully!');
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<void> _fetchTodaySteps() async {
    final result = await _fetchTodayStepsUsecase();

    result.fold(
      (failure) {
        // If server fails, start with 0
        print('⚠️ [Steps] Server fetch failed: ${failure.message}, starting with 0');
        _serverBaselineSteps = 0;
        state = state.copyWith(
          status: StepsStatus.loaded,
          steps: 0,
        );
      },
      (stepsEntity) {
        print('📥 [Steps] Server steps fetched: ${stepsEntity.steps}');
        _serverBaselineSteps = stepsEntity.steps;
        state = state.copyWith(
          status: StepsStatus.loaded,
          steps: stepsEntity.steps,
        );
      },
    );
  }

  void _startWatchingSensor() {
    _sensorSubscription = _watchStepsUsecase().listen(
      (sensorSteps) {
        if (_isFirstSensorValue) {
          // First value from sensor, set as baseline
          _baselineSensorSteps = sensorSteps;
          _isFirstSensorValue = false;
          print('📊 [Steps] Sensor baseline: $_baselineSensorSteps');
        }

        // Calculate delta from baseline
        final delta = (sensorSteps - _baselineSensorSteps).clamp(0, double.infinity).toInt();
        
        // Total steps = server baseline + delta
        final totalSteps = _serverBaselineSteps + delta;

        print('👟 [Steps] Sensor: $sensorSteps | Delta: $delta | Total: $totalSteps');

        state = state.copyWith(
          status: StepsStatus.loaded,
          steps: totalSteps,
        );
      },
      onError: (error) {
        print('❌ [Steps] Sensor error: $error');
        state = state.copyWith(
          status: StepsStatus.error,
          trackingAvailable: false,
          errorMessage: 'Sensor error: $error',
        );
      },
    );
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncNow();
    });
  }

  Future<void> syncNow() async {
    if (state.status == StepsStatus.syncing) {
      // Already syncing, skip
      print('⏳ [Steps] Sync already in progress, skipping...');
      return;
    }

    final previousStatus = state.status;
    print('🔄 [Steps] Starting sync... Current steps: ${state.steps}');
    state = state.copyWith(status: StepsStatus.syncing);

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Add timeout to prevent hanging
      final result = await _syncTodayStepsUsecase(
        SyncStepsParams(date: today, steps: state.steps),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [Steps] Sync timeout after 10 seconds');
          return Left(ApiFailure(message: 'Sync timeout'));
        },
      );

      result.fold(
        (failure) {
          print('❌ [Steps] Sync failed: ${failure.message}');
          state = state.copyWith(
            status: StepsStatus.syncFailed,
            errorMessage: failure.message,
          );
          // Revert to previous status after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (state.status == StepsStatus.syncFailed) {
              state = state.copyWith(status: previousStatus == StepsStatus.syncing ? StepsStatus.loaded : previousStatus);
            }
          });
        },
        (stepsEntity) {
          print('✅ [Steps] Sync successful! Steps: ${stepsEntity.steps}');
          state = state.copyWith(
            status: StepsStatus.syncSuccess,
            lastSyncTime: DateTime.now(),
          );
          // Revert to loaded status after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (state.status == StepsStatus.syncSuccess) {
              state = state.copyWith(status: StepsStatus.loaded);
            }
          });
        },
      );
    } catch (e) {
      // Catch any unexpected errors
      print('❌ [Steps] Unexpected sync error: $e');
      state = state.copyWith(
        status: StepsStatus.syncFailed,
        errorMessage: 'Sync error: $e',
      );
      // Always revert back to loaded status
      Future.delayed(const Duration(seconds: 2), () {
        state = state.copyWith(status: StepsStatus.loaded);
      });
    }
  }

  // Manual reset if state gets stuck
  void resetStatus() {
    print('🔄 [Steps] Manually resetting status to loaded');
    state = state.copyWith(status: StepsStatus.loaded);
  }

  void dispose() {
    _sensorSubscription?.cancel();
    _syncTimer?.cancel();
  }
}
