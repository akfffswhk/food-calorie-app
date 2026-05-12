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
import 'package:food_calorie_app/widgets/bottom_navigation_bar.dart';

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
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.init();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoggedIn) {
      return const MainScreen();
    } else {
      return const AuthScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScanScreen(),
    HistoryScreen(),
    SuggestionsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onScanPressed: () => _onTabTapped(1)),
          const ScanScreen(),
          const HistoryScreen(),
          const SuggestionsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
