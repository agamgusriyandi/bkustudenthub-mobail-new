import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:intl/intl.dart';

class TkMedicalRecordsScreen extends StatefulWidget {
  const TkMedicalRecordsScreen({super.key});

  @override
  State<TkMedicalRecordsScreen> createState() => _TkMedicalRecordsScreenState();
}

class _TkMedicalRecordsScreenState extends State<TkMedicalRecordsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkPatientProvider>().loadPatients();
    });
  }

  List<MedicalRecord> _getFiltered(TkPatientProvider provider) {
    var records = provider.medicalRecords;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      records = records.where((r) {
        final name = (r.namaPemeriksa ?? '').toLowerCase();
        return name.contains(q) || r.statusKesehatan.contains(q);
      }).toList();
    }
    if (_statusFilter != 'Semua') {
      records = records.where((r) => r.statusCategory == _statusFilter).toList();
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Rekam Medis',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Consumer<TkPatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.medicalRecords.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 5, itemHeight: 100),
            );
          }

          final records = _getFiltered(provider);

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari rekam medis...',
                    hintStyle: TextStyle(color: AppColors.neutral400),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500),
                    filled: true,
                    fillColor: AppColors.neutral50,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: const BorderSide(color: AppColors.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: const BorderSide(color: AppColors.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ['Semua', 'Layak Kegiatan', 'Perlu Perhatian', 'Tidak Layak'].length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final filters = ['Semua', 'Layak Kegiatan', 'Perlu Perhatian', 'Tidak Layak'];
                      final f = filters[index];
                      final isActive = _statusFilter == f;
                      return FilterChip(
                        label: Text(f),
                        selected: isActive,
                        onSelected: (_) => setState(() => _statusFilter = f),
                        backgroundColor: AppColors.neutral50,
                        selectedColor: context.appColors.primary,
                        labelStyle: AppTextStyles.labelSm.copyWith(
                          color: isActive ? context.appColors.onPrimary : AppColors.neutral600,
                        ),
                        side: BorderSide(
                          color: isActive ? context.appColors.primary : AppColors.neutral200,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
                ),
              ),

              // Records list
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 64, color: AppColors.neutral300),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum ada rekam medis',
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadPatients(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: records.length,
                          itemBuilder: (context, index) => _buildRecordTile(records[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordTile(MedicalRecord record) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(record.tanggal);
    final statusColor = _getStatusColor(record.statusCategory);

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.jenisPemeriksaan ?? 'Pemeriksaan Reguler',
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$dateStr • ${record.tekananDarah} • SpO2 ${record.spO2}%',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Text(
              record.statusCategory.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String category) {
    switch (category) {
      case 'Layak Kegiatan':
        return context.read<ThemeProvider>().colors.success;
      case 'Perlu Perhatian':
        return context.read<ThemeProvider>().colors.warning;
      case 'Tidak Layak':
        return Theme.of(context).colorScheme.error;
      default:
        return AppColors.neutral500;
    }
  }
}
