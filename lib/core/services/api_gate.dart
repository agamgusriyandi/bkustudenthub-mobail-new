enum AppEnvironment {
  production,
  staging,
  local,
}

class ApiGate {
  static const AppEnvironment defaultEnvironment = AppEnvironment.staging;

  static const String productionBaseUrl = 'https://tukangbku.center.biz.id';
  static const String productionWebUrl = 'https://bku.center.biz.id';

  static const String stagingBaseUrl = 'https://tukangbku.center.biz.id';
  static const String stagingWebUrl = 'https://bku.center.biz.id';

  static const String localBaseUrl = 'http://localhost:3000';
  static const String localWebUrl = 'http://localhost:5173';

  static String avatarCacheBuster =
      DateTime.now().millisecondsSinceEpoch.toString();

  static void refreshAvatarCache() {
    avatarCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String get baseUrl {
    const envUrl = String.fromEnvironment('BASE_URL');
    if (envUrl.isNotEmpty) {
      String cleanUrl = envUrl.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      return cleanUrl;
    }

    switch (currentEnvironment) {
      case AppEnvironment.production:
        return productionBaseUrl;
      case AppEnvironment.staging:
        return stagingBaseUrl;
      case AppEnvironment.local:
        return localBaseUrl;
    }
  }

  static String get webUrl {
    const envWebUrl = String.fromEnvironment('WEB_URL');
    if (envWebUrl.isNotEmpty) {
      String cleanUrl = envWebUrl.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      return cleanUrl;
    }

    switch (currentEnvironment) {
      case AppEnvironment.production:
        return productionWebUrl;
      case AppEnvironment.staging:
        return stagingWebUrl;
      case AppEnvironment.local:
        return localWebUrl;
    }
  }

  static AppEnvironment get currentEnvironment {
    const envStr = String.fromEnvironment('ENVIRONMENT');
    if (envStr.toLowerCase() == 'local') {
      return AppEnvironment.local;
    }
    if (envStr.toLowerCase() == 'production' || envStr.toLowerCase() == 'prod') {
      return AppEnvironment.production;
    }
    if (envStr.toLowerCase() == 'staging' || envStr.toLowerCase() == 'stag') {
      return AppEnvironment.staging;
    }
    return defaultEnvironment;
  }

  static bool get isProduction => currentEnvironment == AppEnvironment.production;
  static bool get isStaging => currentEnvironment == AppEnvironment.staging;

  static String getImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';

    String base = baseUrl;
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }

    String resultUrl = '';
    if (path.startsWith('http')) {
      final isKnownHost = path.contains('localhost') ||
          path.contains('127.0.0.1') ||
          path.contains('10.0.2.2') ||
          path.contains('tukangbku.center.biz.id') ||
          path.contains('bku.center.biz.id') ||
          path.startsWith('http://tukangbku.center.biz.id') ||
          path.startsWith('https://tukangbku.center.biz.id') ||
          path.startsWith('http://bku.center.biz.id') ||
          path.startsWith('https://bku.center.biz.id');

      if (isKnownHost) {
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
