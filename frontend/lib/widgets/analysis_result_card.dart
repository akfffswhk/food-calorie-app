import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class AnalysisResultCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onSave;

  const AnalysisResultCard({
    super.key,
    required this.result,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Analysis Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${(result.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calories
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${result.nutrition.calories}',
                          style: AppTheme.heading1.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kcal',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Macros
                  const Text(
                    'Nutrition',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroChip(
                        'Protein',
                        '${result.nutrition.protein}g',
                        Colors.blue,
                      ),
                      _buildMacroChip(
                        'Carbs',
                        '${result.nutrition.carbs}g',
                        Colors.orange,
                      ),
                      _buildMacroChip(
                        'Fat',
                        '${result.nutrition.fat}g',
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Detected Items
                  const Text(
                    'Detected Items',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 8),
                  ...result.items.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.restaurant,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.portion),
                        trailing: Text(
                          '${(item.confidence * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  // Source Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Analyzed by ${result.source} in ${result.processingTime.toStringAsFixed(2)}s',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
