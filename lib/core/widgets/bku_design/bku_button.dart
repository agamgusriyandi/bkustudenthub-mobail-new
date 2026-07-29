import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

enum BkuButtonVariant { primary, secondary, outline, text, danger, success }

class BkuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BkuButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool fullWidth;
  final double? fontSize;
  final Color? customBgColor;
  final Color? customFgColor;

  const BkuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BkuButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.fullWidth = true,
    this.fontSize,
    this.customBgColor,
    this.customFgColor,
  });

  factory BkuButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    bool fullWidth = true,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.primary,
    isLoading: isLoading,
    icon: icon,
    width: width,
    fullWidth: fullWidth,
  );

  factory BkuButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    bool fullWidth = true,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.secondary,
    isLoading: isLoading,
    icon: icon,
    width: width,
    fullWidth: fullWidth,
  );

  factory BkuButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    bool fullWidth = true,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.outline,
    isLoading: isLoading,
    icon: icon,
    width: width,
    fullWidth: fullWidth,
  );

  factory BkuButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    bool fullWidth = true,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.text,
    isLoading: isLoading,
    icon: icon,
    width: width,
    fullWidth: fullWidth,
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    Color bg;
    Color fg;
    BorderSide? border;
    double elevation = 0;

    switch (variant) {
      case BkuButtonVariant.primary:
        bg = theme.primary;
        fg = theme.onPrimary;
        // Soft & Clean elevation
        elevation = 2;
        break;
      case BkuButtonVariant.secondary:
        bg = theme.secondary;
        fg = theme.onSecondary;
        elevation = 2;
        break;
      case BkuButtonVariant.success:
        bg = context.appColors.success;
        fg = context.appColors.onPrimary;
        elevation = 2;
        break;
      case BkuButtonVariant.danger:
        bg = context.appColors.danger;
        fg = context.appColors.onPrimary;
        elevation = 2;
        break;
      case BkuButtonVariant.outline:
        bg = Colors.transparent;
        fg = theme.primary;
        border = BorderSide(
          color: theme.primary.withValues(alpha: 0.5),
          width: 1.5,
        );
        break;
      case BkuButtonVariant.text:
        bg = Colors.transparent;
        fg = theme.primary;
        break;
    }

    if (customBgColor != null) bg = customBgColor!;
    if (customFgColor != null) fg = customFgColor!;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withValues(alpha: 0.3),
      disabledForegroundColor: fg.withValues(alpha: 0.5),
      elevation: elevation,
      shadowColor: bg.withValues(alpha: 0.4), // Soft shadow inheriting color
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: variant == BkuButtonVariant.text ? 8 : (height < 44 ? 6 : 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMd, // 12px radius as agreed
        side: border ?? BorderSide.none,
      ),
    );

    final textWidget = Text(
      text,
      style: AppTextStyles.labelLg.copyWith(
        fontWeight: FontWeight.w700,
        color: fg,
        letterSpacing: 0.5,
        fontSize: fontSize,
      ),
    );

    Widget content;
    if (isLoading || icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: AppSpacing.sm),
          ],
          textWidget,
        ],
      );
    } else {
      content = textWidget;
    }

    if (width != null) {
      content = SizedBox(width: width, child: content);
    }

    return SizedBox(
      height: height,
      width: width ?? (fullWidth ? double.infinity : null),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
