import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorNoteDetailScreen extends StatefulWidget {
  final int noteId; // This is actually studentId
  const MentorNoteDetailScreen({super.key, required this.noteId});

  @override
  State<MentorNoteDetailScreen> createState() => _MentorNoteDetailScreenState();
}

class _MentorNoteDetailScreenState extends State<MentorNoteDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMenteeDetail(widget.noteId);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      AppSnackbar.showError(context, 'Catatan tidak boleh kosong');
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<MentorKencanaProvider>();
    final success = await provider.submitMenteeNotes(widget.noteId, text);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Catatan berhasil ditambahkan');
        _noteController.clear();
      } else {
        AppSnackbar.showError(context, 'Gagal menambahkan catatan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final menteeDetail = provider.menteeDetail;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Catatan Bimbingan',
            subtitle: 'Tulis dan tinjau catatan bimbingan berkala untuk mahasiswa.',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/mentor-kencana/notes');
              }
            },
          ),
          if (provider.isLoading && menteeDetail == null)
            const SliverFillRemaining(child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()))
          else if (menteeDetail == null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Data mahasiswa tidak ditemukan',
                  style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Profile Card
                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menteeDetail.name,
                              style: AppTextStyles.titleLg.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primary.withAlpha(15),
                                    borderRadius: AppRadius.radiusSm,
                                    border: Border.all(color: context.appColors.primary.withAlpha(30)),
                                  ),
                                  child: Text(
                                    menteeDetail.nim,
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.primary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${menteeDetail.faculty}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.outline,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Form Tambah Catatan Card
                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.add, color: context.appColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'TAMBAH CATATAN',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _noteController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Tulis progres, evaluasi, atau kendala mahasiswa disini...',
                                hintStyle: TextStyle(color: context.appColors.outline.withAlpha(150), fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                  borderSide: BorderSide(color: AppThemeColors.surfaceContainerHighest),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                  borderSide: BorderSide(color: AppThemeColors.surfaceContainerHighest),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                  borderSide: BorderSide(color: context.appColors.primary),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: BkuButton(
                                text: 'SIMPAN CATATAN',
                                icon: Icons.save_outlined,
                                isLoading: _isSubmitting,
                                onPressed: _submitNote,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Riwayat Catatan Card
                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, color: context.appColors.secondary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'RIWAYAT CATATAN (${menteeDetail.notes.length})',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (menteeDetail.notes.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 48,
                                        color: context.appColors.outline.withAlpha(80),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Belum ada catatan bimbingan',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.appColors.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tambahkan catatan pertama Anda menggunakan form di atas.',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.outline,
                                          fontSize: 11,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: menteeDetail.notes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final n = menteeDetail.notes[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: AppRadius.radiusMd,
                                      border: Border.all(color: AppThemeColors.surfaceContainerHighest),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.notes,
                                          style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurface),
                                        ),
                                        if (n.assessedAt.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            n.assessedAt,
                                            style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 9),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
