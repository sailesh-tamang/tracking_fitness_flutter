
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/services/connecitvity/network_info.dart';
import 'package:fitness_tracker/features/auth/data/datasources/auth_datasource.dart';
import 'package:fitness_tracker/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_tracker/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_api_model.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_hive_model.dart';
import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:fitness_tracker/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository{

  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authDataSource = authDatasource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
    
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        print('🌐 Attempting remote login for: $email');
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          // Check if user already exists in local database
          final existingUser = await _authDataSource.getUserByEmail(apiModel.email);
          
          // Create/update user in local database for offline access and profile updates
          final localModel = AuthHiveModel(
            authId: apiModel.id,
            fullName: apiModel.fullName,
            email: apiModel.email,
            phoneNumber: apiModel.phoneNumber,
            password: password, // Store password for local verification
            profilePicture: apiModel.profilePicture,
          );
          
          if (existingUser != null) {
            // Update existing user with new password
            print('📝 Updating existing user in Hive with fresh password');
            await _authDataSource.updateUser(localModel);
          } else {
            // Register new user
            print('✨ Registering new user in Hive');
            await _authDataSource.register(localModel);
          }
          
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid email or password"));
      } on DioException catch (e) {
        print('⚠️ Remote login failed: ${e.message}');
        print('🔄 Attempting local login as fallback...');
        
        // Fallback to local login if remote fails
        try {
          final model = await _authDataSource.login(email, password);
          if (model != null) {
            print('✅ Local login successful');
            final entity = model.toEntity();
            return Right(entity);
          }
          // If local login also fails, return the original API error
          return Left(ApiFailure(
            message: e.response?.data?['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ));
        } catch (localError) {
          return Left(ApiFailure(
            message: e.response?.data?['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ));
        }
      } catch (e) {
        print('⚠️ Remote login error: $e');
        print('🔄 Attempting local login as fallback...');
        
        // Fallback to local login
        try {
          final model = await _authDataSource.login(email, password);
          if (model != null) {
            print('✅ Local login successful');
            final entity = model.toEntity();
            return Right(entity);
          }
          return Left(ApiFailure(message: e.toString()));
        } catch (localError) {
          return Left(ApiFailure(message: e.toString()));
        }
      }
    } else {
      print('📴 No network connection, using local login');
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        final registeredUser = await _authRemoteDataSource.register(apiModel);
        
        // Also save to local database for offline access
        final localModel = AuthHiveModel(
          authId: registeredUser.id,
          fullName: registeredUser.fullName,
          email: registeredUser.email,
          phoneNumber: registeredUser.phoneNumber,
          password: user.password, // Store password for local verification
          profilePicture: registeredUser.profilePicture,
        );
        await _authDataSource.register(localModel);
        
        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data?['message'] ?? 'Registration failed',
          statusCode: e.response?.statusCode,
          ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }else {
      try {
        // Check if email already exists
        final existingUser = await _authDataSource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }
        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          password: user.password,
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDataSource.uploadPhoto(image);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity entity, String password) async {
    // First, get current user from local database to verify password
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      print('❌ Update failed: No user found in local database');
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    }

    print('📝 Current user found: ${currentUser.email}');
    print('📝 Password in database: ${currentUser.password?.isEmpty == true ? "EMPTY" : "EXISTS"}');
    
    // Check if password is missing (user logged in before sync was implemented)
    if (currentUser.password == null || currentUser.password!.isEmpty) {
      print('❌ Update failed: Password not stored in database');
      return const Left(LocalDatabaseFailure(
        message: "Please log out and log back in to update your profile"
      ));
    }

    // Verify password
    if (currentUser.password != password) {
      print('❌ Update failed: Password mismatch');
      return const Left(LocalDatabaseFailure(message: "Incorrect password"));
    }
    
    print('✅ Password verified successfully');

    // Try to update on backend first if connected
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel(
          id: currentUser.authId,
          fullName: entity.fullName,
          email: entity.email,
          phoneNumber: entity.phoneNumber,
          profilePicture: entity.profilePicture,
        );
        
        final updatedApiUser = await _authRemoteDataSource.updateUser(
          currentUser.authId!,
          apiModel,
        );

        // Also update in local database for offline access
        final updatedLocalUser = AuthHiveModel(
          authId: updatedApiUser.id,
          fullName: updatedApiUser.fullName,
          email: updatedApiUser.email,
          phoneNumber: updatedApiUser.phoneNumber,
          password: currentUser.password, // Keep the same password
          profilePicture: updatedApiUser.profilePicture,
        );
        await _authDataSource.updateUser(updatedLocalUser);

        return Right(updatedApiUser.toEntity());
      } on DioException catch (e) {
        // If backend update fails, try local update
        print('⚠️ Backend update failed, attempting local update: ${e.message}');
      } catch (e) {
        print('⚠️ Error during remote update: $e');
      }
    }

    // Fall back to local update (offline or backend failed)
    try {
      final updatedUser = AuthHiveModel(
        authId: currentUser.authId,
        fullName: entity.fullName,
        email: entity.email,
        phoneNumber: entity.phoneNumber,
        password: currentUser.password,
        profilePicture: entity.profilePicture ?? currentUser.profilePicture,
      );

      final success = await _authDataSource.updateUser(updatedUser);
      if (success) {
        return Right(updatedUser.toEntity());
      } else {
        return const Left(LocalDatabaseFailure(message: "Failed to update user"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}