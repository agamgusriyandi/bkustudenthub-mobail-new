import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_dashboard_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_schedule_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_booking_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_patient_list_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_settings_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_nav_bar.dart';

class TkMainScreen extends StatefulWidget {
  final int initialTab;
  const TkMainScreen({super.key, this.initialTab = 0});

  @override
  State<TkMainScreen> createState() => TkMainScreenState();
}

class TkMainScreenState extends State<TkMainScreen> {
  late int _selectedIndex;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go('/tenagakes?tab=$index');
  }

  final List<Widget> _pages = [
    const TkDashboardScreen(),
    const TkScheduleScreen(showBackButton: true),
    const TkBookingScreen(),
    const TkPatientListScreen(showBackButton: true),
    const TkSettingsScreen(showBackButton: false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkDashboardProvider>().loadDashboard();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final state = GoRouterState.of(context);
      final tabStr = state.uri.queryParameters['tab'];
      final tab = int.tryParse(tabStr ?? '0') ?? 0;
      if (_selectedIndex != tab) {
        setState(() {
          _selectedIndex = tab;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  void didUpdateWidget(TkMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _selectedIndex = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BkuBottomNavBar.tenagaKesehatan(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          context.go('/tenagakes?tab=$index');
        },
      ),
    );
  }
}
