import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class ApiService {
  static late Dio _dio;
  static String? _baseUrl;
  static String? _authToken;
  static const _storage = FlutterSecureStorage();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // For web, use the actual backend URL
    String defaultUrl = 'http://localhost:8000';
    if (kIsWeb) {
      // For web, use the actual IP address or localhost
      defaultUrl = 'http://localhost:8000';
    }
    _baseUrl = prefs.getString('api_base_url') ?? defaultUrl;
    _authToken = await _storage.read(key: 'auth_token');

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    ));

    // Add token refresh interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _storage.read(key: 'auth_token').then((token) {
            if (token != null) {
              Dio().post(
                '$_baseUrl/api/auth/refresh',
                data: {'refresh_token': token},
              ).then((response) {
                final newToken = response.data['access_token'] as String?;

                if (newToken != null) {
                  _storage.write(key: 'auth_token', value: newToken);
                  _authToken = newToken;
                  _dio.options.headers['Authorization'] = 'Bearer $newToken';

                  // Retry the original request
                  final opts = error.requestOptions;
                  _dio.fetch(opts).then((clonedRequest) {
                    handler.resolve(clonedRequest);
                  });
                }
              });
            }
          });
        }
        handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
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

  // Auth Endpoints
  static Future<Map<String, dynamic>> login(String email, String password) =>
      post('/api/auth/login', data: {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(String email, String password) =>
      post('/api/auth/register', data: {'email': email, 'password': password});

  static Future<Map<String, dynamic>> logout() => post('/api/auth/logout');

  static Future<Map<String, dynamic>> refreshToken(String refreshToken) =>
      post('/api/auth/refresh', data: {'refresh_token': refreshToken});

  static Future<Map<String, dynamic>> getCurrentUser() => get('/api/auth/me');

  // Analysis Endpoints
  static Future<Map<String, dynamic>> getStatus() => get('/api/status');
  static Future<Map<String, dynamic>> analyzeImage(String imagePath) =>
      uploadFile('/api/analyze', imagePath, 'image');
  static Future<Map<String, dynamic>> analyzeImageBase64(String base64Image) =>
      post('/api/analyze/base64', data: {'image': base64Image});

  // History Endpoints
  static Future<Map<String, dynamic>> getHistory({int page = 1, int limit = 20}) =>
      get('/api/history?page=$page&limit=$limit');
  static Future<Map<String, dynamic>> getDailyHistory(String date) =>
      get('/api/history/daily/$date');
  static Future<Map<String, dynamic>> getWeeklyHistory() =>
      get('/api/history/weekly');
  static Future<Map<String, dynamic>> getMonthlyHistory() =>
      get('/api/history/monthly');
  static Future<Map<String, dynamic>> getHistoryStats() =>
      get('/api/history/stats');
  static Future<Map<String, dynamic>> getAnalysis(String id) =>
      get('/api/history/$id');
  static Future<Map<String, dynamic>> deleteAnalysis(String id) =>
      delete('/api/history/$id');

  // Suggestions Endpoints
  static Future<Map<String, dynamic>> getSuggestions({
    String? mealType,
    int? maxCalories,
  }) {
    String path = '/api/suggestions';
    final params = <String, String>{};
    if (mealType != null) params['meal_type'] = mealType;
    if (maxCalories != null) params['max_calories'] = maxCalories.toString();
    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return get(path);
  }

  static Future<Map<String, dynamic>> getMealSuggestions({
    String? mealType,
    int? maxCalories,
  }) {
    String path = '/api/suggestions/meal';
    final params = <String, String>{};
    if (mealType != null) params['meal_type'] = mealType;
    if (maxCalories != null) params['max_calories'] = maxCalories.toString();
    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return get(path);
  }

  static Future<Map<String, dynamic>> getRecipeSuggestions(List<String> ingredients) =>
      post('/api/suggestions/recipe', data: {'ingredients': ingredients});

  static Future<Map<String, dynamic>> getAlternatives(String foodName) =>
      get('/api/suggestions/alternative/$foodName');

  static Future<Map<String, dynamic>> toggleFavorite(String suggestionId) =>
      post('/api/suggestions/favorite/$suggestionId');

  static Future<Map<String, dynamic>> getFavorites() =>
      get('/api/suggestions/favorites');

  // Profile Endpoints
  static Future<Map<String, dynamic>> getProfile() => get('/api/profile');
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      put('/api/profile', data: data);
  static Future<Map<String, dynamic>> updateGoals(int dailyCalorieGoal) =>
      put('/api/profile/goals', data: {'daily_calorie_goal': dailyCalorieGoal});
  static Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) =>
      post('/api/profile/change-password',
          data: {'old_password': oldPassword, 'new_password': newPassword});
  static Future<Map<String, dynamic>> deleteAccount() => delete('/api/profile');
}
