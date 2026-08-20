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
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
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
              color: iconBgColor ?? (iconColor ?? OrmawaTheme.primary).withAlpha(18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (iconColor ?? OrmawaTheme.primary).withAlpha(25),
                width: 0.8,
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
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: OrmawaTheme.textMuted,
              height: 1.45,
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
