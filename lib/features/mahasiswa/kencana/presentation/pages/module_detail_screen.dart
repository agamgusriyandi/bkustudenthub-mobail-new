import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class ModuleDetailScreen extends StatelessWidget {
  final Mission mission;

  const ModuleDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Materi Modul',
            info: mission.title ?? '',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mission.fileUrl != null && mission.fileUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: InkWell(
                        onTap: () async {
                          final fullUrl = ApiGate.getImageUrl(mission.fileUrl);
                          final url = Uri.tryParse(fullUrl);
                          if (url != null && await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.inAppBrowserView,
                            );
                          } else {
                            if (context.mounted) {
                              AppSnackbar.showError(
                                context,
                                'Tidak dapat membuka tautan ini.',
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: AppRadius.radiusLg,
                            border: Border.all(
                              color: const Color(0xFF93C5FD),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: AppSpacing.padding10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.attach_file_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lampiran Materi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.s3),
                                    Text(
                                      'Ketuk untuk membuka file atau tautan',
                                      style: TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF2563EB),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Text(
                    mission.title ?? '',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Diposting oleh Panitia PKKMB Kencana',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    mission.content ?? 'Tidak ada deskripsi materi.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  BkuButton(
                    onPressed:
                        mission.isCompleted
                            ? null
                            : () async {
                              BkuLoadingDialog.show(
                                context,
                                message: 'Menyimpan progress...',
                              );
                              try {
                                final materialId =
                                    int.tryParse(mission.id ?? '') ?? 0;
                                final success = await context
                                    .read<KencanaProvider>()
                                    .completeMaterial(materialId);
                                if (context.mounted) {
                                  BkuLoadingDialog.hide(context);
                                }
                                if (success) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (dialogContext) => CustomDialog(
                                            title: 'Sukses!',
                                            content:
                                                'Materi telah selesai dipelajari!',
                                            cancelText: '',
                                            confirmText: 'Selesai',
                                            isSuccess: true,
                                            onConfirm: () {
                                              Navigator.pop(dialogContext);
                                              Navigator.pop(context, true);
                                            },
                                            onCancel: () {},
                                          ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    AppSnackbar.showError(
                                      context,
                                      'Gagal menyimpan progress materi.',
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  BkuLoadingDialog.hide(context);
                                }
                              }
                            },
                    text:
                        mission.isCompleted
                            ? 'Sudah Selesai Belajar'
                            : 'Tandai Selesai Belajar',
                    variant: BkuButtonVariant.success,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
