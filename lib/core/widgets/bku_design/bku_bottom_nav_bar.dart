import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';

import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
/// Navigation item definition
class BottomNavItem {
  final int index;
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavItem({
    required this.index,
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Predefined navigation sets for different roles
class BottomNavPresets {
  /// Navigation items for Mahasiswa (Student)
  static const List<BottomNavItem> mahasiswa = [
    BottomNavItem(index: 0, icon: Icons.grid_view_rounded, label: 'Home'),
    BottomNavItem(index: 1, icon: Icons.auto_awesome_rounded, label: 'Kencana'),
    BottomNavItem(
      index: 2,
      icon: Icons.emoji_events_rounded,
      label: 'Prestasi',
    ),
    BottomNavItem(index: 3, icon: Icons.school_rounded, label: 'Beasiswa'),
    BottomNavItem(index: 4, icon: Icons.person_rounded, label: 'Profil'),
  ];

  /// Navigation items for Ormawa
  static const List<BottomNavItem> ormawa = [
    BottomNavItem(index: 0, icon: Icons.grid_view_rounded, label: 'Dashboard'),
    BottomNavItem(index: 1, icon: Icons.assignment_rounded, label: 'Proposal'),
    BottomNavItem(
      index: 2,
      icon: Icons.qr_code_scanner_rounded,
      label: 'Absensi',
    ),
    BottomNavItem(
      index: 3,
      icon: Icons.account_balance_wallet_rounded,
      label: 'Keuangan',
    ),
    BottomNavItem(index: 4, icon: Icons.settings_rounded, label: 'Pengaturan'),
  ];

  /// Navigation items for Psychologist
  static const List<BottomNavItem> psychologist = [
    BottomNavItem(index: 0, icon: Icons.dashboard_rounded, label: 'Home'),
    BottomNavItem(index: 1, icon: Icons.event_note_rounded, label: 'Booking'),
    BottomNavItem(index: 2, icon: Icons.people_alt_rounded, label: 'Pasien'),
    BottomNavItem(index: 3, icon: Icons.settings_rounded, label: 'Settings'),
  ];

  /// Navigation items for Tenaga Kesehatan
  static const List<BottomNavItem> tenagaKesehatan = [
    BottomNavItem(index: 0, icon: Icons.dashboard_rounded, label: 'Home'),
    BottomNavItem(index: 1, icon: Icons.schedule_rounded, label: 'Jadwal'),
    BottomNavItem(index: 2, icon: Icons.event_note_rounded, label: 'Booking'),
    BottomNavItem(index: 3, icon: Icons.people_alt_rounded, label: 'Pasien'),
    BottomNavItem(index: 4, icon: Icons.settings_rounded, label: 'Setelan'),
  ];

  /// Navigation items for Mentor Kencana
  static const List<BottomNavItem> mentorKencana = [
    BottomNavItem(index: 0, icon: Icons.dashboard_rounded, label: 'Dashboard'),
    BottomNavItem(index: 1, icon: Icons.groups_rounded, label: 'Mahasiswa'),
    BottomNavItem(index: 2, icon: Icons.how_to_reg_rounded, label: 'Kehadiran'),
    BottomNavItem(index: 3, icon: Icons.grade_rounded, label: 'Skoring'),
    BottomNavItem(index: 4, icon: Icons.person_rounded, label: 'Profil'),
  ];
}

/// BkuBottomNavBar - Single bottom navigation bar for all roles
///
/// Uses ThemeProvider to get dynamic colors from backend API.
/// Replaces multiple bottom nav variants (CustomBottomNavBar, OrmawaBottomNavBar, etc.)
class BkuBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final bool enableHaptic;
  final AppBarVariant variant;

  const BkuBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
    this.enableHaptic = true,
    this.variant = AppBarVariant.student,
  });

  /// Factory constructor for Mahasiswa
  factory BkuBottomNavBar.mahasiswa({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BkuBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.mahasiswa,
      variant: AppBarVariant.student,
    );
  }

  /// Factory constructor for Ormawa
  factory BkuBottomNavBar.ormawa({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BkuBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.ormawa,
      variant: AppBarVariant.ormawa,
    );
  }

  /// Factory constructor for Psychologist
  factory BkuBottomNavBar.psychologist({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BkuBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.psychologist,
      variant: AppBarVariant.psychologist,
    );
  }

  /// Factory constructor for Tenaga Kesehatan
  factory BkuBottomNavBar.tenagaKesehatan({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BkuBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.tenagaKesehatan,
      variant: AppBarVariant.nakes,
    );
  }

  /// Factory constructor for Mentor Kencana
  factory BkuBottomNavBar.mentorKencana({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BkuBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.mentorKencana,
      variant: AppBarVariant.student,
    );
  }

  @override
  State<BkuBottomNavBar> createState() => _BkuBottomNavBarState();
}

class _BkuBottomNavBarState extends State<BkuBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final items =
        widget.items.isEmpty ? BottomNavPresets.mahasiswa : widget.items;

    Color solidColor;
    switch (widget.variant) {
      case AppBarVariant.secondary:
        solidColor = themeProvider.secondary;
        break;
      case AppBarVariant.student:
      case AppBarVariant.ormawa:
      case AppBarVariant.psychologist:
      case AppBarVariant.nakes:
        solidColor = themeProvider.primary;
        break;
    }

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.md,
        top: AppSpacing.s6,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusXxl,
          color: solidColor,
          boxShadow: [
            BoxShadow(
              color: solidColor.withAlpha(100),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusXxl,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/batik_pattern.png'),
                        repeat: ImageRepeat.repeat,
                        scale: 4.0,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        items.map((item) {
                          final isSelected = widget.currentIndex == item.index;
                          return GestureDetector(
                            onTap: () => widget.onTap(item.index),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuint,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 16 : 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? context.appColors.onPrimary.withAlpha(55)
                                        : Colors.transparent,
                                borderRadius: AppRadius.br20,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      isSelected
                                          ? (item.activeIcon ?? item.icon)
                                          : item.icon,
                                      key: ValueKey<bool>(isSelected),
                                      color:
                                          isSelected
                                              ? context.appColors.onPrimary
                                              : context.appColors.onPrimary.withAlpha(160),
                                      size: 22,
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutQuint,
                                    child:
                                        isSelected
                                            ? Padding(
                                              padding: const EdgeInsets.only(
                                                left: AppSpacing.s6,
                                              ),
                                              child: Text(
                                                item.label,
                                                style: TextStyle(
                                                  color: context.appColors.onPrimary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
