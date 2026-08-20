import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class BkuEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final EdgeInsetsGeometry padding;

  const BkuEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: BkuTheme.borderSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: 48,
                color: BkuTheme.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: BkuTheme.textSectionTitle.copyWith(
                fontSize: 16,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: BkuTheme.textBodyRegular.copyWith(
                  color: BkuTheme.textMuted,
                ),
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              BkuButton.primary(
                text: buttonText!,
                onPressed: onButtonPressed,
                width: 200,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
