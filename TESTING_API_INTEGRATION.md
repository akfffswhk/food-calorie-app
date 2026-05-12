# API Integration Testing

## Overview

This document outlines the comprehensive testing plan for all API integrations in the Food Calorie App.

## Test Environment

- **Backend API**: http://localhost:8000
- **Frontend**: Flutter app
- **Authentication**: JWT Bearer tokens
- **Database**: MongoDB

## API Endpoints Summary

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login user | No |
| POST | `/api/auth/logout` | Logout user | Yes |
| GET | `/api/auth/me` | Get current user | Yes |
| POST | `/api/auth/refresh` | Refresh access token | No |

### Analysis Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/status` | Get service status | No |
| POST | `/api/analyze` | Analyze food image (file) | Yes |
| POST | `/api/analyze/base64` | Analyze food image (base64) | Yes |

### History Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/history` | Get user history | Yes |
| GET | `/api/history/daily/{date}` | Get daily history | Yes |
| GET | `/api/history/weekly` | Get weekly history | Yes |
| GET | `/api/history/monthly` | Get monthly history | Yes |
| GET | `/api/history/stats` | Get user statistics | Yes |
| GET | `/api/history/{id}` | Get specific analysis | Yes |
| DELETE | `/api/history/{id}` | Delete analysis | Yes |

### Suggestions Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/suggestions` | Get suggestions | Yes |
| GET | `/api/suggestions/meal` | Get meal suggestions | Yes |
| GET | `/api/suggestions/recipe` | Get recipe suggestions | Yes |
| GET | `/api/suggestions/alternative/{food_name}` | Get alternatives | Yes |
| POST | `/api/suggestions/favorite/{id}` | Toggle favorite | Yes |
| GET | `/api/suggestions/favorites` | Get favorites | Yes |

### Profile Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/profile` | Get user profile | Yes |
| PUT | `/api/profile` | Update profile | Yes |
| PUT | `/api/profile/goals` | Update goals | Yes |
| POST | `/api/profile/change-password` | Change password | Yes |
| DELETE | `/api/profile` | Delete account | Yes |

## Test Cases

### Authentication API Tests

#### POST /api/auth/register

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-AUTH-001 | Valid email and password | 201 Created with access token | ⏳ |
| TC-AUTH-002 | Duplicate email | 400 Bad Request | ⏳ |
| TC-AUTH-003 | Invalid email format | 422 Validation Error | ⏳ |
| TC-AUTH-004 | Password too short (<6 chars) | 422 Validation Error | ⏳ |
| TC-AUTH-005 | Password too long (>100 chars) | 422 Validation Error | ⏳ |
| TC-AUTH-006 | Duplicate username | 400 Bad Request | ⏳ |

#### POST /api/auth/login

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-AUTH-007 | Valid credentials | 200 OK with access token | ⏳ |
| TC-AUTH-008 | Invalid email | 401 Unauthorized | ⏳ |
| TC-AUTH-009 | Invalid password | 401 Unauthorized | ⏳ |
| TC-AUTH-010 | Deactivated account | 403 Forbidden | ⏳ |

#### POST /api/auth/logout

| Test Case | Headers | Expected Response | Status |
|-----------|---------|-------------------|--------|
| TC-AUTH-011 | Valid token | 200 OK | ⏳ |
| TC-AUTH-012 | Invalid token | 401 Unauthorized | ⏳ |
| TC-AUTH-013 | No token | 401 Unauthorized | ⏳ |

#### GET /api/auth/me

| Test Case | Headers | Expected Response | Status |
|-----------|---------|-------------------|--------|
| TC-AUTH-014 | Valid token | 200 OK with user data | ⏳ |
| TC-AUTH-015 | Invalid token | 401 Unauthorized | ⏳ |
| TC-AUTH-016 | Expired token | 401 Unauthorized | ⏳ |

#### POST /api/auth/refresh

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-AUTH-017 | Valid refresh token | 200 OK with new access token | ⏳ |
| TC-AUTH-018 | Invalid refresh token | 401 Unauthorized | ⏳ |
| TC-AUTH-019 | Expired refresh token | 401 Unauthorized | ⏳ |

### Analysis API Tests

#### GET /api/status

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-ANL-001 | Service status with all services | 200 OK | ⏳ |

#### POST /api/analyze

| Test Case | Request | Expected Response | Status |
|-----------|---------|-------------------|--------|
| TC-ANL-002 | Valid food image | 200 OK with analysis result | ⏳ |
| TC-ANL-003 | Invalid file type | 400 Bad Request | ⏳ |
| TC-ANL-004 | Corrupted image | 400 Bad Request | ⏳ |
| TC-ANL-005 | No auth token | 401 Unauthorized | ⏳ |
| TC-ANL-006 | Expired token | 401 Unauthorized | ⏳ |

#### POST /api/analyze/base64

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-ANL-007 | Valid base64 image | 200 OK with analysis result | ⏳ |
| TC-ANL-008 | Invalid base64 string | 400 Bad Request | ⏳ |
| TC-ANL-009 | Missing image field | 400 Bad Request | ⏳ |
| TC-ANL-010 | No auth token | 401 Unauthorized | ⏳ |

