import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;

  const OrmawaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? OrmawaTheme.r20;

    return Container(
      decoration: BoxDecoration(
        color: color ?? OrmawaTheme.cardSurface,
        borderRadius: effectiveBorderRadius,
        border: border ?? Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: OrmawaTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: OrmawaTheme.primary.withAlpha(12),
          highlightColor: OrmawaTheme.primary.withAlpha(6),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
