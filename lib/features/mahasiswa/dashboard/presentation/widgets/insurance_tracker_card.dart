import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';

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

    return BkuCard.doubleBezel(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: context.appColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Klaim Asuransi',
                    style: AppTextStyles.eyebrowSmall.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                  Text(
                    claim.jenisProvider.replaceAll('_', ' '),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.appColors.onSurface,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildStatusBadge(context, status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Faskes: ${claim.lokasiFaskes}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Horizontal Stepper
          Row(
            children: [
              _buildStepNode(
                context: context,
                step: 1,
                activeStep: currentStep,
                label: 'Diajukan',
                isRejected: false,
              ),
              _buildStepLine(active: currentStep >= 2),
              _buildStepNode(
                context: context,
                step: 2,
                activeStep: currentStep,
                label: 'Verifikasi TK',
                isRejected: false,
              ),
              _buildStepLine(active: currentStep >= 3 && !isRejected),
              _buildStepNode(
                context: context,
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    BkuStatus bkuStatus = BkuStatus.info;
    String label = 'Diajukan';

    if (status == 'PENDING_VERIFICATION') {
      bkuStatus = BkuStatus.warning;
      label = 'Proses Awal';
    } else if (status == 'APPROVED_TK') {
      bkuStatus = BkuStatus.info;
      label = 'Verifikasi TK';
    } else if (status == 'APPROVED_FINAL' || status == 'FINAL') {
      bkuStatus = BkuStatus.success;
      label = 'Disetujui';
    } else if (status == 'REJECTED') {
      bkuStatus = BkuStatus.error;
      label = 'Ditolak';
    }

    return BkuStatusBadge(
      status: bkuStatus,
      customText: label,
      showIcon: false,
    );
  }

  Widget _buildStepNode({
    required BuildContext context,
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
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: context.appColors.surface,
      ),
    );

    if (isRejected && step == 3) {
      nodeColor = AppColors.danger;
      icon = Icon(
        Icons.close_rounded,
        color: context.appColors.surface,
        size: 12,
      );
    } else if (isCompleted) {
      nodeColor = AppColors.success;
      icon = Icon(
        Icons.check_rounded,
        color: context.appColors.surface,
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
