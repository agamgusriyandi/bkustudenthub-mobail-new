import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:go_router/go_router.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInAnimation(
                delay: 0.2,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeInAnimation(
                delay: 0.4,
                child: Text(
                  featureName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLg.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeInAnimation(
                delay: 0.6,
                child: Text(
                  'Fitur ini sedang dalam tahap pengembangan oleh tim teknis kami untuk memberikan pengalaman terbaik bagi Anda.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeInAnimation(
                delay: 0.8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: AppRadius.radiusXl,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    'Segera Hadir',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s100),
            ],
          ),
        ),
      ),
    );
  }
}
