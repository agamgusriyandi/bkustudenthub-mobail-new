import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final String? badgeText;
  final Color? badgeColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const OrmawaKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.badgeText,
    this.badgeColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = badgeColor ?? OrmawaTheme.primary;

    Widget card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrmawaTheme.cardSurface,
        borderRadius: OrmawaTheme.r20,
        border: Border.all(color: OrmawaTheme.border),
        boxShadow: OrmawaTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badgeText != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: effectiveColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 13, color: effectiveColor),
                  )
                else
                  const SizedBox.shrink(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: effectiveColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
          Text(
            value,
            style: OrmawaTheme.textKpiValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3),
          Text(
            title,
            style: OrmawaTheme.textKpiLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 1),
            Text(
              subtitle!,
              style: OrmawaTheme.textCaption.copyWith(
                fontSize: 9.5,
                color: OrmawaTheme.textPlaceholder,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: OrmawaTheme.r20,
        child: card,
      );
    }

    return card;
  }
}
