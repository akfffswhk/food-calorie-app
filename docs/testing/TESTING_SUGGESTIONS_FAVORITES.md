# Suggestions and Favorites Testing

## Overview

This document outlines the testing plan for the suggestions and favorites functionality in the Food Calorie App.

## Test Environment

- **Backend API**: http://localhost:8000
- **Frontend**: Flutter app
- **Authentication**: JWT Bearer tokens
- **Database**: MongoDB

## Test Cases

### Suggestions Loading Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-SUG-001 | Load suggestions on app start | Suggestions display with loading indicator | ⏳ |
| TC-SUG-002 | Load suggestions with meal type filter | Filtered suggestions display | ⏳ |
| TC-SUG-003 | Load suggestions with calorie limit | Suggestions within calorie limit | ⏳ |
| TC-SUG-004 | Load suggestions with no auth token | Redirect to login or error | ⏳ |
| TC-SUG-005 | Load suggestions with expired token | Token refresh, then suggestions load | ⏳ |
| TC-SUG-006 | Load suggestions with network error | Error message shown | ⏳ |
| TC-SUG-007 | Load suggestions with server error | Error message shown | ⏳ |
| TC-SUG-008 | Load suggestions with timeout | Timeout error message | ⏳ |
| TC-SUG-009 | Load suggestions with empty result | Empty state message shown | ⏳ |
| TC-SUG-010 | Pull to refresh suggestions | Suggestions reload with animation | ⏳ |

### Meal Suggestions Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-MS-001 | Load meal suggestions for breakfast | Breakfast suggestions display | ⏳ |
| TC-MS-002 | Load meal suggestions for lunch | Lunch suggestions display | ⏳ |
| TC-MS-003 | Load meal suggestions for dinner | Dinner suggestions display | ⏳ |
| TC-MS-004 | Load meal suggestions for snacks | Snack suggestions display | ⏳ |
| TC-MS-005 | Load meal suggestions with 0 calories | Empty list or error message | ⏳ |
| TC-MS-006 | Load meal suggestions with high calories | All available suggestions | ⏳ |

### Recipe Suggestions Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-RS-001 | Load recipe suggestions with ingredients | Recipe suggestions display | ⏳ |
| TC-RS-002 | Load recipe suggestions with single ingredient | Relevant recipes display | ⏳ |
| TC-RS-003 | Load recipe suggestions with multiple ingredients | Filtered recipes display | ⏳ |
| TC-RS-004 | Load recipe suggestions with no matching recipes | Empty state message | ⏳ |
| TC-RS-005 | Load recipe suggestions with calorie limit | Recipes within limit display | ⏳ |

### Alternative Suggestions Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-AS-001 | Load alternatives for high-calorie food | Healthier alternatives display | ⏳ |
| TC-AS-002 | Load alternatives with calorie savings | Savings percentage shown | ⏳ |
| TC-AS-003 | Load alternatives for common food | Relevant alternatives display | ⏳ |
| TC-AS-004 | Load alternatives with no results | Empty state message | ⏳ |

### Favorites Toggle Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FAV-001 | Tap favorite icon on suggestion | Icon changes to filled, API called | ⏳ |
| TC-FAV-002 | Tap favorite icon again | Icon changes to outline, API called | ⏳ |
| TC-FAV-003 | Toggle favorite with network error | Error message, state reverts | ⏳ |
| TC-FAV-004 | Toggle favorite with server error | Error message, state reverts | ⏳ |
| TC-FAV-005 | Toggle favorite with no auth token | Redirect to login or error | ⏳ |
| TC-FAV-006 | Toggle favorite with optimistic update | UI updates immediately, API in background | ⏳ |

### Favorites Loading Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FAV-007 | Load favorites on app start | Favorites display with loading indicator | ⏳ |
| TC-FAV-008 | Load favorites with no auth token | Redirect to login or error | ⏳ |
| TC-FAV-009 | Load favorites with empty list | Empty state message shown | ⏳ |
| TC-FAV-010 | Load favorites with network error | Error message shown | ⏳ |
| TC-FAV-011 | Load favorites after adding favorite | New favorite appears in list | ⏳ |
| TC-FAV-012 | Load favorites after removing favorite | Favorite removed from list | ⏳ |

### Favorites Persistence Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-FAV-013 | Add favorite, close app, reopen | Favorite persists | ⏳ |
| TC-FAV-014 | Remove favorite, close app, reopen | Favorite removed persists | ⏳ |
| TC-FAV-015 | Add multiple favorites, close app, reopen | All favorites persist | ⏳ |
| TC-FAV-016 | Clear all favorites, close app, reopen | Empty list persists | ⏳ |

