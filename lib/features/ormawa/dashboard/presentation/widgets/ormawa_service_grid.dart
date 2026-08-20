import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

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
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_profile_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/struktur/presentation/pages/ormawa_struktur_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/staf/presentation/pages/ormawa_staf_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/ormawa_recruitment_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pagu/presentation/pages/ormawa_pagu_screen.dart';

class _ServiceItemData {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final Widget? target;
  final String category;
  final bool isPermitted;

  const _ServiceItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    this.target,
    required this.category,
    required this.isPermitted,
  });
}

List<_ServiceItemData> _getAvailableServices(OrmawaProvider provider) {
  return [
    _ServiceItemData(
      title: 'Proposal',
      icon: Icons.assignment_rounded,
      color: OrmawaTheme.indigo,
      bgColor: OrmawaTheme.indigoSoft,
      borderColor: OrmawaTheme.indigoBorder,
      target: const OrmawaProposalScreen(),
      category: 'Administrasi & Proker',
      isPermitted: provider.hasPermission(
        'ormawa.proposals.view, ormawa.proposals.create, ormawa.proposals.manage, view_proposal',
      ),
    ),
    _ServiceItemData(
      title: 'LPJ',
      icon: Icons.description_rounded,
      color: OrmawaTheme.rose,
      bgColor: OrmawaTheme.roseSoft,
      borderColor: OrmawaTheme.roseBorder,
      target: const OrmawaLpjScreen(),
      category: 'Administrasi & Proker',
      isPermitted: provider.hasPermission(
        'ormawa.lpj.view, ormawa.lpj.create, ormawa.lpj.manage, view_lpj',
      ),
    ),
    _ServiceItemData(
      title: 'Kalender',
      icon: Icons.event_rounded,
      color: OrmawaTheme.amber,
      bgColor: OrmawaTheme.amberSoft,
      borderColor: OrmawaTheme.amberBorder,
      target: const OrmawaKalenderScreen(),
      category: 'Administrasi & Proker',
      isPermitted: provider.hasPermission(
        'ormawa.events.view, ormawa.events.create, ormawa.events.manage, view_calendar',
      ),
    ),
    _ServiceItemData(
      title: 'Absensi',
      icon: Icons.qr_code_scanner_rounded,
      color: OrmawaTheme.primary,
      bgColor: OrmawaTheme.primarySoft,
      borderColor: OrmawaTheme.primaryBorder,
      target: const OrmawaAbsensiScreen(),
      category: 'Administrasi & Proker',
      isPermitted: provider.hasPermission(
        'ormawa.attendance.view, ormawa.attendance.manage, view_attendance',
      ),
    ),
    _ServiceItemData(
      title: 'Keuangan',
      icon: Icons.account_balance_wallet_rounded,
      color: OrmawaTheme.emerald,
      bgColor: OrmawaTheme.emeraldSoft,
      borderColor: OrmawaTheme.emeraldBorder,
      target: const OrmawaFinanceScreen(),
      category: 'Keuangan & Pagu',
      isPermitted: provider.hasPermission(
        'ormawa.finance.view, ormawa.finance.create, ormawa.finance.manage, view_finance',
      ),
    ),
    _ServiceItemData(
      title: 'Pagu',
      icon: Icons.savings_rounded,
      color: OrmawaTheme.teal,
      bgColor: OrmawaTheme.tealSoft,
      borderColor: OrmawaTheme.tealBorder,
      target: const OrmawaPaguScreen(),
      category: 'Keuangan & Pagu',
      isPermitted: provider.hasPermission(
        'ormawa.pagu.view, ormawa.pagu.manage, ormawa.pagu.update',
      ),
    ),
    _ServiceItemData(
      title: 'Anggota',
      icon: Icons.groups_rounded,
      color: OrmawaTheme.purple,
      bgColor: OrmawaTheme.purpleSoft,
      borderColor: OrmawaTheme.purpleBorder,
      target: const OrmawaAnggotaScreen(),
      category: 'Personil & Organisasi',
      isPermitted: provider.hasPermission(
        'ormawa.members.view, ormawa.members.create, ormawa.members.manage, view_members',
      ),
    ),
    _ServiceItemData(
      title: 'Staf',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFF2563EB),
      bgColor: const Color(0xFFEFF6FF),
      borderColor: const Color(0xFFBFDBFE),
      target: const OrmawaStafScreen(),
      category: 'Personil & Organisasi',
      isPermitted: provider.hasPermission(
        'ormawa.staff.view, ormawa.staff.create, ormawa.staff.manage, view_staff',
      ),
    ),
    _ServiceItemData(
      title: 'Struktur',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF4F46E5),
      bgColor: const Color(0xFFEEF2FF),
      borderColor: const Color(0xFFC7D2FE),
      target: const OrmawaStrukturScreen(),
      category: 'Personil & Organisasi',
      isPermitted: provider.hasPermission(
        'ormawa.structure.view, ormawa.structure.manage, ormawa.members.view, ormawa.members.update, ormawa.organisasi.view, ormawa.organisasi.manage, view_structure',
      ),
    ),
    _ServiceItemData(
      title: 'Rekrutmen',
      icon: Icons.person_add_rounded,
      color: const Color(0xFF0284C7),
      bgColor: const Color(0xFFE0F2FE),
      borderColor: const Color(0xFFBAE6FD),
      target: const OrmawaRecruitmentScreen(),
      category: 'Personil & Organisasi',
      isPermitted: provider.hasPermission(
        'ormawa.recruitment.view, ormawa.recruitment.create, ormawa.recruitment.manage, view_recruitment',
      ),
    ),
    _ServiceItemData(
      title: 'Pengumuman',
      icon: Icons.campaign_rounded,
      color: const Color(0xFF0EA5E9),
      bgColor: const Color(0xFFE0F2FE),
      borderColor: const Color(0xFFBAE6FD),
      target: const OrmawaPengumumanScreen(),
      category: 'Komunikasi & Aspirasi',
      isPermitted: provider.hasPermission(
        'ormawa.announcements.view, ormawa.announcements.create, ormawa.announcements.update, view_announcements',
      ),
    ),
    _ServiceItemData(
      title: 'Aspirasi',
      icon: Icons.chat_bubble_outline_rounded,
      color: const Color(0xFFF43F5E),
      bgColor: const Color(0xFFFFF1F2),
      borderColor: const Color(0xFFFFE4E6),
      target: const OrmawaAspirasiScreen(),
      category: 'Komunikasi & Aspirasi',
      isPermitted: provider.hasPermission(
        'ormawa.aspiration.view, ormawa.aspirations.view, ormawa.aspiration.update, view_aspirations',
      ),
    ),
    _ServiceItemData(
      title: 'Notifikasi',
      icon: Icons.notifications_rounded,
      color: OrmawaTheme.amber,
      bgColor: OrmawaTheme.amberSoft,
      borderColor: OrmawaTheme.amberBorder,
      target: const OrmawaNotificationsScreen(),
      category: 'Pengaturan & Akun',
      isPermitted: true,
    ),
    _ServiceItemData(
      title: 'Profil',
      icon: Icons.person_rounded,
      color: OrmawaTheme.purple,
      bgColor: OrmawaTheme.purpleSoft,
      borderColor: OrmawaTheme.purpleBorder,
      target: const OrmawaProfileScreen(),
      category: 'Pengaturan & Akun',
      isPermitted: true,
    ),
    _ServiceItemData(
      title: 'Pengaturan',
      icon: Icons.settings_rounded,
      color: const Color(0xFF475569),
      bgColor: const Color(0xFFF1F5F9),
      borderColor: const Color(0xFFCBD5E1),
      target: const OrmawaSettingsScreen(),
      category: 'Pengaturan & Akun',
      isPermitted: provider.hasPermission(
        'ormawa.settings.view, ormawa.settings.manage, ormawa.settings.update, view_settings',
      ),
    ),
  ];
}

