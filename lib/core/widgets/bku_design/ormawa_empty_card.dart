import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaEmptyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final bool isPrimaryAction;

  const OrmawaEmptyCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.calendar_today_rounded,
    this.action,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.isPrimaryAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: OrmawaTheme.r16,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: OrmawaTheme.textPlaceholder,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
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
          ] else if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            if (isPrimaryAction)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: actionIcon != null ? Icon(actionIcon, size: 15) : const SizedBox.shrink(),
                label: Text(
                  actionLabel!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrmawaTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: onAction,
                icon: actionIcon != null ? Icon(actionIcon, size: 15, color: OrmawaTheme.textHeading) : const SizedBox.shrink(),
                label: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: OrmawaTheme.textHeading,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.1),
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
