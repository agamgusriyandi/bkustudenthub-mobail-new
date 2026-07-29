import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class UnifiedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final bool enableShadow;
  final double? width;
  final double? height;

  const UnifiedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 20.0,
    this.enableShadow = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? context.appColors.surface;
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: context.appColors.outline.withAlpha(30), width: 1),
        boxShadow:
            enableShadow
                ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(6), // Extremely soft shadow
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
                : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }
    return cardContent;
  }
}
