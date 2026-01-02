import 'package:fitness_tracking/app/app.dart';
import 'package:fitness_tracking/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  await hiveService.openboxes();
  runApp(const ProviderScope(child: App()));
}