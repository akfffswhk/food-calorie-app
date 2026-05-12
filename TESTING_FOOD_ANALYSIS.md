# Food Analysis Flow Testing

## Overview

This document outlines the testing plan for the food analysis flow in the Food Calorie App.

## Test Environment

- **Backend API**: http://localhost:8000
- **Frontend**: Flutter app
- **Authentication**: Required (Bearer token)

## Test Cases

### 1. Image Selection Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-001 | Select image from camera | Image displays in preview area | ⏳ |
| TC-FA-002 | Select image from gallery | Image displays in preview area | ⏳ |
| TC-FA-003 | Cancel image selection | No image selected, preview empty | ⏳ |
| TC-FA-004 | Select large image (>5MB) | Image compressed and displayed | ⏳ |
| TC-FA-005 | Select invalid file type | Error message shown | ⏳ |

### 2. Meal Type Selection Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-006 | Select breakfast meal type | "breakfast" selected | ⏳ |
| TC-FA-007 | Select lunch meal type | "lunch" selected | ⏳ |
| TC-FA-008 | Select dinner meal type | "dinner" selected | ⏳ |
| TC-FA-009 | Select snack meal type | "snack" selected (default) | ⏳ |

### 3. Analysis Request Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-010 | Analyze with valid image | Loading indicator, then result | ⏳ |
| TC-FA-011 | Analyze without image | Button disabled | ⏳ |
| TC-FA-012 | Analyze with no auth token | 401 error, token refresh attempted | ⏳ |
| TC-FA-013 | Analyze with expired token | Token refresh, then analysis | ⏳ |
| TC-FA-014 | Analyze with network error | Error message shown | ⏳ |
| TC-FA-015 | Analyze with server error (500) | Error message shown | ⏳ |
| TC-FA-016 | Analyze with timeout (30s) | Timeout error message | ⏳ |
| TC-FA-017 | Analyze during analysis | Button disabled, no duplicate request | ⏳ |

### 4. Analysis Result Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-018 | Display analysis result | Result card shown with nutrition info | ⏳ |
| TC-FA-019 | Display food items | List of identified food items | ⏳ |
| TC-FA-020 | Display calories | Total calories shown | ⏳ |
| TC-FA-021 | Display macros | Protein, carbs, fat shown | ⏳ |
| TC-FA-022 | Display confidence scores | Confidence percentages shown | ⏳ |
| TC-FA-023 | Display source | Analysis source (AI/ML) shown | ⏳ |

### 5. Save to History Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-024 | Save result to history | Entry added to history | ⏳ |
| TC-FA-025 | Save with meal type | Meal type saved correctly | ⏳ |
| TC-FA-026 | Save with timestamp | Timestamp saved correctly | ⏳ |
| TC-FA-027 | Save without auth | 401 error, not saved | ⏳ |
| TC-FA-028 | Save with network error | Error message, not saved | ⏳ |

### 6. Result Display Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-029 | Show result dialog | Dialog with result card | ⏳ |
| TC-FA-030 | Close result dialog | Dialog dismissed, returns to scan | ⏳ |
| TC-FA-031 | Save and close | Entry saved, dialog dismissed | ⏳ |

### 7. Error Handling Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-032 | Invalid base64 image | Error message shown | ⏳ |
| TC-FA-033 | Corrupted image data | Error message shown | ⏳ |
| TC-FA-034 | Empty image data | Error message shown | ⏳ |
| TC-FA-035 | API returns invalid JSON | Error message shown | ⏳ |
| TC-FA-036 | API returns missing fields | Error message shown | ⏳ |

### 8. Integration Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FA-037 | Full flow: select → analyze → save | Complete flow works end-to-end | ⏳ |
| TC-FA-038 | Multiple analyses in session | Each analysis independent | ⏳ |
| TC-FA-039 | Analysis updates daily stats | Stats reflect new entry | ⏳ |
| TC-FA-040 | Analysis updates suggestions | Suggestions based on new calories | ⏳ |

## API Endpoint Tests

### POST /api/analyze/base64

