import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = true; // Set to true for physical device
  static const String _ipAddress = '10.61.35.98'; // Replace with your computer's actual IP address
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/fitness';
  static String get mediaServerUrl => serverUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

 

  // ============ Customer Endpoints ============
  static const String customers = '/customers';
  static const String customerLogin = '/customers/login';
  static const String customerRegister = '/customers/signup';
  static const String customerProfile = '/customers/upload-image';

  // ============ Steps Endpoints ============
  static const String stepsToday = '/steps/today';
  static const String stepsSync = '/steps/sync';
}