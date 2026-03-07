import 'package:dio/dio.dart';

/// Create a Dio instance configured for testing
Dio createMockDio() {
  return Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    contentType: 'application/json',
  ));
}

/// Create a Dio instance with custom base URL for testing
Dio createMockDioWithBaseUrl(String baseUrl) {
  return Dio(BaseOptions(
    baseUrl: baseUrl,
    contentType: 'application/json',
  ));
}
