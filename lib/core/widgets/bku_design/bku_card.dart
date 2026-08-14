import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

class BkuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool borderOnly;
  final double? borderRadius;
  final bool? enableShadow;
  final double? width;
  final double? height;
  final bool isDoubleBezel;
  final bool isGlass;
  final double blurAmount;
  final Color? borderColor;

  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  const BkuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderOnly = false,
    this.borderRadius,
    this.enableShadow,
    this.width,
    this.height,
    this.isDoubleBezel = false,
    this.isGlass = false,
    this.blurAmount = 10,
    this.borderColor,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior,
  });

  factory BkuCard.doubleBezel({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? borderRadius,
    bool? enableShadow,
    double? width,
    double? height,
    Color? borderColor,
  }) => BkuCard(
    key: key,
    padding: padding,
    margin: margin,
    onTap: onTap,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    enableShadow: enableShadow,
    width: width,
    height: height,
    isDoubleBezel: true,
    borderColor: borderColor,
    child: child,
  );

  factory BkuCard.glass({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? borderRadius,
    double? width,
    double? height,
    double blurAmount = 16,
    Color? borderColor,
  }) => BkuCard(
    key: key,
    padding: padding,
    margin: margin,
    onTap: onTap,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    enableShadow: false,
    width: width,
    height: height,
    isGlass: true,
    blurAmount: blurAmount,
    borderColor: borderColor,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final resolvedRadius = borderRadius ?? 20.0;
    final resolvedBg = borderOnly
        ? Colors.transparent
        : (backgroundColor ?? color ?? theme.surface);
    final resolvedBorderColor = borderColor ?? (borderOnly ? AppColors.neutral200 : context.appColors.outlineVariant.withAlpha(40));

    final hasShadow =
        (borderOnly == false) &&
        (isGlass == false) &&
        (enableShadow != false) &&
        (elevation == null || (elevation ?? 0) > 0);

    Widget content;

    if (isGlass) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedBg.withAlpha(190),
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withAlpha(60),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      );
    } else if (isDoubleBezel) {
      final innerRadius = (resolvedRadius - 3.5).clamp(8.0, 40.0);
      content = Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: context.appColors.outlineVariant.withAlpha(20),
          borderRadius: BorderRadius.circular(resolvedRadius),
          border: Border.all(
            color: resolvedBorderColor.withAlpha(35),
            width: 0.8,
          ),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: BorderRadius.circular(innerRadius),
            border: Border.all(
              color: Colors.white.withAlpha(60),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      );
    } else {
      content = Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: resolvedBg,
          borderRadius: BorderRadius.circular(resolvedRadius),
          border: Border.all(
            color: resolvedBorderColor,
            width: 1,
          ),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(7),
                    blurRadius: 22,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(resolvedRadius),
            child: content,
          ),
        ),
      );
    }

    return Padding(padding: margin, child: content);
  }
}
