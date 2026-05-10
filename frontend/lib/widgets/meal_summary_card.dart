import 'package:flutter/material.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class MealSummaryCard extends StatelessWidget {
  final Map<String, int> caloriesByMeal;

  const MealSummaryCard({
    super.key,
    required this.caloriesByMeal,
  });

  @override
  Widget build(BuildContext context) {
    final meals = [
      {'name': 'Breakfast', 'icon': Icons.free_breakfast, 'key': 'breakfast'},
      {'name': 'Lunch', 'icon': Icons.lunch_dining, 'key': 'lunch'},
      {'name': 'Dinner', 'icon': Icons.dinner_dining, 'key': 'dinner'},
      {'name': 'Snacks', 'icon': Icons.cookie, 'key': 'snacks'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...meals.map((meal) {
              final key = meal['key'] as String;
              final calories = caloriesByMeal[key] ?? 0;
              final icon = meal['icon'] as IconData;
              final name = meal['name'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$calories kcal',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
