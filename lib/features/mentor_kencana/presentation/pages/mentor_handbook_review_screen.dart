import 'dart:convert';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
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
    final isPascaKencanaActive = provider.progressData?['is_pasca_kencana_active'] == true;
    
    if (provider.isLoading && mentee == null) {
      return const Scaffold(body: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()));
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
              'Review Handbook: ${mentee.name.isNotEmpty ? mentee.name : widget.studentName}',
              style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.w900, color: context.appColors.onSurface),
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
                      Icon(Icons.menu_book_rounded, color: context.appColors.onSurface, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Isian Handbook',
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
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: const BoxDecoration(
                                color: AppColors.neutral100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_late_outlined,
                                size: 36,
                                color: AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Mahasiswa Belum Mengirimkan Handbook',
                              style: AppTextStyles.labelMd.copyWith(
                                color: context.appColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Isian handbook akan secara otomatis ditampilkan di sini setelah dikirimkan oleh mahasiswa.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.neutral500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Builder(
                      builder: (context) {
                        Map<String, dynamic>? contentMap;
                        if (handbookData['content_json'] != null) {
                          var raw = handbookData['content_json'];
                          if (raw is Map<String, dynamic>) {
                            contentMap = raw;
                          } else if (raw is String) {
                            try {
                              contentMap = Map<String, dynamic>.from(jsonDecode(raw));
                            } catch (_) {}
                          }
                        }

                        if (contentMap == null || contentMap.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                'Data handbook tidak tersedia.',
                                style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BkuCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status Pengiriman',
                                        style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        handbookData['status'].toString().toUpperCase(),
                                        style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                  if (handbookData['submitted_at'] != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Tanggal Submit',
                                          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          handbookData['submitted_at'].toString().split('T')[0], // Simplified date
                                          style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Isi Ringkasan Handbook:',
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...contentMap.entries.map((e) {
                              return BkuCard(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.key.replaceAll('_', ' ').toUpperCase(),
                                      style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      e.value.toString(),
                                      style: AppTextStyles.bodySm.copyWith(color: context.appColors.onSurface, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
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
                      Icon(Icons.fact_check_outlined, color: context.appColors.onSurface, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Keputusan Evaluasi',
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
                  if (!isPascaKencanaActive) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Penilaian handbook tidak dapat dilakukan. Tahap Pasca Kencana belum aktif.',
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.onErrorContainer, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  Text(
                    'Status Persetujuan',
                    style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: context.appColors.outline, fontSize: 10.5),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  BkuDropdown<String>(
                    initialValue: _reviewStatus,
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurface, fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      enabled: isPascaKencanaActive,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Setujui (Approved)', style: AppTextStyles.labelSm.copyWith(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Perlu Perbaikan (Rejected)', style: AppTextStyles.labelSm.copyWith(fontSize: 12)),
                      ),
                    ],
                    onChanged: isPascaKencanaActive ? (val) {
                      if (val != null) setState(() => _reviewStatus = val);
                    } : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'FEEDBACK / CATATAN',
                    style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: context.appColors.outline, fontSize: 10),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  BkuTextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    enabled: isPascaKencanaActive,
                    style: AppTextStyles.labelSm.copyWith(fontSize: 12),
                    hint: 'Tuliskan catatan perbaikan...',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Center(
                    child: BkuButton(
                      onPressed: isPascaKencanaActive ? _submitReview : null,
                      text: 'Simpan Evaluasi',
                      icon: Icons.save_rounded,
                      isLoading: _isSubmitting,
                      fullWidth: false,
                      width: 200,
                      customBgColor: isPascaKencanaActive ? AppColors.success : AppColors.neutral500,
                      customFgColor: AppColors.onSuccess,
                    ),
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
