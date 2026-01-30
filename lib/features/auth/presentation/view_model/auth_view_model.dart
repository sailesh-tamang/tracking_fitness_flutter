import 'dart:io';

import 'package:fitness_tracker/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/register_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:fitness_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/storage/user_session_service.dart' show userSessionServiceProvider;

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<String?> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadPhotoUsecase(photo);

    String? uploadedUrl;

    result.fold(
      (failure) {
        print('❌ Upload failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (url) {
        print('✅ Upload successful, received URL: $url');
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadedPhotoUrl: url,
        );
        uploadedUrl = url;
      },
    );

    // Save the profile picture filename to session for persistence if upload was successful
    if (uploadedUrl != null) {
      try {
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.updateUserProfilePicture(uploadedUrl!);
        print('✅ Profile picture saved to session: $uploadedUrl');
      } catch (e) {
        print('❌ Error saving profile picture to session: $e');
      }
    } else {
      print('❌ Upload returned null URL');
    }

    return uploadedUrl;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}