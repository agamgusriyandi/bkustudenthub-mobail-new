import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';

class BkuKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final String? badgeText;
  final Color? badgeColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? progress;
  final Color? progressColor;

  const BkuKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.badgeText,
    this.badgeColor,
    this.subtitle,
    this.onTap,
    this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = badgeColor ?? BkuTheme.primary;
    final effectiveProgressColor = progressColor ?? effectiveColor;

    Widget card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.borderSubtle, width: 1.0),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badgeText != null || icon != null || progress != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: effectiveColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: effectiveColor),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (progress != null) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress!.clamp(0.0, 1.0),
                              strokeWidth: 2.5,
                              backgroundColor: effectiveProgressColor.withAlpha(30),
                              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: effectiveColor.withAlpha(14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: effectiveColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            value,
            style: BkuTheme.textKpiValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: BkuTheme.textKpiLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: BkuTheme.textCaption.copyWith(
                fontSize: 9.5,
                color: BkuTheme.textPlaceholder,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 3.5,
                backgroundColor: effectiveProgressColor.withAlpha(25),
                valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BkuTheme.r20,
        child: card,
      );
    }

    return card;
  }
}
