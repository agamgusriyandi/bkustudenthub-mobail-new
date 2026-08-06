import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:go_router/go_router.dart';

class ScholarshipItem {
  final String id;
  final String name;
  final String organizer;
  final String category;
  final double amount;
  final DateTime? deadline;
  final String? status;

  ScholarshipItem({
    required this.id,
    required this.name,
    required this.organizer,
    required this.category,
    required this.amount,
    this.deadline,
    this.status,
  });
}

class AvailableScholarships extends StatelessWidget {
  final List<ScholarshipItem> scholarships;
  final VoidCallback? onViewAll;

  const AvailableScholarships({
    super.key,
    this.scholarships = const [],
    this.onViewAll,
  });

  String _formatRupiah(double amount) {
    if (amount <= 0) return 'Rp 0';
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int _getDaysDiff(DateTime? date) {
    if (date == null) return 999;
    final now = DateTime.now();
    final diff = date.difference(now);
    return diff.inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (scholarships.isEmpty) return const SizedBox.shrink();

    final openScholarships = scholarships.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: context.appColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Beasiswa yang Tersedia',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll ?? () {
                  AppSnackbar.showSuccess(context, 'Menampilkan semua beasiswa...');
                },
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: context.appColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...openScholarships.map((item) => _buildScholarshipCard(context, item)),
        ],
      ),
    );
  }

  Widget _buildScholarshipCard(BuildContext context, ScholarshipItem item) {
    final daysDiff = _getDaysDiff(item.deadline);
    final isUrgent = daysDiff >= 0 && daysDiff < 14;
    final isClosed = daysDiff < 0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isClosed) {
      statusColor = context.appColors.onSurfaceVariant;
      statusText = 'Ditutup';
      statusIcon = Icons.event_busy_rounded;
    } else if (isUrgent) {
      statusColor = AppColors.warning;
      statusText = 'Sisa $daysDiff Hari';
      statusIcon = Icons.schedule_rounded;
    } else {
      statusColor = AppColors.success;
      statusText = 'Terbuka';
      statusIcon = Icons.verified_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClosed
              ? context.appColors.outline.withValues(alpha: 0.1)
              : context.appColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: context.appColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  item.category,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: AppTextStyles.titleSm.copyWith(
              fontWeight: FontWeight.w900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.organizer,
            style: AppTextStyles.caption.copyWith(
              color: context.appColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.appColors.outline.withValues(alpha: 0.1),
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payments_rounded,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Benefit',
                          style: AppTextStyles.caption.copyWith(
                            color: context.appColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatRupiah(item.amount),
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: context.appColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Batas Waktu',
                          style: AppTextStyles.caption.copyWith(
                            color: context.appColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(item.deadline),
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/scholarship/program/${item.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daftar Sekarang',
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.appColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: context.appColors.surface,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
