import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

// Modular Widgets
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/today_schedule_card.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_service_grid.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_status_grid.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_agenda_list.dart';

import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/notifications/presentation/pages/notifications_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentProvider>().loadAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final navProvider = context.read<NavigationProvider>();
    final name = student.name;
    final stats = student.dashboardStats;
    final totalMissions =
        stats['kencana']?['total_modul'] ?? student.missions.length;
    final completedMissions =
        stats['kencana']?['modul_selesai'] ??
        student.missions.where((m) => m.isCompleted).length;
    final pendingAspirations =
        stats['student_voice']?['jumlah_aktif'] ?? student.pendingAspirations;
    final latestHealth = student.latestHealthRecord;

    // Beasiswa uses 'jumlah_proses' + 'jumlah_menunggu' from stats, fallback to provider logic
    final statsBeasiswa = stats['beasiswa'];
    int appliedScholarships =
        student.scholarships.where((s) => s.applicationStatus != null).length;
    if (statsBeasiswa != null) {
      appliedScholarships =
          (statsBeasiswa['jumlah_proses'] ?? 0) +
          (statsBeasiswa['jumlah_menunggu'] ?? 0);
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => student.loadAllData(),
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: context.appColors.surface,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: name,
              subtitle: 'SELAMAT DATANG KEMBALI',
              info: '${student.nim} â€¢ SEMESTER ${student.semester}',
              variant: AppBarVariant.student,
              showBackButton: false,
              expandedHeight: 130,
              showProfileOnCollapse: true,
              profileImage:
                  student.fotoUrl != null && student.fotoUrl!.isNotEmpty
                      ? CachedNetworkImage(imageUrl: 
                        ApiGate.getImageUrl(student.fotoUrl!),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.person_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          );
                        },
                        placeholder: (context, url) => Container(color: AppColors.neutral200),
                      )
                      : Icon(
                        Icons.person_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
              showNotification: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const OrmawaQrScanScreen(
                              eventId: '',
                              eventTitle: 'Scan Presensi Mandiri',
                            ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Scan Presensi',
                ),
              ],
              onNotificationTap: (context, _) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentNotificationsScreen(),
                  ),
                );
              },
              onProfileTap: () => navProvider.setIndex(4),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Layanan Mahasiswa'),
                    const SizedBox(height: AppSpacing.md),
                    const StudentServiceGrid(),
                    const SizedBox(height: AppSpacing.s20),
                    const TodayScheduleCard(),
                    const SizedBox(height: AppSpacing.s20),
                    _buildSectionTitle('Status Kamu'),
                    const SizedBox(height: AppSpacing.md),
                    StudentStatusGrid(
                      isLoading: student.isLoading,
                      completedMissions: completedMissions,
                      totalMissions: totalMissions,
                      pendingAspirations: pendingAspirations,
                      appliedScholarships: appliedScholarships,
                      latestHealth: latestHealth,
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildSectionTitle('Berita Kampus'),
                    const SizedBox(height: AppSpacing.md),
                    const StudentAgendaList(),
                    const SizedBox(height: AppSpacing.s100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLg.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
