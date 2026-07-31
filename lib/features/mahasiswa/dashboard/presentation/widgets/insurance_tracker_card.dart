import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class InsuranceTrackerCard extends StatelessWidget {
  final List<InsuranceClaim> claims;

  const InsuranceTrackerCard({
    super.key,
    required this.claims,
  });

  @override
  Widget build(BuildContext context) {
    if (claims.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the latest claim
    final claim = claims.first;
    final status = claim.status;

    // Steps configuration based on status
    int currentStep = 1;
    bool isRejected = status == 'REJECTED';
    
    if (status == 'APPROVED_TK') {
      currentStep = 2;
    } else if (status == 'APPROVED_FINAL' || status == 'FINAL') {
      currentStep = 3;
    } else if (status == 'REJECTED') {
      currentStep = 3;
    }

    String statusText = 'Menunggu verifikasi Tenaga Kesehatan';
    if (status == 'APPROVED_TK') {
      statusText = 'Disetujui Tenaga Kesehatan. Menunggu persetujuan akhir.';
    } else if (status == 'APPROVED_FINAL' || status == 'FINAL') {
      statusText = 'Klaim disetujui secara final.';
    } else if (status == 'REJECTED') {
      statusText = 'Klaim ditolak. Catatan: ${claim.catatanReview ?? "-"}';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_rounded,
                color: context.appColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Status Klaim Asuransi',
                style: AppTextStyles.titleLg.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            claim.jenisProvider.replaceAll('_', ' '),
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
          Text(
            'Faskes: ${claim.lokasiFaskes}',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral50,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Horizontal Stepper
          Row(
            children: [
              _buildStepNode(
                step: 1,
                activeStep: currentStep,
                label: 'Diajukan',
                isRejected: false,
              ),
              _buildStepLine(active: currentStep >= 2),
              _buildStepNode(
                step: 2,
                activeStep: currentStep,
                label: 'Verifikasi TK',
                isRejected: false,
              ),
              _buildStepLine(active: currentStep >= 3 && !isRejected),
              _buildStepNode(
                step: 3,
                activeStep: currentStep,
                label: isRejected ? 'Ditolak' : 'Selesai',
                isRejected: isRejected,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isRejected
                  ? AppColors.danger.withValues(alpha: 0.05)
                  : AppColors.neutral50,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: isRejected
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : AppColors.neutral200,
              ),
            ),
            child: Text(
              statusText,
              style: AppTextStyles.labelSm.copyWith(
                fontSize: 11,
                color: isRejected ? AppColors.danger : AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.neutral100;
    Color text = AppColors.neutral600;
    String label = 'Diajukan';

    if (status == 'PENDING_VERIFICATION') {
      bg = Colors.amber.shade50;
      text = Colors.amber.shade800;
      label = 'Proses Awal';
    } else if (status == 'APPROVED_TK') {
      bg = Colors.blue.shade50;
      text = Colors.blue.shade800;
      label = 'Verifikasi TK';
    } else if (status == 'APPROVED_FINAL' || status == 'FINAL') {
      bg = Colors.green.shade50;
      text = Colors.green.shade800;
      label = 'Disetujui';
    } else if (status == 'REJECTED') {
      bg = Colors.red.shade50;
      text = Colors.red.shade800;
      label = 'Ditolak';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs - 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          fontSize: 9,
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepNode({
    required int step,
    required int activeStep,
    required String label,
    required bool isRejected,
  }) {
    bool isCompleted = activeStep > step;
    bool isActive = activeStep == step;

    Color nodeColor = AppColors.neutral300;
    Widget icon = Text(
      '$step',
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    if (isRejected && step == 3) {
      nodeColor = AppColors.danger;
      icon = const Icon(
        Icons.close_rounded,
        color: Colors.white,
        size: 12,
      );
    } else if (isCompleted) {
      nodeColor = AppColors.success;
      icon = const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 12,
      );
    } else if (isActive) {
      nodeColor = AppColors.primary;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 9,
              color: isActive || isCompleted
                  ? AppColors.neutral800
                  : AppColors.neutral500,
              fontWeight:
                  isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool active}) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: active ? AppColors.success : AppColors.neutral300,
    );
  }
}
