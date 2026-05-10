import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_calorie_app/providers/auth_provider.dart';
import 'package:food_calorie_app/providers/analysis_provider.dart';
import 'package:food_calorie_app/providers/history_provider.dart';
import 'package:food_calorie_app/providers/suggestion_provider.dart';
import 'package:food_calorie_app/screens/auth/auth_screen.dart';
import 'package:food_calorie_app/screens/home/home_screen.dart';
import 'package:food_calorie_app/screens/scan/scan_screen.dart';
import 'package:food_calorie_app/screens/history/history_screen.dart';
import 'package:food_calorie_app/screens/suggestions/suggestions_screen.dart';
import 'package:food_calorie_app/screens/profile/profile_screen.dart';
import 'package:food_calorie_app/services/api_service.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService.init();

  runApp(const FoodCalorieApp());
}

class FoodCalorieApp extends StatelessWidget {
  const FoodCalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => SuggestionProvider()),
      ],
      child: MaterialApp(
        title: 'Food Calorie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/scan': (context) => const ScanScreen(),
          '/history': (context) => const HistoryScreen(),
          '/suggestions': (context) => const SuggestionsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
