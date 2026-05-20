# API E2E Tests

This directory contains comprehensive end-to-end tests for the Food Calorie App API.

## Test Structure

```
tests/
├── test_api_e2e.py          # Main E2E test file
├── pytest.ini               # Pytest configuration
└── README.md                # This file
```

## Test Coverage

The E2E tests cover the following API endpoints:

### Authentication (`/api/auth/*`)
- ✅ Register new user
- ✅ Login with valid credentials
- ✅ Login with invalid credentials
- ✅ Get current user info
- ✅ Logout
- ✅ Token refresh
- ✅ Error handling (duplicate email, short password, etc.)

### Analysis (`/api/analyze*`)
- ✅ Get service status
- ✅ Analyze image (file upload)
- ✅ Analyze image (base64)
- ✅ Authentication requirements
- ✅ Error handling (missing image, invalid image)

### History (`/api/history/*`)
- ✅ Save analysis to history
- ✅ Get user history
- ✅ Get daily history
- ✅ Get weekly history
- ✅ Get monthly history
- ✅ Get statistics
- ✅ Get specific analysis by ID
- ✅ Delete analysis
- ✅ Pagination support

### Suggestions (`/api/suggestions/*`)
- ✅ Get meal suggestions
- ✅ Get meal suggestions (specific endpoint)
- ✅ Get recipe suggestions
- ✅ Get alternative suggestions
- ✅ Toggle favorite
- ✅ Get favorites

### Profile (`/api/profile/*`)
- ✅ Get profile
- ✅ Update profile
- ✅ Update calorie goals
- ✅ Change password
- ✅ Delete account
- ✅ Validation (invalid goals, short passwords)

### Integration Tests
- ✅ Complete user flow (register → use → logout)
- ✅ Analysis and save flow

### Error Handling
- ✅ Invalid tokens
- ✅ Missing authentication
- ✅ Malformed JSON
- ✅ Invalid ID formats
- ✅ Non-existent resources

### Performance Tests
- ✅ Concurrent requests
- ✅ Large history pagination

## Prerequisites

Before running the tests, ensure you have:

1. Python 3.8+ installed
2. MongoDB running (default: localhost:27017)
3. All required dependencies installed

## Installation

```bash
cd backend

# Install test dependencies
pip install pytest pytest-asyncio httpx pillow

# Or install from requirements
pip install -r requirements.txt
```

## Running Tests

### Run All Tests

```bash
pytest tests/test_api_e2e.py
```

### Run with Verbose Output

```bash
pytest tests/test_api_e2e.py -v
```

### Run Specific Test Class

```bash
pytest tests/test_api_e2e.py::TestAuthentication -v
```

### Run Specific Test Method

```bash
pytest tests/test_api_e2e.py::TestAuthentication::test_register_new_user -v
```

### Run with Coverage Report

```bash
pip install pytest-cov
pytest tests/test_api_e2e.py --cov=app --cov-report=html
```

### Run Only Fast Tests

```bash
pytest tests/test_api_e2e.py -m "not slow"
```

### Run Only E2E Tests

```bash
pytest tests/test_api_e2e.py -m e2e
```

## Test Fixtures

The tests use the following fixtures:

- `test_client`: HTTP client for making API requests
- `setup_database`: Sets up and tears down database connections
- `test_user`: Creates a test user and returns credentials
- `auth_token`: Gets authentication token for test user
- `auth_headers`: Gets authentication headers
- `sample_image`: Creates a sample image for testing
- `sample_base64_image`: Creates a sample base64 image for testing

## Environment Variables

You can configure the test environment using environment variables:

```bash
# MongoDB connection string
export MONGODB_URI=mongodb://localhost:27017/food_calorie_test

# API base URL (for external tests)
export API_BASE_URL=http://localhost:8000
```

## Test Data

Tests use unique email addresses with timestamps to avoid conflicts:

```
testuser_20260514123456@example.com
```

Test data is automatically cleaned up after each test.

## Known Limitations

1. **AI Service Dependencies**: Some tests require AI services (YOLO, Gemma) to be running. These tests will be skipped if services are unavailable.

2. **Database State**: Tests assume a clean database state. Run tests in isolation or use a test database.

3. **Image Analysis**: Image analysis tests may fail if AI services are not properly configured.

## Troubleshooting

### Tests Fail with Database Connection Error

```bash
# Ensure MongoDB is running
mongod

# Or check connection
mongo --eval "db.adminCommand('ping')"
```

### Tests Fail with Import Error

```bash
# Ensure you're in the backend directory
cd backend

# Install dependencies
pip install -r requirements.txt
```

### Tests Fail with Authentication Error

```bash
# Check that JWT secret is configured
export JWT_SECRET=your-test-secret-key
```

### Tests Timeout

```bash
# Increase timeout in pytest.ini
# timeout = 600
```

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run E2E Tests
  run: |
    cd backend
    pytest tests/test_api_e2e.py -v --tb=short
```

## Contributing

When adding new endpoints:

1. Add test cases to the appropriate test class
2. Follow the existing naming convention (`test_<endpoint>_<scenario>`)
3. Include both success and error cases
4. Update this README with new test coverage

## License

These tests are part of the Food Calorie App project.
