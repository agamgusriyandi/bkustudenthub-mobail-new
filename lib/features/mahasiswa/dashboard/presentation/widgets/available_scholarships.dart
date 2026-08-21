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
              Text(
                'Beasiswa yang Tersedia',
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w900,
                ),
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
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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

    if (isClosed) {
      statusEnum = BkuStatus.inactive;
      statusText = 'Ditutup';
    } else if (isUrgent) {
      statusEnum = BkuStatus.warning;
      statusText = 'Sisa $daysDiff Hari';
    } else {
      statusEnum = BkuStatus.success;
      statusText = 'Terbuka';
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
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    item.category,
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BkuStatusBadge(
                status: statusEnum,
                customText: statusText,
                showIcon: false,
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
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Benefit',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatRupiah(item.amount),
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Batas Waktu',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(item.deadline),
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          BkuButton.primary(
            text: 'Lihat Detail Program',
            customBgColor: const Color(0xFFF1F5F9),
            customFgColor: const Color(0xFF1E293B),
            height: 32,
            fontSize: 11.5,
            onPressed: () {
              context.push('/scholarship/program/${item.id}');
            },
          ),
        ],
      ),
    );
  }
}
