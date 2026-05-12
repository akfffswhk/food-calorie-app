import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';
import 'package:food_calorie_app/services/api_service.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryEntry> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasMore = true;

  List<HistoryEntry> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;

  int get totalCaloriesToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _history
        .where((entry) =>
            entry.createdAt.isAfter(today) || entry.createdAt.isAtSameMomentAs(today))
        .fold(0, (sum, entry) => sum + entry.calories);
  }

  Map<String, int> get caloriesByMealType {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEntries = _history.where((entry) =>
        entry.createdAt.isAfter(today) || entry.createdAt.isAtSameMomentAs(today));

    return {
      'breakfast': todayEntries
          .where((e) => e.mealType == 'breakfast')
          .fold(0, (sum, e) => sum + e.calories),
      'lunch': todayEntries
          .where((e) => e.mealType == 'lunch')
          .fold(0, (sum, e) => sum + e.calories),
      'dinner': todayEntries
          .where((e) => e.mealType == 'dinner')
          .fold(0, (sum, e) => sum + e.calories),
      'snacks': todayEntries
          .where((e) => e.mealType == 'snack')
          .fold(0, (sum, e) => sum + e.calories),
    };
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _history.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getHistory(
        page: _currentPage,
        limit: 20,
      );

      final entries = (response['entries'] as List?)
              ?.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      if (refresh) {
        _history = entries;
      } else {
        _history.addAll(entries);
      }

      _currentPage++;
      _totalCount = response['total'] as int? ?? _history.length;
      _totalPages = response['total_pages'] as int? ?? 1;
      _hasMore = _currentPage <= _totalPages;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailyHistory(String date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getDailyHistory(date);

      final entries = (response['entries'] as List?)
              ?.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      _history = entries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getWeeklyHistory();

      final entries = (response['entries'] as List?)
              ?.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      _history = entries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getMonthlyHistory();

      final entries = (response['entries'] as List?)
              ?.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      _history = entries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loadStats() async {
    try {
      final response = await ApiService.getHistoryStats();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {};
    }
  }

  Future<void> addEntry(HistoryEntry entry) async {
    _history.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.deleteAnalysis(id);
      _history.removeWhere((entry) => entry.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HistoryEntry?> getAnalysis(String id) async {
    try {
      final response = await ApiService.getAnalysis(id);
      return HistoryEntry.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearHistory() {
    _history.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
