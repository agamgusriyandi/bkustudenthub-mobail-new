import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_dashboard_screen.dart';
import 'package:bkuhub_mobile/core/widgets/unified_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/patient_list_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_bookings_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_settings_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';

class PsychologistMainScreen extends StatefulWidget {
  const PsychologistMainScreen({super.key});

  @override
  State<PsychologistMainScreen> createState() => _PsychologistMainScreenState();
}

class _PsychologistMainScreenState extends State<PsychologistMainScreen> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PsychologistDashboardScreen(),
      PsychologistBookingsScreen(
        onBack: () => context.read<NavigationProvider>().setIndex(0),
      ),
      PatientListScreen(
        showBackButton: true,
        onBack: () => context.read<NavigationProvider>().setIndex(0),
      ),
      PsychologistSettingsScreen(
        showBackButton: true,
        onBack: () => context.read<NavigationProvider>().setIndex(0),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PsychologistDashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(index: navProvider.currentIndex, children: _pages),
      bottomNavigationBar: UnifiedBottomNavBar.psychologist(
        currentIndex: navProvider.currentIndex,
        onTap: (index) => navProvider.setIndex(index),
      ),
    );
  }
}
