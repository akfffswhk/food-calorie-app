import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';

class SuggestionProvider with ChangeNotifier {
  List<Suggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingCalories = 2000;

  List<Suggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingCalories => _remainingCalories;

  Future<void> loadSuggestions(int remaining) async {
    _isLoading = true;
    _errorMessage = null;
    _remainingCalories = remaining;
    notifyListeners();

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock suggestions
      _suggestions = [
        Suggestion(
          id: 's1',
          title: 'Grilled Chicken Salad',
          description: 'Fresh mixed greens with grilled chicken breast',
          calories: 350,
          macros: NutritionData(
            calories: 350,
            protein: 35,
            carbs: 15,
            fat: 18,
          ),
          ingredients: [
            'Chicken breast',
            'Mixed greens',
            'Cherry tomatoes',
            'Cucumber',
            'Olive oil',
          ],
          prepTime: '15 min',
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        ),
        Suggestion(
          id: 's2',
          title: 'Quinoa Buddha Bowl',
          description: 'Nutritious quinoa bowl with roasted vegetables',
          calories: 420,
          macros: NutritionData(
            calories: 420,
            protein: 15,
            carbs: 55,
            fat: 16,
          ),
          ingredients: [
            'Quinoa',
            'Sweet potato',
            'Chickpeas',
            'Kale',
            'Tahini',
          ],
          prepTime: '25 min',
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
        ),
        Suggestion(
          id: 's3',
          title: 'Baked Salmon',
          description: 'Oven-baked salmon with asparagus',
          calories: 380,
          macros: NutritionData(
            calories: 380,
            protein: 38,
            carbs: 8,
            fat: 22,
          ),
          ingredients: [
            'Salmon fillet',
            'Asparagus',
            'Lemon',
            'Garlic',
            'Olive oil',
          ],
          prepTime: '20 min',
          imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
        ),
        Suggestion(
          id: 's4',
          title: 'Greek Yogurt Parfait',
          description: 'Creamy yogurt with fresh berries and granola',
          calories: 280,
          macros: NutritionData(
            calories: 280,
            protein: 20,
            carbs: 35,
            fat: 8,
          ),
          ingredients: [
            'Greek yogurt',
            'Mixed berries',
            'Granola',
            'Honey',
          ],
          prepTime: '5 min',
          imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777',
        ),
      ];

      // Filter by remaining calories
      _suggestions = _suggestions
          .where((s) => s.calories <= remaining)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _suggestions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _suggestions[index] = Suggestion(
        id: _suggestions[index].id,
        title: _suggestions[index].title,
        description: _suggestions[index].description,
        calories: _suggestions[index].calories,
        macros: _suggestions[index].macros,
        ingredients: _suggestions[index].ingredients,
        prepTime: _suggestions[index].prepTime,
        imageUrl: _suggestions[index].imageUrl,
        isFavorite: !_suggestions[index].isFavorite,
      );
      notifyListeners();
    }
  }

  List<Suggestion> get favorites =>
      _suggestions.where((s) => s.isFavorite).toList();
}
