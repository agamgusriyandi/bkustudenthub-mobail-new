import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
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

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderOnly: true,
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
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Beasiswa yang Tersedia',
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll ?? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScholarshipScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
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

    BkuStatus statusEnum;
    String statusText;
    IconData statusIcon;

    if (isClosed) {
      statusEnum = BkuStatus.inactive;
      statusText = 'Ditutup';
      statusIcon = Icons.event_busy_rounded;
    } else if (isUrgent) {
      statusEnum = BkuStatus.warning;
      statusText = 'Sisa $daysDiff Hari';
      statusIcon = Icons.schedule_rounded;
    } else {
      statusEnum = BkuStatus.success;
      statusText = 'Terbuka';
      statusIcon = Icons.verified_rounded;
    }

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      borderOnly: isClosed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  item.category,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              BkuStatusBadge(
                status: statusEnum,
                customText: statusText,
                customIcon: statusIcon,
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
          BkuButton.primary(
            text: 'Lihat Detail Program',
            trailingIcon: Icons.arrow_forward_rounded,
            customBgColor: AppColors.success,
            customFgColor: Colors.white,
            height: 38,
            fontSize: 13,
            onPressed: () {
              context.push('/scholarship/program/${item.id}');
            },
          ),
        ],
      ),
    );
  }
}
