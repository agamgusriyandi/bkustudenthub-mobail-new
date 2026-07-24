import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class UnifiedSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllText;
  final bool isSubtitle;

  const UnifiedSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText = 'LIHAT SEMUA',
    this.isSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            isSubtitle ? title.toUpperCase() : title,
            style:
                isSubtitle
                    ? AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral500,
                      letterSpacing: 1.1,
                    )
                    : AppTextStyles.titleLg.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral800,
                      letterSpacing: -0.5,
                    ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
              child: Text(
                seeAllText,
                style: AppTextStyles.labelSm.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
