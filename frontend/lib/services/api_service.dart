import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static late Dio _dio;
  static String? _baseUrl;
  static String? _authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? 'http://localhost:8000';
    _authToken = prefs.getString('auth_token');

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        response: true,
        error: true,
      ));
    }
  }

  static void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  static void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String path,
    String filePath,
    String fieldName,
  ) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(path, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> uploadBytes(
    String path,
    List<int> bytes,
    String fieldName,
    String filename,
  ) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(path, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Exception _handleError(DioException error) {
    String message = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = 'Unauthorized. Please log in again.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = error.response?.data['message'] ?? 'Request failed.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true) {
          message = 'No internet connection.';
        } else {
          message = 'An unexpected error occurred.';
        }
        break;
      default:
        message = 'An error occurred.';
    }

    return Exception(message);
  }

  // API Endpoints
  static Future<Map<String, dynamic>> getStatus() => get('/api/status');
  static Future<Map<String, dynamic>> analyzeImage(String imagePath) =>
      uploadFile('/api/analyze', imagePath, 'image');
  static Future<Map<String, dynamic>> analyzeImageBase64(String base64Image) =>
      post('/api/analyze/base64', data: {'image': base64Image});
}
