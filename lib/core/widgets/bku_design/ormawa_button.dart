import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

enum OrmawaButtonVariant { primary, secondary, outline, danger }

class OrmawaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OrmawaButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const OrmawaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = OrmawaButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    BkuButtonVariant bkuVariant;
    switch (variant) {
      case OrmawaButtonVariant.primary:
        bkuVariant = BkuButtonVariant.primary;
        break;
      case OrmawaButtonVariant.secondary:
        bkuVariant = BkuButtonVariant.secondary;
        break;
      case OrmawaButtonVariant.outline:
        bkuVariant = BkuButtonVariant.outline;
        break;
      case OrmawaButtonVariant.danger:
        bkuVariant = BkuButtonVariant.danger;
        break;
    }

    return BkuButton(
      text: text,
      onPressed: onPressed,
      variant: bkuVariant,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      fullWidth: width == null,
    );
  }
}
