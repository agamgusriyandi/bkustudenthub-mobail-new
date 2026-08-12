import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

enum BkuButtonVariant { primary, secondary, outline, text, danger, success, dangerOutline }

class BkuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BkuButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final bool fullWidth;
  final double? fontSize;
  final Color? customBgColor;
  final Color? customFgColor;
  final BorderRadiusGeometry? customRadius;

  const BkuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BkuButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.width,
    this.height = 48,
    this.fullWidth = true,
    this.fontSize,
    this.customBgColor,
    this.customFgColor,
    this.customRadius,
  });

  factory BkuButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    double height = 48,
    double? fontSize,
    bool fullWidth = true,
    Color? customBgColor,
    Color? customFgColor,
    BorderRadiusGeometry? customRadius,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.primary,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    height: height,
    fontSize: fontSize,
    fullWidth: fullWidth,
    customBgColor: customBgColor,
    customFgColor: customFgColor,
    customRadius: customRadius,
  );

  factory BkuButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    double height = 48,
    double? fontSize,
    bool fullWidth = true,
    BorderRadiusGeometry? customRadius,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.secondary,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    height: height,
    fontSize: fontSize,
    fullWidth: fullWidth,
    customRadius: customRadius,
  );

  factory BkuButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    bool fullWidth = true,
    BorderRadiusGeometry? customRadius,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.outline,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    fullWidth: fullWidth,
    customRadius: customRadius,
  );

  factory BkuButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    bool fullWidth = true,
    BorderRadiusGeometry? customRadius,
    Color? customFgColor,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.text,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    fullWidth: fullWidth,
    customRadius: customRadius,
    customFgColor: customFgColor,
  );

  factory BkuButton.success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    bool fullWidth = true,
    BorderRadiusGeometry? customRadius,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.success,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    fullWidth: fullWidth,
    customRadius: customRadius,
  );

  factory BkuButton.danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    bool fullWidth = true,
    BorderRadiusGeometry? customRadius,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.danger,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    fullWidth: fullWidth,
    customRadius: customRadius,
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
        elevation = 0;
        break;
      case BkuButtonVariant.secondary:
        bg = AppColors.neutral200;
        fg = AppColors.neutral800;
        border = BorderSide(
          color: context.appColors.outline.withValues(alpha: 0.2),
          width: 1.0,
        );
        elevation = 0;
        break;
      case BkuButtonVariant.dangerOutline:
        bg = Colors.transparent;
        fg = AppColors.error;
        border = const BorderSide(color: AppColors.error, width: 1.0);
        elevation = 0;
        break;
      case BkuButtonVariant.success:
        bg = context.appColors.success;
        fg = context.appColors.onSuccess;
        elevation = 0;
        break;
      case BkuButtonVariant.danger:
        bg = context.appColors.danger;
        fg = context.appColors.onDanger;
        elevation = 0;
        break;
      case BkuButtonVariant.outline:
        bg = Colors.transparent;
        fg = context.appColors.onSurface;
        border = BorderSide(
          color: context.appColors.outline.withValues(alpha: 0.4),
          width: 1.0,
        );
        elevation = 0;
        break;
      case BkuButtonVariant.text:
        bg = Colors.transparent;
        fg = theme.primary;
        elevation = 0;
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
        borderRadius: customRadius ?? AppRadius.radiusMd, // 12px radius as agreed
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
    if (isLoading || icon != null || trailingIcon != null) {
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
          if (!isLoading && trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(trailingIcon, size: 18, color: fg),
          ],
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

  factory BkuButton.dangerOutline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = true,
  }) {
    return BkuButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: BkuButtonVariant.dangerOutline,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
    );
  }
}
