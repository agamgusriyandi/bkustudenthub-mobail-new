import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:printing/printing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const MedicalRecordDetailScreen({super.key, required this.record});

  String _val(List<String> keys, {String fallback = '-'}) {
    for (final k in keys) {
      final v = record[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final psychologist = _val(['psychologist', 'NamaKonselor', 'nama_konselor']);
    final type = _val(['type', 'tipe']);
    final dateStr = _val(['display_date'], fallback: _val(['date']));
    final timeStr = _val(['time', 'jam_mulai']);
    final diagnosis = _val(['diagnosis', 'icd10_description', 'kesimpulan'], fallback: 'Encrypted');
    final recommendation = _val(['recommendation', 'rekomendasi']);
    final observation = _val(['observation', 'observasi']);
    final bookingId = _val(['booking_id', 'id']);

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: BkuStaticAppBar(
        title: 'Rekam Medis Konseling',
        subtitle: 'Care & Support',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: context.appColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.appColors.primaryContainer.withValues(alpha: 0.12),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          color: context.appColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              psychologist,
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (type.isNotEmpty)
                              Text(
                                type,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _metaRow(Icons.event_rounded, dateStr),
                  if (timeStr.isNotEmpty) _metaRow(Icons.access_time_rounded, timeStr),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              context,
              title: 'Observasi Psikolog',
              icon: Icons.visibility_rounded,
              child: Text(
                observation.isEmpty ? '-' : observation,
                style: AppTextStyles.bodyMd.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'Diagnosis',
              icon: Icons.medical_information_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.appColors.warningContainer,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 11,
                      color: context.appColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Encrypted',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.warningContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: context.appColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  diagnosis,
                  style: AppTextStyles.bodyMd.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'Rekomendasi',
              icon: Icons.lightbulb_rounded,
              child: Text(
                recommendation.isEmpty ? '-' : recommendation,
                style: AppTextStyles.bodyMd.copyWith(height: 1.6, fontWeight: FontWeight.w500),
              ),
            ),
            if (bookingId.isNotEmpty && bookingId != '-') ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.neutral600),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Rekam medis ini terkait dengan sesi #$bookingId dan bersifat rahasia sesuai dengan standar privasi BKU.',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _openPdf(context),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Unduh Laporan Rekam Medis (PDF)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BkuTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(icon, size: 13, color: context.appColors.outline),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: context.appColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.appColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.appColors.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    final id = _val(['id', 'booking_id']);
    if (id.isEmpty || id == '-') return;

    try {
      AppSnackbar.showInfo(context, 'Menyiapkan berkas rekam medis...');
      final response = await ApiClient().client.get<List<int>>(
        '/counseling/session-notes/$id/export-pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && response.data!.isNotEmpty) {
        final bytes = Uint8List.fromList(response.data!);
        await Printing.layoutPdf(
          name: 'Rekam_Medis_Sesi_#$id.pdf',
          onLayout: (format) async => bytes,
        );
      } else {
        if (context.mounted) AppSnackbar.showError(context, 'Berkas rekam medis kosong atau tidak dapat diunduh.');
      }
    } catch (_) {
      if (context.mounted) AppSnackbar.showError(context, 'Gagal mengunduh berkas rekam medis');
    }
  }
}
