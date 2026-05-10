# Food Calorie Analyzer

A cross-platform mobile app that uses AI to analyze food images and provide calorie/nutrition information. Built with Flutter (iOS & Android) and a Python FastAPI backend with hybrid AI processing.

## Features

- **AI Food Analysis**: Upload food photos and get instant calorie estimates
- **Hybrid AI Processing**: LM Studio (local) + Hugging Face (cloud) + Fallback
- **Nutrition Tracking**: Track daily calories, macros, and meal history
- **Smart Suggestions**: Get meal recommendations based on remaining calories
- **Cross-Platform**: Works on both iOS and Android
- **History & Stats**: View your food history and progress over time

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Networking**: Dio
- **Image Handling**: image_picker, camera, image_cropper
- **Storage**: shared_preferences, flutter_secure_storage
- **Charts**: fl_chart

### Backend (Python)
- **Framework**: FastAPI
- **Database**: MongoDB (motor)
- **AI Services**:
  - LM Studio (local vision models)
  - Hugging Face Inference API
  - USDA FoodData Central API

## Project Structure

```
food-calorie-app/
├── backend/                    # Python FastAPI backend
│   ├── app/
│   │   ├── main.py            # API endpoints
│   │   ├── models.py          # Database models
│   │   ├── database.py        # MongoDB connection
│   │   └── services/
│   │       ├── ai_service.py          # Hybrid AI service
│   │       ├── suggestion_service.py  # Meal suggestions
│   │       └── history_service.py     # History tracking
│   ├── requirements.txt
│   ├── .env.example
│   └── SETUP.md
│
├── frontend/                   # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/            # Data models
│   │   ├── providers/         # State management
│   │   ├── screens/           # UI screens
│   │   ├── widgets/           # Reusable widgets
│   │   ├── services/          # API service
│   │   └── theme/             # App theming
│   ├── android/               # Android platform files
│   ├── ios/                   # iOS platform files
│   └── pubspec.yaml
│
└── README.md
```

## Quick Start

### Prerequisites

- Python 3.9+
- Flutter 3.x
- MongoDB
- LM Studio (for local AI processing)
- Hugging Face account (for cloud fallback)
- USDA API key (for nutrition data)

### Backend Setup

1. **Install Python dependencies**
```bash
cd backend
pip install -r requirements.txt
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your API keys
```

3. **Set up LM Studio**
- Download from https://lmstudio.ai/
- Install and launch
- Download a vision model (llava or bakllava)
- Enable server in settings (port 1234)

4. **Get API keys**
- Hugging Face: https://huggingface.co/settings/tokens
- USDA: https://api.nal.usda.gov/

5. **Start the backend**
```bash
python -m app.main
```

Backend will be available at `http://localhost:8000`

### Frontend Setup

1. **Install Flutter**
```bash
# Follow instructions at https://flutter.dev/docs/get-started/install
flutter doctor
```

2. **Install dependencies**
```bash
cd frontend
flutter pub get
```

3. **Configure API URL**
Edit `lib/services/api_service.dart` or set via settings:
```dart
ApiService.setBaseUrl('http://localhost:8000');
```

4. **Run the app**

For Android:
```bash
flutter run
```

For iOS:
```bash
flutter run
```

Or run on specific device:
```bash
flutter devices
flutter run -d <device_id>
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information |
| GET | `/health` | Health check |
| GET | `/api/status` | Service status |
| POST | `/api/analyze` | Analyze food image (file upload) |
| POST | `/api/analyze/base64` | Analyze food image (base64) |

## How the Hybrid AI Works

```
┌─────────────────────────────────────────────────────────┐
│                    Food Image Upload                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              Try LM Studio (Local) First                 │
│  - Fast, no API limits                                   │
│  - Requires LM Studio running                            │
│  - Uses vision model (llava, bakllava)                   │
└─────────────────────────────────────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │   Success?    │
                    └───────┬───────┘
                       No   │   Yes
                       ┌────┴────┐
                       ▼         ▼
┌────────────────────────┐  ┌────────────────────────┐
│  Try Hugging Face     │  │  Return Results        │
│  (Cloud Fallback)     │  │  - Food items          │
│  - Free tier          │  │  - Calories             │
│  - Rate limited       │  │  - Macros               │
│  - Food-101 model     │  │  - Source: lm_studio    │
└────────────────────────┘  └────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │   Success?    │
                    └───────┬───────┘
                       No   │   Yes
                       ┌────┴────┐
                       ▼         ▼
┌────────────────────────┐  ┌────────────────────────┐
│  Use Fallback          │  │  Return Results        │
│  - Conservative est.   │  │  - Food items          │
│  - Generic values      │  │  - Calories             │
│  - Low confidence      │  │  - Source: hugging_face│
└────────────────────────┘  └────────────────────────┘
                            │
                            ▼
                    ┌────────────────────────┐
                    │  Return Results        │
                    │  - "Unknown food"      │
                    │  - Est. 200 calories   │
                    │  - Source: fallback    │
                    └────────────────────────┘
```

## Screens

1. **Auth Screen**: Login/Registration
2. **Home Screen**: Daily progress and recent entries
3. **Scan Screen**: Capture/upload food images for analysis
4. **History Screen**: View past food analyses
5. **Suggestions Screen**: Get meal recommendations
6. **Profile Screen**: Manage settings and preferences

## Building for Production

### Android

```bash
cd frontend
flutter build apk --release
# Or for app bundle
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
cd frontend
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive.

## Troubleshooting

### LM Studio Not Available
- Make sure LM Studio is running
- Check server is started in LM Studio settings
- Verify port matches in `.env` (default: 1234)

### Hugging Face Errors
- Verify your token is valid
- Check you haven't exceeded rate limits
- Try a different model in `.env`

### Image Processing Errors
- Ensure image is JPEG or PNG
- Check file size (max 10MB recommended)
- Verify image is not corrupted

### Flutter Build Issues
- Run `flutter clean`
- Run `flutter pub get`
- Check `flutter doctor` for missing dependencies

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
