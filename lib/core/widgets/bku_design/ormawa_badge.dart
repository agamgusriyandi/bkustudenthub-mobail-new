import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';

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
    BkuStatus bkuStatus;
    switch (variant) {
      case OrmawaBadgeVariant.success:
        bkuStatus = BkuStatus.success;
        break;
      case OrmawaBadgeVariant.warning:
        bkuStatus = BkuStatus.warning;
        break;
      case OrmawaBadgeVariant.danger:
        bkuStatus = BkuStatus.rejected;
        break;
      case OrmawaBadgeVariant.info:
        bkuStatus = BkuStatus.info;
        break;
      case OrmawaBadgeVariant.primary:
        bkuStatus = BkuStatus.primary;
        break;
      case OrmawaBadgeVariant.neutral:
        bkuStatus = BkuStatus.neutral;
        break;
    }

    return BkuStatusBadge(
      status: bkuStatus,
      customText: text,
      customIcon: icon,
      showIcon: icon != null,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    );
  }
}
