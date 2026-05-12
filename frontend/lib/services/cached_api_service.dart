import 'package:food_calorie_app/services/api_service.dart';
import 'package:food_calorie_app/services/cache_service.dart';

/// Cached API service that wraps the base API service with caching
class CachedApiService {
  /// Cache TTL values (in seconds)
  static const int profileCacheTTL = 300; // 5 minutes
  static const int statsCacheTTL = 60; // 1 minute
  static const int suggestionsCacheTTL = 600; // 10 minutes
  static const int favoritesCacheTTL = 300; // 5 minutes
  static const int historyCacheTTL = 120; // 2 minutes

  /// Get user profile with caching
  static Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        CacheKeys.userProfile,
        profileCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getProfile();
    await CacheService.setWithTTL(CacheKeys.userProfile, result, profileCacheTTL);
    return result;
  }

  /// Get user stats with caching
  static Future<Map<String, dynamic>> getHistoryStats({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        CacheKeys.userStats,
        statsCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getHistoryStats();
    await CacheService.setWithTTL(CacheKeys.userStats, result, statsCacheTTL);
    return result;
  }

  /// Get suggestions with caching
  static Future<Map<String, dynamic>> getSuggestions({
    String? mealType,
    int? maxCalories,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheKeys.suggestionsKey(mealType ?? 'any', maxCalories ?? 500);

    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        cacheKey,
        suggestionsCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getSuggestions(
      mealType: mealType,
      maxCalories: maxCalories,
    );
    await CacheService.setWithTTL(cacheKey, result, suggestionsCacheTTL);
    return result;
  }

  /// Get meal suggestions with caching
  static Future<Map<String, dynamic>> getMealSuggestions({
    String? mealType,
    int? maxCalories,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheKeys.mealSuggestionsKey(maxCalories ?? 500);

    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        cacheKey,
        suggestionsCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getMealSuggestions(
      mealType: mealType,
      maxCalories: maxCalories,
    );
    await CacheService.setWithTTL(cacheKey, result, suggestionsCacheTTL);
    return result;
  }

  /// Get favorites with caching
  static Future<Map<String, dynamic>> getFavorites({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        CacheKeys.favorites,
        favoritesCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getFavorites();
    await CacheService.setWithTTL(CacheKeys.favorites, result, favoritesCacheTTL);
    return result;
  }

  /// Get history with caching
  static Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${CacheKeys.historyList}_page$page';

    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        cacheKey,
        historyCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getHistory(page: page, limit: limit);
    await CacheService.setWithTTL(cacheKey, result, historyCacheTTL);
    return result;
  }

  /// Get daily history with caching
  static Future<Map<String, dynamic>> getDailyHistory(
    String date, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheKeys.dailyHistoryKey(date);

    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        cacheKey,
        historyCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getDailyHistory(date);
    await CacheService.setWithTTL(cacheKey, result, historyCacheTTL);
    return result;
  }

  /// Get weekly history with caching
  static Future<Map<String, dynamic>> getWeeklyHistory({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        CacheKeys.weeklyHistory,
        historyCacheTTL,
      );
      if (cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getWeeklyHistory();
    await CacheService.setWithTTL(CacheKeys.weeklyHistory, result, historyCacheTTL);
    return result;
  }

  /// Get monthly history with caching
  static Future<Map<String, dynamic>> getMonthlyHistory(
    int year,
    int month, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheKeys.monthlyHistoryKey(year, month);

    if (!forceRefresh) {
      final cached = await CacheService.getWithTTL<Map<String, dynamic>>(
        cacheKey,
        historyCacheTTL,
      );
      if ( cached != null) {
        return cached;
      }
    }

    final result = await ApiService.getMonthlyHistory();
    await CacheService.setWithTTL(cacheKey, result, historyCacheTTL);
    return result;
  }

  /// Invalidate profile cache
  static Future<void> invalidateProfile() async {
    await CacheService.remove(CacheKeys.userProfile);
  }

  /// Invalidate stats cache
  static Future<void> invalidateStats() async {
    await CacheService.remove(CacheKeys.userStats);
  }

  /// Invalidate suggestions cache
  static Future<void> invalidateSuggestions() async {
    final keys = await CacheService.keys();
    for (final key in keys) {
      if (key.startsWith(CacheKeys.suggestions) ||
          key.startsWith(CacheKeys.mealSuggestions)) {
        await CacheService.remove(key);
      }
    }
  }

  /// Invalidate favorites cache
  static Future<void> invalidateFavorites() async {
    await CacheService.remove(CacheKeys.favorites);
  }

  /// Invalidate history cache
  static Future<void> invalidateHistory() async {
    final keys = await CacheService.keys();
    for (final key in keys) {
      if (key.startsWith(CacheKeys.historyList) ||
          key.startsWith(CacheKeys.dailyHistory) ||
          key.startsWith(CacheKeys.weeklyHistory) ||
          key.startsWith(CacheKeys.monthlyHistory)) {
        await CacheService.remove(key);
      }
    }
  }

  /// Invalidate all cache
  static Future<void> invalidateAll() async {
    await CacheService.clear();
  }

  /// Clear expired cache entries
  static Future<int> clearExpiredCache() async {
    return await CacheService.clearExpired();
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    final size = await CacheService.size();
    final keys = await CacheService.keys();
    final infoList = await CacheService.getAllInfo();

    int expiredCount = 0;
    int validCount = 0;

    for (final info in infoList) {
      if (info['expired'] as bool) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      'total_entries': size,
      'keys': keys,
      'expired': expiredCount,
      'valid': validCount,
      'details': infoList,
    };
  }
}
