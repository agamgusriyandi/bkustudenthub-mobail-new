import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/mobile_theme.dart';

class OrmawaTheme {
  static MobileThemeColors get _colors =>
      ThemeProvider.current?.colors ?? MobileThemeColors.defaults();

  static Color get primary => _colors.primary;
  static Color get primaryDark => _colors.gradientEnd;
  static Color get primarySoft => _colors.primary.withAlpha(20);
  static Color get primaryBorder => _colors.primary.withAlpha(50);

  static LinearGradient get primaryGradient => LinearGradient(
        colors: [
          _colors.primary,
          _colors.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Color get scaffoldBg => const Color(0xFFF8FAFC);
  static Color get cardSurface => _colors.surface;
  static Color get border => const Color(0xFFE2E8F0);
  static Color get borderSubtle => const Color(0xFFF1F5F9);

  static Color get textHeading => _colors.onSurface;
  static Color get textBody => _colors.onSurfaceVariant;
  static Color get textMuted => const Color(0xFF64748B);
  static Color get textPlaceholder => const Color(0xFF94A3B8);

  static Color get statusSuccessBg => _colors.success.withAlpha(25);
  static Color get statusSuccessText => _colors.success;
  static Color get statusSuccessBorder => _colors.success.withAlpha(60);

  static Color get statusWarningBg => _colors.warning.withAlpha(25);
  static Color get statusWarningText => _colors.warning;
  static Color get statusWarningBorder => _colors.warning.withAlpha(60);

  static Color get statusDangerBg => _colors.error.withAlpha(25);
  static Color get statusDangerText => _colors.error;
  static Color get statusDangerBorder => _colors.error.withAlpha(60);

  static Color get statusInfoBg => _colors.info.withAlpha(25);
  static Color get statusInfoText => _colors.info;
  static Color get statusInfoBorder => _colors.info.withAlpha(60);

  static final BorderRadius r8 = BorderRadius.circular(8);
  static final BorderRadius r12 = BorderRadius.circular(12);
  static final BorderRadius r16 = BorderRadius.circular(16);
  static final BorderRadius r20 = BorderRadius.circular(20);
  static final BorderRadius r24 = BorderRadius.circular(24);
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(999));

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF94A3B8).withAlpha(15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle get textPageTitle => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: textHeading,
        letterSpacing: -0.3,
      );

  static TextStyle get textSectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w900,
        color: textHeading,
        letterSpacing: -0.2,
      );

  static TextStyle get textCardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: textHeading,
      );

  static TextStyle get textCardSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMuted,
      );

  static TextStyle get textBodyRegular => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textBody,
        height: 1.45,
      );

  static TextStyle get textCaption => GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: textMuted,
      );

  static TextStyle get textBadge => GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      );

  static TextStyle get textKpiValue => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: textHeading,
        letterSpacing: -0.5,
      );

  static TextStyle get textKpiLabel => GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: textMuted,
      );

  static TextStyle get textButton => GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      );
}
