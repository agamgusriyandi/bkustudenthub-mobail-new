import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class PatientMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  const PatientMedicalRecordScreen({
    super.key,
    required this.patientId,
    this.patientName = 'Pasien',
  });

  @override
  State<PatientMedicalRecordScreen> createState() =>
      _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState
    extends State<PatientMedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdminPsychologistProvider>()
          .loadMedicalRecord(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPsychologistProvider>(
      builder: (context, provider, _) {
        final record = provider.medicalRecord;
        final records = record['records'] ?? record['session_notes'] ?? [];
        final patientInfo = record['patient'] ?? record['mahasiswa'] ?? {};

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Rekam Medis',
                subtitle: widget.patientName,
                variant: AppBarVariant.psychologist,
                isExpandable: false,
                showBackButton: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
                    onPressed: () => context.push(
                      '/counseling/patients/${widget.patientId}/medical-record/create',
                    ),
                  ),
                ],
              ),
              if (provider.medicalRecordLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      0,
                    ),
                    child: _buildPatientInfo(patientInfo),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Sesi',
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          '${records is List ? records.length : 0} sesi',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (records is List && records.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.s120,
                    ),
                    sliver: SliverList.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) =>
                          _buildRecordCard(records[index]),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.medical_information_rounded,
                              size: 64,
                              color: AppColors.neutral300,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum ada rekam medis',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientInfo(Map<String, dynamic> patient) {
    if (patient.isEmpty) return const SizedBox.shrink();
    final name = (patient['name'] ?? patient['nama'] ?? '-').toString();
    final nim = (patient['nim'] ?? patient['NIM'] ?? '-').toString();

    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.appColors.primary.withAlpha(20),
              child: Icon(
                Icons.person_rounded,
                color: context.appColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    nim,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(dynamic record) {
    final r = record is Map<String, dynamic> ? record : <String, dynamic>{};
    final date = (r['date'] ?? r['created_at'] ?? r['tanggal'] ?? '-').toString();
    final note = (r['note'] ?? r['catatan'] ?? r['content'] ?? '-').toString();
    final type = (r['type'] ?? r['jenis'] ?? 'Konseling').toString();
    final status = (r['status'] ?? '-').toString();

    Color statusColor;
    if (status.toLowerCase().contains('selesai') ||
        status.toLowerCase().contains('completed')) {
      statusColor = AppColors.success;
    } else if (status.toLowerCase().contains('aktif') ||
        status.toLowerCase().contains('active')) {
      statusColor = AppColors.info;
    } else {
      statusColor = AppColors.neutral500;
    }

    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(15),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    type,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSm.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              date,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              note,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.neutral800,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
