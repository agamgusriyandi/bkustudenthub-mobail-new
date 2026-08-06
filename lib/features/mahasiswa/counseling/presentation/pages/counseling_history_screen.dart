import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import '../providers/counseling_history_provider.dart';
import '../../data/models/counseling_history_model.dart';

class CounselingHistoryScreen extends StatefulWidget {
  const CounselingHistoryScreen({super.key});

  @override
  State<CounselingHistoryScreen> createState() =>
      _CounselingHistoryScreenState();
}

class _CounselingHistoryScreenState extends State<CounselingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: const BkuStaticAppBar(
        title: 'Riwayat Konseling',
        showNotification: false,
      ),
      body: Consumer<CounselingHistoryProvider>(
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
                    child: _buildFilterChips(context, provider),
                  ),
                ),
                if (provider.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
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
                else if (provider.filteredList.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildHistoryCard(
                          context,
                          provider.filteredList[index],
                          provider,
                        ),
                        childCount: provider.filteredList.length,
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

  Widget _buildFilterChips(
      BuildContext context, CounselingHistoryProvider provider) {
    final filters = [
      _FilterOption(null, 'Semua'),
      _FilterOption('Menunggu', 'Menunggu'),
      _FilterOption('Selesai', 'Selesai'),
      _FilterOption('Dibatalkan', 'Dibatalkan'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = provider.selectedFilter == filter.value;

          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => provider.setFilter(filter.value),
            selectedColor: context.appColors.primary,
            backgroundColor: AppThemeColors.surfaceContainerHighest,
            labelStyle: AppTextStyles.labelMd.copyWith(
              color: isSelected
                  ? context.appColors.onPrimary
                  : context.appColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusFull,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    CounselingHistoryModel booking,
    CounselingHistoryProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BkuCard(
        onTap: () => _showBookingDetail(context, booking, provider),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context, booking),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.psychologistName,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.appColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.psychologistSpecialization.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          booking.psychologistSpecialization,
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.appColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        booking.typeLabel,
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.appColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusBadge(context, booking),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              Icons.calendar_today_rounded,
              booking.formattedDate,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              Icons.access_time_rounded,
              booking.time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, CounselingHistoryModel booking) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: context.appColors.primaryContainer,
      backgroundImage: booking.psychologistPhoto.isNotEmpty
          ? NetworkImage(booking.psychologistPhoto)
          : null,
      child: booking.psychologistPhoto.isEmpty
          ? Icon(
              Icons.person_rounded,
              color: context.appColors.primary,
              size: 28,
            )
          : null,
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

  Widget _buildStatusBadge(
      BuildContext context, CounselingHistoryModel booking) {
    Color bgColor;
    Color fgColor;

    switch (booking.status) {
      case CounselingStatus.menunggu:
        bgColor = context.appColors.warningContainer;
        fgColor = context.appColors.warning;
      case CounselingStatus.selesai:
        bgColor = context.appColors.successContainer;
        fgColor = context.appColors.success;
      case CounselingStatus.dibatalkan:
        bgColor = context.appColors.errorContainer;
        fgColor = context.appColors.error;
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
        booking.statusLabel,
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
              Icons.history_rounded,
              size: 64,
              color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada riwayat',
              style: AppTextStyles.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: context.appColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Riwayat konseling akan muncul di sini',
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

  Widget _buildErrorState(
      BuildContext context, CounselingHistoryProvider provider) {
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
              provider.errorMessage ?? 'Gagal memuat riwayat konseling',
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

  void _showBookingDetail(
    BuildContext context,
    CounselingHistoryModel booking,
    CounselingHistoryProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: AppRadius.radiusFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  _buildAvatar(context, booking),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.psychologistName,
                          style: AppTextStyles.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.appColors.onSurface,
                          ),
                        ),
                        if (booking.psychologistSpecialization.isNotEmpty)
                          Text(
                            booking.psychologistSpecialization,
                            style: AppTextStyles.bodySm.copyWith(
                              color: context.appColors.onSurfaceVariant,
                            ),
                          ),
                        Text(
                          booking.typeLabel,
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.appColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, booking),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(context, 'Tanggal', booking.formattedDate),
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow(context, 'Waktu', booking.time),
              if (booking.notes != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(context, 'Catatan', booking.notes!),
              ],
              if (booking.cancelReason != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(context, 'Alasan Pembatalan', booking.cancelReason!),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (booking.status == CounselingStatus.menunggu) ...[
                if (booking.canReschedule) ...[
                  BkuButton.primary(
                    text: 'Jadwalkan Ulang',
                    icon: Icons.edit_calendar_rounded,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleReschedule(context, booking, provider);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (booking.canCancel) ...[
                  BkuButton.outline(
                    text: 'Batalkan',
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleCancel(context, booking, provider);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              BkuButton.outline(
                text: 'Export PDF',
                icon: Icons.picture_as_pdf_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleExportPdf(context, booking);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleCancel(
    BuildContext context,
    CounselingHistoryModel booking,
    CounselingHistoryProvider provider,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Konseling'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Batalkan konseling dengan ${booking.psychologistName}?'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Alasan pembatalan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
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
              provider.cancelBooking(
                booking.id,
                reason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : null,
              );
            },
            child: Text(
              'Batalkan',
              style: TextStyle(
                color: context.appColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReschedule(
    BuildContext context,
    CounselingHistoryModel booking,
    CounselingHistoryProvider provider,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: booking.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked == null || !context.mounted) return;

    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (timePicked == null || !context.mounted) return;

    final newDate =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    final newTime =
        '${timePicked.hour.toString().padLeft(2, '0')}:${timePicked.minute.toString().padLeft(2, '0')}';

    provider.rescheduleBooking(
      booking.id,
      newDate: newDate,
      newTime: newTime,
    );
  }

  void _handleExportPdf(
      BuildContext context, CounselingHistoryModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export PDF untuk konseling #${booking.id}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),
    );
  }
}

class _FilterOption {
  final String? value;
  final String label;

  const _FilterOption(this.value, this.label);
}
