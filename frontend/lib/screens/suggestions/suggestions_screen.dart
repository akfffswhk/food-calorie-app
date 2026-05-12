import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/suggestion_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/providers/auth_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';
import 'package:food_calorie_app/screens/recipe/recipe_detail_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  String? _selectedMealType;
  int? _maxCalories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<HistoryProvider>();
      final authProvider = context.read<AuthProvider>();
      final remaining = authProvider.dailyCalorieGoal -
          historyProvider.totalCaloriesToday;
      context.read<SuggestionProvider>().loadSuggestions(remaining: remaining);
    });
  }

  void _showFilterDialog() {
    final authProvider = context.read<AuthProvider>();
    final historyProvider = context.read<HistoryProvider>();
    final remaining = authProvider.dailyCalorieGoal -
        historyProvider.totalCaloriesToday;

    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedMealType: _selectedMealType,
        maxCalories: _maxCalories ?? remaining,
        onApply: (mealType, calories) {
          setState(() {
            _selectedMealType = mealType;
            _maxCalories = calories;
          });
          context.read<SuggestionProvider>().loadSuggestions(
            remaining: calories,
            mealType: mealType,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              final historyProvider = context.read<HistoryProvider>();
              final remaining = authProvider.dailyCalorieGoal -
                  historyProvider.totalCaloriesToday;
              await context.read<SuggestionProvider>().loadSuggestions(
                remaining: _maxCalories ?? remaining,
                mealType: _selectedMealType,
              );
            },
            child: ListView.builder(
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(
                                        suggestion: suggestion,
                                      ),
                                    ),
                                  );
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        child: const Icon(Icons.filter_list),
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

class _FilterDialog extends StatefulWidget {
  final String? selectedMealType;
  final int maxCalories;
  final Function(String?, int) onApply;

  const _FilterDialog({
    required this.selectedMealType,
    required this.maxCalories,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _selectedMealType;
  late int _maxCalories;

  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.selectedMealType;
    _maxCalories = widget.maxCalories;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Suggestions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type
            const Text(
              'Meal Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mealTypes.map((type) {
                final isSelected = _selectedMealType == type ||
                    (type == 'All' && _selectedMealType == null);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMealType = selected && type != 'All' ? type.toLowerCase() : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Calorie Range
            const Text(
              'Maximum Calories',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$_maxCalories kcal',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxCalories.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              label: '$_maxCalories kcal',
              onChanged: (value) {
                setState(() {
                  _maxCalories = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedMealType = widget.selectedMealType;
              _maxCalories = widget.maxCalories;
            });
            Navigator.pop(context);
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedMealType, _maxCalories);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
