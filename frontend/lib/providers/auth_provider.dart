import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  int _dailyCalorieGoal = 2000;
  List<String> _dietaryPreferences = [];
  List<String> _allergies = [];

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  List<String> get dietaryPreferences => _dietaryPreferences;
  List<String> get allergies => _allergies;

  Future<bool> login(String email, String password) async {
    // Simulate login - replace with actual auth
    await Future.delayed(const Duration(seconds: 1));

    _isLoggedIn = true;
    _email = email;
    _userId = 'user_123';
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password) async {
    // Simulate registration - replace with actual auth
    await Future.delayed(const Duration(seconds: 1));

    _isLoggedIn = true;
    _email = email;
    _userId = 'user_123';
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
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
}
