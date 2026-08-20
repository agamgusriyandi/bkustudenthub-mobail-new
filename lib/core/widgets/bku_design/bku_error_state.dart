import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class BkuErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;

  const BkuErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.onRetry,
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
                color: BkuTheme.roseSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: BkuTheme.rose,
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BkuTheme.textBodyRegular.copyWith(
                color: BkuTheme.textMuted,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              BkuButton.secondary(
                text: 'Coba Lagi',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                width: 160,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
