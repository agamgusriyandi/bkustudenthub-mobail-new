import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:intl/intl.dart';

class TkScreeningsScreen extends StatefulWidget {
  const TkScreeningsScreen({super.key});

  @override
  State<TkScreeningsScreen> createState() => _TkScreeningsScreenState();
}

class _TkScreeningsScreenState extends State<TkScreeningsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Semua';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
        return name.contains(q) || r.jenisPemeriksaan?.toLowerCase().contains(q) == true;
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
        title: 'Screening',
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
          final totalPages = (records.length / _itemsPerPage).clamp(1, 999).toInt();
          _currentPage = _currentPage.clamp(1, totalPages);
          final start = (_currentPage - 1) * _itemsPerPage;
          final paged = records.sublist(start, (start + _itemsPerPage).clamp(0, records.length));

          return Column(
            children: [
              // Search & Filter
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari screening...',
                        hintStyle: TextStyle(color: AppColors.neutral400),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500),
                        filled: true,
                        fillColor: AppColors.neutral50,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusMd,
                          borderSide: BorderSide(color: AppColors.neutral200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusMd,
                          borderSide: BorderSide(color: AppColors.neutral200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusMd,
                          borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('Semua'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Layak Kegiatan'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Perlu Perhatian'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Tidak Layak'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Summary
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _buildStatCard('Total', '${records.length}', context.appColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard('Layak', '${records.where((r) => r.statusCategory == 'Layak Kegiatan').length}', context.read<ThemeProvider>().colors.success),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard('Pantauan', '${records.where((r) => r.statusCategory == 'Perlu Perhatian').length}', context.read<ThemeProvider>().colors.warning),
                  ],
                ),
              ),

              // List
              Expanded(
                child: paged.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.health_and_safety_outlined, size: 64, color: AppColors.neutral300),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Belum ada data screening', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadPatients(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: paged.length,
                          itemBuilder: (context, index) => _buildScreeningCard(paged[index]),
                        ),
                      ),
              ),

              // Pagination
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                        icon: Icon(Icons.chevron_left_rounded, color: _currentPage > 1 ? context.appColors.primary : AppColors.neutral300),
                      ),
                      Text('$_currentPage / $totalPages', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold, color: context.appColors.primary)),
                      IconButton(
                        onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                        icon: Icon(Icons.chevron_right_rounded, color: _currentPage < totalPages ? context.appColors.primary : AppColors.neutral300),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _statusFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _statusFilter = label),
      backgroundColor: AppColors.neutral50,
      selectedColor: context.appColors.primary,
      labelStyle: AppTextStyles.labelSm.copyWith(
        color: isActive ? context.appColors.onPrimary : AppColors.neutral600,
      ),
      side: BorderSide(color: isActive ? context.appColors.primary : AppColors.neutral200),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningCard(MedicalRecord record) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(record.tanggal);
    final statusColor = _getStatusColor(record.statusCategory);

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
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  record.statusCategory.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
              const Spacer(),
              Text(dateStr, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(Icons.medical_services_rounded, record.jenisPemeriksaan ?? 'Pemeriksaan Reguler'),
          _buildInfoRow(Icons.person_rounded, record.namaPemeriksa ?? 'TK'),
          _buildInfoRow(Icons.monitor_weight_rounded, 'BMI: ${record.bmi.toStringAsFixed(1)} (${record.bmiCategory})'),
          if (record.hasil != null)
            _buildInfoRow(Icons.check_circle_outline_rounded, 'Hasil: ${record.hasil}'),
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

  Color _getStatusColor(String category) {
    switch (category) {
      case 'Layak Kegiatan':
        return context.read<ThemeProvider>().colors.success;
      case 'Perlu Perhatian':
        return context.read<ThemeProvider>().colors.warning;
      case 'Tidak Layak':
        return context.appColors.error;
      default:
        return AppColors.neutral500;
    }
  }
}
