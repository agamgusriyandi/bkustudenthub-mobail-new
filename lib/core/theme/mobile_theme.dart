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
  
  // Tipografi dari API
  final String? fontHeadline;
  final String? fontBody;

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
    this.fontHeadline,
    this.fontBody,
  });

  /// Default BKU Student HUB Theme (Fallback)hing new Orange branding
  factory MobileThemeColors.defaults() {
    return const MobileThemeColors(
      primary: Color(0xFFF29130),
      primaryContainer: Color(0xFFF5BD29), 
      secondary: Color(0xFFE3B886),
      secondaryContainer: Color(0xFFF29130), // Updated to match screenshot
      background: Color(0xFFFFFFFF), // Updated to match screenshot
      surface: Color(0xFFFFFFFF), // Updated to match screenshot
      onSurface: Color(0xFF1B1C1C),
      onSurfaceVariant: Color(0xFF444653),
      outline: Color(0xFF747684),
      outlineVariant: Color(0xFFC4C5D5),
      gradientStart: Color(0xFFF5BD29), // Bright yellowish orange for highlight
      gradientMiddle: Color(0xFFF29130), // Brand primary orange
      gradientEnd: Color(0xFFE85D04), // Deep reddish orange for contrast
      gradientSecondaryStart: Color(0xFFE3B886),
      gradientSecondaryMiddle: Color(0xFFD3A876),
      gradientSecondaryEnd: Color(0xFFC39866),
      success: Color(0xFF16A34A),
      warning: Color(0xFFD97706),
      error: Color(0xFFDC2626),
      info: Color(0xFF2563EB),
    );
  }


  /// Parse from API JSON response
  factory MobileThemeColors.fromJson(Map<String, dynamic> json) {
    final parsedPrimary = _hexToColor(json['mobile_color_primary']);
    final parsedSecondary = _hexToColor(json['mobile_color_secondary']);

    return MobileThemeColors(
      primary: parsedPrimary,
      primaryContainer: _hexToColor(json['mobile_color_primary_container']),
      secondary: parsedSecondary,
      secondaryContainer: _hexToColor(json['mobile_color_secondary_container']),
      background: _hexToColor(json['mobile_color_background']),
      surface: _hexToColor(json['mobile_color_surface']),
      onSurface: _hexToColor(json['mobile_color_on_surface']),
      onSurfaceVariant: _hexToColor(json['mobile_color_on_surface_variant']),
      outline: _hexToColor(json['mobile_color_outline']),
      outlineVariant: _hexToColor(json['mobile_color_outline_variant']),
      
      // Dynamic HSL calculation for beautiful gradients based ONLY on the 6 fields from the API
      // Since the Web Admin doesn't have gradient inputs, we ALWAYS derive them dynamically.
      gradientStart: HSLColor.fromColor(parsedPrimary)
          .withHue((HSLColor.fromColor(parsedPrimary).hue + 15) % 360)
          .withLightness((HSLColor.fromColor(parsedPrimary).lightness + 0.08).clamp(0.0, 1.0))
          .toColor(),
      gradientMiddle: parsedPrimary,
      gradientEnd: HSLColor.fromColor(parsedPrimary)
          .withHue((HSLColor.fromColor(parsedPrimary).hue - 15) % 360)
          .withLightness((HSLColor.fromColor(parsedPrimary).lightness - 0.08).clamp(0.0, 1.0))
          .toColor(),
              
      gradientSecondaryStart: HSLColor.fromColor(parsedSecondary)
          .withHue((HSLColor.fromColor(parsedSecondary).hue + 10) % 360)
          .withLightness((HSLColor.fromColor(parsedSecondary).lightness + 0.08).clamp(0.0, 1.0))
          .toColor(),
      gradientSecondaryMiddle: parsedSecondary,
      gradientSecondaryEnd: HSLColor.fromColor(parsedSecondary)
          .withHue((HSLColor.fromColor(parsedSecondary).hue - 10) % 360)
          .withLightness((HSLColor.fromColor(parsedSecondary).lightness - 0.08).clamp(0.0, 1.0))
          .toColor(),
      
      success: _hexToColor(json['color_success']),
      warning: _hexToColor(json['color_warning']),
      error: _hexToColor(json['color_error']),
      info: _hexToColor(json['color_info']),
      logoUrl: json['mobile_logo_url'] as String?,
      splashLogoUrl: json['mobile_splash_logo_url'] as String?,
      fontHeadline: json['font_headline'] as String?,
      fontBody: json['font_body'] as String?,
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
      'font_headline': fontHeadline,
      'font_body': fontBody,
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
  static Color _hexToColor(dynamic hexValue) {
    if (hexValue == null || hexValue.toString().trim().isEmpty) {
      return const Color(0xFFF29130); // Default fallback to Orange, not Blue!
    }
    String hex = hexValue.toString().replaceAll('#', '').trim();
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    if (hex.length != 6) {
      return const Color(0xFFF29130); // Default fallback to Orange
    }
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Helper: Convert Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
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
    String? fontHeadline,
    String? fontBody,
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
      fontHeadline: fontHeadline ?? this.fontHeadline,
      fontBody: fontBody ?? this.fontBody,
    );
  }
}
