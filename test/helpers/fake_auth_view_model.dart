import 'package:fitness_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fake_auth_notifier.dart';

final fakeAuthViewModelProvider = NotifierProvider<FakeAuthNotifier, AuthState>(
  FakeAuthNotifier.new,
);
