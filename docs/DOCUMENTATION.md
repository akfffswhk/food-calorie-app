# Food Calorie App - Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [Features](#features)
5. [API Integration](#api-integration)
6. [State Management](#state-management)
7. [Navigation](#navigation)
8. [Authentication](#authentication)
9. [Versioning](#versioning)
10. [Testing](#testing)
11. [Deployment](#deployment)

## Overview

Food Calorie App is a cross-platform mobile application that uses AI to analyze food images and provide instant calorie and nutrition information. The app helps users track their daily calorie intake, view meal history, get personalized suggestions, and manage their dietary goals.

### Tech Stack

- **Frontend**: Flutter 3.x
- **Backend**: FastAPI (Python)
- **Database**: MongoDB
- **AI Services**: YOLO, Gemma 4:26B, USDA API
- **State Management**: Provider
- **Networking**: Dio
- **Storage**: flutter_secure_storage, shared_preferences

## Architecture

### Project Structure

```
food-calorie-app/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── models/         # Data models
│   │   ├── services/       # Business logic
│   │   ├── database.py     # Database connection
│   │   ├── auth.py         # Authentication utilities
│   │   └── main.py         # Application entry
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/               # Flutter frontend
│   ├── lib/
│   │   ├── main.dart       # App entry point
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable components
│   │   ├── services/       # API service
│   │   ├── theme/          # App theming
│   │   └── utils/          # Utilities
│   ├── android/            # Android configuration
│   ├── ios/                # iOS configuration
│   └── pubspec.yaml       # Dependencies
│
├── scripts/               # Utility scripts
│   ├── version.bat        # Windows version script
│   └── version.sh        # Linux/Mac version script
│
├── .github/              # GitHub workflows
│   └── workflows/
│       ├── version-bump.yml
│       └── create-release.yml
│
├── CHANGELOG.md          # Version history
├── VERSIONING.md         # Versioning guide
└── README.md            # Project readme
```

### Frontend Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      MaterialApp                         │
├─────────────────────────────────────────────────────────┤
│                    AppInitializer                         │
│  - Check for stored auth token                          │
│  - Initialize providers                                  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                     MainScreen                           │
│  - Bottom navigation bar                                 │
│  - IndexedStack for state preservation                   │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  HomeScreen  │   │  ScanScreen  │   │HistoryScreen │
│              │   │              │   │              │
│ - Dashboard  │   │ - Camera    │   │ - History    │
│ - Progress   │   │ - Gallery   │   │ - Filtering  │
│ - Recent     │   │ - Analysis  │   │ - Stats      │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    Providers                              │
│  - AuthProvider      - HistoryProvider                   │
│  - AnalysisProvider  - SuggestionProvider                │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   ApiService                              │
│  - HTTP requests                                         │
│  - Token management                                       │
│  - Error handling                                        │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Backend API                             │
│  - /api/auth/*      - /api/analyze                       │
│  - /api/history/*   - /api/suggestions/*                 │
│  - /api/profile/*                                          │
└─────────────────────────────────────────────────────────┘
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode
- Python 3.8+ (for backend)
- MongoDB

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/food-calorie-app.git
   cd food-calorie-app
   ```

2. **Install backend dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Install frontend dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

4. **Configure environment variables**
   ```bash
   # backend/.env
   MONGODB_URI=mongodb://localhost:27017/food_calorie
   JWT_SECRET=your-secret-key
   USDA_API_KEY=your-usda-api-key
   ```

5. **Start the backend server**
   ```bash
   cd backend
   python -m uvicorn app.main:app --reload
   ```

6. **Run the Flutter app**
   ```bash
   cd frontend
   flutter run
   ```

## Features

### Core Features

1. **Authentication**
   - User registration and login
   - JWT token authentication
   - Automatic token refresh
   - Secure token storage

2. **Food Analysis**
   - Capture food images from camera or gallery
   - AI-powered food detection
   - Calorie and nutrition estimation
   - Multiple AI service fallbacks

3. **History Tracking**
   - View food analysis history
   - Daily/weekly/monthly views
   - Meal type categorization
   - Statistics and insights

4. **Suggestions**
   - Personalized meal suggestions
   - Recipe recommendations
   - Healthier alternatives
   - Favorites system

5. **Profile Management**
   - Daily calorie goals
   - Dietary preferences
   - Allergies tracking
   - Account settings

### User Flow

```
┌─────────────┐
│   Launch    │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│  Check Auth │────▶│  Auth Screen│
└──────┬──────┘     └──────┬──────┘
       │                    │
       │ Yes                │ No
       ▼                    ▼
┌─────────────┐     ┌─────────────┐
│  Main Screen│     │  Login/Reg  │
└──────┬──────┘     └──────┬──────┘
       │                    │
       │                    ▼
       │              ┌─────────────┐
       │              │  Main Screen│
       │              └──────┬──────┘
       │                     │
       └─────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Scan Food   │    │  View History│    │ Suggestions  │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Analyze     │    │  Filter/View │    │  View/Fav    │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Save Result │    │  Delete/Edit │    │  Add to Day  │
└──────────────┘    └──────────────┘    └──────────────┘
```

## API Integration

### API Service

The `ApiService` class handles all HTTP requests to the backend:

```dart
// Authentication
ApiService.login(email, password)
ApiService.register(email, password)
ApiService.logout()
ApiService.refreshToken(token)
ApiService.getCurrentUser()

// Analysis
ApiService.analyzeImage(imagePath)
ApiService.analyzeImageBase64(base64Image)
ApiService.getStatus()

// History
ApiService.getHistory(page: 1, limit: 20)
ApiService.getDailyHistory(date)
ApiService.getWeeklyHistory()
ApiService.getMonthlyHistory()
ApiService.getHistoryStats()
ApiService.getAnalysis(id)
ApiService.deleteAnalysis(id)

// Suggestions
ApiService.getSuggestions(mealType, maxCalories)
ApiService.getMealSuggestions(mealType, maxCalories)
ApiService.getRecipeSuggestions(ingredients)
ApiService.getAlternatives(foodName)
ApiService.toggleFavorite(suggestionId)
ApiService.getFavorites()

// Profile
ApiService.getProfile()
ApiService.updateProfile(data)
ApiService.updateGoals(dailyCalorieGoal)
ApiService.changePassword(oldPassword, newPassword)
ApiService.deleteAccount()
```

### Error Handling

The API service handles different error types:

- **Connection Timeout**: Network connectivity issues
- **401 Unauthorized**: Token expired or invalid
- **404 Not Found**: Resource not found
- **500 Server Error**: Backend server error
- **Unknown Error**: Unexpected errors

### Token Refresh

The API service includes an automatic token refresh interceptor:

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Try to refresh token
      final newToken = await refreshToken();
      if (newToken != null) {
        // Retry original request
        return handler.resolve(clonedRequest);
      }
    }
    handler.next(error);
  },
));
```

## State Management

### Providers

The app uses the Provider pattern for state management:

#### AuthProvider

Manages authentication state and user profile:

```dart
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  int _dailyCalorieGoal = 2000;
  List<String> _dietaryPreferences = [];
  List<String> _allergies = [];

  // Methods
  Future<bool> login(String email, String password);
  Future<bool> register(String email, String password);
  Future<void> logout();
  Future<void> loadProfile();
  Future<bool> updateProfile(Map<String, dynamic> data);
  Future<bool> updateGoals(int goal);
  Future<bool> changePassword(String old, String new);
  Future<bool> deleteAccount();
}
```

#### HistoryProvider

Manages food analysis history:

```dart
class HistoryProvider with ChangeNotifier {
  List<HistoryEntry> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Computed properties
  int get totalCaloriesToday;
  Map<String, int> get caloriesByMealType;

  // Methods
  Future<void> loadHistory({bool refresh = false});
  Future<void> loadDailyHistory(String date);
  Future<void> loadWeeklyHistory();
  Future<void> loadMonthlyHistory();
  Future<Map<String, dynamic>> loadStats();
  Future<void> addEntry(HistoryEntry entry);
  Future<void> deleteEntry(String id);
}
```

#### SuggestionProvider

Manages meal suggestions and favorites:

```dart
class SuggestionProvider with ChangeNotifier {
  List<Suggestion> _suggestions = [];
  List<Suggestion> _favorites = [];

  // Methods
  Future<void> loadSuggestions({int? remaining, String? mealType});
  Future<void> loadMealSuggestions({String? mealType, int? maxCalories});
  Future<void> loadRecipeSuggestions(List<String> ingredients);
  Future<void> loadAlternatives(String foodName);
  Future<void> toggleFavorite(String id);
  Future<void> loadFavorites();
}
```

#### AnalysisProvider

Manages food analysis state:

```dart
class AnalysisProvider with ChangeNotifier {
  AnalysisResult? _currentResult;
  bool _isAnalyzing = false;

  // Methods
  Future<bool> analyzeImage(String imagePath);
  Future<bool> analyzeImageBase64(String base64Image);
  void clearResult();
}
```

## Navigation

### Bottom Navigation

The app uses a bottom navigation bar with 5 tabs:

1. **Home** - Dashboard with daily progress
2. **Scan** - Food image capture and analysis
3. **History** - Food analysis history
4. **Suggestions** - Meal recommendations
5. **Profile** - User profile and settings

### Navigation Structure

```dart
class MainScreen extends StatefulWidget {
  final List<Widget> _screens = [
    HomeScreen(),
    ScanScreen(),
    HistoryScreen(),
    SuggestionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
```

### Screen Navigation

- **Auth Screen** → Main Screen (after login)
- **Main Screen** → Scan Screen (via FAB)
- **Suggestions Screen** → Recipe Detail Screen
- **Profile Screen** → Version Screen

## Authentication

### Authentication Flow

```
┌─────────────┐
│   Login     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  API Call   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Store Token │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Load Profile│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Navigate to │
│  Home Screen│
└─────────────┘
```

### Token Storage

Tokens are stored securely using `flutter_secure_storage`:

```dart
static const _storage = FlutterSecureStorage();
static const _tokenKey = 'auth_token';
static const _refreshTokenKey = 'refresh_token';

// Store token
await _storage.write(key: _tokenKey, value: accessToken);

// Retrieve token
final token = await _storage.read(key: _tokenKey);

// Delete token
await _storage.delete(key: _tokenKey);
```

### Token Refresh

Tokens are automatically refreshed when they expire:

```dart
Future<bool> refreshToken() async {
  try {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final response = await ApiService.post('/api/auth/refresh', data: {
      'refresh_token': refreshToken,
    });

    final newToken = response['access_token'];
    await _storage.write(key: _tokenKey, value: newToken);
    ApiService.setAuthToken(newToken);

    return true;
  } catch (e) {
    return false;
  }
}
```

## Versioning

### Version Format

The app follows Semantic Versioning: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality
- **PATCH**: Bug fixes
- **BUILD**: Incremental build number

### Current Version

**Version**: 1.0.0+1

### Version Management

Use the version scripts to manage versions:

```batch
# Windows
cd scripts
version.bat show              # Show current version
version.bat bump minor        # Bump version
version.bat release           # Create release

# Linux/Mac
cd scripts
chmod +x version.sh
./version.sh show
./version.sh bump minor
./version.sh release
```

### Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.

## Testing

### Unit Tests

```bash
cd frontend
flutter test
```

### Integration Tests

```bash
cd frontend
flutter test integration_test/
```

### Manual Testing Checklist

- [ ] User registration and login
- [ ] Token persistence across app restarts
- [ ] Token refresh on expiration
- [ ] Food image capture and analysis
- [ ] History loading and filtering
- [ ] Suggestions and favorites
- [ ] Profile updates
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states

## Deployment

### Android

```bash
cd frontend
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
cd frontend
flutter build ios --release
```

### Web

```bash
cd frontend
flutter build web --release
```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Package](https://pub.dev/packages/dio)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)

## Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/yourusername/food-calorie-app/issues)
- Email: support@foodcalorieapp.com
- Documentation: [docs.foodcalorieapp.com](https://docs.foodcalorieapp.com)
