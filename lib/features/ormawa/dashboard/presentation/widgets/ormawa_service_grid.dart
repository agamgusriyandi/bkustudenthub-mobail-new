import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';

import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/finance/presentation/pages/ormawa_finance_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_kalender_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/aspirasi/presentation/pages/ormawa_aspirasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/ormawa_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/notifications/presentation/pages/ormawa_notifications_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_settings_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/struktur/presentation/pages/ormawa_struktur_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/ormawa_recruitment_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pagu/presentation/pages/ormawa_pagu_screen.dart';

class OrmawaServiceGrid extends StatelessWidget {
  const OrmawaServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final items = <Widget>[
      if (ormawaProvider.hasPermission('view_proposal'))
        const _ServiceIcon(
          title: 'Proposal',
          icon: Icons.assignment_rounded,
          color: AppColors.serviceIndigo,
          target: OrmawaProposalScreen(),
        ),
      if (ormawaProvider.hasPermission('view_members'))
        const _ServiceIcon(
          title: 'Anggota',
          icon: Icons.groups_rounded,
          color: AppColors.servicePurple,
          target: OrmawaAnggotaScreen(),
        ),
      if (ormawaProvider.hasPermission('view_finance'))
        const _ServiceIcon(
          title: 'Keuangan',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.serviceEmerald,
          target: OrmawaFinanceScreen(),
        ),
      if (ormawaProvider.hasPermission('view_attendance'))
        const _ServiceIcon(
          title: 'Absensi',
          icon: Icons.qr_code_scanner_rounded,
          color: AppColors.serviceCyan,
          target: OrmawaAbsensiScreen(),
        ),
      if (ormawaProvider.hasPermission('view_calendar'))
        const _ServiceIcon(
          title: 'Kalender',
          icon: Icons.event_rounded,
          color: AppColors.serviceAmber,
          target: OrmawaKalenderScreen(),
        ),
      if (ormawaProvider.hasPermission('view_lpj'))
        const _ServiceIcon(
          title: 'Lpj',
          icon: Icons.description_rounded,
          color: AppColors.serviceRose,
          target: OrmawaLpjScreen(),
        ),
      if (ormawaProvider.hasPermission('view_announcements'))
        const _ServiceIcon(
          title: 'Pengumuman',
          icon: Icons.campaign_rounded,
          color: AppColors.serviceSky,
          target: OrmawaPengumumanScreen(),
        ),
      const _ServiceIcon(
        title: 'Lainnya',
        icon: Icons.grid_view_rounded,
        color: AppColors.neutral600,
        isMore: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
          final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
          final aspectRatio = itemWidth / 84;

          return GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 6,
            childAspectRatio: aspectRatio,
            children: items,
          );
        },
      ),
    );
  }
}

class OrmawaServiceGridModal extends StatelessWidget {
  const OrmawaServiceGridModal({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final canViewRecruitment =
        ormawaProvider.hasPermission('view_recruitment') ||
        ormawaProvider.hasPermission('manage_recruitment');
    final canViewAspirations =
        ormawaProvider.hasPermission('view_aspirations') ||
        ormawaProvider.hasPermission('respond_aspirations');

    final modalItems = <Widget>[
      if (ormawaProvider.hasPermission('view_structure'))
        const _ModalServiceIcon(
          title: 'Struktur',
          icon: Icons.account_tree_rounded,
          color: AppColors.serviceIndigo,
          target: OrmawaStrukturScreen(),
        ),
      if (canViewRecruitment)
        const _ModalServiceIcon(
          title: 'Rekrutmen',
          icon: Icons.person_add_rounded,
          color: AppColors.serviceSky,
          target: OrmawaRecruitmentScreen(),
        ),
      if (canViewAspirations)
        const _ModalServiceIcon(
          title: 'Aspirasi',
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.serviceRose,
          target: OrmawaAspirasiScreen(),
        ),
      const _ModalServiceIcon(
        title: 'Pagu',
        icon: Icons.savings_rounded,
        color: AppColors.serviceTeal,
        target: OrmawaPaguScreen(),
      ),
      const _ModalServiceIcon(
        title: 'Notifikasi',
        icon: Icons.notifications_rounded,
        color: AppColors.serviceAmber,
        target: OrmawaNotificationsScreen(),
      ),
      const _ModalServiceIcon(
        title: 'Pengaturan',
        icon: Icons.settings_rounded,
        color: AppColors.neutral500,
        target: OrmawaSettingsScreen(),
      ),
      _ModalServiceIcon(
        title: 'Keluar',
        icon: Icons.logout_rounded,
        color: AppColors.error,
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Column(
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: AppRadius.radiusXs,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Layanan Tambahan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: context.appColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: modalItems,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    BkuDialog.show(
      context: context,
      title: 'Keluar Portal?',
      message: 'Sesi administrasi Anda akan diakhiri.',
      type: BkuDialogType.error,
      primaryButtonText: 'Keluar',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await AuthService().logout();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}

class _ModalServiceIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? target;
  final VoidCallback? onTap;

  const _ModalServiceIcon({
    required this.title,
    required this.icon,
    required this.color,
    this.target,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BkuBounceButton(
      scaleFactor: 0.92,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target!),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withAlpha(50),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: context.appColors.onSurface,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? target;
  final bool isMore;

  const _ServiceIcon({
    required this.title,
    required this.icon,
    required this.color,
    this.target,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return BkuBounceButton(
      scaleFactor: 0.92,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isMore) {
          _showMoreServices(context);
        } else if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target!),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withAlpha(50),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showMoreServices(BuildContext context) {
    BkuBottomSheet.show(
      context: context,
      padding: EdgeInsets.zero,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const OrmawaServiceGridModal(),
      ),
    );
  }
}
