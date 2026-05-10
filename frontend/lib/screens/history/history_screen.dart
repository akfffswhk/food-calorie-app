import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (historyProvider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start scanning food to build your history',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyProvider.history.length,
            itemBuilder: (context, index) {
              final entry = historyProvider.history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
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
                    '${_formatDate(entry.createdAt)} • ${entry.mealType}',
                  ),
                  trailing: Text(
                    '${entry.calories} kcal',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nutrition
                          const Text(
                            'Nutrition',
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNutrientChip(
                                'Protein',
                                '${entry.macros.protein}g',
                                Colors.blue,
                              ),
                              _buildNutrientChip(
                                'Carbs',
                                '${entry.macros.carbs}g',
                                Colors.orange,
                              ),
                              _buildNutrientChip(
                                'Fat',
                                '${entry.macros.fat}g',
                                Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Items
                          const Text(
                            'Detected Items',
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 8),
                          ...entry.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item.name),
                                  ),
                                  Text(
                                    '${(item.confidence * 100).toInt()}%',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),

                          // Source
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Analyzed by: ${entry.source}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Delete Button
                          OutlinedButton.icon(
                            onPressed: () {
                              historyProvider.deleteEntry(entry.id);
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
