import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class AvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;

  const AvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isAvailable),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 110,
        height: 36,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: isAvailable ? AppColors.success : AppColors.error,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: isAvailable ? AppColors.success : AppColors.error,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isAvailable ? AppColors.success : AppColors.error)
                  .withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Text Layer
            Align(
              alignment: Alignment.center,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: isAvailable ? 0 : 32,
                  right: isAvailable ? 32 : 0,
                ),
                child: Text(
                  isAvailable ? 'Tersedia' : 'Sibuk',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            // Thumb Layer
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              alignment:
                  isAvailable ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isAvailable ? Icons.check_rounded : Icons.close_rounded,
                  color: isAvailable ? AppColors.success : AppColors.error,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
