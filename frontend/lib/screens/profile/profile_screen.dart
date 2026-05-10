import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/auth_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer2<AuthProvider, HistoryProvider>(
        builder: (context, authProvider, historyProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            authProvider.email?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.email ?? 'User',
                                style: AppTheme.heading3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since 2024',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Edit profile
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Goal
                Text(
                  'Daily Calorie Goal',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${authProvider.dailyCalorieGoal} kcal',
                              style: AppTheme.heading2.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showGoalDialog(authProvider),
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: authProvider.dailyCalorieGoal.toDouble(),
                          min: 1200,
                          max: 3500,
                          divisions: 23,
                          label: '${authProvider.dailyCalorieGoal} kcal',
                          onChanged: (value) {
                            authProvider.updateDailyGoal(value.toInt());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Dietary Preferences
                Text(
                  'Dietary Preferences',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPreferenceChip(
                          'Vegetarian',
                          authProvider.dietaryPreferences.contains('vegetarian'),
                          (selected) => _togglePreference(
                              authProvider, 'vegetarian', selected),
                        ),
                        _buildPreferenceChip(
                          'Vegan',
                          authProvider.dietaryPreferences.contains('vegan'),
                          (selected) =>
                              _togglePreference(authProvider, 'vegan', selected),
                        ),
                        _buildPreferenceChip(
                          'Gluten-Free',
                          authProvider.dietaryPreferences.contains('gluten-free'),
                          (selected) => _togglePreference(
                              authProvider, 'gluten-free', selected),
                        ),
                        _buildPreferenceChip(
                          'Low-Carb',
                          authProvider.dietaryPreferences.contains('low-carb'),
                          (selected) =>
                              _togglePreference(authProvider, 'low-carb', selected),
                        ),
                        _buildPreferenceChip(
                          'High-Protein',
                          authProvider.dietaryPreferences.contains('high-protein'),
                          (selected) => _togglePreference(
                              authProvider, 'high-protein', selected),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Allergies
                Text(
                  'Allergies',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (authProvider.allergies.isEmpty)
                          Text(
                            'No allergies added',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: authProvider.allergies
                                .map((allergy) => Chip(
                                      label: Text(allergy),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () {
                                        final updated = List<String>.from(
                                            authProvider.allergies);
                                        updated.remove(allergy);
                                        authProvider.updateAllergies(updated);
                                      },
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showAddAllergyDialog(authProvider),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Allergy'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                Text(
                  'Statistics',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Total Entries',
                          '${historyProvider.history.length}',
                          Icons.history,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Today\'s Calories',
                          '${historyProvider.totalCaloriesToday} kcal',
                          Icons.local_fire_department,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Remaining Today',
                          '${authProvider.dailyCalorieGoal - historyProvider.totalCaloriesToday} kcal',
                          Icons.trending_down,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(authProvider),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceChip(
    String label,
    bool selected,
    Function(bool) onToggle,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onToggle,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTheme.heading3,
          ),
        ],
      ),
    );
  }

  void _togglePreference(AuthProvider provider, String preference, bool selected) {
    final updated = List<String>.from(provider.dietaryPreferences);
    if (selected) {
      updated.add(preference);
    } else {
      updated.remove(preference);
    }
    provider.updateDietaryPreferences(updated);
  }

  void _showGoalDialog(AuthProvider provider) {
    final controller = TextEditingController(
      text: provider.dailyCalorieGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Calories',
            suffixText: 'kcal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                provider.updateDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAllergyDialog(AuthProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Allergy'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Allergy',
            hintText: 'e.g., Peanuts, Dairy',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final allergy = controller.text.trim();
              if (allergy.isNotEmpty) {
                final updated = List<String>.from(provider.allergies);
                if (!updated.contains(allergy)) {
                  updated.add(allergy);
                  provider.updateAllergies(updated);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
