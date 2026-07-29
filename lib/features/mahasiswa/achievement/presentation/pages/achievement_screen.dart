import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/report_achievement_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import '../../../../../core/error/error_handler.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => student.loadAllData(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Prestasi Mahasiswa',
              subtitle: 'Riwayat & Penghargaan',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const FadeInAnimation(delay: 0.2, child: _RecapSection()),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeInAnimation(
                      delay: 0.4,
                      child: Text(
                        'Riwayat Prestasi',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (student.isLoading)
                      const BkuShimmerList(itemCount: 3, itemHeight: 120)
                    else if (student.achievements.isEmpty)
                      const FadeInAnimation(delay: 0.6, child: _EmptyState())
                    else
                      ...List.generate(student.achievements.length, (index) {
                        return FadeInAnimation(
                          delay: 0.6 + (index * 0.1),
                          child: _AchievementCard(
                            achievement: student.achievements[index],
                          ),
                        );
                      }),
                    const SizedBox(height: AppSpacing.s160),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BkuButton(
            text: 'Tambah Prestasi',
            icon: Icons.add_rounded,
            variant: BkuButtonVariant.success,
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportAchievementScreen(),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _RecapSection extends StatelessWidget {
  const _RecapSection();

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indeks Prestasi Kumulatif',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    student.ipk.toStringAsFixed(2),
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.neutral800,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusLg,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStat(
                  'Total',
                  '${student.totalAchievements}',
                  Icons.folder_shared_rounded,
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _buildStat(
                  'Valid',
                  '${student.validatedAchievements}',
                  Icons.verified_rounded,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStat(
                  'Pending',
                  '${student.pendingAchievements}',
                  Icons.pending_rounded,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStat(
                  'Synced',
                  '${student.syncedAchievements}',
                  Icons.sync_rounded,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.titleLg.copyWith(
            color: AppColors.neutral800,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final dynamic achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (achievement.status) {
      case 'Validated':
      case 'Diverifikasi':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
      case 'Ditolak':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty_rounded;
    }

    final date = achievement.date;
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () => _showAchievementDetail(context, achievement),
        borderRadius: AppRadius.radiusXl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusLg,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.neutral600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(15),
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: AppSpacing.s6),
                                  Text(
                                    achievement.status.toUpperCase(),
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (achievement.isSynced)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withAlpha(15),
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sync_rounded,
                                      color: Colors.teal,
                                      size: 12,
                                    ),
                                    const SizedBox(width: AppSpacing.s6),
                                    Text(
                                      'SIMKATMAWA',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          achievement.title,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          achievement.organizer,
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(height: 0),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _buildTag(context, Icons.layers_rounded, achievement.level),
                  const SizedBox(width: AppSpacing.lg),
                  _buildTag(
                    context,
                    Icons.workspace_premium_rounded,
                    achievement.rank,
                  ),
                  const Spacer(),
                  _buildTag(
                    context,
                    Icons.calendar_month_rounded,
                    formattedDate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, dynamic achievement) {
    Color statusColor;
    IconData statusIcon;
    String statusDesc;

    switch (achievement.status) {
      case 'Validated':
      case 'Diverifikasi':
        statusColor = AppColors.success;
        statusIcon = Icons.verified_rounded;
        statusDesc = 'Prestasi telah divalidasi oleh Kemahasiswaan.';
        break;
      case 'Rejected':
      case 'Ditolak':
        statusColor = AppColors.error;
        statusIcon = Icons.error_outline_rounded;
        statusDesc = 'Prestasi ditolak. Silakan cek kembali berkas Anda.';
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty_rounded;
        statusDesc = 'Prestasi sedang dalam proses review panitia.';
    }

    final date = achievement.date;
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                statusIcon,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.status.toUpperCase(),
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'Status Verifikasi',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          achievement.title,
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          achievement.organizer,
                          style: AppTextStyles.labelMd.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Detail Penghargaan',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDetailRow(
                          context,
                          Icons.layers_rounded,
                          'Tingkat',
                          achievement.level,
                        ),
                        _buildDetailRow(
                          context,
                          Icons.emoji_events_rounded,
                          'Pencapaian',
                          achievement.rank,
                        ),
                        _buildDetailRow(
                          context,
                          Icons.calendar_today_rounded,
                          'Tanggal',
                          formattedDate,
                        ),
                        _buildDetailRow(
                          context,
                          Icons.cloud_done_rounded,
                          'Simkatmawa',
                          achievement.isSynced
                              ? 'Sudah Sinkron'
                              : 'Belum Sinkron',
                          color:
                              achievement.isSynced
                                  ? Colors.teal
                                  : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Dokumen Sertifikat',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (achievement.certificateUrl != null)
                          BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withAlpha(10),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sertifikat_${achievement.id}.pdf',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Klik untuk melihat dokumen',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: AppRadius.radiusMd,
                                    onTap: () async {
                                      AppSnackbar.showSuccess(
                                        context,
                                        'Membuka sertifikat...',
                                      );
                                      try {
                                        final String fullUrl =
                                            ApiGate.getImageUrl(
                                              achievement.certificateUrl,
                                            );
                                        if (fullUrl.isEmpty) {
                                          throw Exception('URL kosong');
                                        }
                                        final Uri? url = Uri.tryParse(
                                          fullUrl.trim().replaceAll(' ', '%20'),
                                        );
                                        if (url == null) {
                                          throw Exception('URL tidak valid');
                                        }

                                        bool launched = await launchUrl(
                                          url,
                                          mode: LaunchMode.inAppBrowserView,
                                        );
                                        if (!launched) {
                                          launched = await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                          if (!launched) {
                                            launched = await launchUrl(
                                              url,
                                              mode: LaunchMode.platformDefault,
                                            );
                                          }
                                        }
                                        if (!launched) {
                                          throw Exception('Gagal membuka URL');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppSnackbar.showError(
                                            context,
                                            'Sertifikat belum tersedia atau link rusak',
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: AppSpacing.paddingSm,
                                      child: const Icon(
                                        Icons.visibility_rounded,
                                        color: AppColors.neutral800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(100),
                                  size: 32,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'File sertifikat belum tersedia atau belum diunggah.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(10),
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: statusColor,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  statusDesc,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (achievement.status == 'Pending' ||
                    achievement.status == 'Menunggu') ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: BkuButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ReportAchievementScreen(
                                        achievement: achievement,
                                      ),
                                ),
                              );
                            },
                            icon: Icons.edit_rounded,
                            text: 'Edit Laporan',
                            variant: BkuButtonVariant.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: BkuButton(
                            onPressed:
                                () => _confirmDelete(context, achievement.id),
                            icon: Icons.delete_outline_rounded,
                            text: 'Hapus',
                            variant: BkuButtonVariant.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: BkuButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icons.close_rounded,
                      text: 'Tutup',
                      variant: BkuButtonVariant.outline,
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: BkuButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icons.close_rounded,
                      text: 'Tutup',
                      variant: BkuButtonVariant.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            title: 'Hapus Laporan Prestasi?',
            content:
                'Apakah Anda yakin ingin menghapus laporan prestasi ini? Tindakan ini tidak dapat dibatalkan.',
            isDestructive: true,
            cancelText: 'Batal',
            confirmText: 'Ya, Hapus',
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              Navigator.pop(dialogContext);

              try {
                BkuLoadingDialog.show(context);
                await context.read<StudentProvider>().deleteAchievement(id);
                if (context.mounted) {
                  BkuLoadingDialog.hide(context);
                  Navigator.pop(context);
                  AppSnackbar.showSuccess(
                    context,
                    'Laporan prestasi berhasil dihapus',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  BkuLoadingDialog.hide(context);
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => CustomDialog(
                          title: 'Gagal Menghapus Data',
                          content: ErrorHandler.getMessage(e),
                          cancelText: '',
                          confirmText: 'Tutup',
                          onConfirm: () => Navigator.pop(ctx),
                          onCancel: () {},
                        ),
                  );
                }
              }
            },
          ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.outline.withAlpha(100),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMd.copyWith(
              color: color ?? AppColors.neutral900,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.outline, size: 14),
        const SizedBox(width: AppSpacing.s6),
        Text(
          text,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withAlpha(50),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada prestasi',
            style: AppTextStyles.titleLg.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Yuk, mulai lapor prestasi mandiri kamu!',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
