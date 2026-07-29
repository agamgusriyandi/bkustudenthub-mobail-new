import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';

class KencanaBandingScreen extends StatefulWidget {
  const KencanaBandingScreen({super.key});

  @override
  State<KencanaBandingScreen> createState() => _KencanaBandingScreenState();
}

class _KencanaBandingScreenState extends State<KencanaBandingScreen> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaProvider>().fetchBandingList();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitBanding() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      AppSnackbar.showError(context, 'Alasan banding tidak boleh kosong');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    final provider = context.read<KencanaProvider>();
    final success = await provider.submitBanding(reason);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    BkuLoadingDialog.hide(context);

    if (success) {
      _reasonController.clear();
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Pengajuan banding berhasil dikirim');
    } else {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Gagal Mengirim Data',
              content: provider.errorMessage ?? 'Gagal mengajukan banding',
              cancelText: '',
              confirmText: 'Tutup',
              onCancel: () {},
              onConfirm: () => Navigator.pop(context),
              isDestructive: true,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const BkuAppBar(
            title: 'PENGAJUAN BANDING',
            subtitle: 'KENCANA',
            variant: AppBarVariant.student,
            expandedHeight: 100,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              left: AppSpacing.s20,
              right: AppSpacing.s20,
              bottom: AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Ajukan Banding',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Jika ada nilai yang tidak sesuai atau kamu merasa telah menyelesaikan syarat yang diminta, silakan ajukan banding di sini.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BkuCard(
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: Saya sudah mengumpulkan tugas di e-learning namun nilainya masih 0...',
                      hintStyle: AppTextStyles.bodySm.copyWith(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BkuButton(
                  onPressed: _submitBanding,
                  text: 'KIRIM BANDING',
                  isLoading: _isSubmitting,
                  variant: BkuButtonVariant.primary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Consumer<KencanaProvider>(
                  builder: (context, provider, _) {
                    if (provider.bandingList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: AppRadius.radiusLg,
                        ),
                        child: Text(
                          'Belum ada riwayat banding',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMd.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children:
                          provider.bandingList.map((banding) {
                            final rawStatus = banding['status'] ?? 'pending';
                            final alasan = banding['alasan'] ?? '';
                            Color statusColor = AppColors.warning;

                            // Map known english statuses to ID for label
                            String mappedStatus = rawStatus;
                            if (rawStatus.toLowerCase() == 'pending') {
                              mappedStatus = 'Menunggu';
                            }
                            if (rawStatus.toLowerCase() == 'approved') {
                              mappedStatus = 'Disetujui';
                            }
                            if (rawStatus.toLowerCase() == 'rejected') {
                              mappedStatus = 'Ditolak';
                            }

                            String statusLabel =
                                mappedStatus.toString().toTitleCase();

                            if (rawStatus.toLowerCase() == 'approved') {
                              statusColor = AppColors.success;
                            } else if (rawStatus.toLowerCase() == 'rejected') {
                              statusColor = AppColors.error;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: context.appColors.surface,
                                borderRadius: AppRadius.radiusLg,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withAlpha(50),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        banding['created_at']
                                                ?.toString()
                                                .split('T')
                                                .first ??
                                            '',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(20),
                                          borderRadius: AppRadius.radiusSm,
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    alasan,
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
