import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_voice_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/submit_aspiration_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_detail_screen.dart';

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
    final filteredAspirations = student.aspirations
        .where((a) => _selectedFilter == 'Semua' || a.category == _selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Aspirasi Mahasiswa',
            subtitle: 'Suara, Saran & Masukan Kampus',
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
                  const FadeInAnimation(delay: 0.1, child: _AspirationBanner()),
                  const SizedBox(height: AppSpacing.xl),
                  if (student.isLoading)
                    const BkuShimmer(
                      width: double.infinity,
                      height: 90,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    )
                  else
                    FadeInAnimation(
                      delay: 0.15,
                      child: _buildStatsDashboard(student),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeInAnimation(
                    delay: 0.2,
                    child: Text(
                      'Riwayat Aspirasimu',
                      style: BkuTheme.textSectionTitle.copyWith(
                        fontSize: 14,
                        color: BkuTheme.textHeading,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FadeInAnimation(delay: 0.25, child: _buildCategoryFilter()),
                  const SizedBox(height: AppSpacing.md),
                  if (student.isLoading)
                    const BkuShimmerList(itemCount: 2, itemHeight: 120)
                  else if (filteredAspirations.isEmpty)
                    FadeInAnimation(delay: 0.3, child: _buildEmptyState())
                  else
                    ...List.generate(
                      filteredAspirations.length,
                      (index) => FadeInAnimation(
                        delay: 0.05 + (index * 0.04),
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
        Expanded(
          child: _buildKpiCard(
            label: 'Terkirim',
            value: student.totalAspirations.toString(),
            icon: Icons.send_rounded,
            color: BkuTheme.indigo,
            bgColor: BkuTheme.indigoSoft,
            borderColor: BkuTheme.indigoBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard(
            label: 'Diproses',
            value: student.pendingAspirations.toString(),
            icon: Icons.sync_rounded,
            color: BkuTheme.amber,
            bgColor: BkuTheme.amberSoft,
            borderColor: BkuTheme.amberBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard(
            label: 'Selesai',
            value: student.resolvedAspirations.toString(),
            icon: Icons.task_alt_rounded,
            color: BkuTheme.emerald,
            bgColor: BkuTheme.emeraldSoft,
            borderColor: BkuTheme.emeraldBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: BkuTheme.textKpiValue.copyWith(
              fontSize: 20,
              color: BkuTheme.textHeading,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: BkuTheme.textCaption.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: BkuTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = cat),
              borderRadius: BkuTheme.rPill,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                decoration: BoxDecoration(
                  color: isSelected ? BkuTheme.primary : BkuTheme.cardSurface,
                  borderRadius: BkuTheme.rPill,
                  border: Border.all(
                    color: isSelected ? BkuTheme.primary : BkuTheme.border,
                  ),
                  boxShadow: isSelected ? BkuTheme.cardShadow : null,
                ),
                child: Text(
                  cat,
                  style: BkuTheme.textCaption.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : BkuTheme.textHeading,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAspirationCard(Aspiration asp) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentVoiceDetailScreen(aspirationId: asp.id),
              ),
            );
          },
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BkuTheme.borderSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asp.category,
                        style: BkuTheme.textBadge.copyWith(
                          color: BkuTheme.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(asp.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asp.title,
                            style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            asp.description,
                            style: BkuTheme.textCaption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (asp.imageUrl != null && asp.imageUrl!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.md),
                      if (asp.imageUrl!.toLowerCase().endsWith('.pdf'))
                        InkWell(
                          onTap: () async {
                            final url = Uri.parse(ApiGate.getImageUrl(asp.imageUrl));
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                            }
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: BkuTheme.roseSoft,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.roseBorder),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: BkuTheme.rose,
                              size: 24,
                            ),
                          ),
                        )
                      else if (_isLocalFile(asp.imageUrl))
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BkuTheme.r12,
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
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BkuTheme.r12,
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
                if (asp.feedback != null && asp.feedback!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: BkuTheme.statusSuccessBg,
                      borderRadius: BkuTheme.r12,
                      border: Border.all(color: BkuTheme.statusSuccessBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: BkuTheme.emerald,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggapan Kampus',
                                style: BkuTheme.textBadge.copyWith(
                                  color: BkuTheme.emerald,
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                asp.feedback!,
                                style: BkuTheme.textCaption.copyWith(
                                  color: BkuTheme.textHeading,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(asp.date),
                      style: BkuTheme.textCaption.copyWith(fontSize: 10),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: BkuTheme.textPlaceholder,
                      size: 18,
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
    Color bg = BkuTheme.statusWarningBg;
    Color text = BkuTheme.statusWarningText;
    Color border = BkuTheme.statusWarningBorder;
    String label = 'MENUNGGU';

    switch (status.toLowerCase()) {
      case 'in progress':
      case 'diproses':
      case 'proses':
        bg = BkuTheme.indigoSoft;
        text = BkuTheme.indigo;
        border = BkuTheme.indigoBorder;
        label = 'PROSES';
        break;
      case 'resolved':
      case 'selesai':
        bg = BkuTheme.statusSuccessBg;
        text = BkuTheme.statusSuccessText;
        border = BkuTheme.statusSuccessBorder;
        label = 'SELESAI';
        break;
      case 'rejected':
      case 'ditolak':
        bg = BkuTheme.statusDangerBg;
        text = BkuTheme.statusDangerText;
        border = BkuTheme.statusDangerBorder;
        label = 'DITOLAK';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BkuTheme.rPill,
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: BkuTheme.textBadge.copyWith(
          color: text,
          fontSize: 9,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: BkuTheme.textPlaceholder),
            const SizedBox(height: AppSpacing.md),
            Text('Belum ada riwayat aspirasi', style: BkuTheme.textCaption),
          ],
        ),
      ),
    );
  }
}

class _AspirationBanner extends StatelessWidget {
  const _AspirationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r16,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: BkuTheme.indigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suarakan Aspirasimu',
                      style: BkuTheme.textPageTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Setiap saran berharga untuk kemajuan BKU.',
                      style: BkuTheme.textCardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: BkuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitAspirationScreen(),
                  ),
                );
              },
              text: 'Tulis Aspirasi Baru',
              icon: Icons.edit_note_rounded,
              variant: BkuButtonVariant.primary,
              height: 46,
            ),
          ),
        ],
      ),
    );
  }
}