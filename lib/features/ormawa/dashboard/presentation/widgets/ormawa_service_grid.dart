import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';

// Screens
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/finance/presentation/pages/ormawa_finance_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_kalender_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/laporan/presentation/pages/ormawa_laporan_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/aspirasi/presentation/pages/ormawa_aspirasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/ormawa_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/notifications/presentation/pages/ormawa_notifications_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_settings_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/struktur/presentation/pages/ormawa_struktur_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/ormawa_recruitment_screen.dart';

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
          color: AppColors.info,
          delay: 0.5,
          target: OrmawaProposalScreen(),
        ),
      if (ormawaProvider.hasPermission('view_members'))
        const _ServiceIcon(
          title: 'Anggota',
          icon: Icons.groups_rounded,
          color: AppColors.neutral700,
          delay: 0.55,
          target: OrmawaAnggotaScreen(),
        ),
      if (ormawaProvider.hasPermission('view_finance'))
        const _ServiceIcon(
          title: 'Keuangan',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
          delay: 0.6,
          target: OrmawaFinanceScreen(),
        ),
      if (ormawaProvider.hasPermission('view_attendance'))
        _ServiceIcon(
          title: 'Absensi',
          icon: Icons.qr_code_scanner_rounded,
          color: context.appColors.info,
          delay: 0.65,
          target: OrmawaAbsensiScreen(),
        ),
      if (ormawaProvider.hasPermission('view_calendar'))
        _ServiceIcon(
          title: 'Kalender',
          icon: Icons.event_rounded,
          color: context.appColors.info,
          delay: 0.7,
          target: OrmawaKalenderScreen(),
        ),
      if (ormawaProvider.hasPermission('view_lpj'))
        const _ServiceIcon(
          title: 'Lpj',
          icon: Icons.description_rounded,
          color: AppColors.error,
          delay: 0.75,
          target: OrmawaLaporanScreen(),
        ),
      if (ormawaProvider.hasPermission('view_announcements'))
        const _ServiceIcon(
          title: 'Pengumuman',
          icon: Icons.campaign_rounded,
          color: AppColors.neutral700,
          delay: 0.8,
          target: OrmawaPengumumanScreen(),
        ),
      const _ServiceIcon(
        title: 'Lainnya',
        icon: Icons.menu_rounded,
        color: AppColors.neutral600,
        delay: 0.85,
        isMore: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final crossAxisCount = isTablet ? 8 : 4;
          final aspectRatio = isTablet ? 1.0 : 0.85;

          return GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 0,
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
    final isOpenRecruitment =
        ormawaProvider.ormawaSettings['open_recruitment'] == true;
    final canViewRecruitment =
        ormawaProvider.hasPermission('view_recruitment') ||
        ormawaProvider.hasPermission('manage_recruitment');
    final canViewAspirations =
        ormawaProvider.hasPermission('view_aspirations') ||
        ormawaProvider.hasPermission('respond_aspirations');

    final modalItems = <Widget>[
      if (ormawaProvider.hasPermission('view_structure'))
        _ModalServiceIcon(
          title: 'Struktur',
          icon: Icons.account_tree_rounded,
          color: context.appColors.info,
          target: OrmawaStrukturScreen(),
        ),
      if (isOpenRecruitment && canViewRecruitment)
        _ModalServiceIcon(
          title: 'Open Recruitment',
          icon: Icons.person_add_rounded,
          color: context.appColors.info,
          target: OrmawaRecruitmentScreen(),
        ),
      if (canViewAspirations)
        _ModalServiceIcon(
          title: 'Aspirasi',
          icon: Icons.chat_bubble_outline_rounded,
          color: context.appColors.error,
          target: OrmawaAspirasiScreen(),
        ),
      _ModalServiceIcon(
        title: 'Notifikasi',
        icon: Icons.notifications_rounded,
        color: context.appColors.warning,
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
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: AppRadius.radiusXs,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Lainnya',
          style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 24,
            crossAxisSpacing: 0,
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
      message: 'Sesi administrasi Anda akan diakhiri. Pastikan semua data laporan sudah tersimpan.',
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
    return GestureDetector(
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
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
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
  final double delay;
  final Widget? target;
  final bool isMore;

  const _ServiceIcon({
    required this.title,
    required this.icon,
    required this.color,
    required this.delay,
    this.target,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: delay,
      child: GestureDetector(
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
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: AppRadius.radiusLg,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreServices(BuildContext context) {
    BkuBottomSheet.show(
      context: context,
      padding: EdgeInsets.zero,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: const OrmawaServiceGridModal(),
      ),
    );
  }
}
