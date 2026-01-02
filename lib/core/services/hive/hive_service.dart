import 'package:fitness_tracking/core/constants/hive_table_constants.dart';
import 'package:fitness_tracking/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


final hiveServiceProvider = Provider<HiveService>((ref) {
  final service = HiveService();
  // trigger initialization (don't await here) so consumers can use the service
  service.init();
  service.openboxes();
  return service;
});

class HiveService {

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);
    _registerAdapter();
  }
  
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    
  }

  Future<void> openboxes() async {
    if (!Hive.isBoxOpen(HiveTableConstants.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
    }
    if (!Hive.isBoxOpen(HiveTableConstants.settingsTable)) {
      await Hive.openBox(HiveTableConstants.settingsTable);
    }
  }
  
  Future<void> close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
    Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    try {
      if (!Hive.isBoxOpen(HiveTableConstants.authTable)) {
        await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
      }
      final key = model.authId;
      if (key == null) throw Exception('Auth id is null');
      await _authBox.put(key, model);
      // set as current user
      final settings = Hive.box(HiveTableConstants.settingsTable);
      await settings.put(HiveTableConstants.currentAuthIdKey, key);
      return model;
    } catch (e, st) {
      // helpful debug information during development
      // ignore: avoid_print
      print('HiveService.registerUser error: $e\n$st');
      rethrow;
    }
    }

    //Login
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      // mark as current user
      final settings = Hive.box(HiveTableConstants.settingsTable);
      await settings.put(HiveTableConstants.currentAuthIdKey, users.first.authId);
      return users.first;
    } 
    return null;
  }  

  //logout
  Future<void> logoutUser() async {
    try {
      if (!Hive.isBoxOpen(HiveTableConstants.settingsTable)) {
        await Hive.openBox(HiveTableConstants.settingsTable);
      }
      final settings = Hive.box(HiveTableConstants.settingsTable);
      await settings.delete(HiveTableConstants.currentAuthIdKey);
    } catch (_) {}
  }

  //get current user
  AuthHiveModel? getCurrentUser(String? authId) {
    if (authId == null) return null;
    return _authBox.get(authId);
  }

  String? getCurrentAuthId() {
    if (!Hive.isBoxOpen(HiveTableConstants.settingsTable)) return null;
    final settings = Hive.box(HiveTableConstants.settingsTable);
    return settings.get(HiveTableConstants.currentAuthIdKey) as String?;
  }

  //check email existence
  bool isEmailExists(String email) {
    final users = _authBox.values.where(
      (user) => user.email == email,
    );
    return users.isNotEmpty;
  }
}