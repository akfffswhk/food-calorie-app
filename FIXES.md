# Fix Documentation - Sign Up Issue Resolution

## Date: 2026-05-13

## Summary
Fixed multiple issues preventing user registration and sign-up functionality in the Food Calorie Analyzer app.

---

## Backend Changes

### 1. Database Connection (app/main.py)
**Issue**: Database was not being connected on startup, causing `RuntimeError: Users database not connected`

**Fix**: Added startup and shutdown event handlers to connect/disconnect from MongoDB

```python
@app.on_event("startup")
async def startup_event():
    """Connect to databases on startup"""
    await Database.connect()

@app.on_event("shutdown")
async def shutdown_event():
    """Disconnect from databases on shutdown"""
    await Database.disconnect()
```

### 2. Password Hashing (app/auth.py)
**Issue**: Passlib bcrypt initialization was failing with `ValueError: password cannot be longer than 72 bytes`

**Fix**: Replaced passlib with direct bcrypt library

**Before**:
```python
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)
```

**After**:
```python
import bcrypt

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
```

---

## Frontend Changes

### 1. Auth Provider (lib/providers/auth_provider.dart)
**Issue 1**: Response parsing was incorrect - looking for `user_id` at top level instead of nested in `user` object

**Issue 2**: `setState()` was being called during build phase causing Flutter errors

**Fixes**:

#### Login Method
```dart
// Before
final userId = response['user_id'] as String?;

// After
final user = response['user'] as Map<String, dynamic>?;
final userId = user?['id'] as String?;
```

#### Register Method
```dart
// Before
final refreshToken = response['refresh_token'] as String?;
final userId = response['user_id'] as String?;

// After
final user = response['user'] as Map<String, dynamic>?;
final userId = user?['id'] as String?;
```

#### Init Method
```dart
// Before - removed notifyListeners() during init
Future<void> init() async {
  _isLoading = true;
  notifyListeners();
  // ... code ...
  finally {
    _isLoading = false;
    notifyListeners();
  }
}

// After - removed notifyListeners() calls
Future<void> init() async {
  try {
    // ... code ...
  } catch (e) {
    _errorMessage = e.toString();
  }
}
```

#### Removed Refresh Token Dependencies
Since the backend doesn't return refresh tokens, removed all references to `_refreshTokenKey`:
- Removed from `init()` method
- Removed from `login()` method
- Removed from `register()` method
- Removed from `logout()` method
- Removed from `refreshToken()` method (now uses access token)

### 2. API Service (lib/services/api_service.dart)
**Issue**: Token refresh interceptor was looking for `refresh_token` key that doesn't exist

**Fix**: Updated to use `auth_token` for refresh

```dart
// Before
_storage.read(key: 'refresh_token').then((refreshToken) {
  if (refreshToken != null) {
    Dio().post('$_baseUrl/api/auth/refresh', data: {'refresh_token': refreshToken}, ...)
  }
});

// After
_storage.read(key: 'auth_token').then((token) {
  if (token != null) {
    Dio().post('$_baseUrl/api/auth/refresh', data: {'refresh_token': token}, ...)
  }
});
```

### 3. Dependency Updates (pubspec.yaml)
Updated packages to fix web compatibility issues:

```yaml
# Before
image_cropper: ^5.0.1
intl: ^0.18.1
fl_chart: ^0.66.0
flutter_secure_storage: ^9.0.0

# After
image_cropper: ^12.2.1
intl: ^0.20.2
fl_chart: ^1.2.0
flutter_secure_storage: ^10.1.0
```

---

## Backend API Response Format

### Register/Login Response
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "6a0378bfd314c871ec1469e8",
    "email": "test@example.com",
    "username": null,
    "daily_calorie_goal": 2000,
    "dietary_preferences": [],
    "allergies": [],
    "created_at": "2026-05-12T19:00:15.002320"
  }
}
```

---

## Testing

### Backend Test
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'
```

### Services Status
All services are now running:
- MongoDB Users: `localhost:27017`
- MongoDB Records: `localhost:27018`
- YOLO Service: `localhost:8001`
- Backend API: `localhost:8000`
- Flutter Web: Chrome browser

---

## Files Modified

### Backend
- `app/main.py` - Added database connection events
- `app/auth.py` - Replaced passlib with bcrypt

### Frontend
- `lib/providers/auth_provider.dart` - Fixed response parsing and removed setState during build
- `lib/services/api_service.dart` - Fixed token refresh interceptor
- `pubspec.yaml` - Updated dependencies for web compatibility

---

## Notes

1. The backend now uses direct bcrypt library instead of passlib for password hashing
2. The frontend no longer expects refresh tokens from the backend
3. All notifyListeners() calls during initialization have been removed to prevent build-phase errors
4. The database connection is now established on application startup
