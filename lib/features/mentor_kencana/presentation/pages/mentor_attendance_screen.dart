import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorAttendanceScreen extends StatefulWidget {
  const MentorAttendanceScreen({super.key});

  @override
  State<MentorAttendanceScreen> createState() => _MentorAttendanceScreenState();
}

class _MentorAttendanceScreenState extends State<MentorAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchSessions();
      }
    });
  }

  void _showQrDialog(BuildContext context, String title, String qrToken) {
    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: 'QR Absensi\n$title',
            content: '',
            confirmText: 'Tutup',
            cancelText: '',
            onConfirm: () => Navigator.pop(context),
            onCancel: () {},
            customChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BkuCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: QrImageView(
                    data: qrToken,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Minta mahasiswa untuk scan QR Code ini dari aplikasi mereka.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  void _showManualAttendanceDialog(
    BuildContext context,
    int sessionId,
    String sessionTitle,
  ) {
    final nimController = TextEditingController();
    String status = 'Hadir';

    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: 'Absensi Manual',
              content: 'Input kehadiran mahasiswa untuk $sessionTitle',
              confirmText: 'Simpan',
              cancelText: 'Batal',
              isLoading: isSubmitting,
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                if (nimController.text.trim().isEmpty) return;
                setState(() => isSubmitting = true);
                final success = await context
                    .read<MentorKencanaProvider>()
                    .submitManualAttendance(
                      sessionId,
                      nimController.text.trim(),
                      status,
                    );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  AppSnackbar.showSuccess(context, 'Berhasil menyimpan absen');
                } else {
                  AppSnackbar.showError(context, 'Gagal menyimpan absen');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nimController,
                    decoration: InputDecoration(
                      labelText: 'NIM Mahasiswa',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: 'Status Kehadiran',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    items:
                        ['Hadir', 'Izin', 'Sakit', 'Alpa'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => status = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchSessions(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Absensi Sesi',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: false,

              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.assignment_ind_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.push('/mentor-kencana/absence-requests');
                  },
                ),
              ],
            ),
            if (provider.isLoading && provider.sessions.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && provider.sessions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (provider.sessions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada jadwal sesi aktif.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
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
                    final session = provider.sessions[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: [
                                    Colors.blue,
                                    Colors.green,
                                    Colors.orange,
                                    Colors.purple,
                                    Colors.teal,
                                    Colors.indigo,
                                  ][index % 6].withAlpha(15),
                                  borderRadius: AppRadius.radiusLg,
                                ),
                                child: Icon(
                                  Icons.event_available_rounded,
                                  color:
                                      [
                                        Colors.blue,
                                        Colors.green,
                                        Colors.orange,
                                        Colors.purple,
                                        Colors.teal,
                                        Colors.indigo,
                                      ][index % 6],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.title,
                                      style: AppTextStyles.titleLg.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session.stageName} • ${session.date}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kehadiran Mahasiswa',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session.attendanceCount} / ${session.totalMentees}',
                                      style: AppTextStyles.titleLg.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BkuButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (ctx) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );
                                    final token = await context
                                        .read<MentorKencanaProvider>()
                                        .fetchSessionQrToken(session.id);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      if (token != null && token.isNotEmpty) {
                                        _showQrDialog(
                                          context,
                                          session.title,
                                          token,
                                        );
                                      } else {
                                        AppSnackbar.showError(
                                          context,
                                          'Gagal memuat QR Code. Pastikan sesi aktif.',
                                        );
                                      }
                                    }
                                  },
                                  icon: Icons.qr_code_rounded,
                                  text: 'QR Code',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: BkuButton(
                              onPressed:
                                  () => _showManualAttendanceDialog(
                                    context,
                                    session.id,
                                    session.title,
                                  ),
                              icon: Icons.edit_note_rounded,
                              text: 'Input Absen Manual',
                              variant: BkuButtonVariant.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: provider.sessions.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
