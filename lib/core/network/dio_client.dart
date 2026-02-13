import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Centralized Dio client with global auth headers.
class DioClient {
  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': ApiConstants.authToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}

/// Thrown when API returns non-success status.
class ApiException implements Exception {
  final int? statusCode;
  final String body;

  const ApiException({this.statusCode, required this.body});

  @override
  String toString() => 'ApiException($statusCode): $body';
}
