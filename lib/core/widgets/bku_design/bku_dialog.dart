import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

enum BkuDialogType { success, error, warning, info }

class BkuDialog extends StatelessWidget {
  final String title;
  final String message;
  final BkuDialogType type;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const BkuDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required BkuDialogType type,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BkuDialog(
            title: title,
            message: message,
            type: type,
            primaryButtonText: primaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            secondaryButtonText: secondaryButtonText,
            onSecondaryPressed: onSecondaryPressed,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    IconData iconData;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case BkuDialogType.success:
        iconData = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        iconBgColor = AppColors.successContainer;
        break;
      case BkuDialogType.error:
        iconData = Icons.error_rounded;
        iconColor = theme.colorError;
        iconBgColor = theme.colorError.withValues(alpha: 0.1);
        break;
      case BkuDialogType.warning:
        iconData = Icons.warning_rounded;
        iconColor = AppColors.warning;
        iconBgColor = AppColors.warningContainer;
        break;
      case BkuDialogType.info:
        iconData = Icons.info_rounded;
        iconColor = theme.primary;
        iconBgColor = theme.primary.withValues(alpha: 0.1);
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
      ), // 24px radius
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 48, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: BkuButton.outline(
                      text: secondaryButtonText!,
                      onPressed:
                          onSecondaryPressed ??
                          () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: BkuButton.primary(
                    text: primaryButtonText,
                    onPressed: onPrimaryPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
