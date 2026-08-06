import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/widgets/mentor_service_menu.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/widgets/mentor_stats_grid.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/widgets/mentor_handbook_chart.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/widgets/mentor_group_period_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/widgets/mentor_announcements.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MentorKencanaProvider>().fetchDashboard();
    });
  }

  String _getMentorAvatarUrl(Map<String, dynamic>? rawUser) {
    if (rawUser == null) return '';
    final fullUserData = rawUser['full_user_data'] ?? {};
    final f1 = fullUserData['foto'] ?? '';
    final f2 = fullUserData['avatar'] ?? '';
    final rawF1 = rawUser['foto'] ?? '';
    final rawF2 = rawUser['avatar'] ?? '';

    if (f1.toString().isNotEmpty) return f1.toString();
    if (f2.toString().isNotEmpty) return f2.toString();
    if (rawF1.toString().isNotEmpty) return rawF1.toString();
    if (rawF2.toString().isNotEmpty) return rawF2.toString();

    final userObj = rawUser['user'] ?? {};
    final uf1 = userObj['foto'] ?? '';
    final uf2 = userObj['avatar'] ?? '';

    if (uf1.toString().isNotEmpty) return uf1.toString();
    if (uf2.toString().isNotEmpty) return uf2.toString();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final authService = context.watch<AuthService>();
    final dashboard = provider.dashboardData;
    
    final fullUserData =
        authService.userData?['full_user_data'] ??
        authService.userData?['user'] ??
        authService.userData ??
        {};
    final userData = authService.userData?['user'] ?? {};
    final name =
        userData['name'] ??
        userData['nama'] ??
        fullUserData['name'] ??
        fullUserData['nama'] ??
        'Fasilitator';

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
        backgroundColor: context.appColors.surface,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: name,
              subtitle: 'HALO FASILITATOR KENCANA',
              info: 'Status: Aktif Membimbing',
              variant: AppBarVariant.student,
              showBackButton: false,
              expandedHeight: 130,
              showProfileOnCollapse: true,
              profileImage:
                  fotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: ApiGate.getImageUrl(fotoUrl),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.person_rounded,
                            color: context.appColors.primary,
                            size: 28,
                          );
                        },
                        placeholder:
                            (context, url) => Container(
                              color: context.appColors.primary.withAlpha(20),
                            ),
                      )
                      : Icon(
                        Icons.person_rounded,
                        color: context.appColors.primary,
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
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Layanan Cepat',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const FadeInAnimation(
                        delay: 0.1,
                        child: MentorServiceMenu(),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      if (name == 'Fasilitator' ||
                          (userData['phone'] ?? fullUserData['phone'] ?? '')
                              .toString()
                              .isEmpty)
                        FadeInAnimation(
                          delay: 0.1,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s20),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: context.appColors.warning,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: context.appColors.warning.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: context.appColors.surface.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: context.appColors.surface,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Profil Anda belum lengkap. Silakan lengkapi profil di halaman web.',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: context.appColors.surface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Text(
                        'Statistik Fasilitasi',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.1,
                        child: MentorStatsGrid(dashboard: dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeInAnimation(
                        delay: 0.12,
                        child: MentorHandbookChart(dashboard: dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeInAnimation(
                        delay: 0.13,
                        child: MentorGroupPeriodCard(dashboard: dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Pengumuman',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.2,
                        child: MentorAnnouncements(provider: provider),
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
}
