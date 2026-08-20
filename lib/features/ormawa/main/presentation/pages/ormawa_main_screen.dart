import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/dashboard/presentation/pages/ormawa_dashboard_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/finance/presentation/pages/ormawa_finance_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_profile_screen.dart';

class OrmawaMainScreen extends StatefulWidget {
  const OrmawaMainScreen({super.key});

  @override
  State<OrmawaMainScreen> createState() => _OrmawaMainScreenState();
}

class _OrmawaMainScreenState extends State<OrmawaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OrmawaDashboardScreen(key: PageStorageKey('ormawa_dash')),
    const OrmawaProposalScreen(
      key: PageStorageKey('ormawa_proposal'),
      showBackButton: false,
    ),
    const OrmawaAbsensiScreen(
      key: PageStorageKey('ormawa_absensi'),
      showBackButton: false,
    ),
    const OrmawaFinanceScreen(
      key: PageStorageKey('ormawa_finance'),
      showBackButton: false,
    ),
    const OrmawaProfileScreen(
      key: PageStorageKey('ormawa_profile'),
      showBackButton: false,
    ),
  ];

  void _onNavigate(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BkuBottomNavBar.ormawa(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
      ),
      extendBody: true,
    );
  }
}