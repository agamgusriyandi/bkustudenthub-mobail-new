import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

enum OrmawaBadgeVariant { success, warning, danger, info, primary, neutral }

class OrmawaBadge extends StatelessWidget {
  final String text;
  final OrmawaBadgeVariant variant;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const OrmawaBadge({
    super.key,
    required this.text,
    this.variant = OrmawaBadgeVariant.info,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case OrmawaBadgeVariant.success:
        bg = OrmawaTheme.statusSuccessBg;
        fg = OrmawaTheme.statusSuccessText;
        border = OrmawaTheme.statusSuccessBorder;
        break;
      case OrmawaBadgeVariant.warning:
        bg = OrmawaTheme.statusWarningBg;
        fg = OrmawaTheme.statusWarningText;
        border = OrmawaTheme.statusWarningBorder;
        break;
      case OrmawaBadgeVariant.danger:
        bg = OrmawaTheme.statusDangerBg;
        fg = OrmawaTheme.statusDangerText;
        border = OrmawaTheme.statusDangerBorder;
        break;
      case OrmawaBadgeVariant.info:
        bg = OrmawaTheme.statusInfoBg;
        fg = OrmawaTheme.statusInfoText;
        border = OrmawaTheme.statusInfoBorder;
        break;
      case OrmawaBadgeVariant.primary:
        bg = OrmawaTheme.primarySoft;
        fg = OrmawaTheme.primaryDark;
        border = OrmawaTheme.primaryBorder;
        break;
      case OrmawaBadgeVariant.neutral:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        border = const Color(0xFFE2E8F0);
        break;
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10.5, color: fg),
            const SizedBox(width: 3.5),
          ],
          Text(
            text,
            style: OrmawaTheme.textBadge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
