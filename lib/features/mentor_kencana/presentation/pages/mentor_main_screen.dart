import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_dashboard_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_mentee_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_attendance_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_scoring_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_profile_screen.dart';

class MentorMainScreen extends StatefulWidget {
  final int initialTab;
  const MentorMainScreen({super.key, this.initialTab = 0});

  @override
  State<MentorMainScreen> createState() => _MentorMainScreenState();
}

class _MentorMainScreenState extends State<MentorMainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const MentorDashboardScreen(key: PageStorageKey('mentor_dash')),
    const MentorMenteeScreen(key: PageStorageKey('mentor_mahasiswa')),
    const MentorAttendanceScreen(key: PageStorageKey('mentor_attendance')),
    const MentorScoringScreen(key: PageStorageKey('mentor_scoring')),
    const MentorProfileScreen(key: PageStorageKey('mentor_profile')),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MentorKencanaProvider>().fetchDashboard();
    });
  }

  @override
  void didUpdateWidget(MentorMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _selectedIndex = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MentorMainScreen build with selectedIndex: $_selectedIndex');
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BkuBottomNavBar.mentorKencana(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
