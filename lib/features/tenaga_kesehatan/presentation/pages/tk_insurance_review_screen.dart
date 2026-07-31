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
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_insurance_claim_model.dart';
import 'package:intl/intl.dart';

class TkInsuranceReviewScreen extends StatefulWidget {
  const TkInsuranceReviewScreen({super.key});

  @override
  State<TkInsuranceReviewScreen> createState() => _TkInsuranceReviewScreenState();
}

class _TkInsuranceReviewScreenState extends State<TkInsuranceReviewScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  String _statusFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkHealthProvider>().fetchInsuranceClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Review Asuransi',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Consumer<TkHealthProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.claims.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 4, itemHeight: 140),
            );
          }

          var claims = provider.claims;
          if (_statusFilter != 'Semua') {
            claims = claims.where((c) => _mapStatus(c.status) == _statusFilter).toList();
          }

          final totalPages = (claims.length / _itemsPerPage).clamp(1, 999).toInt();
          _currentPage = _currentPage.clamp(1, totalPages);
          final start = (_currentPage - 1) * _itemsPerPage;
          final paged = claims.sublist(start, (start + _itemsPerPage).clamp(0, claims.length));

          return Column(
            children: [
              // Filter
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'].map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(f),
                          selected: _statusFilter == f,
                          onSelected: (_) => setState(() {
                            _statusFilter = f;
                            _currentPage = 1;
                          }),
                          backgroundColor: AppColors.neutral50,
                          selectedColor: context.appColors.primary,
                          labelStyle: AppTextStyles.labelSm.copyWith(
                            color: _statusFilter == f ? context.appColors.onPrimary : AppColors.neutral600,
                          ),
                          side: BorderSide(
                            color: _statusFilter == f ? context.appColors.primary : AppColors.neutral200,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Claims List
              Expanded(
                child: paged.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_late_rounded, size: 64, color: AppColors.neutral300),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Belum ada klaim', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchInsuranceClaims(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          itemCount: paged.length,
                          itemBuilder: (context, index) => _buildClaimCard(paged[index]),
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

  Widget _buildClaimCard(TkInsuranceClaimModel claim) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(claim.tanggalKejadian);
    final cost = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(claim.estimasiBiaya);
    final statusLabel = _mapStatus(claim.status);
    final statusColor = _getStatusColor(statusLabel);

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, size: 16, color: AppColors.neutral500),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  claim.mahasiswaName.isNotEmpty ? claim.mahasiswaName : 'Mahasiswa',
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            claim.mahasiswaNim,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(Icons.local_hospital_rounded, 'Provider: ${claim.jenisProvider}'),
          _buildInfoRow(Icons.calendar_today_rounded, 'Tanggal: $dateStr'),
          _buildInfoRow(Icons.payments_rounded, 'Biaya: $cost'),
          _buildInfoRow(Icons.description_rounded, 'Kronologi: ${claim.deskripsi}'),
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
          Expanded(child: Text(text, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'PENDING_VERIFICATION':
        return 'Menunggu';
      case 'APPROVED_TK':
      case 'APPROVED_FINAL':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _getStatusColor(String label) {
    switch (label) {
      case 'Disetujui':
        return context.read<ThemeProvider>().colors.success;
      case 'Menunggu':
        return context.read<ThemeProvider>().colors.warning;
      case 'Ditolak':
        return Theme.of(context).colorScheme.error;
      default:
        return AppColors.neutral500;
    }
  }
}
