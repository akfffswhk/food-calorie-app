# Food Calorie App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-5.0+-47A248?logo=mongodb)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)

A cross-platform mobile application that uses AI to analyze food images and provide instant calorie and nutrition information. Track your daily intake, view meal history, get personalized suggestions, and manage your dietary goals.

![App Screenshot](https://via.placeholder.com/400x800?text=Food+Calorie+App)

## Features

### 🎯 Core Features

- **📸 AI Food Analysis** - Capture food images and get instant calorie estimates using hybrid AI processing
- **📊 Nutrition Tracking** - Track daily calories, macros (protein, carbs, fat), and meal history
- **💡 Smart Suggestions** - Get meal recommendations based on remaining calories and dietary preferences
- **📜 History & Stats** - View food history, daily summaries, and progress over time
- **👤 Profile Management** - Set daily calorie goals, dietary preferences, and allergies
- **🌐 Cross-Platform** - Works on both iOS and Android using Flutter

### 🚀 Technical Features

- **JWT Authentication** - Secure token-based authentication with automatic refresh
- **Offline Support** - Cached data for offline access
- **Real-time Updates** - Live calorie tracking and progress updates
- **Dark Theme** - Beautiful dark mode support
- **Responsive Design** - Optimized for various screen sizes

## Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Networking**: Dio
- **Storage**: flutter_secure_storage, shared_preferences
- **Image Handling**: image_picker, camera, image_cropper

### Backend
- **Framework**: FastAPI (Python)
- **Database**: MongoDB
- **AI Services**: YOLO, Gemma 4:26B, USDA API
- **Authentication**: JWT tokens with bcrypt

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Python 3.8+ (for backend)
- MongoDB

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/food-calorie-app.git
   cd food-calorie-app
   ```

2. **Backend Setup**
   ```bash
   cd backend
   pip install -r requirements.txt
   cp .env.example .env
   # Edit .env with your configuration
   python -m uvicorn app.main:app --reload
   ```

3. **Frontend Setup**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

For detailed instructions, see [QUICKSTART.md](QUICKSTART.md).

## Usage

### Authentication

```bash
# Register
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123"
}

# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Food Analysis

```bash
# Analyze food image
POST /api/analyze
Content-Type: multipart/form-data
image: <file>
```

### History

```bash
# Get history
GET /api/history?page=1&limit=20

# Get daily history
GET /api/history/daily/2024-01-01

# Get stats
GET /api/history/stats
```

### Suggestions

```bash
# Get suggestions
GET /api/suggestions?meal_type=lunch&max_calories=500

# Get alternatives
GET /api/suggestions/alternative/pizza
```

## Project Structure

```
food-calorie-app/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── models/         # Data models
│   │   ├── services/       # Business logic
│   │   └── main.py         # Application entry
│   └── requirements.txt
│
├── frontend/               # Flutter frontend
│   ├── lib/
│   │   ├── main.dart       # App entry point
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable components
│   │   └── services/       # API service
│   └── pubspec.yaml
│
├── scripts/               # Utility scripts
├── .github/              # GitHub workflows
├── CHANGELOG.md          # Version history
├── DOCUMENTATION.md      # Full documentation
├── QUICKSTART.md         # Quick start guide
└── README.md            # This file
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide for new users
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Comprehensive documentation
- **[VERSIONING.md](VERSIONING.md)** - Version management guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## Development

### Backend Development

```bash
cd backend
python -m uvicorn app.main:app --reload
```

### Frontend Development

```bash
cd frontend
flutter run
```

### Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
flutter test
```

## Versioning

The project follows Semantic Versioning: `MAJOR.MINOR.PATCH+BUILD`

Current version: **1.0.0+1**

### Version Management

```bash
# Windows
cd scripts
version.bat show
version.bat bump minor
version.bat release

# Linux/Mac
cd scripts
chmod +x version.sh
./version.sh show
./version.sh bump minor
./version.sh release
```

See [VERSIONING.md](VERSIONING.md) for more details.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Format

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

## Roadmap

### Version 1.1.0 (Planned)

- [ ] Date filtering in history
- [ ] Weekly/monthly stats charts
- [ ] Meal type filtering in suggestions
- [ ] Calorie range slider
- [ ] Pull-to-refresh
- [ ] Offline mode with sync

### Version 1.2.0 (Planned)

- [ ] Nutrition charts and graphs
- [ ] Meal planning
- [ ] Grocery list integration
- [ ] Social sharing
- [ ] Barcode scanning
- [ ] Voice commands

### Version 2.0.0 (Planned)

- [ ] Apple Watch integration
- [ ] Google Fit integration
- [ ] Meal reminders
- [ ] Water tracking
- [ ] Exercise tracking
- [ ] Weight tracking

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- FastAPI for the excellent web framework
- YOLO and Gemma for AI capabilities
- USDA for nutrition database

## Support

- **Documentation**: [docs.foodcalorieapp.com](https://docs.foodcalorieapp.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/food-calorie-app/issues)
- **Email**: support@foodcalorieapp.com

## Screenshots

### Home Screen
![Home Screen](https://via.placeholder.com/400x800?text=Home+Screen)

### Scan Screen
![Scan Screen](https://via.placeholder.com/400x800?text=Scan+Screen)

### History Screen
![History Screen](https://via.placeholder.com/400x800?text=History+Screen)

### Suggestions Screen
![Suggestions Screen](https://via.placeholder.com/400x800?text=Suggestions+Screen)

### Profile Screen
![Profile Screen](https://via.placeholder.com/400x800?text=Profile+Screen)

---

Made with ❤️ by the Food Calorie App Team
