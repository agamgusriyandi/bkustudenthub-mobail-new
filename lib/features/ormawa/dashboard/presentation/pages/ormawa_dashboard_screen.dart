import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_section_header.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
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
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';

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
      if (p.isFirstFetch || (p.members.isEmpty && p.proposals.isEmpty && !p.isLoading)) {
        p.refreshData();
      }
    });
  }

  void _openQrScanner(BuildContext context) {
    final provider = context.read<OrmawaProvider>();
    final agendas = provider.agendas;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: BkuTheme.scaffoldBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: BkuTheme.border),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BkuTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: BkuTheme.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: BkuTheme.primaryBorder,
                            ),
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: BkuTheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Presensi QR Ormawa',
                                style: BkuTheme.textCardTitle.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: BkuTheme.textHeading,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pilih agenda kegiatan untuk membuka scanner',
                                style: BkuTheme.textCaption.copyWith(
                                  fontSize: 12,
                                  color: BkuTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: BkuTheme.borderSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: BkuTheme.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (agendas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: BkuEmptyState(
                    title: 'Belum Ada Kegiatan Aktif',
                    message:
                        'Tidak ada agenda kegiatan saat ini. Anda dapat menggunakan Scan Bebas untuk memindai presensi mandiri.',
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: agendas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final agenda = agendas[index];
                      final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(agenda.date);

                      return BkuCard(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrmawaQrScanScreen(
                                eventId: agenda.id,
                                eventTitle: agenda.title,
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(14),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: BkuTheme.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: BkuTheme.primaryBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.event_available_rounded,
                                color: BkuTheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    agenda.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: BkuTheme.textHeading,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.emeraldSoft,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: BkuTheme.emeraldBorder,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 11,
                                              color: BkuTheme.emerald,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: BkuTheme.emerald,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: BkuTheme.borderSubtle,
                                border: Border.all(color: BkuTheme.border),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 16,
                                color: BkuTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: BkuTheme.border),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: BkuButton.outline(
                          text: 'Scan Bebas',
                          icon: Icons.qr_code_rounded,
                          height: 42,
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrmawaQrScanScreen(
                                  eventId: '',
                                  eventTitle: 'Scan Presensi Mandiri',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BkuButton.primary(
                          text: 'Kelola Presensi',
                          icon: Icons.tune_rounded,
                          height: 42,
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push(AppRoutes.ormawaAbsensi);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrmawaProvider>().refreshData();
        },
        color: BkuTheme.primary,
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
                  '${context.watch<OrmawaProvider>().userSubRole} • ${context.watch<OrmawaProvider>().orgName}',
              info:
                  'TAHUN AKADEMIK ${context.watch<OrmawaProvider>().academicYear}',
              variant: AppBarVariant.ormawa,
              showBackButton: false,
              expandedHeight: 140.0,
              showProfileOnCollapse: true,
              actions: [
                IconButton(
                  onPressed: () => _openQrScanner(context),
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Scan QR Presensi',
                ),
              ],
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
                          placeholder: (context, url) => Container(color: BkuTheme.borderSubtle),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.watch<OrmawaProvider>().userSubRole,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
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
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
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
                  if (context.watch<OrmawaProvider>().hasPermission('ormawa.proposals.view, view_proposal, ormawa.core.view')) ...[
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
                  ],
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
                            ? const BkuEmptyState(
                                title: 'Belum Ada Agenda Terdekat',
                                message: 'Agenda kegiatan mendatang akan ditampilkan di sini.',
                              )
                            : Column(
                                children: context
                                    .watch<OrmawaProvider>()
                                    .agendas
                                    .take(3)
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
    BkuStatus badgeStatus = BkuStatus.info;

    if (statusLower == 'selesai' || statusLower == 'completed') {
      badgeStatus = BkuStatus.success;
    } else if (statusLower == 'batal' || statusLower == 'cancelled') {
      badgeStatus = BkuStatus.error;
    } else if (statusLower == 'aktif' || statusLower == 'ongoing' || statusLower == 'berlangsung') {
      badgeStatus = BkuStatus.success;
    }

    final title = agenda.title.trim().isNotEmpty ? agenda.title.trim() : 'Kegiatan Organisasi';
    final hasSpecificTime = !(agenda.date.hour == 0 && agenda.date.minute == 0 && agenda.endDate.hour == 0 && agenda.endDate.minute == 0);
    final timeStr = hasSpecificTime
        ? '${DateFormat('HH:mm').format(agenda.date)} - ${DateFormat('HH:mm').format(agenda.endDate)} WIB'
        : 'Sepanjang Hari';
    final locStr = agenda.location.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BkuCard(
        onTap: () {
          context.push(AppRoutes.ormawaAgendaDetail, extra: agenda);
        },
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: BkuTheme.purpleSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BkuTheme.purpleBorder.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(agenda.date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: BkuTheme.purple,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'id').format(agenda.date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: BkuTheme.purple,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: BkuTheme.textHeading,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BkuStatusBadge(
                        status: badgeStatus,
                        customText: agenda.status.toUpperCase(),
                        showIcon: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.5,
                        color: BkuTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: BkuTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (locStr.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on_outlined,
                          size: 12.5,
                          color: BkuTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            locStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: BkuTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: BkuTheme.border,
            ),
          ],
        ),
      ),
    );
  }
}