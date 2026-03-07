import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserSessionService implements UserSessionService {
  final String fullName;
  final String email;
  final String userId;
  final String phoneNumber;
  final String? profilePicture;
  final bool loggedIn;

  FakeUserSessionService({
    this.fullName = 'Test User',
    this.email = 'test@gmail.com',
    this.userId = 'test_id_123',
    this.phoneNumber = '1234567890',
    this.profilePicture,
    this.loggedIn = true,
  });

  @override
  String? getCurrentUserFullName() => fullName;

  @override
  String? getCurrentUserEmail() => email;

  @override
  String? getCurrentUserProfilePicture() => profilePicture;

  @override
  Future<void> clearSession() async {
    // No-op for fake implementation
  }

  @override
  String? getCurrentUserId() => userId;

  @override
  String? getCurrentUserPhoneNumber() => phoneNumber;

  @override
  bool isLoggedIn() => loggedIn;

  @override
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    // No-op for fake implementation
  }

  @override
  Future<void> updateUserProfilePicture(String pictureFileName) async {
    // No-op for fake implementation
  }
}

class FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) =>
      _data[key] as List<String>?;

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> reload() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
