import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

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
    return BkuCard(
      padding: padding,
      onTap: onTap,
      backgroundColor: color ?? BkuTheme.cardSurface,
      borderRadius: borderRadius?.topLeft.x ?? 20.0,
      borderColor: border?.top.color ?? BkuTheme.borderSubtle,
      child: child,
    );
  }
}
