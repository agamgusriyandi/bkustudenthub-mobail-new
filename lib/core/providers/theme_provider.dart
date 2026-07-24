import 'package:flutter/material.dart';
import 'dart:async';
import '../repositories/theme_repository.dart';
import '../theme/mobile_theme.dart';
import '../../core/error/error_handler.dart';

/// ThemeProvider - Provides theme state to the entire app
///
/// Uses Provider pattern to make theme colors available throughout the app.
/// Theme is fetched from API and cached for performance.
class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _repository;
  static ThemeProvider? _currentInstance;
  static ThemeProvider? get current => _currentInstance;

  MobileThemeColors _colors = MobileThemeColors.defaults();
  String _themeVersion = '0';
  bool _isLoading = true;
  String? _error;
  bool _initialized = false;
  Timer? _pollingTimer;

  ThemeProvider({ThemeRepository? repository})
    : _repository = repository ?? ThemeRepository() {
    _currentInstance = this;
    _startRealtimePolling();
  }

  void _startRealtimePolling() {
    _pollingTimer?.cancel();
    // Poll every 10 seconds for real-time superadmin changes
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refreshThemeSilent();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Current theme colors
  MobileThemeColors get colors => _colors;

  /// Whether theme is currently loading
  bool get isLoading => _isLoading;

  /// Whether an error occurred
  bool get hasError => _error != null;

  /// Error message if any
  String? get errorMessage => _error;

  /// Whether theme has been initialized
  bool get isInitialized => _initialized;

  /// Convenience getters for common colors
  Color get primary => _colors.primary;
  Color get primaryContainer => _colors.primaryContainer;
  Color get onPrimary => _colors.onPrimary;
  Color get secondary => _colors.secondary;
  Color get secondaryContainer => _colors.secondaryContainer;
  Color get onSecondary => _colors.onSecondary;
  Color get background => _colors.background;
  Color get surface => _colors.surface;
  Color get onSurface => _colors.onSurface;
  Color get onSurfaceVariant => _colors.onSurfaceVariant;
  Color get outline => _colors.outline;
  Color get outlineVariant => _colors.outlineVariant;

  /// Primary gradient colors
  List<Color> get primaryGradient => _colors.primaryGradient;

  /// Secondary gradient colors
  List<Color> get secondaryGradient => _colors.secondaryGradient;

  /// Semantic colors
  Color get success => _colors.success;
  Color get successContainer => _colors.successContainer;
  Color get warning => _colors.warning;
  Color get warningContainer => _colors.warningContainer;
  Color get colorError =>
      _colors.error; // Renamed to avoid conflict with errorMessage
  Color get errorContainer => _colors.errorContainer;
  Color get info => _colors.info;
  Color get infoContainer => _colors.infoContainer;
  Color get danger => _colors.danger;
  Color get dangerContainer => _colors.dangerContainer;

  /// Tertiary colors
  Color get tertiary => _colors.tertiary;
  Color get tertiaryContainer => _colors.tertiaryContainer;
  Color get onTertiaryContainer => _colors.onTertiaryContainer;

  /// Initialize and load theme
  Future<void> loadTheme() async {
    if (_initialized) return; // Don't reload if already initialized

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getThemeWithVersion();
      _colors = result.colors;
      _themeVersion = result.version;
      _isLoading = false;
      _initialized = true;
    } catch (e) {
      _colors = MobileThemeColors.defaults();
      _error = ErrorHandler.getMessage(e);
      _isLoading = false;
      _initialized = true;
    }
    notifyListeners();
  }

  /// Force refresh theme from API
  Future<void> refreshTheme() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getThemeWithVersion();
      _colors = result.colors;
      _themeVersion = result.version;
      _isLoading = false;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Silently refresh without showing loading indicator
  Future<void> refreshThemeSilent() async {
    try {
      final result = await _repository.getThemeWithVersion();
      if (_themeVersion != result.version ||
          _colors.primary.toARGB32() != result.colors.primary.toARGB32()) {
        _colors = result.colors;
        _themeVersion = result.version;
        notifyListeners();
      }
    } catch (_) {
      // Ignore errors during silent polling
    }
  }

  /// Clear cached theme and reset to defaults
  Future<void> resetTheme() async {
    await _repository.clearCache();
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repository.getThemeWithVersion();
      _colors = result.colors;
      _isLoading = false;
    } catch (e) {
      _colors = MobileThemeColors.defaults();
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Get a specific color by key (for dynamic access)
  Color getColorByKey(String key) {
    switch (key) {
      case 'primary':
        return primary;
      case 'primaryContainer':
        return primaryContainer;
      case 'secondary':
        return secondary;
      case 'secondaryContainer':
        return secondaryContainer;
      case 'background':
        return background;
      case 'surface':
        return surface;
      case 'onSurface':
        return onSurface;
      case 'onSurfaceVariant':
        return onSurfaceVariant;
      case 'outline':
        return outline;
      case 'outlineVariant':
        return outlineVariant;
      case 'success':
        return success;
      case 'warning':
        return warning;
      case 'error':
        return colorError;
      case 'info':
        return info;
      case 'danger':
        return danger;
      default:
        return primary;
    }
  }

  /// Get gradient by type
  List<Color> getGradient(String type) {
    switch (type) {
      case 'primary':
        return primaryGradient;
      case 'secondary':
        return secondaryGradient;
      default:
        return primaryGradient;
    }
  }
}
