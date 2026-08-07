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
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:intl/intl.dart';

class TkPatientRecordScreen extends StatefulWidget {
  final int patientId;
  final String? patientName;

  const TkPatientRecordScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<TkPatientRecordScreen> createState() => _TkPatientRecordScreenState();
}

class _TkPatientRecordScreenState extends State<TkPatientRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkPatientProvider>().loadPatientMedicalRecord(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: widget.patientName ?? 'Rekam Medis',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Consumer<TkPatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingRecord) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 4, itemHeight: 120),
            );
          }

          final patient = provider.selectedPatient;
          final records = provider.medicalRecords;

          if (patient == null && records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 64, color: AppColors.neutral300),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Data pasien tidak ditemukan',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Patient Info
              if (patient != null) _buildPatientInfo(patient),
              const SizedBox(height: AppSpacing.xl),

              // Medical Records
              _buildSectionHeader('Riwayat Pemeriksaan', records.length),
              const SizedBox(height: AppSpacing.md),

              if (records.isEmpty)
                _buildEmptyRecords()
              else
                ...records.map((r) => _buildRecordCard(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientInfo(Patient patient) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.appColors.primary.withAlpha(20),
            child: Text(
              patient.initials,
              style: TextStyle(
                color: context.appColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.nama,
                  style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${patient.nim} • ${patient.prodi}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _buildTag(patient.fakultas),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTag('Sem ${patient.semester}'),
                    if (patient.golonganDarah != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag('Goldar ${patient.golonganDarah}'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.neutral600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: context.appColors.primary.withAlpha(20),
            borderRadius: AppRadius.radiusFull,
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRecords() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.medical_information_outlined, size: 48, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada riwayat pemeriksaan',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
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
              Text(
                dateStr,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  record.statusCategory,
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildVitalRow('Tekanan Darah', record.tekananDarah),
          _buildVitalRow('SpO2', '${record.spO2}%'),
          _buildVitalRow('Suhu', '${record.suhuTubuh}°C'),
          _buildVitalRow('Nadi', '${record.denyutNadi} bpm'),
          _buildVitalRow('BMI', '${record.bmi.toStringAsFixed(1)} (${record.bmiCategory})'),
          if (record.hasil != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.neutral200),
            _buildVitalRow('Hasil', record.hasil!),
          ],
          if (record.catatan != null && record.catatan!.isNotEmpty) ...[
            _buildVitalRow('Catatan', record.catatan!),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500)),
          Text(value, style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
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
