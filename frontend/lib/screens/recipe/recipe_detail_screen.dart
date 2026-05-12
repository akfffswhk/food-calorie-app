import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';
import 'package:food_calorie_app/providers/suggestion_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Suggestion suggestion;

  const RecipeDetailScreen({
    super.key,
    required this.suggestion,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.suggestion.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.suggestion.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: widget.suggestion.imageUrl != null
                  ? Image.network(
                      widget.suggestion.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  context
                      .read<SuggestionProvider>()
                      .toggleFavorite(widget.suggestion.id);
                },
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    widget.suggestion.description,
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calories and Prep Time
                  Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '${widget.suggestion.calories} kcal',
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      if (widget.suggestion.prepTime != null)
                        _buildInfoCard(
                          icon: Icons.schedule,
                          label: 'Prep Time',
                          value: widget.suggestion.prepTime!,
                          color: AppTheme.accentColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nutrition
                  Text(
                    'Nutrition',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroChip(
                            'Protein',
                            '${widget.suggestion.macros.protein}g',
                            Colors.blue,
                          ),
                          _buildMacroChip(
                            'Carbs',
                            '${widget.suggestion.macros.carbs}g',
                            Colors.orange,
                          ),
                          _buildMacroChip(
                            'Fat',
                            '${widget.suggestion.macros.fat}g',
                            Colors.red,
                          ),
                          if (widget.suggestion.macros.fiber > 0)
                            _buildMacroChip(
                              'Fiber',
                              '${widget.suggestion.macros.fiber}g',
                              Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.suggestion.ingredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: AppTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions (placeholder for now)
                  Text(
                    'Instructions',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Recipe instructions will be available soon.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _addToToday(context),
            icon: const Icon(Icons.add),
            label: const Text('Add to Today'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTheme.heading3.copyWith(color: color),
              ),
              Text(
                label,
                style: AppTheme.caption,
              ),
            ],
          ),
        ),
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

  void _addToToday(BuildContext context) {
    final historyProvider = context.read<HistoryProvider>();
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      mealType: 'snack',
      calories: widget.suggestion.calories,
      macros: widget.suggestion.macros,
      items: widget.suggestion.ingredients
          .map((i) => FoodItem(
                name: i,
                confidence: 1.0,
                portion: '1 serving',
              ))
          .toList(),
      source: 'suggestion',
    );

    historyProvider.addEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.suggestion.title} added to today!'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    Navigator.pop(context);
  }
}
