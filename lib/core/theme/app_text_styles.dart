import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';

/// Typography System
/// =================
/// Menggunakan Google Fonts: Plus Jakarta Sans
/// Scale: Display > Headline > Title > Body > Label
/// Weight: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold), 900 (Black)
///
/// Usage:
/// - display, headline*: Untuk headings besar
/// - title*: Untuk card titles, section headers
/// - body*: Untuk paragraphs, descriptions
/// - label*: Untuk chips, captions, timestamps
class AppTextStyles {
  // ==================== DISPLAY ====================
  /// Display Large - Hero titles
  /// Size: 57px, Weight: 700
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 64 / 57,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );

  /// Display Medium - Page titles
  /// Size: 45px, Weight: 700
  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 52 / 45,
    color: AppColors.onSurface,
  );

  /// Display Small - Section banners
  /// Size: 36px, Weight: 700
  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    color: AppColors.onSurface,
  );

  /// Display - Primary display (legacy/compatibility)
  /// Size: 24px, Weight: 700
  static TextStyle get display => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.48,
    color: AppColors.primary,
  );

  // ==================== HEADLINE ====================
  /// Headline Large - Major section headers
  /// Size: 32px, Weight: 600
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    color: AppColors.onSurface,
  );

  /// Headline Medium - Card headers
  /// Size: 28px, Weight: 600
  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    color: AppColors.onSurface,
  );

  /// Headline Small - Subsection headers
  /// Size: 24px, Weight: 600
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  /// Headline MD - Legacy/compatibility
  /// Size: 20px, Weight: 600
  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  // ==================== TITLE ====================
  /// Title Large - Dialog titles, prominent labels
  /// Size: 22px, Weight: 600
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: AppColors.onSurface,
  );

  /// Title Medium - List item titles, card titles
  /// Size: 16px, Weight: 600
  /// ⚠️ Use this for most interactive item titles (NOT bodyMd)
  static TextStyle get titleMd => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.onSurface,
  );

  /// Title Small - Chip labels, small headers
  /// Size: 14px, Weight: 600
  static TextStyle get titleSm => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  /// Title LG - Legacy/compatibility
  /// Size: 18px, Weight: 600
  static TextStyle get titleLg => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.onSurface,
  );

  // ==================== BODY ====================
  /// Body Large - Primary paragraphs, descriptions
  /// Size: 16px, Weight: 400
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  /// Body Medium - Secondary paragraphs, content
  /// Size: 14px, Weight: 400
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  /// Body Small - Tertiary text, footnotes
  /// Size: 12px, Weight: 400
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.onSurface,
  );

  // ==================== LABEL ====================
  /// Label Large - Buttons, navigation items
  /// Size: 14px, Weight: 500
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Label Medium - Tab labels, form inputs
  /// Size: 12px, Weight: 500
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  /// Label Small - Captions, timestamps, badges
  /// Size: 11px, Weight: 600
  /// ⚠️ Use for section headers with letter-spacing
  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.2,
    color: AppColors.neutral500,
  );

  // ==================== SPECIAL ====================
  /// Caption - Smallest readable text
  /// Size: 10px, Weight: 400
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 14 / 10,
    letterSpacing: 0,
    color: AppColors.neutral500,
  );

  /// Overline - Decorative uppercase labels
  /// Size: 10px, Weight: 700, Letter-spacing: 1.5
  static TextStyle get overline => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 16 / 10,
    letterSpacing: 0.5,
    color: AppColors.neutral500,
  );
}
