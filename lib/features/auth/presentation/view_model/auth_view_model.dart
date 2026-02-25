import 'dart:io';

import 'package:fitness_tracker/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_hive_model.dart';
import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/register_usecase.dart';
import 'package:fitness_tracker/features/auth/domain/usecases/update_user_usecase.dart';
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
  late final UpdateUserUsecase _updateUserUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    _updateUserUsecase = ref.read(updateUserUsecaseProvider);
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

    // Save the profile picture to session and Hive for persistence
    if (uploadedUrl != null) {
      try {
        final userSessionService = ref.read(userSessionServiceProvider);

        // Update session (SharedPreferences)
        await userSessionService.updateUserProfilePicture(uploadedUrl!);
        print('✅ Profile picture saved to session: $uploadedUrl');

        // Also update in Hive database for persistence
        final userId = userSessionService.getCurrentUserId();
        if (userId != null) {
          final currentUserResult = await _getCurrentUserUsecase();
          await currentUserResult.fold(
            (failure) async {
              print('⚠️ Could not get current user to update Hive: ${failure.message}');
            },
            (currentUser) async {
              final updatedEntity = AuthEntity(
                authId: currentUser.authId,
                fullName: currentUser.fullName,
                email: currentUser.email,
                phoneNumber: currentUser.phoneNumber,
                password: currentUser.password,
                profilePicture: uploadedUrl,
              );

              final localDatasource = ref.read(authLocalDatasourceProvider);
              final hiveModel = AuthHiveModel(
                authId: updatedEntity.authId,
                fullName: updatedEntity.fullName,
                email: updatedEntity.email,
                phoneNumber: updatedEntity.phoneNumber,
                password: currentUser.password,
                profilePicture: uploadedUrl,
              );

              final success = await localDatasource.updateUser(hiveModel);
              if (success) {
                print('✅ Profile picture also saved to Hive database');
                state = state.copyWith(user: updatedEntity);
              } else {
                print('❌ Failed to update profile picture in Hive');
              }
            },
          );
        }
      } catch (e) {
        print('❌ Error saving profile picture: $e');
      }
    } else {
      print('❌ Upload returned null URL');
    }

    return uploadedUrl;
  }

  Future<bool> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    print('📝 [Auth] Updating user profile...');

    final result = await _updateUserUsecase(
      UpdateUserParams(
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );

    return result.fold(
      (failure) {
        print('❌ [Auth] Update failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedUser) async {
        print('✅ [Auth] Update successful');
        
        // Update session with new user data
        try {
          final userSessionService = ref.read(userSessionServiceProvider);
          await userSessionService.saveUserSession(
            userId: updatedUser.authId!,
            email: updatedUser.email,
            fullName: updatedUser.fullName,
            phoneNumber: updatedUser.phoneNumber,
            profilePicture: updatedUser.profilePicture,
          );
          print('✅ [Auth] Session updated with new user data');
        } catch (e) {
          print('❌ [Auth] Error updating session: $e');
        }
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
        );
        return true;
      },
    );
  }

  Future<bool> deleteCustomer(String userId, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    print('🗑️ [Auth] Deleting customer account...');

    try {
      // TODO: Implement delete customer logic when backend endpoint is ready
      // This is a placeholder that expects the backend to handle password verification
      // and account deletion
      
      print('⚠️ [Auth] Delete customer method not fully implemented - awaiting backend endpoint details');
      
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Account deletion feature is not yet available',
      );
      return false;
    } catch (e) {
      print('❌ [Auth] Error deleting account: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}