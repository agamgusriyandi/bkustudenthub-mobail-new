import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/core/widgets/unified_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/profile/presentation/pages/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const DashboardScreen(key: PageStorageKey('dash_v1')),
    const KencanaScreen(key: PageStorageKey('kencana_v1')),
    const AchievementScreen(key: PageStorageKey('achieve_v1')),
    const ScholarshipScreen(key: PageStorageKey('scholar_v1')),
    const ProfileScreen(key: PageStorageKey('profile_v1')),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: UnifiedBottomNavBar.mahasiswa(
        currentIndex: currentIndex,
        onTap: (index) => navProvider.setIndex(index),
      ),
      extendBody: true,
    );
  }
}
