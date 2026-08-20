import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/mobile_theme.dart';

class BkuTheme {
  static MobileThemeColors get _colors =>
      ThemeProvider.current?.colors ?? MobileThemeColors.defaults();

  static Color get primary => _colors.primary;
  static Color get primaryDark => _colors.gradientEnd;
  static Color get primarySoft => _colors.primary.withAlpha(20);
  static Color get primaryBorder => _colors.primary.withAlpha(50);

  static LinearGradient get primaryGradient => LinearGradient(
        colors: [
          _colors.gradientStart,
          _colors.gradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get heroGradient => LinearGradient(
        colors: [
          _colors.gradientStart,
          _colors.gradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  static const Color textHeading = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);

  static const Color emerald = Color(0xFF059669);
  static const Color emeraldSoft = Color(0xFFECFDF5);
  static const Color emeraldBorder = Color(0xFFA7F3D0);

  static const Color amber = Color(0xFFD97706);
  static const Color amberSoft = Color(0xFFFEF3C7);
  static const Color amberBorder = Color(0xFFFDE68A);

  static const Color rose = Color(0xFFE11D48);
  static const Color roseSoft = Color(0xFFFFF1F2);
  static const Color roseBorder = Color(0xFFFFE4E6);

  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoSoft = Color(0xFFEEF2FF);
  static const Color indigoBorder = Color(0xFFC7D2FE);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF3E8FF);
  static const Color purpleBorder = Color(0xFFE9D5FF);

  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetSoft = Color(0xFFF5F3FF);
  static const Color violetBorder = Color(0xFFDDD6FE);

  static const Color teal = Color(0xFF0D9488);
  static const Color tealSoft = Color(0xFFCCFBF1);
  static const Color tealBorder = Color(0xFF99F6E4);

  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanSoft = Color(0xFFECFEFF);
  static const Color cyanBorder = Color(0xFFA5F3FC);

  static const Color sky = Color(0xFF0EA5E9);
  static const Color skySoft = Color(0xFFE0F2FE);
  static const Color skyBorder = Color(0xFFBAE6FD);

  static const Color slate = Color(0xFF64748B);
  static const Color slateSoft = Color(0xFFF1F5F9);
  static const Color slateBorder = Color(0xFFE2E8F0);

  static const Color textPrimary = textHeading;

  static const Color statusSuccessBg = emeraldSoft;
  static const Color statusSuccessText = emerald;
  static const Color statusSuccessBorder = emeraldBorder;

  static const Color statusWarningBg = amberSoft;
  static const Color statusWarningText = amber;
  static const Color statusWarningBorder = amberBorder;

  static const Color statusDangerBg = roseSoft;
  static const Color statusDangerText = rose;
  static const Color statusDangerBorder = roseBorder;

  static const Color statusInfoBg = skySoft;
  static const Color statusInfoText = Color(0xFF0284C7);
  static const Color statusInfoBorder = skyBorder;

  static Color get danger => rose;
  static Color get success => emerald;
  static Color get warning => amber;
  static Color get info => sky;
  static Color get surfaceLight => cardSurface;

  static final BorderRadius r8 = BorderRadius.circular(8);
  static final BorderRadius r10 = BorderRadius.circular(10);
  static final BorderRadius r12 = BorderRadius.circular(12);
  static final BorderRadius r16 = BorderRadius.circular(16);
  static final BorderRadius r18 = BorderRadius.circular(18);
  static final BorderRadius r20 = BorderRadius.circular(20);
  static final BorderRadius r24 = BorderRadius.circular(24);
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(999));

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x060F172A),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x030F172A),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get glowShadow => const [
        BoxShadow(
          color: Color(0x140284C7),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ];

  static TextStyle get textPageTitle => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textHeading,
        letterSpacing: -0.3,
      );

  static TextStyle get textSectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: textHeading,
        letterSpacing: -0.2,
      );

  static TextStyle get textCardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textHeading,
      );

  static TextStyle get textCardSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get textBodyRegular => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textBody,
        height: 1.45,
      );

  static TextStyle get textCaption => GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get textBadge => GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get textKpiValue => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textHeading,
        letterSpacing: -0.4,
      );

  static TextStyle get textMetricValue => textKpiValue;

  static TextStyle get textKpiLabel => GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: textMuted,
      );

  static TextStyle get textButton => GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );

  static TextStyle get textSectionHeader => textSectionTitle;
  static TextStyle get textLabelBold => textCardTitle;
  static TextStyle get textSecondary => textCardSubtitle;
}
