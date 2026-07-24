import 'package:flutter/material.dart';

/// App Color Palette - Semantic & Neutral Colors
/// =============================================
/// Primary: Deep Blue (Institutional)
/// Secondary: Gold (Academic)
/// Neutral: Slate Gray Scale
/// Semantic: Success, Warning, Info, Error variants
class AppColors {
  // ==================== PRIMARY ====================
  static const Color primary = Color(0xFFE85D04);
  static const Color primaryContainer = Color(0xFFD35400);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixedDim = Color(0xFFB5C4FF);
  static const Color primaryFixed = Color(0xFFDCE1FF);
  static const Color onPrimaryFixed = Color(0xFF00164E);
  static const Color onPrimaryContainer = Color(0xFF8AA4FF);
  static const Color onPrimaryFixedVariant = Color(0xFF153EA3);

  // ==================== SECONDARY ====================
  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryContainer = Color(0xFF334155);
  static const Color onSecondaryContainer = Color(0xFF735A00);
  static const Color secondaryFixed = Color(0xFFFFE08B);
  static const Color secondaryFixedDim = Color(0xFFEBC246);
  static const Color onSecondaryFixed = Color(0xFF241A00);

  // ==================== TERTIARY ====================
  static const Color tertiary = Color(0xFF002E14);
  static const Color tertiaryContainer = Color(0xFF004721);
  static const Color onTertiaryContainer = Color(0xFF3DBE6E);
  static const Color tertiaryFixed = Color(0xFF7EFBA4);
  static const Color tertiaryFixedDim = Color(0xFF61DE8A);
  static const Color onTertiaryFixed = Color(0xFF00210C);
  static const Color onTertiaryFixedVariant = Color(0xFF005228);

  // ==================== ERROR ====================
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ==================== SURFACE ====================
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E2);
  static const Color surfaceVariant = Color(0xFFE4E2E2);
  static const Color surfaceBright = Color(0xFFFBF9F8);
  static const Color surfaceDim = Color(0xFFDBDAD9);

  // ==================== OUTLINE ====================
  static const Color outline = Color(0xFF747684);
  static const Color outlineVariant = Color(0xFFC4C5D5);

  // ==================== ON SURFACE ====================
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF444653);

  // ==================== INVERSE ====================
  static const Color inverseSurface = Color(0xFF303031);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);
  static const Color inversePrimary = Color(0xFFB5C4FF);

  // ==================== NEUTRAL SCALE ====================
  // Digunakan untuk background, border, dan text hierarchy
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF8FAFC); // Background default
  static const Color neutral200 = Color(0xFFF1F5F9); // Border light
  static const Color neutral300 = Color(0xFFE2E8F0);
  static const Color neutral400 = Color(0xFFCBD5E1); // Icon muted
  static const Color neutral500 = Color(0xFF94A3B8); // Subtitle muted
  static const Color neutral600 = Color(0xFF64748B);
  static const Color neutral700 = Color(0xFF475569);
  static const Color neutral800 = Color(0xFF1E293B); // Primary text dark
  static const Color neutral900 = Color(0xFF0F172A);

  // ==================== SEMANTIC COLORS ====================
  // Success - Green
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF064E3B);

  // Warning - Amber
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF92400E);

  // Info - Blue
  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF1E40AF);

  // Danger - Red (alternatif untuk error yang lebih soft)
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerContainer = Color(0xFFFEE2E2);
  static const Color onDanger = Color(0xFFFFFFFF);
  static const Color onDangerContainer = Color(0xFF991B1B);
}
