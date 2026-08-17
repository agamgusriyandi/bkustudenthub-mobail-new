import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

// Unified Core Widgets
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_section_header.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

// Modular Widgets
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_quick_stats.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_gamification_card.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_service_grid.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_proposal_list.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_recent_members.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrmawaDashboardScreen extends StatefulWidget {
  const OrmawaDashboardScreen({super.key});

  @override
  State<OrmawaDashboardScreen> createState() => _OrmawaDashboardScreenState();
}

class _OrmawaDashboardScreenState extends State<OrmawaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<OrmawaProvider>();
      if (p.members.isEmpty) {
        p.refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: themeProvider.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrmawaProvider>().refreshData();
        },
        color: context.appColors.primary,
        backgroundColor: context.appColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title:
                  'Halo, ${context.watch<OrmawaProvider>().currentMember?.name.split(' ').first ?? context.watch<OrmawaProvider>().orgName}!',
              subtitle:
                  context.watch<OrmawaProvider>().currentMember?.role != null &&
                          context
                              .watch<OrmawaProvider>()
                              .currentMember!
                              .role
                              .isNotEmpty
                      ? '${context.watch<OrmawaProvider>().currentMember!.role} • ${context.watch<OrmawaProvider>().orgName}'
                      : context.watch<OrmawaProvider>().orgName,
              info:
                  'TAHUN AKADEMIK ${context.watch<OrmawaProvider>().academicYear}',
              variant: AppBarVariant.ormawa,
              showBackButton: false,
              expandedHeight: 140.0,
              showProfileOnCollapse: true,
              profileImage:
                  context.watch<OrmawaProvider>().currentMember?.fotoUrl !=
                              null &&
                          context
                              .watch<OrmawaProvider>()
                              .currentMember!
                              .fotoUrl!
                              .isNotEmpty
                      ? CachedNetworkImage(imageUrl: 
                        ApiGate.getImageUrl(
                          context
                              .watch<OrmawaProvider>()
                              .currentMember!
                              .fotoUrl!,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.groups_rounded,
                            color: context.appColors.onPrimary,
                            size: 28,
                          );
                        },
                        placeholder: (context, url) => Container(color: AppColors.neutral200),
                      )
                      : Icon(
                        Icons.groups_rounded,
                        color: context.appColors.onPrimary,
                        size: 28,
                      ),
              isExpandable: true,
              notificationCount:
                  context.watch<OrmawaProvider>().unreadNotificationsCount,
              bottomChild: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(AppRadius.radius20),
                        border: Border.all(
                          color: Colors.white.withAlpha(60),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kepengurusan Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(AppRadius.radius20),
                        border: Border.all(
                          color: Colors.white.withAlpha(50),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.watch<OrmawaProvider>().ormawaSettings['nomor_sk'] != null &&
                                    context
                                        .watch<OrmawaProvider>()
                                        .ormawaSettings['nomor_sk']
                                        .toString()
                                        .isNotEmpty
                                ? 'SK: ${context.watch<OrmawaProvider>().ormawaSettings['nomor_sk']}'
                                : 'SK Terverifikasi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (context.watch<OrmawaProvider>().gamifikasiPeringkat > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(AppRadius.radius20),
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.leaderboard_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Rank #${context.watch<OrmawaProvider>().gamifikasiPeringkat} Univ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: BkuSectionHeader(title: 'Layanan Administrasi'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const OrmawaServiceGrid(),
                  const SizedBox(height: AppSpacing.s18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: BkuSectionHeader(title: 'Statistik Organisasi'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const OrmawaQuickStats(),
                  const SizedBox(height: AppSpacing.s18),
                  const OrmawaGamificationCard(),
                  const SizedBox(height: AppSpacing.s18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: BkuSectionHeader(
                      title: 'Proposal Terbaru',
                      onSeeAll: () {
                        context.push(AppRoutes.ormawaProposal);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const OrmawaProposalList(),
                  const SizedBox(height: AppSpacing.s18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: BkuSectionHeader(
                      title: 'Agenda Kegiatan',
                      onSeeAll: () {
                        context.push(AppRoutes.ormawaAgenda);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child:
                        context.watch<OrmawaProvider>().isLoading
                            ? const BkuShimmerList(itemCount: 2, itemHeight: 80)
                            : context.watch<OrmawaProvider>().agendas.isEmpty
                            ? _buildEmptyState('Belum ada agenda terdekat')
                            : Column(
                              children:
                                  context
                                      .watch<OrmawaProvider>()
                                      .agendas
                                      .take(2)
                                      .map((agenda) => _buildAgendaCard(agenda))
                                      .toList(),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.s18),
                  const OrmawaRecentMembers(),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard(OrmawaAgenda agenda) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        context.push(AppRoutes.ormawaAgendaDetail, extra: agenda);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.serviceAmber.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_outlined,
              color: AppColors.serviceAmber,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agenda.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('dd MMM', 'id').format(agenda.date)} • ${DateFormat('HH:mm').format(agenda.date)} - ${DateFormat('HH:mm').format(agenda.endDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: context.appColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          BkuStatusBadge(
            status: _getAgendaStatus(agenda.status),
            customText: agenda.status.toUpperCase(),
            showIcon: false,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return BkuCard(
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            color: context.appColors.outlineVariant,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BkuStatus _getAgendaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'berlangsung':
      case 'ongoing':
        return BkuStatus.active;
      case 'selesai':
      case 'completed':
        return BkuStatus.success;
      case 'batal':
      case 'dibatalkan':
      case 'cancelled':
        return BkuStatus.error;
      case 'menunggu':
      case 'pending':
        return BkuStatus.pending;
      default:
        return BkuStatus.info;
    }
  }
}
