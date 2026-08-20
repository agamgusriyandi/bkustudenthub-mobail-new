import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';

enum BkuStatus {
  approved,
  pending,
  rejected,
  active,
  inactive,
  draft,
  warning,
  error,
  success,
  info,
  primary,
  neutral,
}

class BkuStatusBadge extends StatelessWidget {
  final BkuStatus status;
  final String? customText;
  final IconData? customIcon;
  final bool showIcon;
  final bool showDot;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? customColor;
  final Color? customBgColor;
  final Color? customBorderColor;

  const BkuStatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.customIcon,
    this.showIcon = false,
    this.showDot = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    this.borderRadius = 6.0,
    this.customColor,
    this.customBgColor,
    this.customBorderColor,
  });

  factory BkuStatusBadge.dot({
    Key? key,
    required BkuStatus status,
    String? customText,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) => BkuStatusBadge(
    key: key,
    status: status,
    customText: customText,
    showIcon: false,
    showDot: true,
    padding: padding,
  );

  factory BkuStatusBadge.icon({
    Key? key,
    required BkuStatus status,
    String? customText,
    IconData? customIcon,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => BkuStatusBadge(
    key: key,
    status: status,
    customText: customText,
    customIcon: customIcon,
    showIcon: true,
    showDot: false,
    padding: padding,
  );

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    String statusText;
    IconData defaultIcon;

    switch (status) {
      case BkuStatus.approved:
      case BkuStatus.success:
        bg = BkuTheme.emeraldSoft;
        fg = BkuTheme.emerald;
        border = BkuTheme.emeraldBorder;
        statusText = status == BkuStatus.approved ? 'Disetujui' : 'Berhasil';
        defaultIcon = Icons.verified_rounded;
        break;
      case BkuStatus.pending:
      case BkuStatus.warning:
        bg = BkuTheme.amberSoft;
        fg = BkuTheme.amber;
        border = BkuTheme.amberBorder;
        statusText = status == BkuStatus.pending ? 'Menunggu' : 'Peringatan';
        defaultIcon = Icons.schedule_rounded;
        break;
      case BkuStatus.rejected:
      case BkuStatus.error:
        bg = BkuTheme.roseSoft;
        fg = BkuTheme.rose;
        border = BkuTheme.roseBorder;
        statusText = status == BkuStatus.rejected ? 'Ditolak' : 'Gagal';
        defaultIcon = Icons.cancel_rounded;
        break;
      case BkuStatus.active:
        bg = BkuTheme.skySoft;
        fg = BkuTheme.sky;
        border = BkuTheme.skyBorder;
        statusText = 'Aktif';
        defaultIcon = Icons.check_circle_rounded;
        break;
      case BkuStatus.inactive:
        bg = BkuTheme.slateSoft;
        fg = BkuTheme.slate;
        border = BkuTheme.slateBorder;
        statusText = 'Nonaktif';
        defaultIcon = Icons.remove_circle_rounded;
        break;
      case BkuStatus.draft:
        bg = BkuTheme.slateSoft;
        fg = BkuTheme.slate;
        border = BkuTheme.slateBorder;
        statusText = 'Draft';
        defaultIcon = Icons.edit_document;
        break;
      case BkuStatus.info:
        bg = BkuTheme.skySoft;
        fg = BkuTheme.statusInfoText;
        border = BkuTheme.skyBorder;
        statusText = 'Info';
        defaultIcon = Icons.info_rounded;
        break;
      case BkuStatus.primary:
        bg = BkuTheme.primarySoft;
        fg = BkuTheme.primary;
        border = BkuTheme.primaryBorder;
        statusText = 'Utama';
        defaultIcon = Icons.star_rounded;
        break;
      case BkuStatus.neutral:
        bg = BkuTheme.borderSubtle;
        fg = BkuTheme.textBody;
        border = BkuTheme.border;
        statusText = 'Netral';
        defaultIcon = Icons.circle_outlined;
        break;
    }

    final effectiveFg = customColor ?? fg;
    final effectiveBg = customBgColor ?? bg;
    final effectiveBorder = customBorderColor ?? border;
    final displayText = customText ?? statusText;
    final displayIcon = customIcon ?? defaultIcon;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: effectiveFg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effectiveFg.withAlpha(120),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ] else if (showIcon) ...[
            Icon(displayIcon, color: effectiveFg, size: 12),
            const SizedBox(width: 5),
          ],
          Text(
            displayText,
            style: BkuTheme.textBadge.copyWith(
              color: effectiveFg,
            ),
          ),
        ],
      ),
    );
  }
}