### History API Tests

#### GET /api/history

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-HIST-001 | Default params | 200 OK with history list | ⏳ |
| TC-HIST-002 | limit=10 | 200 OK with 10 entries | ⏳ |
| TC-HIST-003 | skip=5 | 200 OK with offset entries | ⏳ |
| TC-HIST-004 | No auth token | 401 Unauthorized | ⏳ |

#### GET /api/history/daily/{date}

| Test Case | Date | Expected Response | Status |
|-----------|------|-------------------|--------|
| TC-HIST-005 | Valid date (YYYY-MM-DD) | 200 OK with daily summary | ⏳ |
| TC-HIST-006 | Invalid date format | 400 Bad Request | ⏳ |
| TC-HIST-007 | Date with no entries | 200 OK with empty list | ⏳ |

#### GET /api/history/weekly

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-HIST-008 | Default (today) | 200 OK with weekly data | ⏳ |
| TC-HIST-009 | end_date=2024-01-15 | 200 OK with weekly data | ⏳ |
| TC-HIST-010 | Invalid date format | 400 Bad Request | ⏳ |

#### GET /api/history/monthly

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-HIST-011 | year=2024, month=1 | 200 OK with monthly data | ⏳ |
| TC-HIST-012 | Invalid year (<2020) | 422 Validation Error | ⏳ |
| TC-HIST-013 | Invalid month (>12) | 422 Validation Error | ⏳ |

#### GET /api/history/stats

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-HIST-014 | User statistics | 200 OK with stats | ⏳ |

#### GET /api/history/{id}

| Test Case | ID | Expected Response | Status |
|-----------|----|-------------------|--------|
| TC-HIST-015 | Valid ID | 200 OK with analysis | ⏳ |
| TC-HIST-016 | Invalid ID format | 400 Bad Request | ⏳ |
| TC-HIST-017 | Non-existent ID | 404 Not Found | ⏳ |
| TC-HIST-018 | ID from different user | 404 Not Found | ⏳ |

#### DELETE /api/history/{id}

| Test Case | ID | Expected Response | Status |
|-----------|----|-------------------|--------|
| TC-HIST-019 | Valid ID | 200 OK with success message | ⏳ |
| TC-HIST-020 | Invalid ID format | 400 Bad Request | ⏳ |
| TC-HIST-021 | Non-existent ID | 404 Not Found | ⏳ |

### Suggestions API Tests

#### GET /api/suggestions

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-SUG-001 | Default params | 200 OK with suggestions | ⏳ |
| TC-SUG-002 | meal_type=breakfast | 200 OK with breakfast suggestions | ⏳ |
| TC-SUG-003 | remaining_calories=500 | 200 OK with filtered suggestions | ⏳ |
| TC-SUG-004 | No auth token | 401 Unauthorized | ⏳ |

#### GET /api/suggestions/meal

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-SUG-005 | remaining_calories=500 | 200 OK with meal suggestions | ⏳ |
| TC-SUG-006 | remaining_calories=0 | 200 OK with empty list | ⏳ |

#### GET /api/suggestions/recipe

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-SUG-007 | ingredients=chicken,rice | 200 OK with recipes | ⏳ |
| TC-SUG-008 | max_calories=500 | 200 OK with filtered recipes | ⏳ |

#### GET /api/suggestions/alternative/{food_name}

| Test Case | Params | Expected Response | Status |
|-----------|--------|-------------------|--------|
| TC-SUG-009 | food_name=pizza, current_calories=300 | 200 OK with alternatives | ⏳ |

#### POST /api/suggestions/favorite/{id}

| Test Case | ID | Expected Response | Status |
|-----------|----|-------------------|--------|
| TC-SUG-010 | Valid ID | 200 OK with updated status | ⏳ |
| TC-SUG-011 | Invalid ID format | 400 Bad Request | ⏳ |
| TC-SUG-012 | Non-existent ID | 404 Not Found | ⏳ |

#### GET /api/suggestions/favorites

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-SUG-013 | User's favorites | 200 OK with favorites list | ⏳ |
| TC-SUG-014 | No favorites | 200 OK with empty list | ⏳ |

### Profile API Tests

#### GET /api/profile

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-PROF-001 | User profile | 200 OK with profile data | ⏳ |
| TC-PROF-002 | No auth token | 401 Unauthorized | ⏳ |

#### PUT /api/profile

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-PROF-003 | Valid update | 200 OK with updated profile | ⏳ |
| TC-PROF-004 | Duplicate username | 400 Bad Request | ⏳ |
| TC-PROF-005 | No auth token | 401 Unauthorized | ⏳ |

#### PUT /api/profile/goals

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-PROF-006 | daily_calorie_goal=2000 | 200 OK with updated profile | ⏳ |
| TC-PROF-007 | daily_calorie_goal=1000 (<1200) | 422 Validation Error | ⏳ |
| TC-PROF-008 | daily_calorie_goal=6000 (>5000) | 422 Validation Error | ⏳ |

