import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

enum BkuButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
  dangerOutline,
  pill,
}

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
  final bool isButtonInButton;
  final Gradient? gradient;

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
    this.isButtonInButton = false,
    this.gradient,
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
    bool isButtonInButton = false,
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
    isButtonInButton: isButtonInButton,
  );

  factory BkuButton.pill({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    double? width,
    double height = 52,
    double? fontSize,
    bool fullWidth = true,
    Color? customBgColor,
    Color? customFgColor,
    Gradient? gradient,
  }) => BkuButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: BkuButtonVariant.pill,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    height: height,
    fontSize: fontSize,
    fullWidth: fullWidth,
    customBgColor: customBgColor,
    customFgColor: customFgColor,
    customRadius: BorderRadius.circular(999),
    isButtonInButton: trailingIcon != null,
    gradient: gradient,
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
    double height = 48,
    double? fontSize,
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
    height: height,
    fontSize: fontSize,
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
    double height = 48,
    double? fontSize,
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
    height: height,
    fontSize: fontSize,
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
    double height = 48,
    double? fontSize,
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
    height: height,
    fontSize: fontSize,
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
    double height = 48,
    double? fontSize,
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
    height: height,
    fontSize: fontSize,
    fullWidth: fullWidth,
    customRadius: customRadius,
  );

  factory BkuButton.dangerOutline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
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
    variant: BkuButtonVariant.dangerOutline,
    isLoading: isLoading,
    icon: icon,
    trailingIcon: trailingIcon,
    width: width,
    height: height,
    fontSize: fontSize,
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
      case BkuButtonVariant.pill:
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

    final resolvedRadius = customRadius ?? (variant == BkuButtonVariant.pill ? BorderRadius.circular(999) : BorderRadius.circular(16));

    final textContent = Text(
      text,
      style: AppTextStyles.labelLg.copyWith(
        fontWeight: FontWeight.w700,
        color: fg,
        letterSpacing: 0.4,
        fontSize: fontSize,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    Widget content;
    if (isLoading || icon != null || trailingIcon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: height < 44 ? 14 : 18,
              height: height < 44 ? 14 : 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            ),
            SizedBox(width: height < 44 ? 4 : AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: height < 44 ? 15 : 18, color: fg),
            SizedBox(width: height < 44 ? 4 : AppSpacing.sm),
          ],
          Flexible(child: textContent),
          if (!isLoading && trailingIcon != null) ...[
            SizedBox(width: height < 44 ? 4 : AppSpacing.sm),
            if (isButtonInButton)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: fg.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(trailingIcon, size: 16, color: fg),
                ),
              )
            else
              Icon(trailingIcon, size: height < 44 ? 15 : 18, color: fg),
          ],
        ],
      );
    } else {
      content = textContent;
    }

    if (gradient != null && variant != BkuButtonVariant.text) {
      return Container(
        height: height,
        width: width ?? (fullWidth ? double.infinity : null),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: resolvedRadius,
          boxShadow: [
            BoxShadow(
              color: bg.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: resolvedRadius as BorderRadius?,
            child: Center(child: content),
          ),
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withValues(alpha: 0.3),
      disabledForegroundColor: fg.withValues(alpha: 0.5),
      elevation: elevation,
      shadowColor: bg.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(
        horizontal: isButtonInButton ? AppSpacing.md : (height < 44 ? AppSpacing.sm : AppSpacing.md),
        vertical: variant == BkuButtonVariant.text ? 8 : (height < 44 ? 4 : 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: resolvedRadius,
        side: border ?? BorderSide.none,
      ),
    );

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
