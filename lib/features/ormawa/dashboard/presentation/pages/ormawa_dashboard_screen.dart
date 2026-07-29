import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

// Unified Core Widgets
import 'package:bkuhub_mobile/core/widgets/unified_section_header.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
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
        color: Theme.of(context).colorScheme.primary,
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
                  context.watch<OrmawaProvider>().currentMember?.role ??
                  'PORTAL ADMINISTRATOR',
              info:
                  'TAHUN AKADEMIK ${context.watch<OrmawaProvider>().academicYear}',
              variant: AppBarVariant.ormawa,
              showBackButton: false,
              expandedHeight: 200.0,
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
              actions: [],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: UnifiedSectionHeader(title: 'Layanan Administrasi'),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  const OrmawaServiceGrid(),
                  const SizedBox(height: AppSpacing.xxl),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: UnifiedSectionHeader(title: 'Statistik Organisasi'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const OrmawaQuickStats(),
                  const SizedBox(height: AppSpacing.xxl),
                  const OrmawaGamificationCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: UnifiedSectionHeader(
                      title: 'Proposal Terbaru',
                      onSeeAll: () {
                        context.push(AppRoutes.ormawaProposal);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const OrmawaProposalList(),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: UnifiedSectionHeader(
                      title: 'Agenda Kegiatan',
                      onSeeAll: () {
                        context.push(AppRoutes.ormawaAgenda);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.xxl),
                  const OrmawaRecentMembers(),
                  const SizedBox(height: AppSpacing.s120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed local section header methods

  Widget _buildAgendaCard(OrmawaAgenda agenda) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () {
        context.push(AppRoutes.ormawaAgendaDetail, extra: agenda);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agenda.title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormat('dd MMM', 'id').format(agenda.date)} â€¢ ${DateFormat('HH:mm').format(agenda.date)} - ${DateFormat('HH:mm').format(agenda.endDate)}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(15),
              borderRadius: AppRadius.radiusXl,
            ),
            child: Text(
              agenda.status,
              style: AppTextStyles.labelSm.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
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
            color: Theme.of(context).colorScheme.outlineVariant,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
