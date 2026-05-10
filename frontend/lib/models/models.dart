import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final double confidence;
  final String portion;
  final int estimatedGrams;

  FoodItem({
    required this.name,
    required this.confidence,
    this.portion = '1 serving',
    this.estimatedGrams = 100,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      portion: json['portion'] as String? ?? '1 serving',
      estimatedGrams: json['estimated_grams'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'portion': portion,
      'estimated_grams': estimatedGrams,
    };
  }
}

class NutritionData {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }
}

class AnalysisResult {
  final List<FoodItem> items;
  final NutritionData nutrition;
  final String source;
  final double processingTime;
  final double confidence;

  AnalysisResult({
    required this.items,
    required this.nutrition,
    required this.source,
    required this.processingTime,
    required this.confidence,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      items: (json['items'] as List)
          .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      nutrition: NutritionData.fromJson(
          json['nutrition'] as Map<String, dynamic>),
      source: json['source'] as String,
      processingTime: (json['processing_time'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'nutrition': nutrition.toJson(),
      'source': source,
      'processing_time': processingTime,
      'confidence': confidence,
    };
  }
}

class Suggestion {
  final String id;
  final String title;
  final String description;
  final int calories;
  final NutritionData macros;
  final List<String> ingredients;
  final String? prepTime;
  final String? imageUrl;
  final bool isFavorite;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.macros,
    this.ingredients = const [],
    this.prepTime,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      macros: NutritionData.fromJson(
          json['macros'] as Map<String, dynamic>? ?? {}),
      ingredients:
          (json['ingredients'] as List?)?.map((e) => e as String).toList() ??
              [],
      prepTime: json['prep_time'] as String?,
      imageUrl: json['image_url'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'calories': calories,
      'macros': macros.toJson(),
      'ingredients': ingredients,
      'prep_time': prepTime,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }
}

class HistoryEntry {
  final String id;
  final DateTime createdAt;
  final String mealType;
  final int calories;
  final NutritionData macros;
  final List<FoodItem> items;
  final String source;

  HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.mealType,
    required this.calories,
    required this.macros,
    required this.items,
    required this.source,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mealType: json['meal_type'] as String,
      calories: json['calories'] as int,
      macros: NutritionData.fromJson(
          json['macros'] as Map<String, dynamic>? ?? {}),
      items: (json['items'] as List)
          .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'meal_type': mealType,
      'calories': calories,
      'macros': macros.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'source': source,
    };
  }
}
