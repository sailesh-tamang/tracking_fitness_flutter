import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserSessionService implements UserSessionService {
  @override
  String? getCurrentUserFullName() => 'Test User';

  @override
  String? getCurrentUserEmail() => 'test@gmail.com';

  @override
  String? getCurrentUserProfilePicture() => '';

  @override
  Future<void> clearSession() async {}

  @override
  String? getCurrentUserId() => 'test_id';

  @override
  String? getCurrentUserPhoneNumber() => '1234567890';

  @override
  bool isLoggedIn() => true;

  @override
  Future<void> saveUserSession({required String userId, required String email, required String fullName, String? phoneNumber, String? profilePicture}) async {}

  @override
  Future<void> updateUserProfilePicture(String pictureFileName) async {}
}

class FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
