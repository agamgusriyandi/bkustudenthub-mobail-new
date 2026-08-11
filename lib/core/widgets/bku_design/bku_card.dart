import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
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

  // Legacy Card parameters for drop-in replacement
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
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final hasShadow =
        (borderOnly == false) &&
        (enableShadow != false) &&
        (elevation == null || (elevation ?? 0) > 0);

    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color:
            borderOnly
                ? Colors.transparent
                : (backgroundColor ?? color ?? theme.surface),
        borderRadius:
            borderRadius != null
                ? BorderRadius.circular(borderRadius ?? 0)
                : AppRadius.radiusLg,
        border: borderOnly ? Border.all(color: AppColors.neutral200) : Border.all(color: context.appColors.outlineVariant.withAlpha(40), width: 1),
        boxShadow:
            hasShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(8), // Softer premium shadow
                      blurRadius: 24,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                borderRadius != null
                    ? BorderRadius.circular(borderRadius ?? 0)
                    : AppRadius.radiusLg,
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(padding: margin, child: cardContent);
  }
}
