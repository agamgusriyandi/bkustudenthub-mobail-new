import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';

import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  Timer? _dashboardTimer;

  String _getMentorAvatarUrl(Map? fullData) {
    return AuthService().studentAvatarUrl ?? '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchDashboard();

        _dashboardTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
          if (mounted) {
            context.read<MentorKencanaProvider>().fetchDashboard(silent: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _dashboardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final authService = context.watch<AuthService>();
    final fullUserData =
        authService.userData?['user'] ?? authService.userData ?? {};
    final userData = authService.userData?['user'] ?? {};
    final name =
        userData['name'] ??
        userData['nama'] ??
        fullUserData['name'] ??
        fullUserData['nama'] ??
        'Fasilitator';
    final dashboard = provider.dashboardData;

    final rawFoto = _getMentorAvatarUrl(authService.userData);

    String fotoUrl = rawFoto;
    if (fotoUrl.isNotEmpty && !fotoUrl.startsWith('http')) {
      String base = ApiGate.baseUrl;
      if (base.endsWith('/api')) {
        base = base.substring(0, base.length - 4);
      }
      if (fotoUrl.startsWith('/')) {
        fotoUrl = '$base$fotoUrl';
      } else {
        fotoUrl = '$base/$fotoUrl';
      }
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchDashboard(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: name,
              subtitle: 'HALO FASILITATOR KENCANA',
              info: 'Status: Aktif Membimbing',
              variant: AppBarVariant.student,
              showBackButton: false,
              expandedHeight: 120,
              showProfileOnCollapse: true,
              profileImage:
                  fotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: ApiGate.getImageUrl(fotoUrl),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.person_rounded,
                            color: AppColors.neutral500,
                            size: 28,
                          );
                        },
                        placeholder:
                            (context, url) =>
                                Container(color: AppColors.neutral200),
                      )
                      : const Icon(
                        Icons.person_rounded,
                        color: AppColors.neutral500,
                        size: 28,
                      ),
            ),
            if (provider.isLoading && dashboard == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && dashboard == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (dashboard != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name == 'Fasilitator' ||
                          (userData['phone'] ?? fullUserData['phone'] ?? '')
                              .toString()
                              .isEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: AppSpacing.xl),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.appColors.warning.withAlpha(20),
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(
                              color: context.appColors.warning,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: context.appColors.warning,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Profil Anda belum lengkap. Silakan lengkapi profil di halaman web.',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('Statistik Fasilitasi'),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.1,
                        child: _buildStatsGrid(dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeInAnimation(
                        delay: 0.12,
                        child: _buildHandbookAndPieChart(context, dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeInAnimation(
                        delay: 0.13,
                        child: _buildGroupAndPeriodInfo(context, dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionTitle('Layanan Kencana'),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(delay: 0.15, child: _buildServiceMenu()),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionTitle('Pengumuman'),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.2,
                        child: _buildAnnouncements(provider),
                      ),
                      const SizedBox(height: AppSpacing.s120),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLg.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildStatsGrid(MentorDashboardData dashboard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final aspectRatio = isTablet ? 1.8 : 1.35;

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          children: [
            _buildStatCard(
              'TOTAL BIMBINGAN',
              '${dashboard.totalMentees} Mahasiswa',
              Icons.school_rounded,
              context.appColors.primary,
              'Aktif',
              () => context.go('/mentor-kencana?tab=1'),
            ),
            _buildStatCard(
              'REVIEW HANDBOOK',
              '${dashboard.pendingHandbooks} Berkas',
              Icons.menu_book_rounded,
              context.appColors.warning,
              dashboard.pendingHandbooks > 0 ? 'Butuh ACC' : null,
              () => context.push(AppRoutes.mentorHandbookList),
            ),
            _buildStatCard(
              'MAHASISWA LULUS',
              '${dashboard.passedStudents} Mahasiswa',
              Icons.verified_rounded,
              context.appColors.success,
              'Lengkap',
              () => context.go('/mentor-kencana?tab=3'),
            ),
            _buildStatCard(
              'PERLU PERBAIKAN / REMEDIAL',
              '${dashboard.remedialStudents} Mahasiswa',
              Icons.error_outline_rounded,
              context.appColors.error,
              'Evaluasi',
              () => context.go('/mentor-kencana?tab=3'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? badgeText,
    VoidCallback onTap,
  ) {
    return BkuCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(color: color.withAlpha(40)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMenu() {
    final actions = [
      {
        'title': 'Persetujuan Handbook',
        'desc': 'Persetujuan tugas',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => context.push(AppRoutes.mentorHandbookList),
      },
      {
        'title': 'Kelola Materi & Tugas',
        'desc': 'Kelola materi',
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF14B8A6),
        'onTap': () => context.push(AppRoutes.mentorMaterials),
      },
      {
        'title': 'Penilaian & Skoring',
        'desc': 'Skoring kelulusan',
        'icon': Icons.star_rounded,
        'color': const Color(0xFF6366F1),
        'onTap': () => context.go('/mentor-kencana?tab=3'),
      },
      {
        'title': 'Penilaian Essay',
        'desc': 'Evaluasi tugas essay',
        'icon': Icons.rate_review_rounded,
        'color': const Color(0xFF06B6D4),
        'onTap': () => context.push(AppRoutes.mentorEssayGrading),
      },
      {
        'title': 'Validasi Presensi (Izin)',
        'desc': 'Permohonan izin',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFFF43F5E),
        'onTap': () => context.push(AppRoutes.mentorAbsenceRequests),
      },
      {
        'title': 'Kelompok Saya',
        'desc': 'Daftar kelompok',
        'icon': Icons.diversity_3_rounded,
        'color': context.appColors.primary,
        'onTap': () => context.push(AppRoutes.mentorGroups),
      },
      {
        'title': 'Catatan Bimbingan',
        'desc': 'Kelola catatan',
        'icon': Icons.speaker_notes_rounded,
        'color': const Color(0xFFF59E0B),
        'onTap': () => context.push(AppRoutes.mentorNotes),
      },
      {
        'title': 'Presensi Kehadiran',
        'desc': 'Input & validasi',
        'icon': Icons.how_to_reg_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => context.go('/mentor-kencana?tab=2'),
      },
      {
        'title': 'Pengaturan Profil',
        'desc': 'Kelola profil',
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF64748B),
        'onTap': () => context.go('/mentor-kencana?tab=4'),
      },
    ];

    final rows = <Widget>[];
    for (int i = 0; i < actions.length; i += 2) {
      final a1 = actions[i];
      final hasSecond = i + 1 < actions.length;
      final a2 = hasSecond ? actions[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                a1['title'] as String,
                a1['desc'] as String,
                a1['icon'] as IconData,
                a1['color'] as Color,
                a1['onTap'] as VoidCallback,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (hasSecond)
              Expanded(
                child: _buildServiceCard(
                  a2!['title'] as String,
                  a2['desc'] as String,
                  a2['icon'] as IconData,
                  a2['color'] as Color,
                  a2['onTap'] as VoidCallback,
                ),
              )
            else
              Expanded(child: const SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < actions.length) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
    }

    return Column(children: rows);
  }

  Widget _buildHandbookAndPieChart(BuildContext context, dynamic dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.warning.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: context.appColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dokumen Handbook', style: AppTextStyles.labelSm),
                    const SizedBox(height: 2),
                    Text(
                      '${dashboard.pendingHandbooks} Menunggu Persetujuan',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionTitle('Evaluasi Mahasiswa'),
        const SizedBox(height: AppSpacing.lg),
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: context.appColors.success,
                          value: dashboard.passedStudents.toDouble(),
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: context.appColors.error,
                          value: dashboard.remedialStudents.toDouble(),
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: AppColors.neutral300,
                          value: dashboard.pendingScoring.toDouble(),
                          title: '',
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        context.appColors.success,
                        'Lulus (${dashboard.passedStudents})',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        context.appColors.error,
                        'Remedial (${dashboard.remedialStudents})',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        AppColors.neutral300,
                        'Belum (${dashboard.pendingScoring})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }

  Widget _buildServiceCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return BkuCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAndPeriodInfo(
    BuildContext context,
    MentorDashboardData dashboard,
  ) {
    final raw = dashboard.rawData;
    final group = raw['group'] as Map<String, dynamic>?;
    final period = group?['period'] as Map<String, dynamic>?;

    // Calculate progress
    final studentCount = dashboard.totalMentees;
    final evaluatedCount =
        dashboard.passedStudents + dashboard.remedialStudents;
    final progressPercent =
        studentCount > 0
            ? (evaluatedCount / studentCount).clamp(0.0, 1.0)
            : 0.0;

    // Formatting dates
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '-';
      try {
        final date = DateTime.parse(dateStr);
        return '${date.day}-${date.month}-${date.year}';
      } catch (_) {
        return dateStr;
      }
    }

    final groupName = group?['name']?.toString() ?? '-';
    final groupCode = group?['code']?.toString() ?? '-';
    final scope = group?['scope_type']?.toString() ?? '-';
    final periodName = period?['name']?.toString() ?? '-';
    final startDateStr = formatDate(period?['start_date']?.toString());
    final endDateStr = formatDate(period?['end_date']?.toString());
    final passGrade = period?['passing_grade']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: AppRadius.radiusXl,
            ),
            child: Text(
              scope.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            groupName,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kode: $groupCode',
            style: AppTextStyles.labelMd.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              _buildModernPill(context, Icons.event, periodName),
              _buildModernPill(context, Icons.calendar_today, '$startDateStr - $endDateStr'),
              _buildModernPill(context, Icons.grade, 'Lulus: $passGrade'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kemajuan Evaluasi',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
                    ),
                    Text(
                      '$evaluatedCount dari $studentCount',
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(context.appColors.success),
                  borderRadius: AppRadius.radiusSm,
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements(MentorKencanaProvider provider) {
    if (provider.announcements.isEmpty) {
      return BkuCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            'Tidak ada pengumuman terbaru.',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: provider.announcements.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final ann = provider.announcements[index];
        return BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ann.title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!ann.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.error.withAlpha(15),
                        border: Border.all(
                          color: context.appColors.error.withAlpha(30),
                        ),
                        borderRadius: AppRadius.radiusXs,
                      ),
                      child: Text(
                        'BARU',
                        style: AppTextStyles.labelSm.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _cleanHtml(ann.content),
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _formatDate(ann.date),
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  color: context.appColors.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      String dayName = days[dt.weekday - 1];
      String monthName = months[dt.month - 1];
      String dayNum = dt.day.toString().padLeft(2, '0');
      return '$dayName, $dayNum $monthName ${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    var document = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    document = document
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    return document.trim();
  }
}
