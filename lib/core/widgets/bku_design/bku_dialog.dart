import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:go_router/go_router.dart';

enum BkuDialogType { success, error, warning, info }

class BkuDialog extends StatelessWidget {
  final String title;
  final String message;
  final BkuDialogType type;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final String? customImageAsset;

  const BkuDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.customImageAsset,
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
    String? customImageAsset,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BkuDialog(
        title: title,
        message: message,
        type: type,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        customImageAsset: customImageAsset,
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
        iconColor = BkuTheme.emerald;
        iconBgColor = BkuTheme.emeraldSoft;
        break;
      case BkuDialogType.error:
        iconData = Icons.error_rounded;
        iconColor = BkuTheme.rose;
        iconBgColor = BkuTheme.roseSoft;
        break;
      case BkuDialogType.warning:
        iconData = Icons.warning_rounded;
        iconColor = BkuTheme.amber;
        iconBgColor = BkuTheme.amberSoft;
        break;
      case BkuDialogType.info:
        iconData = Icons.info_rounded;
        iconColor = theme.primary;
        iconBgColor = BkuTheme.primarySoft;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BkuTheme.r24,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: BkuTheme.r24,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customImageAsset != null)
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Image.asset(
                  customImageAsset!,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              )
            else
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
              style: BkuTheme.textSectionTitle.copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BkuTheme.textBodyRegular.copyWith(
                color: BkuTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: BkuButton(
                      variant: BkuButtonVariant.outline,
                      text: secondaryButtonText!,
                      height: 40,
                      fontSize: 11,
                      onPressed: onSecondaryPressed ?? () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: BkuButton(
                    variant: type == BkuDialogType.error
                        ? BkuButtonVariant.danger
                        : BkuButtonVariant.primary,
                    text: primaryButtonText,
                    height: 40,
                    fontSize: 11,
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
