import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';

/// Typography System
/// =================
/// Font Family: Google Fonts Plus Jakarta Sans
/// Canonical Scale: Display > Headline > Title > Body > Label > Special
/// Font Weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
///
/// Hierarchy Contract:
/// - Display  (40, 32, 28) : Hero titles, splash branding
/// - Headline (24, 22, 20) : Major section headers, page titles
/// - Title    (18, 16, 14) : Dialog titles, card headers, list titles
/// - Body     (16, 14, 12) : Primary descriptions, body text, secondary notes
/// - Label    (14, 12, 11) : Buttons, inputs, tab labels, badges
/// - Special  (10)         : Captions, overline uppercase labels
class AppTextStyles {
  // ==================== DISPLAY ====================
  /// Display Large - Hero titles / Branding
  /// Size: 40px, Weight: 700, Height: 48/40
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );

  /// Display Medium - Main page hero banners
  /// Size: 32px, Weight: 700, Height: 40/32
  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.onSurface,
  );

  /// Display Small - Section hero banners
  /// Size: 28px, Weight: 700, Height: 36/28
  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    color: AppColors.onSurface,
  );

  // ==================== HEADLINE ====================
  /// Headline Large - Major page titles
  /// Size: 24px, Weight: 700, Height: 32/24
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  /// Headline Medium - Major section headers
  /// Size: 22px, Weight: 600, Height: 28/22
  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: AppColors.onSurface,
  );

  /// Headline Small - Subsection headers
  /// Size: 20px, Weight: 600, Height: 28/20
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  // ==================== TITLE ====================
  /// Title Large - Dialog titles, prominent card titles
  /// Size: 18px, Weight: 600, Height: 24/18
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.onSurface,
  );

  /// Title Medium - Card titles, interactive item headers
  /// Size: 16px, Weight: 600, Height: 24/16
  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  /// Title Small - Small headers, chip titles
  /// Size: 14px, Weight: 600, Height: 20/14
  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  // ==================== BODY ====================
  /// Body Large - Primary paragraphs, prominent descriptions
  /// Size: 16px, Weight: 400, Height: 24/16
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  /// Body Medium - Normal body text, secondary descriptions
  /// Size: 14px, Weight: 400, Height: 20/14
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  /// Body Small - Tertiary text, helper descriptions
  /// Size: 12px, Weight: 400, Height: 16/12
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.onSurface,
  );

  // ==================== LABEL ====================
  /// Label Large - Primary buttons, navigation labels
  /// Size: 14px, Weight: 500, Height: 20/14
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Label Medium - Input labels, tab items
  /// Size: 12px, Weight: 500, Height: 16/12
  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  /// Label Small - Badges, timestamps, small action labels
  /// Size: 11px, Weight: 600, Height: 14/11
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.2,
    color: AppColors.neutral500,
  );

  // ==================== SPECIAL ====================
  /// Caption - Smallest readable secondary text
  /// Size: 10px, Weight: 400, Height: 14/10
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 14 / 10,
    letterSpacing: 0,
    color: AppColors.neutral500,
  );

  /// Overline - Decorative uppercase labels
  /// Size: 10px, Weight: 700, Height: 16/10
  static TextStyle get overline => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 16 / 10,
    letterSpacing: 0.5,
    color: AppColors.neutral500,
  );

  static TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    height: 14 / 10,
    letterSpacing: 1.6,
    color: AppColors.neutral500,
  );

  static TextStyle get eyebrowSmall => GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    height: 12 / 9,
    letterSpacing: 1.8,
    color: AppColors.neutral500,
  );

  // ==================== BACKWARD COMPATIBILITY ALIASES ====================
  @Deprecated('Use displaySmall instead.')
  static TextStyle get display => displaySmall;

  @Deprecated('Use headlineSmall instead.')
  static TextStyle get headlineMd => headlineSmall;

  @Deprecated('Use titleLarge instead.')
  static TextStyle get titleLg => titleLarge;

  @Deprecated('Use titleMedium instead.')
  static TextStyle get titleMd => titleMedium;

  @Deprecated('Use titleSmall instead.')
  static TextStyle get titleSm => titleSmall;

  @Deprecated('Use bodyLarge instead.')
  static TextStyle get bodyLg => bodyLarge;

  @Deprecated('Use bodyMedium instead.')
  static TextStyle get bodyMd => bodyMedium;

  @Deprecated('Use bodySmall instead.')
  static TextStyle get bodySm => bodySmall;

  @Deprecated('Use labelLarge instead.')
  static TextStyle get labelLg => labelLarge;

  @Deprecated('Use labelMedium instead.')
  static TextStyle get labelMd => labelMedium;

  @Deprecated('Use labelSmall instead.')
  static TextStyle get labelSm => labelSmall;
}
