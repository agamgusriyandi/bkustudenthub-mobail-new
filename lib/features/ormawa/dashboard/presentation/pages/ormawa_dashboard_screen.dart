import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_section_header.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_quick_stats.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_gamification_card.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_service_grid.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_proposal_list.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/widgets/ormawa_recent_members.dart';

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
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrmawaProvider>().refreshData();
        },
        color: OrmawaTheme.primary,
        backgroundColor: Colors.white,
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
                  context.watch<OrmawaProvider>().currentMember?.fotoUrl != null &&
                          context
                              .watch<OrmawaProvider>()
                              .currentMember!
                              .fotoUrl!
                              .isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ApiGate.getImageUrl(
                            context.watch<OrmawaProvider>().currentMember!.fotoUrl!,
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.groups_rounded,
                              color: Colors.white,
                              size: 28,
                            );
                          },
                          placeholder: (context, url) => Container(color: const Color(0xFFF1F5F9)),
                        )
                      : const Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
              isExpandable: true,
              notificationCount: context.watch<OrmawaProvider>().unreadNotificationsCount,
              onProfileTap: () => context.push(AppRoutes.ormawaProfile),
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
                        borderRadius: BorderRadius.circular(20),
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
                        borderRadius: BorderRadius.circular(20),
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
                          borderRadius: BorderRadius.circular(20),
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
              actions: const [],
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
                    child: context.watch<OrmawaProvider>().isLoading
                        ? const BkuShimmerList(itemCount: 2, itemHeight: 80)
                        : context.watch<OrmawaProvider>().agendas.isEmpty
                            ? const OrmawaEmptyCard(
                                title: 'Belum Ada Agenda Terdekat',
                                description: 'Agenda kegiatan mendatang akan ditampilkan di sini.',
                                icon: Icons.event_note_outlined,
                              )
                            : Column(
                                children: context
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
    final statusLower = agenda.status.toLowerCase();
    Color badgeBg = OrmawaTheme.statusInfoBg;
    Color badgeText = OrmawaTheme.statusInfoText;

    if (statusLower == 'selesai' || statusLower == 'completed') {
      badgeBg = OrmawaTheme.statusSuccessBg;
      badgeText = OrmawaTheme.statusSuccessText;
    } else if (statusLower == 'batal' || statusLower == 'cancelled') {
      badgeBg = OrmawaTheme.statusDangerBg;
      badgeText = OrmawaTheme.statusDangerText;
    } else if (statusLower == 'aktif' || statusLower == 'ongoing' || statusLower == 'berlangsung') {
      badgeBg = OrmawaTheme.statusSuccessBg;
      badgeText = OrmawaTheme.statusSuccessText;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OrmawaCard(
        onTap: () {
          context.push(AppRoutes.ormawaAgendaDetail, extra: agenda);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: OrmawaTheme.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event_outlined,
                color: OrmawaTheme.primary,
                size: 19,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agenda.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: OrmawaTheme.textHeading,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${DateFormat('dd MMM yyyy', 'id').format(agenda.date)} • ${DateFormat('HH:mm').format(agenda.date)} - ${DateFormat('HH:mm').format(agenda.endDate)}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: OrmawaTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                agenda.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: badgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
