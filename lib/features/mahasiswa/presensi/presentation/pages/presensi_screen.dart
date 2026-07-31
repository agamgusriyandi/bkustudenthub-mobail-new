import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/unified_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import '../providers/presensi_provider.dart';
import '../../data/models/presensi_model.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PresensiProvider>().loadPresensi();
    });
  }

  Future<void> _pickDate() async {
    final provider = context.read<PresensiProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: UnifiedStaticAppBar(
        title: 'Presensi Kelas',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<PresensiProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: context.appColors.primary,
            backgroundColor: context.appColors.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDatePicker(context, provider),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const BkuShimmerCard(height: 120),
                        childCount: 3,
                      ),
                    ),
                  )
                else if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: _buildErrorState(context, provider),
                  )
                else if (provider.presensiList.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPresensiCard(
                          context,
                          provider.presensiList[index],
                          provider,
                        ),
                        childCount: provider.presensiList.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.s100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, PresensiProvider provider) {
    final date = provider.selectedDate;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dateLabel = isToday ? 'Hari Ini' : '$dayName, ${date.day} $monthName ${date.year}';

    return BkuCard(
      onTap: _pickDate,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: context.appColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.appColors.onSurface,
                  ),
                ),
                if (!isToday)
                  Text(
                    'Ketuk untuk memilih tanggal lain',
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.appColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.appColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildPresensiCard(
    BuildContext context,
    PresensiModel presensi,
    PresensiProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    presensi.matkulName,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.appColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusBadge(context, presensi),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              Icons.access_time_rounded,
              presensi.jam,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              Icons.meeting_room_rounded,
              presensi.ruangan,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              Icons.person_rounded,
              presensi.dosen,
            ),
            if (presensi.checkInTime != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(
                context,
                Icons.check_circle_outline_rounded,
                'Check-in: ${presensi.checkInTime}',
              ),
            ],
            if (presensi.status == PresensiStatus.belum && presensi.canCheckIn) ...[
              const SizedBox(height: AppSpacing.lg),
              BkuButton.primary(
                text: 'Check-in Sekarang',
                icon: Icons.location_on_rounded,
                onPressed: () => _handleCheckIn(context, presensi, provider),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: context.appColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, PresensiModel presensi) {
    Color bgColor;
    Color fgColor;

    switch (presensi.status) {
      case PresensiStatus.hadir:
        bgColor = context.appColors.successContainer;
        fgColor = context.appColors.success;
      case PresensiStatus.terlambat:
        bgColor = context.appColors.warningContainer;
        fgColor = context.appColors.warning;
      case PresensiStatus.sakit:
      case PresensiStatus.izin:
        bgColor = context.appColors.infoContainer;
        fgColor = context.appColors.info;
      case PresensiStatus.alpa:
        bgColor = context.appColors.errorContainer;
        fgColor = context.appColors.error;
      case PresensiStatus.belum:
        bgColor = context.appColors.onSurfaceVariant.withValues(alpha: 0.1);
        fgColor = context.appColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        presensi.statusLabel,
        style: AppTextStyles.labelSm.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tidak ada jadwal',
              style: AppTextStyles.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: context.appColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada jadwal presensi untuk hari ini',
              style: AppTextStyles.bodyMd.copyWith(
                color: context.appColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PresensiProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.appColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Terjadi kesalahan',
              style: AppTextStyles.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: context.appColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              provider.errorMessage ?? 'Gagal memuat data presensi',
              style: AppTextStyles.bodyMd.copyWith(
                color: context.appColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            BkuButton.outline(
              text: 'Coba Lagi',
              onPressed: provider.refresh,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckIn(
    BuildContext context,
    PresensiModel presensi,
    PresensiProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check-in Presensi'),
        content: Text('Check-in untuk ${presensi.matkulName}?'),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: context.appColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.checkIn(presensi);
            },
            child: Text(
              'Check-in',
              style: TextStyle(
                color: context.appColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
