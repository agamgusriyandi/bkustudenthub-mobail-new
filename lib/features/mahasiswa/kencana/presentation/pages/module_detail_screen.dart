import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class ModuleDetailScreen extends StatelessWidget {
  final Mission mission;

  const ModuleDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
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
                  if (mission.fileUrl != null && mission.fileUrl!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        onTap: () async {
                          final rawPath = mission.fileUrl!.trim();
                          final fullUrl = rawPath.startsWith('http')
                              ? rawPath
                              : ApiGate.getImageUrl(rawPath);
                          final url = Uri.tryParse(fullUrl);
                          if (url != null) {
                            try {
                              bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                              if (!launched) {
                                launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                              }
                              if (!launched && context.mounted) {
                                AppSnackbar.showError(context, 'Tidak dapat membuka file.');
                              }
                            } catch (_) {
                              if (context.mounted) AppSnackbar.showError(context, 'Error membuka file.');
                            }
                          }
                        },
child: Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: BkuTheme.slateSoft,
                              borderRadius: BkuTheme.r16,
                              border: Border.all(color: BkuTheme.border, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: BkuTheme.textHeading, shape: BoxShape.circle),
                                  child: const Icon(Icons.attach_file_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.s14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('File Dokumen / Lampiran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: BkuTheme.textHeading)),
                                      SizedBox(height: AppSpacing.s3),
                                      Text('Ketuk untuk mengunduh / membuka file', style: TextStyle(color: BkuTheme.textMuted, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: BkuTheme.textHeading, size: 22),
                              ],
                            ),
                          ),
                      ),
                    ),
                  if (mission.linkUrl != null && mission.linkUrl!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: InkWell(
                        onTap: () async {
                          String rawUrl = mission.linkUrl!.trim();
                          if (!rawUrl.startsWith('http')) {
                            rawUrl = 'https://$rawUrl';
                          }
                          final url = Uri.tryParse(rawUrl);
                          if (url != null) {
                            try {
                              bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                              if (!launched) {
                                launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                              }
                              if (!launched && context.mounted) {
                                AppSnackbar.showError(context, 'Tidak dapat membuka tautan link.');
                              }
                            } catch (_) {
                              if (context.mounted) AppSnackbar.showError(context, 'Error membuka tautan link.');
                            }
                          }
                        },
child: Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: BkuTheme.indigoSoft,
                              borderRadius: BkuTheme.r16,
                              border: Border.all(color: BkuTheme.indigoBorder, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: BkuTheme.indigo, shape: BoxShape.circle),
                                  child: const Icon(Icons.link_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tautan Web Eksternal', style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, color: BkuTheme.indigo)),
                                      const SizedBox(height: 2),
                                      Text(mission.linkUrl!, style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: BkuTheme.indigo, size: 22),
                              ],
                            ),
                          ),
                      ),
                    ),
                  Text(
                    mission.title ?? '',
                    style: BkuTheme.textPageTitle.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Diposting oleh Panitia PKKMB Kencana',
                    style: BkuTheme.textCardSubtitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    mission.content ?? 'Tidak ada deskripsi materi.',
                    style: BkuTheme.textBodyRegular.copyWith(height: 1.6),
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
                                    BkuDialog.show(
                                      context: context,
                                      type: BkuDialogType.success,
                                      title: 'Sukses!',
                                      message: 'Materi telah selesai dipelajari!',
                                      primaryButtonText: 'Selesai',
                                      onPrimaryPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context, true);
                                      },
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
