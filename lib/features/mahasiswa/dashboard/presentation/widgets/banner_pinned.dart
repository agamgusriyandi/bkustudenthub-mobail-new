import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class BannerPinned extends StatefulWidget {
  final String? message;
  final String? link;
  final bool isActive;

  const BannerPinned({
    super.key,
    this.message,
    this.link,
    this.isActive = true,
  });

  @override
  State<BannerPinned> createState() => _BannerPinnedState();
}

class _BannerPinnedState extends State<BannerPinned> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.isActive && (widget.message?.isNotEmpty ?? false);
  }

  void _dismiss() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: context.appColors.surface,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message ?? '',
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.appColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.link != null && widget.link!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to link
                      },
                      child: Text(
                        'Selengkapnya →',
                        style: AppTextStyles.caption.copyWith(
                          color: context.appColors.surface,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          decorationColor: context.appColors.surface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: context.appColors.surface,
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
