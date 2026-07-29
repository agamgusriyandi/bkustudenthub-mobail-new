import 'package:flutter/material.dart';

/// Semantic Spacing Tokens for UI consistency
/// Semua nilai spacing harus lewat token ini.
/// Ketika ganti design system, cukup ganti di sini.
class AppSpacing {
  // Base scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Extended values (sering dipakai)
  static const double s1 = 1.0;
  static const double s2 = 2.0;
  static const double s3 = 3.0;
  static const double s6 = 6.0;
  static const double s7 = 7.0;
  static const double s9 = 9.0;
  static const double s10 = 10.0;
  static const double s11 = 11.0;
  static const double s14 = 14.0;
  static const double s15 = 15.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s28 = 28.0;
  static const double s30 = 30.0;
  static const double s36 = 36.0;
  static const double s48 = 48.0;
  static const double s50 = 50.0;
  static const double s60 = 60.0;
  static const double s70 = 70.0;
  static const double s80 = 80.0;
  static const double s100 = 100.0;
  static const double s120 = 120.0;
  static const double s140 = 140.0;
  static const double s150 = 150.0;
  static const double s160 = 160.0;
  static const double s170 = 170.0;

  // Shortcuts untuk EdgeInsets.all
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);

  // Extended padding.all
  static const EdgeInsets padding2 = EdgeInsets.all(s2);
  static const EdgeInsets padding3 = EdgeInsets.all(s3);
  static const EdgeInsets padding6 = EdgeInsets.all(s6);
  static const EdgeInsets padding7 = EdgeInsets.all(s7);
  static const EdgeInsets padding9 = EdgeInsets.all(s9);
  static const EdgeInsets padding10 = EdgeInsets.all(s10);
  static const EdgeInsets padding14 = EdgeInsets.all(s14);
  static const EdgeInsets padding18 = EdgeInsets.all(s18);
  static const EdgeInsets padding20 = EdgeInsets.all(s20);
  static const EdgeInsets padding28 = EdgeInsets.all(s28);

  // Horizontal saja
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  // Vertical saja
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
}
