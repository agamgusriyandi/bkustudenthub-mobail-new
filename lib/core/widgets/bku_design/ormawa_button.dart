import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';

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
    Decoration decoration;
    Color textColor;

    switch (variant) {
      case OrmawaButtonVariant.primary:
        decoration = BoxDecoration(
          color: OrmawaTheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: OrmawaTheme.primary.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        );
        textColor = Colors.white;
        break;
      case OrmawaButtonVariant.secondary:
        decoration = BoxDecoration(
          color: OrmawaTheme.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrmawaTheme.primaryBorder),
        );
        textColor = OrmawaTheme.primaryDark;
        break;
      case OrmawaButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrmawaTheme.border),
        );
        textColor = OrmawaTheme.textHeading;
        break;
      case OrmawaButtonVariant.danger:
        decoration = BoxDecoration(
          color: OrmawaTheme.statusDangerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrmawaTheme.statusDangerBorder),
        );
        textColor = OrmawaTheme.statusDangerText;
        break;
    }

    return BkuBounceButton(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: decoration,
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: OrmawaTheme.textButton.copyWith(color: textColor),
                  ),
                ],
              ),
      ),
    );
  }
}
