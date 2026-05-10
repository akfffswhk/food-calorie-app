import 'package:flutter/material.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class MealTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const MealTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mealTypes = [
      {'value': 'breakfast', 'label': 'Breakfast', 'icon': Icons.free_breakfast},
      {'value': 'lunch', 'label': 'Lunch', 'icon': Icons.lunch_dining},
      {'value': 'dinner', 'label': 'Dinner', 'icon': Icons.dinner_dining},
      {'value': 'snack', 'label': 'Snack', 'icon': Icons.cookie},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: AppTheme.heading3,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mealTypes.map((meal) {
            final value = meal['value'] as String;
            final label = meal['label'] as String;
            final icon = meal['icon'] as IconData;
            final isSelected = selectedType == value;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onTypeChanged(value);
                }
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              avatar: isSelected
                  ? null
                  : Icon(icon, size: 16, color: Colors.grey[600]),
            );
          }).toList(),
        ),
      ],
    );
  }
}