#### POST /api/profile/change-password

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-PROF-009 | Valid current and new password | 200 OK with success message | ⏳ |
| TC-PROF-010 | Invalid current password | 400 Bad Request | ⏳ |
| TC-PROF-011 | New password too short | 422 Validation Error | ⏳ |

#### DELETE /api/profile

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-PROF-012 | Account deletion | 200 OK with success message | ⏳ |
| TC-PROF-013 | No auth token | 401 Unauthorized | ⏳ |

## Error Handling Tests

### Network Error Tests

| Test Case | Scenario | Expected Behavior | Status |
|-----------|----------|-------------------|--------|
| TC-ERR-001 | No internet connection | Appropriate error message | ⏳ |
| TC-ERR-002 | Connection timeout | Timeout error message | ⏳ |
| TC-ERR-003 | Server not responding | Connection error message | ⏳ |

### Server Error Tests

| Test Case | Scenario | Expected Behavior | Status |
|-----------|----------|-------------------|--------|
| TC-ERR-004 | 500 Internal Server Error | Server error message | ⏳ |
| TC-ERR-005 | 503 Service Unavailable | Service unavailable message | ⏳ |
| TC-ERR-006 | 504 Gateway Timeout | Timeout error message | ⏳ |

### Client Error Tests

| Test Case | Scenario | Expected Behavior | Status |
|-----------|----------|-------------------|--------|
| TC-ERR-007 | 400 Bad Request | Validation error message | ⏳ |
| TC-ERR-008 | 401 Unauthorized | Login prompt or error | ⏳ |
| TC-ERR-009 | 403 Forbidden | Permission error message | ⏳ |
| TC-ERR-010 | 404 Not Found | Resource not found message | ⏳ |
| TC-ERR-011 | 422 Validation Error | Validation error details | ⏳ |
| TC-ERR-012 | 429 Too Many Requests | Rate limit message | ⏳ |

## Token Refresh Tests

| Test Case | Scenario | Expected Behavior | Status |
|-----------|----------|-------------------|--------|
| TC-TOKEN-001 | Access token expires | Automatic refresh with refresh token | ⏳ |
| TC-TOKEN-002 | Refresh token expires | Redirect to login | ⏳ |
| TC-TOKEN-003 | Both tokens expired | Redirect to login | ⏳ |
| TC-TOKEN-004 | Invalid refresh token | Redirect to login | ⏳ |

## Integration Tests

### End-to-End Flows

| Test Case | Flow | Expected Result | Status |
|-----------|------|-----------------|--------|
| TC-E2E-001 | Register → Login → Analyze → Save | Complete flow works | ⏳ |
| TC-E2E-002 | Login → Get History → Delete Entry | Complete flow works | ⏳ |
| TC-E2E-003 | Login → Get Suggestions → Favorite | Complete flow works | ⏳ |
| TC-E2E-004 | Login → Update Profile → Verify | Complete flow works | ⏳ |
| TC-E2E-005 | Login → Change Password → Re-login | Complete flow works | ⏳ |

## Performance Tests

| Metric | Target | Status |
|--------|--------|--------|
| API response time (average) | < 500ms | ⏳ |
| API response time (p95) | < 1s | ⏳ |
| API response time (p99) | < 2s | ⏳ |
| Concurrent requests (100) | All successful | ⏳ |
| Concurrent requests (1000) | All successful | ⏳ |

## Test Results Summary

| Category | Total | Passed | Failed | Pending |
|----------|-------|--------|--------|---------|
| Authentication | 19 | 0 | 0 | 19 |
| Analysis | 10 | 0 | 0 | 10 |
| History | 21 | 0 | 0 | 21 |
| Suggestions | 13 | 0 | 0 | 13 |
| Profile | 13 | 0 | 0 | 13 |
| Error Handling | 12 | 0 | 0 | 12 |
| Token Refresh | 4 | 0 | 0 | 4 |
| Integration | 5 | 0 | 0 | 5 |
| Performance | 5 | 0 | 0 | 5 |
| **Total** | **102** | **0** | **0** | **102** |

## Known Issues

### Fixed Issues

1. ✅ **Auth refresh endpoint** - Fixed to accept refresh token in request body instead of requiring authentication
2. ✅ **History stats endpoint** - Fixed route ordering to prevent conflict with `/{analysis_id}` endpoint
3. ✅ **MongoDB query typos** - Fixed `"<lt"` to `"$lt"` in history queries

### Pending Issues

None currently documented.

## Testing Tools

### Manual Testing

Use tools like:
- Postman
- Insomnia
- curl
- Swagger UI (http://localhost:8000/docs)

### Automated Testing

Create test files:
- `test_auth_api.py`
- `test_analysis_api.py`
- `test_history_api.py`
- `test_suggestions_api.py`
- `test_profile_api.py`

## Next Steps

1. Execute manual tests for each endpoint
2. Create automated test files
3. Run automated tests
4. Document any issues found
5. Fix issues and retest
6. Update implementation status
7. Prepare for production deployment
