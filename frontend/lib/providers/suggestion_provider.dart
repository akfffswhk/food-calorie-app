import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';
import 'package:food_calorie_app/services/api_service.dart';

class SuggestionProvider with ChangeNotifier {
  List<Suggestion> _suggestions = [];
  List<Suggestion> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingCalories = 2000;
  String? _currentMealType;
  int? _currentMaxCalories;

  List<Suggestion> get suggestions => _suggestions;
  List<Suggestion> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingCalories => _remainingCalories;

  Future<void> loadSuggestions({
    int? remaining,
    String? mealType,
    int? maxCalories,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _remainingCalories = remaining ?? _remainingCalories;
    _currentMealType = mealType;
    _currentMaxCalories = maxCalories ?? remaining;

    notifyListeners();

    try {
      final response = await ApiService.getSuggestions(
        mealType: mealType,
        maxCalories: maxCalories ?? remaining,
      );

      _suggestions = (response['suggestions'] as List?)
              ?.map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMealSuggestions({
    String? mealType,
    int? maxCalories,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentMealType = mealType;
    _currentMaxCalories = maxCalories;

    notifyListeners();

    try {
      final response = await ApiService.getMealSuggestions(
        mealType: mealType,
        maxCalories: maxCalories,
      );

      _suggestions = (response['suggestions'] as List?)
              ?.map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecipeSuggestions(List<String> ingredients) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getRecipeSuggestions(ingredients);

      _suggestions = (response['suggestions'] as List?)
              ?.map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlternatives(String foodName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getAlternatives(foodName);

      _suggestions = (response['alternatives'] as List?)
              ?.map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

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
      final wasFavorite = _suggestions[index].isFavorite;

      // Optimistic update
      _suggestions[index] = Suggestion(
        id: _suggestions[index].id,
        title: _suggestions[index].title,
        description: _suggestions[index].description,
        calories: _suggestions[index].calories,
        macros: _suggestions[index].macros,
        ingredients: _suggestions[index].ingredients,
        prepTime: _suggestions[index].prepTime,
        imageUrl: _suggestions[index].imageUrl,
        isFavorite: !wasFavorite,
      );
      notifyListeners();

      try {
        await ApiService.toggleFavorite(id);

        // Update favorites list
        if (!wasFavorite) {
          _favorites.add(_suggestions[index]);
        } else {
          _favorites.removeWhere((s) => s.id == id);
        }
      } catch (e) {
        // Revert on error
        _suggestions[index] = Suggestion(
          id: _suggestions[index].id,
          title: _suggestions[index].title,
          description: _suggestions[index].description,
          calories: _suggestions[index].calories,
          macros: _suggestions[index].macros,
          ingredients: _suggestions[index].ingredients,
          prepTime: _suggestions[index].prepTime,
          imageUrl: _suggestions[index].imageUrl,
          isFavorite: wasFavorite,
        );
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getFavorites();

      _favorites = (response['favorites'] as List?)
              ?.map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSuggestions() {
    _suggestions.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
