import 'package:fitness_tracker/core/constants/hive_table_constants.dart';
import 'package:fitness_tracker/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);

    // register adapter
    _registerAdapter();
    await _openBoxes();
    // insert dummy data
    // await insertBatchDummyData();
    //await insertCategoryDummyData();
  }


  // Adapter register
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // box open
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }

  // box close
  Future<void> _close() async {
    await Hive.close();
  }

  // ======================= Auth Queries =========================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    print('✅ User registered/updated in Hive: ${user.authId} (${user.email})');
    print('🔐 Password stored: ${user.password?.isEmpty == true ? "EMPTY" : "EXISTS (${user.password?.length} chars)"}');
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      print('🔍 Searching Hive for user: $email');
      print('📊 Total users in Hive: ${_authBox.length}');
      
      final user = _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      
      print('✅ User found and password matched');
      return user;
    } catch (e) {
      print('❌ User not found or password mismatch');
      
      // Try to find user by email to see if user exists
      try {
        final userByEmail = _authBox.values.firstWhere((user) => user.email == email);
        print('ℹ️ User exists with email: $email');
        print('⚠️ Password mismatch (stored: ${userByEmail.password?.length} chars, entered: ${password.length} chars)');
      } catch (e2) {
        print('ℹ️ User does not exist with email: $email');
      }
      
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      await _authBox.put(user.authId, user);
      print('✅ User updated in Hive: ${user.authId} (${user.email})');
      return true;
    } catch (e) {
      print('❌ Error updating user in Hive: $e');
      return false;
    }
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }
}
