# Food Calorie App - Quick Start Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** 3.0.0 or higher
- **Dart SDK** 3.0.0 or higher
- **Android Studio** or **Xcode** (for mobile development)
- **Python** 3.8+ (for backend)
- **MongoDB** (for database)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/food-calorie-app.git
cd food-calorie-app
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment (optional but recommended)
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env

# Edit .env with your configuration
# MONGODB_URI=mongodb://localhost:27017/food_calorie
# JWT_SECRET=your-secret-key-here
# USDA_API_KEY=your-usda-api-key

# Start MongoDB (if not running)
# Windows:
mongod
# Linux/Mac:
sudo systemctl start mongod

# Start the backend server
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend will be available at `http://localhost:8000`

### 3. Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Verify Flutter installation
flutter doctor

# Run the app
flutter run
```

## Quick Start

### Running the App

1. **Start the Backend**
   ```bash
   cd backend
   python -m uvicorn app.main:app --reload
   ```

2. **Run the Frontend**
   ```bash
   cd frontend
   flutter run
   ```

3. **Test the App**
   - Open the app on your device/emulator
   - Register a new account
   - Login with your credentials
   - Try scanning a food image
   - View your history
   - Check suggestions

### Using the App

#### 1. Authentication

- **Register**: Create a new account with email and password
- **Login**: Sign in with your credentials
- **Logout**: Sign out from the app

#### 2. Food Scanning

- Tap the "Scan Food" button or navigate to the Scan tab
- Choose "Camera" to take a photo or "Gallery" to select an existing image
- Select the meal type (breakfast, lunch, dinner, or snack)
- Tap "Analyze Food" to get calorie and nutrition information
- Save the result to your history

#### 3. Viewing History

- Navigate to the History tab
- View all your food analyses
- Tap on an entry to see detailed nutrition information
- Delete entries you no longer need

#### 4. Getting Suggestions

- Navigate to the Suggestions tab
- View meal suggestions based on your remaining calories
- Tap on a suggestion to see full recipe details
- Add recipes to your daily meals
- Favorite suggestions for quick access

#### 5. Managing Profile

- Navigate to the Profile tab
- Set your daily calorie goal
- Add dietary preferences (vegetarian, vegan, etc.)
- Track allergies
- View your statistics
- Log out when done

## Development

### Backend Development

```bash
cd backend

# Run with auto-reload
python -m uvicorn app.main:app --reload

# Run tests
pytest

# Run with specific host/port
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Frontend Development

```bash
cd frontend

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device-id>

# Hot reload (while app is running)
# Press 'r' in terminal
```

### Code Formatting

```bash
# Format Dart code
cd frontend
dart format .

# Format Python code
cd backend
black .
```

### Linting

```bash
# Flutter lint
cd frontend
flutter analyze

# Python lint
cd backend
flake8 .
```

## Troubleshooting

### Backend Issues

**MongoDB Connection Error**
```bash
# Check if MongoDB is running
# Windows:
net start MongoDB
# Linux/Mac:
sudo systemctl status mongod

# Start MongoDB if not running
# Windows:
net start MongoDB
# Linux/Mac:
sudo systemctl start mongod
```

**Port Already in Use**
```bash
# Find process using port 8000
# Windows:
netstat -ano | findstr :8000
# Linux/Mac:
lsof -i :8000

# Kill the process
# Windows:
taskkill /PID <PID> /F
# Linux/Mac:
kill -9 <PID>
```

### Frontend Issues

**Flutter Doctor Issues**
```bash
# Check Flutter installation
flutter doctor

# Fix Android licenses
flutter doctor --android-licenses

# Clean build
flutter clean
flutter pub get
```

**Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Clear cache
flutter pub cache repair
```

**Emulator Issues**
```bash
# List available emulators
flutter emulators

# Start specific emulator
flutter emulators --launch <emulator-id>

# Create new emulator
flutter emulators --create
```

## API Testing

### Using cURL

```bash
# Health check
curl http://localhost:8000/health

# Register
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'

# Get history (with token)
curl http://localhost:8000/api/history \
  -H "Authorization: Bearer <your-token>"
```

### Using Postman

1. Import the API collection (if available)
2. Set base URL to `http://localhost:8000`
3. Test endpoints with proper authentication

## Version Management

### Bump Version

```bash
# Windows
cd scripts
version.bat bump minor

# Linux/Mac
cd scripts
chmod +x version.sh
./version.sh bump minor
```

### Create Release

```bash
# Windows
version.bat release

# Linux/Mac
./version.sh release
```

## Next Steps

1. **Explore the Code**
   - Read the [DOCUMENTATION.md](DOCUMENTATION.md) for detailed information
   - Check the [VERSIONING.md](VERSIONING.md) for version management
   - Review the [CHANGELOG.md](CHANGELOG.md) for version history

2. **Customize the App**
   - Modify the theme in `frontend/lib/theme/app_theme.dart`
   - Add new features following the existing patterns
   - Update API endpoints in `frontend/lib/services/api_service.dart`

3. **Contribute**
   - Fork the repository
   - Create a feature branch
   - Make your changes
   - Submit a pull request

## Support

- **Documentation**: [docs.foodcalorieapp.com](https://docs.foodcalorieapp.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/food-calorie-app/issues)
- **Email**: support@foodcalorieapp.com

## License

This project is licensed under the MIT License - see the LICENSE file for details.
