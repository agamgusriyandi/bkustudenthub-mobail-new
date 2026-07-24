import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';

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

/// UnifiedBottomNavBar - Single bottom navigation bar for all roles
///
/// Uses ThemeProvider to get dynamic colors from backend API.
/// Replaces multiple bottom nav variants (CustomBottomNavBar, OrmawaBottomNavBar, etc.)
class UnifiedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final bool enableHaptic;
  final AppBarVariant variant;

  const UnifiedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
    this.enableHaptic = true,
    this.variant = AppBarVariant.student,
  });

  /// Factory constructor for Mahasiswa
  factory UnifiedBottomNavBar.mahasiswa({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return UnifiedBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.mahasiswa,
      variant: AppBarVariant.student,
    );
  }

  /// Factory constructor for Ormawa
  factory UnifiedBottomNavBar.ormawa({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return UnifiedBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.ormawa,
      variant: AppBarVariant.ormawa,
    );
  }

  /// Factory constructor for Psychologist
  factory UnifiedBottomNavBar.psychologist({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return UnifiedBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.psychologist,
      variant: AppBarVariant.psychologist,
    );
  }

  /// Factory constructor for Tenaga Kesehatan
  factory UnifiedBottomNavBar.tenagaKesehatan({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return UnifiedBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.tenagaKesehatan,
      variant: AppBarVariant.nakes,
    );
  }

  /// Factory constructor for Mentor Kencana
  factory UnifiedBottomNavBar.mentorKencana({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return UnifiedBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: BottomNavPresets.mentorKencana,
      variant: AppBarVariant.student,
    );
  }

  @override
  State<UnifiedBottomNavBar> createState() => _UnifiedBottomNavBarState();
}

class _UnifiedBottomNavBarState extends State<UnifiedBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final items =
        widget.items.isEmpty ? BottomNavPresets.mahasiswa : widget.items;

    List<Color> gradientColors;
    switch (widget.variant) {
      case AppBarVariant.secondary:
        gradientColors = themeProvider.secondaryGradient;
        break;
      case AppBarVariant.student:
      case AppBarVariant.ormawa:
      case AppBarVariant.psychologist:
      case AppBarVariant.nakes:
        gradientColors = themeProvider.primaryGradient;
        break;
    }

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
        top: 6,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withAlpha(100),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/batik_pattern.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
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
                                        ? Colors.white.withAlpha(55)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
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
                                              ? Colors.white
                                              : Colors.white.withAlpha(160),
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
                                                left: 6,
                                              ),
                                              child: Text(
                                                item.label,
                                                style: const TextStyle(
                                                  color: Colors.white,
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
