import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_calorie_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';

  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  int _dailyCalorieGoal = 2000;
  List<String> _dietaryPreferences = [];
  List<String> _allergies = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  List<String> get dietaryPreferences => _dietaryPreferences;
  List<String> get allergies => _allergies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userId = await _storage.read(key: _userIdKey);
      final email = await _storage.read(key: _emailKey);

      if (token != null && userId != null) {
        _userId = userId;
        _email = email;
        _isLoggedIn = true;
        ApiService.setAuthToken(token);

        // Load user profile
        await loadProfile();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response['access_token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      if (accessToken != null && userId != null) {
        await _storage.write(key: _tokenKey, value: accessToken);
        await _storage.write(key: _userIdKey, value: userId);
        await _storage.write(key: _emailKey, value: email);

        _isLoggedIn = true;
        _email = email;
        _userId = userId;
        ApiService.setAuthToken(accessToken);

        // Load user profile
        await loadProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid response from server';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/api/auth/register', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response['access_token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      if (accessToken != null && userId != null) {
        await _storage.write(key: _tokenKey, value: accessToken);
        await _storage.write(key: _userIdKey, value: userId);
        await _storage.write(key: _emailKey, value: email);

        _isLoggedIn = true;
        _email = email;
        _userId = userId;
        ApiService.setAuthToken(accessToken);

        // Load user profile
        await loadProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid response from server';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return false;

      final response = await ApiService.post('/api/auth/refresh', data: {
        'refresh_token': token,
      });

      final accessToken = response['access_token'] as String?;

      if (accessToken != null) {
        await _storage.write(key: _tokenKey, value: accessToken);
        ApiService.setAuthToken(accessToken);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      final response = await ApiService.get('/api/profile');

      if (response['daily_calorie_goal'] != null) {
        _dailyCalorieGoal = response['daily_calorie_goal'] as int;
      }
      if (response['dietary_preferences'] != null) {
        _dietaryPreferences = List<String>.from(response['dietary_preferences'] as List);
      }
      if (response['allergies'] != null) {
        _allergies = List<String>.from(response['allergies'] as List);
      }
      if (response['email'] != null) {
        _email = response['email'] as String;
      }

      notifyListeners();
    } catch (e) {
      // Profile load failed, but user is still logged in
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.put('/api/profile', data: data);
      await loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoals(int goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.put('/api/profile/goals', data: {'daily_calorie_goal': goal});
      _dailyCalorieGoal = goal;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.post('/api/profile/change-password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.delete('/api/profile');
      await logout();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/api/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);

    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _dailyCalorieGoal = 2000;
    _dietaryPreferences = [];
    _allergies = [];
    _errorMessage = null;

    ApiService.setAuthToken(null);
    notifyListeners();
  }

  void updateDailyGoal(int goal) {
    _dailyCalorieGoal = goal;
    notifyListeners();
  }

  void updateDietaryPreferences(List<String> preferences) {
    _dietaryPreferences = preferences;
    notifyListeners();
  }

  void updateAllergies(List<String> allergies) {
    _allergies = allergies;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
