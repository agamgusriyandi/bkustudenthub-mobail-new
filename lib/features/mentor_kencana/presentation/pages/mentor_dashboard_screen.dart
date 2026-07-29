import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
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
        'Mentor';
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
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: name,
              subtitle: 'HALO MENTOR KENCANA',
              info: 'Status: Aktif Membimbing',
              variant: AppBarVariant.student,
              showBackButton: false,
              expandedHeight: 120,
              showProfileOnCollapse: true,
              profileImage:
                  fotoUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: 
                        ApiGate.getImageUrl(fotoUrl),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.person_rounded,
                            color: AppColors.neutral500,
                            size: 28,
                          );
                        },
                        placeholder: (context, url) => Container(color: AppColors.neutral200),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('Statistik Mentoring'),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.1,
                        child: _buildStatsGrid(dashboard),
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

  Widget _buildStatsGrid(dashboard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final aspectRatio = isTablet ? 1.8 : 1.5;

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            _buildStatCard(
              'Mahasiswa',
              dashboard.totalMentees.toString(),
              Icons.groups_rounded,
              AppColors.neutral600,
              () => context.go('/mentor-kencana?tab=1'),
            ),
            _buildStatCard(
              'Kelompok Saya',
              dashboard.totalGroups.toString(),
              Icons.diversity_3_rounded,
              context.appColors.success,
              () => context.go('/mentor-kencana?tab=1'),
            ),
            _buildStatCard(
              'Penilaian Akhir',
              dashboard.pendingScoring.toString(),
              Icons.grade_rounded,
              context.appColors.warning,
              () => context.go('/mentor-kencana?tab=3'),
            ),
            _buildStatCard(
              'Validasi Presensi',
              dashboard.unreadAnnouncements.toString(),
              Icons.edit_note_rounded,
              context.appColors.error,
              () => context.push(AppRoutes.mentorAbsenceRequests),
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
    VoidCallback onTap,
  ) {
    return BkuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  value,
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMenu() {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            'Cari Mahasiswa',
            'Cari & undang mahasiswa baru',
            Icons.person_search_rounded,
            AppColors.neutral600,
            () => context.push(AppRoutes.mentorRecruit),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _buildServiceCard(
            'Validasi Presensi',
            'Kelola permohonan izin',
            Icons.edit_note_rounded,
            AppColors.neutral700,
            () => context.push(AppRoutes.mentorAbsenceRequests),
          ),
        ),
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
              color: Theme.of(context).colorScheme.outline,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
              color: Theme.of(context).colorScheme.outline,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _formatDate(ann.date),
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline,
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
