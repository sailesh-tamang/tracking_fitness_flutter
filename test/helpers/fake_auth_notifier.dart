import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:fitness_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeAuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: AuthEntity(
        authId: 'test_id_123',
        fullName: 'Test User',
        email: 'test@gmail.com',
        phoneNumber: '1234567890',
        profilePicture: null,
      ),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: AuthEntity(
        authId: 'test_id',
        fullName: 'Test User',
        email: email,
        phoneNumber: '1234567890',
      ),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      status: AuthStatus.registered,
      user: AuthEntity(
        authId: 'test_id',
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  Future<void> updateUser({
    required String fullName,
    required String phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: state.user?.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  Future<void> uploadPhoto(String imagePath) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      status: AuthStatus.authenticated,
      uploadedPhotoUrl: 'https://example.com/photo.jpg',
    );
  }
}

extension on AuthEntity {
  AuthEntity copyWith({
    String? authId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    String? profilePicture,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
