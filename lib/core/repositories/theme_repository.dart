import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../network/api_client.dart';
import '../theme/mobile_theme.dart';

/// ThemeRepository - Handles fetching and caching theme from API
///
/// This repository fetches theme settings from the backend API and caches
/// them locally for offline support. Also tracks theme version for auto-refresh.
class ThemeRepository {
  static const String _cacheKey = 'cached_mobile_theme';
  static const String _versionKey = 'cached_theme_version';

  final ApiClient _apiClient;

  ThemeRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get theme from API with local cache fallback
  /// Returns the theme version along with colors
  Future<({MobileThemeColors colors, String version})>
  getThemeWithVersion() async {
    try {
      final response = await _apiClient.client.get('/public/theme');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final theme = MobileThemeColors.fromJson(data['data']);
          final version = data['data']['theme_version']?.toString() ?? '1';

          // Cache the theme and version
          await _cacheTheme(theme, version);

          return (colors: theme, version: version);
        }
      }

      // If API fails, try to get cached theme
      final cached = await _getCachedThemeWithVersion();
      return cached ?? (colors: MobileThemeColors.defaults(), version: '0');
    } catch (e) {
      // On any error, try cached version
      final cached = await _getCachedThemeWithVersion();
      return cached ?? (colors: MobileThemeColors.defaults(), version: '0');
    }
  }

  /// Get theme from API (backward compatible)
  Future<MobileThemeColors> getTheme() async {
    final result = await getThemeWithVersion();
    return result.colors;
  }

  /// Check if theme version has changed
  Future<bool> hasVersionChanged(String currentVersion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedVersion = prefs.getString(_versionKey);
      return cachedVersion != currentVersion;
    } catch (e) {
      return true; // Assume changed if error
    }
  }

  /// Get theme from local cache
  Future<({MobileThemeColors colors, String version})?>
  _getCachedThemeWithVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      final cachedVersion = prefs.getString(_versionKey);

      if (cached != null) {
        final Map<String, dynamic> json = jsonDecode(cached);
        final theme = MobileThemeColors.fromJson(json);
        return (colors: theme, version: cachedVersion ?? '0');
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  /// Cache theme locally with version
  Future<void> _cacheTheme(MobileThemeColors theme, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = theme.toJson();
      await prefs.setString(_cacheKey, jsonEncode(json));
      await prefs.setString(_versionKey, version);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Clear cached theme
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_versionKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Check if we have cached theme
  Future<bool> hasCachedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cacheKey);
    } catch (e) {
      return false;
    }
  }
}
