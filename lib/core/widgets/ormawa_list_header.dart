import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class OrmawaListHeader extends StatelessWidget {
  final String title;
  final String searchHint;
  final TextEditingController searchController;
  final VoidCallback onRefresh;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  const OrmawaListHeader({
    super.key,
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.onRefresh,
    this.onFilterTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                'Refresh',
                style: AppTextStyles.labelSm.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                height: 52,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.neutral400,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onChanged,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral800,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Cari',
                          hintText: searchHint,
                          hintStyle: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchController.clear();
                          if (onChanged != null) onChanged!('');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.neutral400,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onFilterTap != null) ...[
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
