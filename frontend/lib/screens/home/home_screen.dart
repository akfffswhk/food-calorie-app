import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/auth_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';
import 'package:food_calorie_app/widgets/calorie_progress_card.dart';
import 'package:food_calorie_app/widgets/meal_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Today\'s Progress'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                final totalCalories = historyProvider.totalCaloriesToday;
                final authProvider = context.watch<AuthProvider>();
                final goal = authProvider.dailyCalorieGoal;
                final remaining = goal - totalCalories;
                final progress = totalCalories / goal;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calorie Progress Card
                      CalorieProgressCard(
                        totalCalories: totalCalories,
                        goal: goal,
                        remaining: remaining,
                        progress: progress,
                      ),
                      const SizedBox(height: 24),

                      // Meal Summary
                      Text(
                        'Meals Today',
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 12),
                      MealSummaryCard(
                        caloriesByMeal: historyProvider.caloriesByMealType,
                      ),
                      const SizedBox(height: 24),

                      // Recent Entries
                      Text(
                        'Recent Entries',
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 12),
                      if (historyProvider.history.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No entries yet. Start by scanning your food!',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...historyProvider.history.take(3).map((entry) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryLight,
                                child: Icon(
                                  _getMealIcon(entry.mealType),
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                entry.items.first.name,
                                style: AppTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                '${entry.mealType} • ${_formatTime(entry.createdAt)}',
                              ),
                              trailing: Text(
                                '${entry.calories} kcal',
                                style: AppTheme.heading3.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Food'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.cookie;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