### Recipe Detail Navigation Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-RD-001 | Tap "View Recipe" on suggestion | Navigate to recipe detail screen | ⏳ |
| TC-RD-002 | View recipe with ingredients | Ingredients list displays | ⏳ |
| TC-RD-003 | View recipe with nutrition info | Nutrition breakdown displays | ⏳ |
| TC-RD-004 | View recipe with prep time | Prep time displays | ⏳ |
| TC-RD-005 | View recipe with image | Recipe image displays | ⏳ |
| TC-RD-006 | Tap back button on recipe detail | Return to suggestions screen | ⏳ |

### Add to Today Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-AT-001 | Tap "Add to Today" on suggestion | Confirmation dialog shows | ⏳ |
| TC-AT-002 | Confirm "Add to Today" | Item added to today's meals | ⏳ |
| TC-AT-003 | Cancel "Add to Today" | Dialog closes, nothing added | ⏳ |
| TC-AT-004 | Add to Today with network error | Error message, nothing added | ⏳ |
| TC-AT-005 | Add to Today with server error | Error message, nothing added | ⏳ |

### Caching Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-CACHE-001 | Load suggestions, check cache | Suggestions cached | ⏳ |
| TC-CACHE-002 | Load suggestions again from cache | Suggestions load from cache (faster) | ⏳ |
| TC-CACHE-003 | Force refresh suggestions | Cache invalidated, new data loaded | ⏳ |
| TC-CACHE-004 | Cache expires after TTL | New data loaded on next request | ⏳ |
| TC-CACHE-005 | Invalidate cache on favorite toggle | Cache cleared, new data loaded | ⏳ |

### UI/UX Tests

| Test Case | Description | Expected Result | Status |
|-----------|-------------|-----------------|--------|
| TC-UI-001 | Suggestions display in card format | Cards with image, title, calories | ⏳ |
| TC-UI-002 | Favorite icon visible on suggestion | Heart icon displays | ⏳ |
| TC-UI-003 | Favorite icon changes state | Filled/outline states visible | ⏳ |
| TC-UI-004 | Calories display prominently | Calorie count visible | ⏳ |
| TC-UI-005 | Meal type selector works | Filter updates suggestions | ⏳ |
| TC-UI-006 | Calorie slider works | Filter updates suggestions | ⏳ |
| TC-UI-007 | Empty state displays helpful message | User knows what to do | ⏳ |
| TC-UI-008 | Loading state displays spinner | User knows data is loading | ⏳ |
| TC-UI-009 | Error state displays retry button | User can retry failed request | ⏳ |

### Performance Tests

| Metric | Target | Status |
|--------|--------|--------|
| Suggestions load time | < 1s | ⏳ |
| Favorites load time | < 500ms | ⏳ |
| Favorite toggle response | < 300ms | ⏳ |
| Recipe detail navigation | < 200ms | ⏳ |
| Cache hit response | < 100ms | ⏳ |

## API Endpoint Tests

### GET /api/suggestions

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-API-SUG-001 | Default params | 200 OK with suggestions | ⏳ |
| TC-API-SUG-002 | meal_type=breakfast | 200 OK with breakfast suggestions | ⏳ |
| TC-API-SUG-003 | remaining_calories=500 | 200 OK with filtered suggestions | ⏳ |
| TC-API-SUG-004 | No auth token | 401 Unauthorized | ⏳ |
| TC-API-SUG-005 | Invalid meal_type | 400 Bad Request or empty list | ⏳ |

### GET /api/suggestions/meal

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-API-MS-001 | remaining_calories=500 | 200 OK with meal suggestions | ⏳ |
| TC-API-MS-002 | remaining_calories=0 | 200 OK with empty list | ⏳ |
| TC-API-MS-003 | No auth token | 401 Unauthorized | ⏳ |

### GET /api/suggestions/recipe

| Test Case | Query Params | Expected Response | Status |
|-----------|--------------|-------------------|--------|
| TC-API-RS-001 | ingredients=chicken,rice | 200 OK with recipes | ⏳ |
| TC-API-RS-002 | max_calories=500 | 200 OK with filtered recipes | ⏳ |
| TC-API-RS-003 | No auth token | 401 Unauthorized | ⏳ |

### GET /api/suggestions/alternative/{food_name}

| Test Case | Params | Expected Response | Status |
|-----------|--------|-------------------|--------|
| TC-API-AS-001 | food_name=pizza, current_calories=300 | 200 OK with alternatives | ⏳ |
| TC-API-AS-002 | No auth token | 401 Unauthorized | ⏳ |

### POST /api/suggestions/favorite/{id}

| Test Case | ID | Expected Response | Status |
|-----------|----|-------------------|--------|
| TC-API-FAV-001 | Valid ID | 200 OK with updated status | ⏳ |
| TC-API-FAV-002 | Invalid ID format | 400 Bad Request | ⏳ |
| TC-API-FAV-003 | Non-existent ID | 404 Not Found | ⏳ |
| TC-API-FAV-004 | No auth token | 401 Unauthorized | ⏳ |

