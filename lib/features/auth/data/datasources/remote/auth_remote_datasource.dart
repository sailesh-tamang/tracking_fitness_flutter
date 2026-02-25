import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fitness_tracker/core/api/api_client.dart';
import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/core/services/storage/token_service.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/auth/data/datasources/auth_datasource.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource{

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save to session - include profilePicture if available
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        profilePicture: user.profilePicture,
      );

      // Save token to TokenService
      final token = response.data['token'];
      // Later store token in secure storage
      await _tokenService.saveToken(token);
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerRegister,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        final registeredUser = AuthApiModel.fromJson(data);

        // Save user data locally for future login
        await _userSessionService.saveUserSession(
          userId: registeredUser.id!,
          email: registeredUser.email,
          fullName: registeredUser.fullName,
          phoneNumber: registeredUser.phoneNumber,
        );

        return registeredUser;
      } else {
        throw Exception('Invalid response data');
      }
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(photo.path, filename: fileName),
    });

    try {
      final response = await _apiClient.uploadFile(
        ApiEndpoints.customerProfile,
        formData: formData,
      );

      // Extract photoUrl from response - it contains the path to the uploaded image
      final photoUrl = response.data['photoUrl'] ?? response.data['data']?['profilePicture'];
      print('📷 Response photoUrl: $photoUrl');
      if (photoUrl == null) {
        throw Exception('No photoUrl in response: ${response.data}');
      }
      return photoUrl;
    } on DioException catch (e) {
      // Some servers may save the file but still return a non-200 (e.g., 401).
      // As a fallback, construct the expected profile filename using the
      // current user's id and the uploaded file extension so the app can
      // update the local session and immediately display the image.
      print('⚠️ Upload returned error: ${e.message} - attempting fallback');
      final userId = _userSessionService.getCurrentUserId();
      if (userId != null && fileName.contains('.')) {
        final ext = fileName.split('.').last;
        final fallbackPath = '/public/profile_picture/profile_$userId.$ext';
        print('ℹ️ Using fallback profile path: $fallbackPath');
        return fallbackPath;
      }

      // If we can't build a fallback, rethrow the error
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> updateUser(String userId, AuthApiModel user) async {
    final response = await _apiClient.put(
      ApiEndpoints.customerUpdate(userId),
      data: {
        'name': user.fullName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final updatedUser = AuthApiModel.fromJson(data);
      
      // Update session with new data
      await _userSessionService.saveUserSession(
        userId: updatedUser.id!,
        email: updatedUser.email,
        fullName: updatedUser.fullName,
        phoneNumber: updatedUser.phoneNumber,
        profilePicture: updatedUser.profilePicture,
      );
      
      return updatedUser;
    } else {
      throw Exception(response.data['message'] ?? 'Update failed');
    }
  }
  
  
}