| Test Case | Request Body | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-API-001 | Valid base64 image | 200 OK with analysis result | ⏳ |
| TC-API-002 | Missing image field | 400 Bad Request | ⏳ |
| TC-API-003 | Invalid base64 string | 400 Bad Request | ⏳ |
| TC-API-004 | No auth token | 401 Unauthorized | ⏳ |
| TC-API-005 | Expired token | 401 Unauthorized (refresh attempted) | ⏳ |
| TC-API-006 | Large image (>10MB) | 413 Payload Too Large | ⏳ |
| TC-API-007 | Server error | 500 Internal Server Error | ⏳ |

## Expected Response Format

```json
{
  "id": "string",
  "nutrition": {
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fat": 0
  },
  "items": [
    {
      "name": "string",
      "calories": 0,
      "confidence": 0.0
    }
  ],
  "source": "string",
  "created_at": "ISO8601 timestamp"
}
```

## Test Data

### Sample Images

1. **Clear food image**: Well-lit, single food item
2. **Multiple food items**: Plate with multiple foods
3. **Blurred image**: Low quality, hard to identify
4. **Non-food image**: Should return error or no results
5. **Large image**: High resolution, >5MB

### Sample Meal Types

- breakfast
- lunch
- dinner
- snack

## Manual Testing Steps

### Step 1: Setup
1. Start the backend server
2. Launch the Flutter app
3. Log in with valid credentials

### Step 2: Test Image Selection
1. Navigate to Scan tab
2. Tap "Camera" button
3. Capture an image
4. Verify image displays in preview
5. Tap "Gallery" button
6. Select an image
7. Verify image displays in preview

### Step 3: Test Meal Type Selection
1. Tap each meal type option
2. Verify selection updates
3. Verify default is "snack"

### Step 4: Test Analysis
1. With image selected, tap "Analyze Food"
2. Verify loading indicator appears
3. Wait for analysis to complete
4. Verify result dialog appears
5. Verify nutrition information is displayed
6. Verify food items are listed

### Step 5: Test Save to History
1. In result dialog, tap "Save"
2. Verify dialog closes
3. Navigate to History tab
4. Verify new entry appears
5. Verify meal type is correct
6. Verify calories are correct

### Step 6: Test Error Scenarios
1. Try to analyze without image (button should be disabled)
2. Try to analyze with network disconnected
3. Verify error message appears
4. Log out and try to analyze
5. Verify redirect to login or error message

## Automated Testing

### Unit Tests

Create unit tests for:
- `AnalysisProvider.analyzeImageBase64()`
- `AnalysisProvider.clearResult()`
- `AnalysisProvider.clearError()`

### Widget Tests

Create widget tests for:
- `ScanScreen` image selection
- `ScanScreen` meal type selection
- `ScanScreen` analyze button state
- `AnalysisResultCard` display

### Integration Tests

Create integration tests for:
- Full analysis flow
- Save to history flow
- Error handling flow

## Performance Tests

| Metric | Target | Status |
|--------|--------|--------|
| Image selection time | < 1s | ⏳ |
| Analysis request time | < 10s | ⏳ |
| Result display time | < 1s | ⏳ |
| Save to history time | < 2s | ⏳ |

## Known Issues

None currently documented.

## Test Results Summary

| Category | Total | Passed | Failed | Pending |
|----------|-------|--------|--------|---------|
| Image Selection | 5 | 0 | 0 | 5 |
| Meal Type Selection | 4 | 0 | 0 | 4 |
| Analysis Request | 8 | 0 | 0 | 8 |
| Analysis Result | 6 | 0 | 0 | 6 |
| Save to History | 5 | 0 | 0 | 5 |
| Result Display | 3 | 0 | 0 | 3 |
| Error Handling | 5 | 0 | 0 | 5 |
| Integration | 4 | 0 | 0 | 4 |
| API Endpoint | 7 | 0 | 0 | 7 |
| **Total** | **47** | **0** | **0** | **47** |

## Notes

- All tests require a running backend server
- Tests should be run with both valid and invalid auth tokens
- Network conditions should be varied (good, poor, offline)
- Test with various image types and sizes

## Next Steps

1. Execute manual tests
2. Create automated test files
3. Run automated tests
4. Document any issues found
5. Fix issues and retest
6. Update implementation status
