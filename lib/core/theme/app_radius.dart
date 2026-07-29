import 'package:flutter/material.dart';

/// Semantic Border Radius Tokens for UI consistency
/// Semua nilai BorderRadius harus lewat token ini.
/// Ketika ganti design system, cukup ganti di sini.
class AppRadius {
  // Base scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;

  // Extended values (sering dipakai)
  static const double radius2 = 2.0;
  static const double radius3 = 3.0;
  static const double radius6 = 6.0;
  static const double radius10 = 10.0;
  static const double radius13 = 13.0;
  static const double radius14 = 14.0;
  static const double radius20 = 20.0;
  static const double radius22 = 22.0;
  static const double radius25 = 25.0;
  static const double radius28 = 28.0;
  static const double radius35 = 35.0;
  static const double radius36 = 36.0;

  // BorderRadius shortcuts
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // Extended BorderRadius shortcuts
  static const BorderRadius br2 = BorderRadius.all(Radius.circular(radius2));
  static const BorderRadius br3 = BorderRadius.all(Radius.circular(radius3));
  static const BorderRadius br6 = BorderRadius.all(Radius.circular(radius6));
  static const BorderRadius br10 = BorderRadius.all(Radius.circular(radius10));
  static const BorderRadius br13 = BorderRadius.all(Radius.circular(radius13));
  static const BorderRadius br14 = BorderRadius.all(Radius.circular(radius14));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(radius20));
  static const BorderRadius br22 = BorderRadius.all(Radius.circular(radius22));
  static const BorderRadius br25 = BorderRadius.all(Radius.circular(radius25));
  static const BorderRadius br28 = BorderRadius.all(Radius.circular(radius28));
  static const BorderRadius br35 = BorderRadius.all(Radius.circular(radius35));
  static const BorderRadius br36 = BorderRadius.all(Radius.circular(radius36));
}
