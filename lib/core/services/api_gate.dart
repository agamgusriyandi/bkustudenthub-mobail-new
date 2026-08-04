/// API Configuration for BKU Hub Mobile
///
/// Base URL is determined in the following order:
/// 1. Environment variable (--dart-define=BASE_URL=https://api.example.com)
/// 2. Platform-specific localhost for development
///
/// IMPORTANT: Do NOT hardcode production URLs in code.
/// Always use --dart-define when building for production.
class ApiGate {
  static String avatarCacheBuster =
      DateTime.now().millisecondsSinceEpoch.toString();

  static void refreshAvatarCache() {
    avatarCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get the base API URL
  ///
  /// For development:
  /// - Android Emulator: use 10.0.2.2 instead of localhost
  /// - iOS Simulator: use localhost
  /// - Physical Device: use your computer's local IP
  ///
  /// For production, pass BASE_URL via --dart-define:
  /// flutter build apk --dart-define=BASE_URL=https://api.production.com
  static String get baseUrl {
    // 1. Check for environment variable first (highest priority)
    const envUrl = String.fromEnvironment('BASE_URL');
    if (envUrl.isNotEmpty) {
      String cleanUrl = envUrl.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      return cleanUrl;
    }

    // Default hardcoded URL as requested
    return 'https://tukang.bkustudenthub.com';
  }

  /// Current environment: 'development' or 'production'
  /// Override with --dart-define=ENVIRONMENT=production
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';

  static String getImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';

    String base = baseUrl;
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }

    String resultUrl = '';
    if (path.startsWith('http')) {
      if (path.contains('localhost') ||
          path.contains('127.0.0.1') ||
          path.startsWith('http://tukang.bkustudenthub.com') ||
          path.startsWith('https://tukang.bkustudenthub.com')) {
        final uri = Uri.tryParse(path);
        if (uri != null) {
          resultUrl = '$base${uri.path}';
        } else {
          resultUrl = path;
        }
      } else {
        resultUrl = path;
      }
    } else {
      if (!path.startsWith('/')) {
        path = '/$path';
      }
      resultUrl = '$base$path';
    }

    // If the path looks like a profile picture or uploaded image, append the cache buster
    final lowerUrl = resultUrl.toLowerCase();
    if (lowerUrl.contains('avatar') ||
        lowerUrl.contains('foto') ||
        lowerUrl.contains('uploads')) {
      try {
        final uri = Uri.parse(resultUrl);
        final cleanParams = Map<String, String>.from(uri.queryParameters);
        cleanParams['v'] = avatarCacheBuster;
        resultUrl = uri.replace(queryParameters: cleanParams).toString();
      } catch (_) {
        // Fallback to simple query appending if URI parsing fails
        if (resultUrl.contains('?')) {
          resultUrl = '$resultUrl&v=$avatarCacheBuster';
        } else {
          resultUrl = '$resultUrl?v=$avatarCacheBuster';
        }
      }
    }

    return resultUrl;
  }
}
