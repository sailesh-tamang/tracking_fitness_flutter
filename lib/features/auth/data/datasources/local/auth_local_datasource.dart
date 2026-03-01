import 'package:fitness_tracker/core/services/hive/hive_service.dart';
import 'package:fitness_tracker/core/services/biometric/biometric_auth_service.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/auth/data/datasources/auth_datasource.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final biometricAuthService = ref.read(biometricAuthServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
    biometricAuthService: biometricAuthService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  final BiometricAuthService _biometricAuthService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
    required BiometricAuthService biometricAuthService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService,
       _biometricAuthService = biometricAuthService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      print('🔍 Attempting local login for: $email');
      final user = _hiveService.login(email, password);
      if (user != null && user.authId != null) {
        print('✅ User found in Hive: ${user.email}');
        print('🔐 Password matches: YES');
        
        // Save user session to SharedPreferences
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profilePicture: user.profilePicture,
        );
        print('✅ Session saved');
      } else {
        print('❌ Login failed: Invalid email or password');
      }
      return user;
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // Check if user is logged in
      if (!_userSessionService.isLoggedIn()) {
        print('⚠️ getCurrentUser: User not logged in (no session)');
        return null;
      }

      // Get user ID from session
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        print('⚠️ getCurrentUser: No userId in session');
        return null;
      }

      print('🔍 Looking for user in Hive: $userId');
      
      // Try to fetch user from Hive database
      var user = _hiveService.getUserById(userId);
      
      if (user != null) {
        print('✅ User found in Hive: ${user.email}');
        print('🔐 Password stored: ${user.password?.isEmpty == true ? "EMPTY" : "EXISTS (${user.password?.length} chars)"}');
      }
      
      // If user is in session but not in Hive, create Hive record from session data
      if (user == null) {
        print('⚠️ User found in session but not in Hive. Syncing to local database...');
        final email = _userSessionService.getCurrentUserEmail();
        final fullName = _userSessionService.getCurrentUserFullName();
        final phoneNumber = _userSessionService.getCurrentUserPhoneNumber();
        final profilePicture = _userSessionService.getCurrentUserProfilePicture();
        
        if (email != null && fullName != null) {
          // Create user in Hive with session data
          // Note: Password is not stored in session, so we use a placeholder
          user = AuthHiveModel(
            authId: userId,
            email: email,
            fullName: fullName,
            phoneNumber: phoneNumber,
            password: '', // Placeholder - user needs to re-login for password verification
            profilePicture: profilePicture,
          );
          
          await _hiveService.register(user);
          print('✅ User synced to local database (without password)');
          print('⚠️ User needs to log out and log back in for password verification');
        }
      }
      
      return user;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      if (_biometricAuthService.isBiometricEnabled()) {
        final userId = _userSessionService.getCurrentUserId();
        final email = _userSessionService.getCurrentUserEmail();
        final fullName = _userSessionService.getCurrentUserFullName();

        if (userId != null && email != null && fullName != null) {
          await _biometricAuthService.saveBiometricSessionData(
            userId: userId,
            email: email,
            fullName: fullName,
            phoneNumber: _userSessionService.getCurrentUserPhoneNumber(),
            profilePicture: _userSessionService.getCurrentUserProfilePicture(),
          );
        }
      }

      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      print('📝 Updating user in Hive: ${user.authId} (${user.email})');
      print('🔐 Password to store: ${user.password?.isEmpty == true ? "EMPTY" : "EXISTS (${user.password?.length} chars)"}');
      
      final success = await _hiveService.updateUser(user);
      if (success && user.authId != null) {
        // Update session with new user data
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profilePicture: user.profilePicture,
        );
        print('✅ Session updated after Hive update');
      }
      return success;
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
