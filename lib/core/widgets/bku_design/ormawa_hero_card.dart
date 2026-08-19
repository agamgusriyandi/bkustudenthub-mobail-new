import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaHeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final Color? iconColor;
  final Color? iconBgColor;

  const OrmawaHeroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: OrmawaTheme.cardSurface,
        borderRadius: OrmawaTheme.r24,
        border: Border.all(color: OrmawaTheme.border),
        boxShadow: OrmawaTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBgColor ?? OrmawaTheme.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: (iconColor ?? OrmawaTheme.primary).withAlpha(40),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? OrmawaTheme.primary,
              ),
            ),
          ),
          SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: OrmawaTheme.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
