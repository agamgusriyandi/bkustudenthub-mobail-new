import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

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
        (elevation == null || elevation! > 0);

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
                ? BorderRadius.circular(borderRadius!)
                : AppRadius.radiusLg,
        border: borderOnly ? Border.all(color: AppColors.neutral200) : null,
        boxShadow:
            hasShadow
                ? [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(
                      alpha: 0.04,
                    ), // Sangat soft shadow
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
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
                    ? BorderRadius.circular(borderRadius!)
                    : AppRadius.radiusLg,
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(padding: margin, child: cardContent);
  }
}
