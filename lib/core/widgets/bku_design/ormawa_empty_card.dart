import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaEmptyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  const OrmawaEmptyCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.calendar_today_rounded,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: OrmawaTheme.r16,
              border: Border.all(color: OrmawaTheme.border),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: OrmawaTheme.textPlaceholder,
              ),
            ),
          ),
          SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
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
