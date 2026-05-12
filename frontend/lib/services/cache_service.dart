import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache service for storing API responses and other data
class CacheService {
  static const String _prefix = 'cache_';
  static const String _timestampPrefix = 'cache_timestamp_';
  static const int _defaultTTL = 3600; // 1 hour in seconds

  /// Get a cached value
  static Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedValue = prefs.getString('$_prefix$key');

    if (cachedValue == null) return null;

    // Check if cache is expired
    final timestamp = prefs.getInt('$_timestampPrefix$key');
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now - timestamp > _defaultTTL) {
      // Cache expired, remove it
      await remove(key);
      return null;
    }

    // Return cached value based on type
    if (T == String) {
      return cachedValue as T?;
    } else if (T == int) {
      return int.tryParse(cachedValue) as T?;
    } else if (T == double) {
      return double.tryParse(cachedValue) as T?;
    } else if (T == bool) {
      final boolValue = cachedValue.toLowerCase() == 'true';
      return boolValue as T?;
    } else {
      // Assume it's a JSON object
      return jsonDecode(cachedValue) as T?;
    }
  }

  /// Get a cached value with custom TTL
  static Future<T?> getWithTTL<T>(String key, int ttlSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedValue = prefs.getString('$_prefix$key');

    if (cachedValue == null) return null;

    // Check if cache is expired
    final timestamp = prefs.getInt('$_timestampPrefix$key');
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now - timestamp > ttlSeconds) {
      // Cache expired, remove it
      await remove(key);
      return null;
    }

    // Return cached value based on type
    if (T == String) {
      return cachedValue as T?;
    } else if (T == int) {
      return int.tryParse(cachedValue) as T?;
    } else if (T == double) {
      return double.tryParse(cachedValue) as T?;
    } else if (T == bool) {
      final boolValue = cachedValue.toLowerCase() == 'true';
      return boolValue as T?;
    } else {
      // Assume it's a JSON object
      return jsonDecode(cachedValue) as T?;
    }
  }

  /// Set a cached value
  static Future<bool> set(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String stringValue;
    if (value is String) {
      stringValue = value;
    } else if (value is int || value is double || value is bool) {
      stringValue = value.toString();
    } else {
      stringValue = jsonEncode(value);
    }

    await prefs.setInt('$_timestampPrefix$key', timestamp);
    return prefs.setString('$_prefix$key', stringValue);
  }

  /// Set a cached value with custom TTL
  static Future<bool> setWithTTL(String key, dynamic value, int ttlSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String stringValue;
    if (value is String) {
      stringValue = value;
    } else if (value is int || value is double || value is bool) {
      stringValue = value.toString();
    } else {
      stringValue = jsonEncode(value);
    }

    await prefs.setInt('$_timestampPrefix$key', timestamp);
    await prefs.setInt('${_timestampPrefix}ttl_$key', ttlSeconds);
    return prefs.setString('$_prefix$key', stringValue);
  }

  /// Remove a cached value
  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_timestampPrefix$key');
    await prefs.remove('${_timestampPrefix}ttl_$key');
    return prefs.remove('$_prefix$key');
  }

  /// Clear all cached values
  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_prefix) || key.startsWith(_timestampPrefix)) {
        await prefs.remove(key);
      }
    }

    return true;
  }

  /// Clear expired cache entries
  static Future<int> clearExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int clearedCount = 0;

    for (final key in keys) {
      if (key.startsWith(_timestampPrefix) && !key.contains('ttl_')) {
        final cacheKey = key.replaceFirst(_timestampPrefix, '');
        final timestamp = prefs.getInt(key);

        if (timestamp != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final ttl = prefs.getInt('${_timestampPrefix}ttl_$cacheKey') ?? _defaultTTL;

          if (now - timestamp > ttl) {
            await remove(cacheKey);
            clearedCount++;
          }
        }
      }
    }

    return clearedCount;
  }

  /// Check if a key exists in cache
  static Future<bool> exists(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_prefix$key');
  }

  /// Get cache size (number of entries)
  static Future<int> size() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys.where((key) => key.startsWith(_prefix)).length;
  }

  /// Get cache keys
  static Future<List<String>> keys() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    return allKeys
        .where((key) => key.startsWith(_prefix))
        .map((key) => key.replaceFirst(_prefix, ''))
        .toList();
  }

  /// Get cache info for a key
  static Future<Map<String, dynamic>?> getInfo(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_timestampPrefix$key');

    if (timestamp == null) return null;

    final ttl = prefs.getInt('${_timestampPrefix}ttl_$key') ?? _defaultTTL;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final age = now - timestamp;
    final remaining = ttl - age;

    return {
      'key': key,
      'timestamp': timestamp,
      'age': age,
      'ttl': ttl,
      'remaining': remaining > 0 ? remaining : 0,
      'expired': remaining <= 0,
    };
  }

  /// Get all cache info
  static Future<List<Map<String, dynamic>>> getAllInfo() async {
    final cacheKeys = await keys();
    final infoList = <Map<String, dynamic>>[];

    for (final key in cacheKeys) {
      final info = await getInfo(key);
      if (info != null) {
        infoList.add(info);
      }
    }

    return infoList;
  }
}

/// Cache keys for different data types
class CacheKeys {
  // User data
  static const String userProfile = 'user_profile';
  static const String userStats = 'user_stats';

  // History data
  static const String historyList = 'history_list';
  static const String dailyHistory = 'daily_history_';
  static const String weeklyHistory = 'weekly_history';
  static const String monthlyHistory = 'monthly_history_';

  // Suggestions data
  static const String suggestions = 'suggestions_';
  static const String mealSuggestions = 'meal_suggestions_';
  static const String favorites = 'favorites';

  // Analysis results
  static const String analysisResult = 'analysis_result_';

  // API status
  static const String apiStatus = 'api_status';

  // Generate a key for daily history
  static String dailyHistoryKey(String date) => '$dailyHistory$date';

  // Generate a key for monthly history
  static String monthlyHistoryKey(int year, int month) => '$monthlyHistory$year-$month';

  // Generate a key for suggestions
  static String suggestionsKey(String mealType, int maxCalories) =>
      '$suggestions${mealType}_$maxCalories';

  // Generate a key for meal suggestions
  static String mealSuggestionsKey(int maxCalories) => '$mealSuggestions$maxCalories';
}
