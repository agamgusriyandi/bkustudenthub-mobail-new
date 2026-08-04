import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorHandbookReviewScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  
  const MentorHandbookReviewScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<MentorHandbookReviewScreen> createState() => _MentorHandbookReviewScreenState();
}

class _MentorHandbookReviewScreenState extends State<MentorHandbookReviewScreen> {
  String _reviewStatus = 'approved';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMenteeDetail(widget.studentId);
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final provider = context.read<MentorKencanaProvider>();
    final handbookData = provider.handbookData;
    
    if (handbookData == null || handbookData['status'] == 'not_started') {
      AppSnackbar.showError(context, 'Mahasiswa belum membuat atau mengirimkan handbook.');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await provider.reviewHandbook(
      studentId: widget.studentId,
      action: _reviewStatus,
      feedback: _feedbackController.text,
    );
    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        AppSnackbar.showSuccess(context, 'Review handbook berhasil disimpan!');
        context.pop();
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan review handbook');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final mentee = provider.menteeDetail;
    final handbookData = provider.handbookData;
    
    if (provider.isLoading && mentee == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (mentee == null) {
      return Scaffold(
        backgroundColor: context.appColors.surface,
        body: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'Review Handbook',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () => context.pop(),
            ),
            const SliverFillRemaining(
              child: Center(child: Text('Data mahasiswa tidak ditemukan')),
            ),
          ],
        ),
      );
    }

    final isNotStarted = handbookData == null || handbookData['status'] == 'not_started';

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Review Handbook',
            subtitle: mentee.name,
            variant: AppBarVariant.student,
            isExpandable: false,
            showBackButton: true,
            onBack: () => context.pop(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Header
            Text(
              'Review Handbook: ${mentee.name.toUpperCase()}',
              style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.w900, color: context.appColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: ${mentee.nim} • ${mentee.faculty}',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Left Section equivalent: ISIAN HANDBOOK
            BkuCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: context.appColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'ISIAN HANDBOOK',
                        style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review isian handbook yang telah dikumpulkan mahasiswa.',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (isNotStarted)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl * 2),
                        child: Column(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 48, color: context.appColors.warning),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'MAHASISWA BELUM MENGIRIMKAN HANDBOOK',
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.warning,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Here we'd render the actual JSON handbook content, 
                    // for now placeholder since the web just maps over content_json.
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Data handbook tersedia untuk direview.',
                          style: AppTextStyles.labelMd.copyWith(color: context.appColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),

            // Right Section equivalent: KEPUTUSAN EVALUASI
            BkuCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fact_check_outlined, color: context.appColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'KEPUTUSAN EVALUASI',
                        style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sebagai Fasilitator, Anda wajib memverifikasi keabsahan handbook sebelum menyetujuinya.',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Example Warning Block if not active
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.neutral300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_rounded, size: 16, color: context.appColors.outline),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Penilaian handbook tidak dapat dilakukan. Tahap Pasca Kencana belum aktif.',
                            style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'STATUS PERSETUJUAN',
                    style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: context.appColors.outline, fontSize: 10),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    initialValue: _reviewStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'approved', child: Text('Setujui (Approved)')),
                      DropdownMenuItem(value: 'rejected', child: Text('Perlu Perbaikan (Rejected)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _reviewStatus = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'FEEDBACK / CATATAN',
                    style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: context.appColors.outline, fontSize: 10),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan perbaikan...',
                      border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  BkuButton(
                    onPressed: _submitReview,
                    text: 'SIMPAN EVALUASI',
                    icon: Icons.save_rounded,
                    isLoading: _isSubmitting,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    ),
  ],
),
);
  }
}