class OrmawaServiceGrid extends StatelessWidget {
  const OrmawaServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allServices = _getAvailableServices(ormawaProvider);
    final permittedServices = allServices.where((s) => s.isPermitted).toList();

    final List<Widget> gridWidgets = [];

    if (permittedServices.length <= 8) {
      for (final service in permittedServices) {
        gridWidgets.add(
          _ServiceIcon(
            title: service.title,
            icon: service.icon,
            color: service.color,
            bgColor: service.bgColor,
            borderColor: service.borderColor,
            target: service.target,
          ),
        );
      }
    } else {
      for (int i = 0; i < 7; i++) {
        final service = permittedServices[i];
        gridWidgets.add(
          _ServiceIcon(
            title: service.title,
            icon: service.icon,
            color: service.color,
            bgColor: service.bgColor,
            borderColor: service.borderColor,
            target: service.target,
          ),
        );
      }
      gridWidgets.add(
        const _ServiceIcon(
          title: 'Lainnya',
          icon: Icons.grid_view_rounded,
          color: Color(0xFF64748B),
          bgColor: Color(0xFFF1F5F9),
          borderColor: Color(0xFFE2E8F0),
          isMore: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
          final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
          final aspectRatio = itemWidth / 86;

          return GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 6,
            childAspectRatio: aspectRatio,
            children: gridWidgets,
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
    final allServices = _getAvailableServices(ormawaProvider);
    final permittedServices = allServices.where((s) => s.isPermitted).toList();

    final categories = <String, List<_ServiceItemData>>{};
    for (final service in permittedServices) {
      categories.putIfAbsent(service.category, () => []).add(service);
    }

    return Column(
      children: [
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: OrmawaTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: OrmawaTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 13, color: OrmawaTheme.primary),
              const SizedBox(width: 5),
              Text(
                'ROLE: ${ormawaProvider.userSubRole.toUpperCase()}',
                style: OrmawaTheme.textBadge.copyWith(
                  color: OrmawaTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Seluruh Menu & Layanan',
          style: OrmawaTheme.textPageTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 3),
        Text(
          'Akses fitur sesuai hak kelola peran organisasi',
          style: OrmawaTheme.textCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
            children: [
              ...categories.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 10),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: OrmawaTheme.textSectionTitle.copyWith(
                            fontSize: 11,
                            color: OrmawaTheme.textMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.80,
                        children: entry.value.map((item) {
                          return _ModalServiceIcon(
                            title: item.title,
                            icon: item.icon,
                            color: item.color,
                            bgColor: item.bgColor,
                            borderColor: item.borderColor,
                            target: item.target,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFE4E6), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFE11D48)),
                        const SizedBox(width: 8),
                        Text(
                          'Keluar Sesi Ormawa',
                          style: OrmawaTheme.textButton.copyWith(
                            color: const Color(0xFFE11D48),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
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
  final Color bgColor;
  final Color borderColor;
  final Widget? target;

  const _ModalServiceIcon({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    return BkuBounceButton(
      scaleFactor: 0.92,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (target != null) {
          Navigator.pop(context);
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.16),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 23,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: OrmawaTheme.textCardSubtitle.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.1,
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
  final Color bgColor;
  final Color borderColor;
  final Widget? target;
  final bool isMore;

  const _ServiceIcon({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
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
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.16),
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
            style: OrmawaTheme.textCardSubtitle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: OrmawaTheme.textHeading,
              letterSpacing: -0.1,
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: const OrmawaServiceGridModal(),
      ),
    );
  }
}
