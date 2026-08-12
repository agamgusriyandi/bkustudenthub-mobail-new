import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_schedule_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:intl/intl.dart';

class TkAllSchedulesScreen extends StatefulWidget {
  const TkAllSchedulesScreen({super.key});

  @override
  State<TkAllSchedulesScreen> createState() => _TkAllSchedulesScreenState();
}

class _TkAllSchedulesScreenState extends State<TkAllSchedulesScreen> {
  String _searchQuery = '';
  String _typeFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkScheduleProvider>().loadSchedules();
    });
  }

  List<Schedule> _getFiltered(TkScheduleProvider provider) {
    var schedules = provider.schedules;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      schedules = schedules.where((s) {
        return s.lokasi.toLowerCase().contains(q) || s.tipeLayanan.toLowerCase().contains(q);
      }).toList();
    }
    if (_typeFilter != 'Semua') {
      schedules = schedules.where((s) => s.tipeLayanan == _typeFilter).toList();
    }
    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Semua Jadwal',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Consumer<TkScheduleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.schedules.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 5, itemHeight: 100),
            );
          }

          final schedules = _getFiltered(provider);

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: BkuTextField(
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  hint: 'Cari jadwal...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutral500),
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Semua', 'Pemeriksaan Umum', 'Screening', 'Konsultasi'].map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(f),
                          selected: _typeFilter == f,
                          onSelected: (_) => setState(() => _typeFilter = f),
                          backgroundColor: AppColors.neutral50,
                          selectedColor: context.appColors.primary,
                          labelStyle: AppTextStyles.labelSm.copyWith(
                            color: _typeFilter == f ? context.appColors.onPrimary : AppColors.neutral600,
                          ),
                          side: BorderSide(
                            color: _typeFilter == f ? context.appColors.primary : AppColors.neutral200,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Schedules List
              Expanded(
                child: schedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded, size: 64, color: AppColors.neutral300),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Belum ada jadwal', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadSchedules(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: schedules.length,
                          itemBuilder: (context, index) => _buildScheduleCard(schedules[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(schedule.tanggal);
    final slotsAvailable = schedule.availableSlots;
    final isFull = slotsAvailable <= 0;

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  schedule.tipeLayanan,
                  style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: isFull ? context.appColors.error.withAlpha(20) : context.read<ThemeProvider>().colors.success.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  isFull ? 'PENUH' : '$slotsAvailable SLOT',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isFull ? context.appColors.error : context.read<ThemeProvider>().colors.success,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(Icons.calendar_today_rounded, dateStr),
          _buildInfoRow(Icons.access_time_rounded, schedule.waktuFormat),
          _buildInfoRow(Icons.location_on_outlined, schedule.lokasi),
          _buildInfoRow(Icons.people_outline_rounded, 'Kuota: ${schedule.bookedCount ?? 0}/${schedule.kuota}'),
          if (schedule.catatan != null && schedule.catatan!.isNotEmpty)
            _buildInfoRow(Icons.notes_rounded, schedule.catatan!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral700))),
        ],
      ),
    );
  }
}
