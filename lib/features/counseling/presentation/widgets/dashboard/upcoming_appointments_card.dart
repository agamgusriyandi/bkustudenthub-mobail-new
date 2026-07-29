import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpcomingAppointmentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const UpcomingAppointmentsCard({super.key, this.bookings = const []});

  @override
  Widget build(BuildContext context) {
    // Limit to 4 as requested
    final displayBookings =
        bookings.length > 4 ? bookings.sublist(0, 4) : bookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Mendatang',
                    style: AppTextStyles.titleMd.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _todayDate(),
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              if (bookings.isNotEmpty)
                TextButton(
                  onPressed: () => context.push(AppRoutes.psychologistBookings),

                  child: Text(
                    'Lihat Semua',
                    style: AppTextStyles.labelMd.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (displayBookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BkuCard(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 40,
                    color: AppColors.neutral300,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tidak ada jadwal mendatang',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              scrollDirection: Axis.horizontal,
              itemCount: displayBookings.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.lg),
              itemBuilder: (context, index) {
                final booking = displayBookings[index];
                return _HorizontalAppointmentCard(
                  name: booking['name'] ?? '-',
                  id: booking['nim'] ?? '',
                  time: booking['time'] ?? '-',
                  reason: booking['issue'] ?? '-',
                  isActive:
                      booking['status']?.toString().toLowerCase() ==
                          'dikonfirmasi' ||
                      booking['status']?.toString().toLowerCase() ==
                          'confirmed',
                  isPending:
                      booking['status']?.toString().toLowerCase() ==
                          'menunggu' ||
                      booking['status']?.toString().toLowerCase() == 'pending',
                  imageUrl:
                      booking['avatar_url']?.toString() ??
                      booking['foto_url']?.toString() ??
                      booking['foto']?.toString() ??
                      booking['avatar']?.toString() ??
                      '',
                );
              },
            ),
          ),
      ],
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _HorizontalAppointmentCard extends StatelessWidget {
  final String name;
  final String id;
  final String time;
  final String reason;
  final bool isActive;
  final bool isPending;
  final String? imageUrl;

  const _HorizontalAppointmentCard({
    required this.name,
    required this.id,
    required this.time,
    required this.reason,
    required this.isActive,
    required this.isPending,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color:
              isActive ? AppColors.primary.withAlpha(50) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isActive
                    ? AppColors.primary.withAlpha(20)
                    : Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.primary : AppColors.neutral500)
                      .withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child:
                    imageUrl != null && imageUrl!.isNotEmpty
                        ? ClipOval(
                          child: CachedNetworkImage(imageUrl: 
                            ApiGate.getImageUrl(imageUrl!),
                            fit: BoxFit.cover,
                            errorWidget:
                                (_, url, error) => Icon(
                                  isActive
                                      ? Icons.videocam_rounded
                                      : Icons.person_rounded,
                                  color:
                                      isActive
                                          ? AppColors.primary
                                          : AppColors.neutral500,
                                  size: 18,
                                ),
                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                              ),
                            )
                            : Icon(
                              isActive
                                  ? Icons.videocam_rounded
                                  : Icons.person_rounded,
                              color: isActive ? AppColors.primary : AppColors.neutral500,
                          size: 18,
                        ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'NIM: $id',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: const Color(0xFF0D9488)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                time,
                style: AppTextStyles.labelMd.copyWith(
                  color: const Color(0xFF0D9488),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            reason,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500.withAlpha(150)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (isActive)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: context.appColors.onPrimary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusSm,
                  ),
                ),
                onPressed: () {
                  context.read<NavigationProvider>().setBookingTabIndex(
                    2,
                  ); // Dikonfirmasi tab
                  context.push(AppRoutes.psychologistBookings);
                },

                child: Text(
                  'Tangani',
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onPrimary,
                  ),
                ),
              ),
            )
          else if (isPending)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                onPressed: () {
                  context.read<NavigationProvider>().setBookingTabIndex(
                    1,
                  ); // Menunggu tab
                  context.push(AppRoutes.psychologistBookings);
                },
                child: Text(
                  'Konfirmasi',
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutral500.withAlpha(20),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                'Menunggu Waktu',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.neutral600,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
