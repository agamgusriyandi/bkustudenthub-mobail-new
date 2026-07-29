import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isDestructive;
  final bool isSuccess;
  final bool isLoading;
  final Widget? customChild;
  final Color? confirmColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Batal',
    this.confirmText = 'Ya',
    required this.onCancel,
    required this.onConfirm,
    this.isDestructive = false,
    this.isSuccess = false,
    this.isLoading = false,
    this.customChild,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBgColor = context.appColors.info.withAlpha(25);
    Color iconColor = context.appColors.info;
    IconData iconData = Icons.info_outline_rounded;

    if (isSuccess) {
      iconBgColor = context.appColors.success.withAlpha(25);
      iconColor = context.appColors.success;
      iconData = Icons.check_circle_rounded;
    } else if (isDestructive) {
      iconBgColor = context.appColors.error.withAlpha(25);
      iconColor = context.appColors.error;
      iconData = Icons.error_outline_rounded;
    }

    Widget headerWidget;
    if (isLoading) {
      headerWidget = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        padding: AppSpacing.paddingLg,
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 3,
        ),
      );
    } else {
      headerWidget = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(iconData, color: iconColor, size: 30),
      );
    }

    Widget actionsWidget;
    final resolvedConfirmColor = confirmColor ?? (isDestructive ? null : (isSuccess ? null : context.appColors.secondary));

    if (cancelText.isEmpty) {
      actionsWidget = BkuButton(
        text: confirmText,
        variant:
            isDestructive
                ? BkuButtonVariant.danger
                : isSuccess
                ? BkuButtonVariant.success
                : BkuButtonVariant.primary,
        customBgColor: resolvedConfirmColor,
        onPressed: isLoading ? null : onConfirm,
        isLoading: isLoading,
        height: 48,
      );
    } else {
      actionsWidget = Row(
        children: [
          Expanded(
            child: BkuButton(
              text: cancelText,
              variant: BkuButtonVariant.outline,
              customFgColor: context.appColors.secondary,
              onPressed: isLoading ? null : onCancel,
              height: 48,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: BkuButton(
              text: confirmText,
              variant:
                  isDestructive
                      ? BkuButtonVariant.danger
                      : isSuccess
                      ? BkuButtonVariant.success
                      : BkuButtonVariant.primary,
              customBgColor: resolvedConfirmColor,
              onPressed: isLoading ? null : onConfirm,
              isLoading: isLoading,
              height: 48,
            ),
          ),
        ],
      );
    }

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      backgroundColor: context.appColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            headerWidget,
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (content.isNotEmpty)
              Text(
                content,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            if (customChild != null) ...[
              const SizedBox(height: AppSpacing.md),
              customChild!,
            ],
            const SizedBox(height: AppSpacing.xl),
            actionsWidget,
          ],
        ),
      ),
    );
  }
}
