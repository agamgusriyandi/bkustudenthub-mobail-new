import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

class MentorAbsenceRequestsScreen extends StatefulWidget {
  const MentorAbsenceRequestsScreen({super.key});

  @override
  State<MentorAbsenceRequestsScreen> createState() =>
      _MentorAbsenceRequestsScreenState();
}

class _MentorAbsenceRequestsScreenState
    extends State<MentorAbsenceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchAbsenceRequests();
      }
    });
  }

  void _respondRequest(int id, String status) async {
    final provider = context.read<MentorKencanaProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => CustomDialog(
            title: status == 'Approved' ? 'Setujui Izin' : 'Tolak Izin',
            content:
                status == 'Approved'
                    ? 'Apakah Anda yakin ingin menyetujui permohonan izin ini?'
                    : 'Apakah Anda yakin ingin menolak permohonan izin ini?',
            cancelText: 'Batal',
            confirmText: status == 'Approved' ? 'Setujui' : 'Tolak',
            isDestructive: status == 'Rejected',
            isSuccess: status == 'Approved',
            onCancel: () => Navigator.pop(ctx, false),
            onConfirm: () => Navigator.pop(ctx, true),
          ),
    );

    if (confirmed == true) {
      final success = await provider.respondAbsenceRequest(id, status);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Permohonan berhasil diperbarui'
                : 'Gagal memproses permohonan',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final requests = provider.absenceRequests;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAbsenceRequests(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Surat Izin Mahasiswa',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () => context.pop(),
            ),
            if (provider.isLoading && requests.isEmpty)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null && requests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: context.appColors.error,
                    ),
                  ),
                ),
              )
            else if (requests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada permohonan izin.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final req = requests[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.studentName,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      req.status == 'Pending'
                                          ? AppColors.warning.withAlpha(15)
                                          : req.status == 'Approved'
                                          ? AppColors.success.withAlpha(15)
                                          : AppColors.error.withAlpha(15),
                                  border: Border.all(
                                    color:
                                        req.status == 'Pending'
                                            ? AppColors.warning.withAlpha(30)
                                            : req.status == 'Approved'
                                            ? AppColors.success.withAlpha(30)
                                            : AppColors.error.withAlpha(30),
                                  ),
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Text(
                                  req.status,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        req.status == 'Pending'
                                            ? AppColors.warning
                                            : req.status == 'Approved'
                                            ? AppColors.success
                                            : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            req.nim,
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.outline,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Sesi: ${req.sessionTitle}',
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            'Tanggal: ${req.date}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.outline,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color:
                                    AppThemeColors.surfaceContainerHighest,
                              ),
                            ),
                            child: Text(
                              req.reason,
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                          ),
                          if (req.status == 'Pending') ...[
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: BkuButton(
                                    onPressed:
                                        provider.isLoading
                                            ? null
                                            : () => _respondRequest(
                                              req.id,
                                              'Rejected',
                                            ),
                                    variant: BkuButtonVariant.danger,
                                    text: 'Tolak',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: BkuButton(
                                    onPressed:
                                        provider.isLoading
                                            ? null
                                            : () => _respondRequest(
                                              req.id,
                                              'Approved',
                                            ),
                                    variant: BkuButtonVariant.success,
                                    text: 'Setujui',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }, childCount: requests.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
