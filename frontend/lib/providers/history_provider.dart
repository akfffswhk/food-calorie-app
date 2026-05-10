import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryEntry> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HistoryEntry> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for now
      _history = [
        HistoryEntry(
          id: '1',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          mealType: 'lunch',
          calories: 450,
          macros: NutritionData(
            calories: 450,
            protein: 25,
            carbs: 45,
            fat: 15,
          ),
          items: [
            FoodItem(
              name: 'Grilled Chicken Salad',
              confidence: 0.92,
              portion: '1 bowl',
              estimatedGrams: 300,
            ),
          ],
          source: 'lm_studio',
        ),
        HistoryEntry(
          id: '2',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          mealType: 'breakfast',
          calories: 320,
          macros: NutritionData(
            calories: 320,
            protein: 18,
            carbs: 40,
            fat: 10,
          ),
          items: [
            FoodItem(
              name: 'Oatmeal with Berries',
              confidence: 0.88,
              portion: '1 bowl',
              estimatedGrams: 250,
            ),
          ],
          source: 'hugging_face',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(HistoryEntry entry) async {
    _history.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _history.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