### GET /api/suggestions/favorites

| Test Case | Expected Response | Status |
|-----------|-------------------|--------|
| TC-API-FAV-005 | User's favorites | 200 OK with favorites list | ⏳ |
| TC-API-FAV-006 | No favorites | 200 OK with empty list | ⏳ |
| TC-API-FAV-007 | No auth token | 401 Unauthorized | ⏳ |

## Integration Tests

| Test Case | Flow | Expected Result | Status |
|-----------|------|-----------------|--------|
| TC-E2E-001 | Load suggestions → Favorite → Verify in favorites | Complete flow works | ⏳ |
| TC-E2E-002 | Load suggestions → View recipe → Add to today | Complete flow works | ⏳ |
| TC-E2E-003 | Load favorites → Remove favorite → Verify removed | Complete flow works | ⏳ |
| TC-E2E-004 | Load suggestions → Filter by meal type → Favorite | Complete flow works | ⏳ |
| TC-E2E-005 | Load suggestions → Filter by calories → View recipe | Complete flow works | ⏳ |

## Test Results Summary

| Category | Total | Passed | Failed | Pending |
|----------|-------|--------|--------|---------|
| Suggestions Loading | 10 | 0 | 0 | 10 |
| Meal Suggestions | 6 | 0 | 0 | 6 |
| Recipe Suggestions | 5 | 0 | 0 | 5 |
| Alternative Suggestions | 4 | 0 | 0 | 4 |
| Favorites Toggle | 6 | 0 | 0 | 6 |
| Favorites Loading | 6 | 0 | 0 | 6 |
| Favorites Persistence | 4 | 0 | 0 | 4 |
| Recipe Detail Navigation | 6 | 0 | 0 | 6 |
| Add to Today | 5 | 0 | 0 | 5 |
| Caching | 5 | 0 | 0 | 5 |
| UI/UX | 9 | 0 | 0 | 9 |
| Performance | 5 | 0 | 0 | 5 |
| API Endpoints | 17 | 0 | 0 | 17 |
| Integration | 5 | 0 | 0 | 5 |
| **Total** | **93** | **0** | **0** | **93** |

## Manual Testing Steps

### Step 1: Setup
1. Start the backend server
2. Launch the Flutter app
3. Log in with valid credentials

### Step 2: Test Suggestions Loading
1. Navigate to Suggestions tab
2. Verify loading indicator appears
3. Wait for suggestions to load
4. Verify suggestions display with images, titles, and calories

### Step 3: Test Meal Type Filter
1. Tap meal type selector
2. Select "Breakfast"
3. Verify suggestions filter to breakfast items
4. Select "Lunch"
5. Verify suggestions filter to lunch items

### Step 4: Test Calorie Filter
1. Adjust calorie slider
2. Verify suggestions filter to items within limit
3. Set slider to 0
4. Verify empty state displays

### Step 5: Test Favorites Toggle
1. Tap favorite icon on a suggestion
2. Verify icon changes to filled
3. Navigate to Favorites tab
4. Verify suggestion appears in favorites
5. Tap favorite icon again
6. Verify icon changes to outline
7. Navigate to Favorites tab
8. Verify suggestion removed from favorites

### Step 6: Test Recipe Detail
1. Tap "View Recipe" on a suggestion
2. Verify recipe detail screen opens
3. Verify ingredients list displays
4. Verify nutrition breakdown displays
5. Tap back button
6. Verify return to suggestions screen

### Step 7: Test Add to Today
1. Tap "Add to Today" on a suggestion
2. Verify confirmation dialog appears
3. Tap "Cancel"
4. Verify dialog closes
5. Tap "Add to Today" again
6. Tap "Confirm"
7. Navigate to History tab
8. Verify item added to today's meals

### Step 8: Test Caching
1. Load suggestions
2. Navigate away and back
3. Verify suggestions load quickly (from cache)
4. Pull to refresh
5. Verify suggestions reload with animation

### Step 9: Test Error Scenarios
1. Turn off network connection
2. Try to load suggestions
3. Verify error message appears
4. Turn on network connection
5. Tap retry button
6. Verify suggestions load successfully

## Known Issues

None currently documented.

## Notes

- All tests require a running backend server
- Tests should be run with both valid and invalid auth tokens
- Network conditions should be varied (good, poor, offline)
- Test with various suggestion types and calorie ranges

## Next Steps

1. Execute manual tests
2. Create automated test files
3. Run automated tests
4. Document any issues found
5. Fix issues and retest
6. Update implementation status
