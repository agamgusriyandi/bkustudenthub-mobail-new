import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

enum UnifiedButtonVariant { primary, secondary, success, danger, outline, text }

class UnifiedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final UnifiedButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool fullWidth;

  const UnifiedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = UnifiedButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.fullWidth = true,
  });

  factory UnifiedButton.success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 48,
  }) => UnifiedButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: UnifiedButtonVariant.success,
    isLoading: isLoading,
    icon: icon,
    width: width,
    height: height,
  );

  factory UnifiedButton.danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 48,
  }) => UnifiedButton(
    key: key,
    text: text,
    onPressed: onPressed,
    variant: UnifiedButtonVariant.danger,
    isLoading: isLoading,
    icon: icon,
    width: width,
    height: height,
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case UnifiedButtonVariant.primary:
        bg = theme.primary;
        fg = Colors.white;
        break;
      case UnifiedButtonVariant.secondary:
        bg = theme.secondary;
        fg = Colors.white;
        break;
      case UnifiedButtonVariant.success:
        bg = AppColors.success;
        fg = Colors.white;
        break;
      case UnifiedButtonVariant.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        break;
      case UnifiedButtonVariant.outline:
        bg = Colors.transparent;
        fg = theme.primary;
        border = BorderSide(color: theme.primary, width: 1.5);
        break;
      case UnifiedButtonVariant.text:
        bg = Colors.transparent;
        fg = theme.primary;
        break;
    }

    final lowerText = text.toLowerCase();
    if (variant == UnifiedButtonVariant.primary ||
        variant == UnifiedButtonVariant.outline) {
      if (lowerText == 'batal' ||
          lowerText == 'batalkan' ||
          lowerText == 'ya, batalkan' ||
          lowerText == 'hapus' ||
          lowerText == 'dibatalkan' ||
          lowerText == 'tolak' ||
          lowerText == 'kembali' ||
          lowerText == 'tutup') {
        bg = AppColors.danger;
        fg = Colors.white;
        border = null;
      } else if (lowerText == 'setuju' ||
          lowerText == 'setujui' ||
          lowerText == 'ya, setuju' ||
          lowerText.contains('simpan') ||
          lowerText == 'konfirmasi' ||
          lowerText == 'terima' ||
          lowerText == 'selesai' ||
          lowerText == 'reschedule' ||
          lowerText.contains('ajukan') ||
          lowerText == 'kirim') {
        bg = AppColors.success;
        fg = Colors.white;
        border = null;
      }
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withAlpha(100),
      disabledForegroundColor: fg.withAlpha(100),
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: variant == UnifiedButtonVariant.text ? 8 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMd,
        side: border ?? BorderSide.none,
      ),
    );

    final textWidget = Text(
      text,
      style: AppTextStyles.labelMd.copyWith(
        fontWeight: FontWeight.bold,
        color: fg,
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
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
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
