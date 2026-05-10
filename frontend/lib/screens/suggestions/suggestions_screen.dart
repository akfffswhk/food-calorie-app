import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/suggestion_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/providers/auth_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<HistoryProvider>();
      final authProvider = context.read<AuthProvider>();
      final remaining = authProvider.dailyCalorieGoal -
          historyProvider.totalCaloriesToday;
      context.read<SuggestionProvider>().loadSuggestions(remaining);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Consumer<SuggestionProvider>(
        builder: (context, suggestionProvider, child) {
          if (suggestionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (suggestionProvider.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No suggestions available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your calorie goal',
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
            itemCount: suggestionProvider.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestionProvider.suggestions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (suggestion.imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          suggestion.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.restaurant,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Favorite
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  suggestion.title,
                                  style: AppTheme.heading3,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  suggestion.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: suggestion.isFavorite
                                      ? AppTheme.errorColor
                                      : null,
                                ),
                                onPressed: () {
                                  suggestionProvider.toggleFavorite(
                                      suggestion.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Text(
                            suggestion.description,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Calories and Prep Time
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${suggestion.calories} kcal',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (suggestion.prepTime != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(suggestion.prepTime!),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Macros
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMacroChip(
                                'Protein',
                                '${suggestion.macros.protein}g',
                                Colors.blue,
                              ),
                              _buildMacroChip(
                                'Carbs',
                                '${suggestion.macros.carbs}g',
                                Colors.orange,
                              ),
                              _buildMacroChip(
                                'Fat',
                                '${suggestion.macros.fat}g',
                                Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Ingredients
                          if (suggestion.ingredients.isNotEmpty) ...[
                            const Text(
                              'Ingredients',
                              style: AppTheme.heading3,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestion.ingredients
                                  .map((ingredient) => Chip(
                                        label: Text(ingredient),
                                        backgroundColor: Colors.grey[200],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // View Details Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Show details dialog
                              },
                              child: const Text('View Recipe'),
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

  Widget _buildMacroChip(String label, String value, Color color) {
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
