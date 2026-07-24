import 'package:flutter/material.dart';

/// MobileThemeColors - Dynamic theme colors loaded from API
///
/// This class represents the mobile-specific theme colors that can be
/// configured from the Super Admin panel and loaded at runtime.
class MobileThemeColors {
  // Primary Colors
  final Color primary;
  final Color primaryContainer;

  // Secondary Colors
  final Color secondary;
  final Color secondaryContainer;

  // Surface & Background
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;

  // Outline & Border
  final Color outline;
  final Color outlineVariant;

  // Gradient Colors (Primary)
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;

  // Gradient Colors (Secondary)
  final Color gradientSecondaryStart;
  final Color gradientSecondaryMiddle;
  final Color gradientSecondaryEnd;

  // Semantic Colors
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Branding URLs
  final String? logoUrl;
  final String? splashLogoUrl;

  const MobileThemeColors({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.gradientSecondaryStart,
    required this.gradientSecondaryMiddle,
    required this.gradientSecondaryEnd,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    this.logoUrl,
    this.splashLogoUrl,
  });

  /// Default colors matching BKU branding
  factory MobileThemeColors.defaults() {
    return const MobileThemeColors(
      primary: Color(0xFFE85D04),
      primaryContainer: Color(0xFFD35400),
      secondary: Color(0xFF1E293B),
      secondaryContainer: Color(0xFF334155),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1B1C1C),
      onSurfaceVariant: Color(0xFF444653),
      outline: Color(0xFF747684),
      outlineVariant: Color(0xFFC4C5D5),
      gradientStart: Color(0xFFE85D04),
      gradientMiddle: Color(0xFFF97316),
      gradientEnd: Color(0xFFFB923C),
      gradientSecondaryStart: Color(0xFF0F172A),
      gradientSecondaryMiddle: Color(0xFF1E293B),
      gradientSecondaryEnd: Color(0xFF334155),
      success: Color(0xFF16A34A),
      warning: Color(0xFFD97706),
      error: Color(0xFFDC2626),
      info: Color(0xFF2563EB),
    );
  }

  /// Helper to check if a color configuration is customized from the default
  static bool _isCustomColor(dynamic value, String defaultHex) {
    if (value == null) return false;
    final valStr = value.toString().replaceAll('#', '').trim().toLowerCase();
    final defStr = defaultHex.replaceAll('#', '').trim().toLowerCase();
    return valStr.isNotEmpty && valStr != defStr;
  }

  /// Parse from API JSON response
  factory MobileThemeColors.fromJson(Map<String, dynamic> json) {
    final parsedPrimary = _hexToColor(
      json['mobile_color_primary'] ?? '#E85D04',
    );
    final parsedPrimaryContainer =
        _isCustomColor(json['mobile_color_primary_container'], '#D35400')
            ? _hexToColor(json['mobile_color_primary_container'])
            : Color.lerp(parsedPrimary, const Color(0xFFFFFFFF), 0.2) ??
                parsedPrimary;

    final parsedSecondary =
        _isCustomColor(json['mobile_color_secondary'], '#1E293B')
            ? _hexToColor(json['mobile_color_secondary'])
            : const Color(0xFF1E293B); // Fallback standard secondary

    final parsedSecondaryContainer =
        _isCustomColor(json['mobile_color_secondary_container'], '#334155')
            ? _hexToColor(json['mobile_color_secondary_container'])
            : Color.lerp(parsedSecondary, const Color(0xFFFFFFFF), 0.2) ??
                parsedSecondary;

    return MobileThemeColors(
      primary: parsedPrimary,
      primaryContainer: parsedPrimaryContainer,
      secondary: parsedSecondary,
      secondaryContainer: parsedSecondaryContainer,
      background: _hexToColor(json['mobile_color_background'] ?? '#F8FAFC'),
      surface: _hexToColor(json['mobile_color_surface'] ?? '#FFFFFF'),
      onSurface: _hexToColor(json['mobile_color_on_surface'] ?? '#1B1C1C'),
      onSurfaceVariant: _hexToColor(
        json['mobile_color_on_surface_variant'] ?? '#444653',
      ),
      outline: _hexToColor(json['mobile_color_outline'] ?? '#747684'),
      outlineVariant: _hexToColor(
        json['mobile_color_outline_variant'] ?? '#C4C5D5',
      ),
      // Jika data gradient dari API kosong atau masih menggunakan warna biru bawaan, otomatis samakan dengan warna kustom Primary/Secondary
      gradientStart:
          _isCustomColor(json['mobile_gradient_start'], '#00164E')
              ? _hexToColor(json['mobile_gradient_start'])
              : parsedPrimary,
      gradientMiddle:
          _isCustomColor(json['mobile_gradient_middle'], '#002068')
              ? _hexToColor(json['mobile_gradient_middle'])
              : parsedPrimary,
      gradientEnd:
          _isCustomColor(json['mobile_gradient_end'], '#003399')
              ? _hexToColor(json['mobile_gradient_end'])
              : parsedPrimary,
      gradientSecondaryStart:
          _isCustomColor(json['mobile_gradient_secondary_start'], '#745B00')
              ? _hexToColor(json['mobile_gradient_secondary_start'])
              : parsedSecondary,
      gradientSecondaryMiddle:
          _isCustomColor(json['mobile_gradient_secondary_middle'], '#B48A00')
              ? _hexToColor(json['mobile_gradient_secondary_middle'])
              : parsedSecondary,
      gradientSecondaryEnd:
          _isCustomColor(json['mobile_gradient_secondary_end'], '#FDD355')
              ? _hexToColor(json['mobile_gradient_secondary_end'])
              : parsedSecondary,
      success: _hexToColor(json['color_success'] ?? '#16A34A'),
      warning: _hexToColor(json['color_warning'] ?? '#D97706'),
      error: _hexToColor(json['color_error'] ?? '#DC2626'),
      info: _hexToColor(json['color_info'] ?? '#2563EB'),
      logoUrl: json['mobile_logo_url'] as String?,
      splashLogoUrl: json['mobile_splash_logo_url'] as String?,
    );
  }

  /// Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'mobile_color_primary': _colorToHex(primary),
      'mobile_color_primary_container': _colorToHex(primaryContainer),
      'mobile_color_secondary': _colorToHex(secondary),
      'mobile_color_secondary_container': _colorToHex(secondaryContainer),
      'mobile_color_background': _colorToHex(background),
      'mobile_color_surface': _colorToHex(surface),
      'mobile_color_on_surface': _colorToHex(onSurface),
      'mobile_color_on_surface_variant': _colorToHex(onSurfaceVariant),
      'mobile_color_outline': _colorToHex(outline),
      'mobile_color_outline_variant': _colorToHex(outlineVariant),
      'mobile_gradient_start': _colorToHex(gradientStart),
      'mobile_gradient_middle': _colorToHex(gradientMiddle),
      'mobile_gradient_end': _colorToHex(gradientEnd),
      'mobile_gradient_secondary_start': _colorToHex(gradientSecondaryStart),
      'mobile_gradient_secondary_middle': _colorToHex(gradientSecondaryMiddle),
      'mobile_gradient_secondary_end': _colorToHex(gradientSecondaryEnd),
      'color_success': _colorToHex(success),
      'color_warning': _colorToHex(warning),
      'color_error': _colorToHex(error),
      'color_info': _colorToHex(info),
      'mobile_logo_url': logoUrl,
      'mobile_splash_logo_url': splashLogoUrl,
    };
  }

  /// Get primary gradient list
  List<Color> get primaryGradient => [
    gradientStart,
    gradientMiddle,
    gradientEnd,
  ];

  /// Get secondary gradient list
  List<Color> get secondaryGradient => [
    gradientSecondaryStart,
    gradientSecondaryMiddle,
    gradientSecondaryEnd,
  ];

  // Dynamic Color Helpers
  Color get onPrimary => _getOnColor(primary);
  Color get onSecondary => _getOnColor(secondary);

  Color _getOnColor(Color color) {
    return color.computeLuminance() > 0.5
        ? const Color(0xFF1B1C1C)
        : const Color(0xFFFFFFFF);
  }

  Color _getContainer(Color color) {
    return Color.lerp(color, surface, 0.85) ?? color.withValues(alpha: 0.15);
  }

  Color _getOnContainer(Color color) {
    return Color.lerp(color, const Color(0xFF1B1C1C), 0.5) ?? color;
  }

  /// Semantic Colors (Dynamically computed from base colors)
  Color get successContainer => _getContainer(success);
  Color get onSuccess => _getOnColor(success);
  Color get onSuccessContainer => _getOnContainer(success);

  Color get warningContainer => _getContainer(warning);
  Color get onWarning => _getOnColor(warning);
  Color get onWarningContainer => _getOnContainer(warning);

  Color get errorContainer => _getContainer(error);
  Color get onError => _getOnColor(error);
  Color get onErrorContainer => _getOnContainer(error);

  Color get infoContainer => _getContainer(info);
  Color get onInfo => _getOnColor(info);
  Color get onInfoContainer => _getOnContainer(info);

  Color get danger => error;
  Color get dangerContainer => errorContainer;
  Color get onDanger => onError;
  Color get onDangerContainer => onErrorContainer;

  /// Tertiary Colors (Derived from primary and secondary)
  Color get tertiary => Color.lerp(primary, secondary, 0.5) ?? secondary;
  Color get tertiaryContainer => _getContainer(tertiary);
  Color get onTertiaryContainer => _getOnContainer(tertiary);

  // Helper: Parse hex string to Color
  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    if (hex.length != 6) {
      return const Color(0xFF002068); // Default fallback
    }
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Helper: Convert Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Copy with new values
  MobileThemeColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? gradientStart,
    Color? gradientMiddle,
    Color? gradientEnd,
    Color? gradientSecondaryStart,
    Color? gradientSecondaryMiddle,
    Color? gradientSecondaryEnd,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    String? logoUrl,
    String? splashLogoUrl,
  }) {
    return MobileThemeColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMiddle: gradientMiddle ?? this.gradientMiddle,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientSecondaryStart:
          gradientSecondaryStart ?? this.gradientSecondaryStart,
      gradientSecondaryMiddle:
          gradientSecondaryMiddle ?? this.gradientSecondaryMiddle,
      gradientSecondaryEnd: gradientSecondaryEnd ?? this.gradientSecondaryEnd,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      logoUrl: logoUrl ?? this.logoUrl,
      splashLogoUrl: splashLogoUrl ?? this.splashLogoUrl,
    );
  }
}
