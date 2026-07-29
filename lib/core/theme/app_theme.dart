import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// AppTheme - Centralized Theme Access
/// ====================================
/// Single source of truth for ALL colors in the app.
/// All widgets SHOULD use `context.appColors.xxx` instead of:
/// - `AppColors.xxx` (static, doesn't update from API)
/// - `Color(0xFF...)` (hardcoded, bypasses theme)
/// - `Colors.white/grey/etc` (bypasses theme)
///
/// Usage:
///   Container(color: context.appColors.primary)
///   Text(style: TextStyle(color: context.appColors.onSurface))
extension AppTheme on BuildContext {
  /// Access ThemeProvider directly
  ThemeProvider get theme => read<ThemeProvider>();

  /// All colors from the centralized theme
  AppThemeColors get appColors => AppThemeColors._(theme);
}

/// Dynamic color palette sourced from ThemeProvider
///
/// Provides ALL colors the app needs, derived from the API-driven theme.
/// Falls back to sensible defaults if ThemeProvider is not available.
class AppThemeColors {
  final ThemeProvider _theme;

  AppThemeColors._(this._theme);

  // ==================== PRIMARY ====================
  Color get primary => _theme.primary;
  Color get primaryContainer => _theme.primaryContainer;
  Color get onPrimary => _theme.onPrimary;

  // ==================== SECONDARY ====================
  Color get secondary => _theme.secondary;
  Color get secondaryContainer => _theme.secondaryContainer;
  Color get onSecondary => _theme.onSecondary;

  // ==================== TERTIARY ====================
  Color get tertiary => _theme.tertiary;
  Color get tertiaryContainer => _theme.tertiaryContainer;
  Color get onTertiaryContainer => _theme.onTertiaryContainer;

  // ==================== SURFACE & BACKGROUND ====================
  Color get background => _theme.background;
  Color get surface => _theme.surface;
  Color get onSurface => _theme.onSurface;
  Color get onSurfaceVariant => _theme.onSurfaceVariant;

  // ==================== OUTLINE & BORDER ====================
  Color get outline => _theme.outline;
  Color get outlineVariant => _theme.outlineVariant;

  // ==================== SEMANTIC COLORS ====================
  Color get success => _theme.success;
  Color get successContainer => _theme.successContainer;
  Color get onSuccess => _theme.success.computeLuminance() > 0.5 ? const Color(0xFF1B1C1C) : const Color(0xFFFFFFFF);
  Color get onSuccessContainer => _theme.successContainer;

  Color get warning => _theme.warning;
  Color get warningContainer => _theme.warningContainer;
  Color get onWarning => _theme.warning.computeLuminance() > 0.5 ? const Color(0xFF1B1C1C) : const Color(0xFFFFFFFF);
  Color get onWarningContainer => _theme.warningContainer;

  Color get error => _theme.colorError;
  Color get errorContainer => _theme.errorContainer;

  Color get info => _theme.info;
  Color get infoContainer => _theme.infoContainer;
  Color get onInfo => _theme.info.computeLuminance() > 0.5 ? const Color(0xFF1B1C1C) : const Color(0xFFFFFFFF);
  Color get onInfoContainer => _theme.infoContainer;

  Color get danger => _theme.danger;
  Color get dangerContainer => _theme.dangerContainer;
  Color get onDanger => _theme.danger.computeLuminance() > 0.5 ? const Color(0xFF1B1C1C) : const Color(0xFFFFFFFF);
  Color get onDangerContainer => _theme.dangerContainer;

  // ==================== NEUTRAL SCALE ====================
  // These are static because neutral colors don't change with theme.
  // They provide the gray scale for text hierarchy, borders, etc.
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF8FAFC);
  static const Color neutral200 = Color(0xFFF1F5F9);
  static const Color neutral300 = Color(0xFFE2E8F0);
  static const Color neutral400 = Color(0xFFCBD5E1);
  static const Color neutral500 = Color(0xFF94A3B8);
  static const Color neutral600 = Color(0xFF64748B);
  static const Color neutral700 = Color(0xFF475569);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ==================== SURFACE VARIANTS (static) ====================
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E2);
  static const Color surfaceVariant = Color(0xFFE4E2E2);
  static const Color surfaceBright = Color(0xFFFBF9F8);
  static const Color surfaceDim = Color(0xFFDBDAD9);

  // ==================== INVERSE (static) ====================
  static const Color inverseSurface = Color(0xFF303031);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);
  static const Color inversePrimary = Color(0xFFB5C4FF);

  // ==================== ADDITIONAL STATIC COLORS ====================
  static const Color onPrimaryFixed = Color(0xFF00164E);
  static const Color onPrimaryContainer = Color(0xFF8AA4FF);
  static const Color onPrimaryFixedVariant = Color(0xFF153EA3);
  static const Color primaryFixedDim = Color(0xFFB5C4FF);
  static const Color primaryFixed = Color(0xFFDCE1FF);
  static const Color onSecondaryContainer = Color(0xFF735A00);
  static const Color secondaryFixed = Color(0xFFFFE08B);
  static const Color secondaryFixedDim = Color(0xFFEBC246);
  static const Color onSecondaryFixed = Color(0xFF241A00);
  static const Color tertiaryFixed = Color(0xFF7EFBA4);
  static const Color tertiaryFixedDim = Color(0xFF61DE8A);
  static const Color onTertiaryFixed = Color(0xFF00210C);
  static const Color onTertiaryFixedVariant = Color(0xFF005228);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ==================== GRADIENT COLORS ====================
  List<Color> get primaryGradient => _theme.primaryGradient;
  List<Color> get secondaryGradient => _theme.secondaryGradient;
}
