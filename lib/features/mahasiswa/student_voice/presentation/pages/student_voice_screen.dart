import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_voice_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/submit_aspiration_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_detail_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentVoiceScreen extends StatefulWidget {
  const StudentVoiceScreen({super.key});

  @override
  State<StudentVoiceScreen> createState() => _StudentVoiceScreenState();
}

class _StudentVoiceScreenState extends State<StudentVoiceScreen> {
  String _selectedFilter = 'Semua';

  bool _isLocalFile(String? path) {
    if (path == null) return false;
    if (path.startsWith('file://')) return true;
    if (path.startsWith('/')) {
      if (path.startsWith('/uploads/') || path.startsWith('/storage/')) {
        return false;
      }
      try {
        return File(path).existsSync();
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentVoiceProvider>();
    final filteredAspirations =
        student.aspirations
            .where(
              (a) =>
                  _selectedFilter == 'Semua' || a.category == _selectedFilter,
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          BkuAppBar(
            title: 'Aspirasi Mahasiswa',
            subtitle: 'SUARA & SARAN',
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
                  const FadeInAnimation(delay: 0.2, child: _AspirationBanner()),
                  const SizedBox(height: AppSpacing.xxl),
                  if (student.isLoading)
                    const BkuShimmer(
                      width: double.infinity,
                      height: 120,
                      borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
                    )
                  else
                    FadeInAnimation(
                      delay: 0.4,
                      child: _buildStatsDashboard(student),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeInAnimation(
                    delay: 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Aspirasimu',
                          style: AppTextStyles.titleLg.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Lihat Semua',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeInAnimation(delay: 0.7, child: _buildCategoryFilter()),
                  const SizedBox(height: AppSpacing.lg),
                  if (student.isLoading)
                    const BkuShimmerList(itemCount: 2, itemHeight: 120)
                  else if (filteredAspirations.isEmpty)
                    FadeInAnimation(delay: 0.8, child: _buildEmptyState())
                  else
                    ...List.generate(
                      filteredAspirations.length,
                      (index) => FadeInAnimation(
                        delay: 0.8 + (index * 0.1),
                        child: _buildAspirationCard(filteredAspirations[index]),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(StudentVoiceProvider student) {
    return Row(
      children: [
        _buildStatCard(
          'Terkirim',
          student.totalAspirations.toString(),
          Icons.send_rounded,
          AppColors.info,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          'Diproses',
          student.pendingAspirations.toString(),
          Icons.sync_rounded,
          AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          'Selesai',
          student.resolvedAspirations.toString(),
          Icons.task_alt_rounded,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.neutral200.withAlpha(150)),
        ),
        child: Column(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.titleLg.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral600,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'Semua',
      'Akademik',
      'Fasilitas',
      'Kemahasiswaan',
      'Saran & Ide',
      'Lainnya',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((cat) {
              bool isSelected = _selectedFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = cat);
                  },
                  selectedColor: AppColors.neutral100,
                  labelStyle: AppTextStyles.labelSm.copyWith(
                    color:
                        isSelected
                            ? AppColors.neutral800
                            : context.appColors.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: context.appColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                    side: BorderSide(
                      color:
                          isSelected
                              ? AppColors.neutral800
                              : AppColors.neutral200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAspirationCard(Aspiration asp) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => StudentVoiceDetailScreen(aspirationId: asp.id),
              ),
            );
          },
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Text(
                        asp.category,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(asp.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asp.title,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            asp.description,
                            style: AppTextStyles.labelSm.copyWith(
                          color:
                                   context.appColors.onSurfaceVariant,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (asp.imageUrl != null && asp.imageUrl!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.lg),
                      if (asp.imageUrl!.toLowerCase().endsWith('.pdf'))
                        InkWell(
                          onTap: () async {
                            final url = Uri.parse(
                              ApiGate.getImageUrl(asp.imageUrl),
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.inAppBrowserView,
                              );
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.appColors.primary.withAlpha(10),
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: context.appColors.primary.withAlpha(20),
                              ),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: context.appColors.primary,
                              size: 28,
                            ),
                          ),
                        )
                      else if (_isLocalFile(asp.imageUrl))
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.radiusMd,
                            image: DecorationImage(
                              image: FileImage(
                                File(asp.imageUrl!.replaceFirst('file://', '')),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.radiusMd,
                            image: DecorationImage(
                              image: NetworkImage(
                                ApiGate.getImageUrl(asp.imageUrl),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                if (asp.feedback != null) ...[
                  const SizedBox(height: AppSpacing.s20),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(10),
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(
                        color: AppColors.success.withAlpha(20),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BALASAN KAMPUS:',
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                asp.feedback!,
                                style: AppTextStyles.labelSm.copyWith(
                               color:
                                       context.appColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(asp.date),
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.appColors.outline,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
        color = AppColors.warning;
        text = 'MENUNGGU';
        break;
      case 'in progress':
      case 'diproses':
      case 'proses':
        color = AppColors.info;
        text = 'PROSES';
        break;
      case 'resolved':
      case 'selesai':
        color = AppColors.success;
        text = 'SELESAI';
        break;
      case 'rejected':
      case 'ditolak':
        color = AppColors.error;
        text = 'DITOLAK';
        break;
      default:
        color = context.appColors.outline;
        text = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 8,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: context.appColors.outline.withAlpha(50),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada riwayat aspirasi',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AspirationBanner extends StatelessWidget {
  const _AspirationBanner();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: themeProvider.primary.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: themeProvider.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suarakan Aspirasimu',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.neutral900,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Setiap suara berharga untuk BKU.',
                      style: AppTextStyles.labelSm.copyWith(
                        color: themeProvider.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: BkuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitAspirationScreen(),
                  ),
                );
              },
              text: 'Tulis Aspirasi Sekarang',
            ),
          ),
        ],
      ),
    );
  }
}
