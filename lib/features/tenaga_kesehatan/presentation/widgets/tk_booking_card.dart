import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';

class TkBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final bool showActions;

  const TkBookingCard({
    super.key,
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onTap,
    this.showActions = true,
  });

  Color get statusColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('selesai') || s.contains('completed')) {
      return const Color(0xFF15803D);
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return const Color(0xFFB45309);
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF475569);
  }

  Color get statusBgColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return const Color(0xFFEFF6FF);
    } else if (s.contains('selesai') || s.contains('completed')) {
      return const Color(0xFFF0FDF4);
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return const Color(0xFFFEF3C7);
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return const Color(0xFFFEF2F2);
    }
    return const Color(0xFFF8FAFC);
  }

  Color get statusBorderColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return const Color(0xFF93C5FD);
    } else if (s.contains('selesai') || s.contains('completed')) {
      return const Color(0xFF86EFAC);
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return const Color(0xFFFCD34D);
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return const Color(0xFFFCA5A5);
    }
    return const Color(0xFFE2E8F0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      booking.initials,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        booking.nim,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.prodi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusBorderColor),
                  ),
                  child: Text(
                    booking.status.capitalizeFirstLetter(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                _buildInfoItem(
                  Icons.calendar_today_rounded,
                  booking.jadwalTanggal ?? '-',
                ),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.access_time_rounded, booking.waktu ?? '-'),
                const SizedBox(width: 16),
                _buildInfoItem(
                  Icons.medical_services_rounded,
                  booking.tipeLayanan ?? 'Umum',
                ),
              ],
            ),

            // Keluhan
            if (booking.keluhan != null && booking.keluhan!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.keluhan!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (showActions && booking.isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text(
                        'Terima',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: AppColors.neutral600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
