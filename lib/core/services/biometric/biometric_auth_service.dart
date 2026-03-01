import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/user_session_service.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return BiometricAuthService(prefs: prefs);
});

class BiometricAuthService {
  final SharedPreferences _prefs;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserIdKey = 'biometric_user_id';
  static const String _biometricUserEmailKey = 'biometric_user_email';
  static const String _biometricUserFullNameKey = 'biometric_user_full_name';
  static const String _biometricUserPhoneKey = 'biometric_user_phone_number';
  static const String _biometricUserProfileKey = 'biometric_user_profile_picture';
  
  BiometricAuthService({required SharedPreferences prefs}) : _prefs = prefs;
  
  /// Check if device has biometric hardware
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if device is capable of using biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final canAuthenticate = await canCheckBiometrics() || await isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }
      
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
  
  /// Check if biometric authentication is enabled by user
  bool isBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
    if (!enabled) {
      await _prefs.remove(_biometricUserIdKey);
      await _prefs.remove(_biometricUserEmailKey);
      await _prefs.remove(_biometricUserFullNameKey);
      await _prefs.remove(_biometricUserPhoneKey);
      await _prefs.remove(_biometricUserProfileKey);
    }
  }
  
  /// Check if biometric login is available (device supports it AND user enabled it)
  Future<bool> isBiometricLoginAvailable() async {
    if (!isBiometricEnabled()) {
      return false;
    }
    
    final canAuthenticate = await canCheckBiometrics() || await isDeviceSupported();
    if (!canAuthenticate) {
      return false;
    }
    
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  Future<void> saveBiometricSessionData({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    await _prefs.setString(_biometricUserIdKey, userId);
    await _prefs.setString(_biometricUserEmailKey, email);
    await _prefs.setString(_biometricUserFullNameKey, fullName);
    if (phoneNumber != null) {
      await _prefs.setString(_biometricUserPhoneKey, phoneNumber);
    }
    if (profilePicture != null) {
      await _prefs.setString(_biometricUserProfileKey, profilePicture);
    }
  }

  bool hasBiometricSessionData() {
    final userId = _prefs.getString(_biometricUserIdKey);
    final email = _prefs.getString(_biometricUserEmailKey);
    final fullName = _prefs.getString(_biometricUserFullNameKey);
    return userId != null && email != null && fullName != null;
  }

  Future<bool> restoreSessionFromBiometricData(UserSessionService userSessionService) async {
    final userId = _prefs.getString(_biometricUserIdKey);
    final email = _prefs.getString(_biometricUserEmailKey);
    final fullName = _prefs.getString(_biometricUserFullNameKey);
    final phoneNumber = _prefs.getString(_biometricUserPhoneKey);
    final profilePicture = _prefs.getString(_biometricUserProfileKey);

    if (userId == null || email == null || fullName == null) {
      return false;
    }

    await userSessionService.saveUserSession(
      userId: userId,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );

    return true;
  }
}
