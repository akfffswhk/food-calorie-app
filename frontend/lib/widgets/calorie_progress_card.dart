import 'package:flutter/material.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class CalorieProgressCard extends StatelessWidget {
  final int totalCalories;
  final int goal;
  final int remaining;
  final double progress;

  const CalorieProgressCard({
    super.key,
    required this.totalCalories,
    required this.goal,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isOverGoal = totalCalories > goal;
    final progressColor = isOverGoal ? AppTheme.errorColor : AppTheme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Calories',
                  style: AppTheme.bodyLarge,
                ),
                Text(
                  '$totalCalories / $goal kcal',
                  style: AppTheme.heading3.copyWith(
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Consumed',
                  '$totalCalories',
                  Icons.local_fire_department,
                  isOverGoal ? AppTheme.errorColor : AppTheme.primaryColor,
                ),
                _buildStatItem(
                  'Remaining',
                  '${remaining > 0 ? remaining : 0}',
                  Icons.trending_down,
                  remaining > 0 ? AppTheme.successColor : AppTheme.errorColor,
                ),
                _buildStatItem(
                  'Progress',
                  '${(progress * 100).toInt()}%',
                  Icons.pie_chart,
                  progressColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.heading3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }
}
