import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

// Modular Widgets
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/banner_pinned.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/deadline_alert.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/today_schedule_card.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_service_grid.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_status_grid.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/student_agenda_list.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/activity_feed.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/available_scholarships.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/calendar_mini.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/ipk_chart_card.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/insurance_tracker_card.dart';


import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/notifications/presentation/pages/notifications_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';
import 'package:bkuhub_mobile/core/utils/string_extensions.dart';
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
        context.read<ProfileProvider>().fetchProfile();
        context.read<AcademicProvider>().loadAcademicData();
        context.read<MahasiswaCounselingProvider>().loadCounselingData();
        context.read<ScholarshipProvider>().loadScholarships();
        context.read<HealthViewModel>().loadInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final academic = context.watch<AcademicProvider>();
    final counseling = context.watch<MahasiswaCounselingProvider>();
    final scholarship = context.watch<ScholarshipProvider>();
    final health = context.watch<HealthViewModel>();
    final navProvider = context.read<NavigationProvider>();
    final name = profile.name;
    final stats = academic.dashboardStats;
    // Web uses persentase and status
    final statsKencana = stats['kencana'];
    final kencanaPercentage = statsKencana?['persentase'] ?? 0.0;
    final kencanaStatus = statsKencana?['status'] ?? 'Belum Dimulai';

    final statsVoice = stats['student_voice'];
    final voiceAktif =
        statsVoice?['jumlah_aktif'] ?? counseling.pendingAspirations;
    final voiceMenunggu = statsVoice?['jumlah_belum_direspons'] ?? 0;

    final statsBeasiswa = stats['beasiswa'];
    final beasiswaTersedia = statsBeasiswa?['total_tersedia'] ?? 0;

    final latestHealth = health.latestHealthRecord;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          final profileProvider = context.read<ProfileProvider>();
          final academicProvider = context.read<AcademicProvider>();
          final counselingProvider = context.read<MahasiswaCounselingProvider>();
          final scholarshipProvider = context.read<ScholarshipProvider>();
          final healthProvider = context.read<HealthViewModel>();
          
          await profileProvider.fetchProfile();
          await academicProvider.loadAcademicData();
          await counselingProvider.loadCounselingData();
          await scholarshipProvider.loadScholarships();
          await healthProvider.loadInitialData();
        },
        color: context.appColors.primary,
        backgroundColor: context.appColors.surface,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: name.toTitleCase(),
              subtitle: 'Selamat Datang Kembali',
              info: '${profile.nim} • Semester ${profile.semester}',
              variant: AppBarVariant.student,
              showBackButton: false,
              expandedHeight: 130,
              showProfileOnCollapse: true,
              profileImage:
                  profile.fotoUrl != null && profile.fotoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: ApiGate.getImageUrl(profile.fotoUrl!),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.person_rounded,
                            color: context.appColors.primary,
                            size: 28,
                          );
                        },
                        placeholder:
                            (context, url) =>
                                Container(color: AppColors.neutral200),
                      )
                      : Icon(
                        Icons.person_rounded,
                        color: context.appColors.primary,
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
                  icon: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: context.appColors.surface,
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

                    // 1. Layanan Cepat
                    _buildSectionTitle('Layanan Cepat'),
                    const SizedBox(height: AppSpacing.md),
                    const StudentServiceGrid(),
                    const SizedBox(height: AppSpacing.s20),

                    // 2. Banner Pinned (matches web BannerPinned.jsx)
                    const BannerPinned(),
                    const SizedBox(height: AppSpacing.s20),

                    // 2. Deadline Alert (matches web DeadlineAlert.jsx)
                    DeadlineAlert(deadlines: _buildDeadlines(scholarship)),
                    const SizedBox(height: AppSpacing.s20),

                    // 3. Today Schedule (mobile extra)
                    const TodayScheduleCard(),
                    const SizedBox(height: AppSpacing.s20),

                    // 4. Status Kamu (matches web PrimaryStatsCard)
                    _buildSectionTitle('Status Kamu'),
                    const SizedBox(height: AppSpacing.md),
                    StudentStatusGrid(
                      isLoading: profile.isLoading,
                      kencanaPercentage: kencanaPercentage,
                      kencanaStatus: kencanaStatus,
                      beasiswaTersedia: beasiswaTersedia,
                      voiceAktif: voiceAktif,
                      voiceMenunggu: voiceMenunggu,
                      latestHealth: latestHealth,
                    ),
                    const SizedBox(height: AppSpacing.s20),



                    // 6. Aktivitas Terbaru (matches web ActivityFeed.jsx)
                    _buildSectionTitle('Aktivitas Terbaru'),
                    const SizedBox(height: AppSpacing.md),
                    ActivityFeed(activities: _buildActivities(academic, counseling)),
                    const SizedBox(height: AppSpacing.s20),

                    // 7. Beasiswa Tersedia (matches web AvailableScholarships.jsx)
                    _buildSectionTitle('Beasiswa Tersedia'),
                    const SizedBox(height: AppSpacing.md),
                    AvailableScholarships(
                      scholarships: _buildScholarshipItems(scholarship),
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // 8. Kalender Mini (matches web CalendarMini.jsx)
                    CalendarMini(events: _buildCalendarEvents(academic)),
                    const SizedBox(height: AppSpacing.s20),


                    // 10. IPK Chart (mobile extra)
                    IpkChartCard(
                      currentIpk: profile.ipk,
                      currentSemester: profile.semester,
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // 11. Asuransi (mobile extra)
                    InsuranceTrackerCard(claims: health.insuranceClaims),
                    const SizedBox(height: AppSpacing.s20),

                    // 12. Berita Kampus (mobile extra)
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
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }

  List<DeadlineItem> _buildDeadlines(ScholarshipProvider scholarship) {
    final now = DateTime.now();
    final items = <DeadlineItem>[];
    for (final s in scholarship.scholarships) {
      if (s.applicationStatus == null && s.status == 'Open') {
        final deadline = DateTime.tryParse(s.deadline);
        if (deadline != null && deadline.isAfter(now)) {
          items.add(
            DeadlineItem(
              name: s.title,
              daysLeft: deadline.difference(now).inDays,
              type: 'beasiswa',
            ),
          );
        }
      }
    }
    return items;
  }

  List<ActivityItem> _buildActivities(AcademicProvider academic, MahasiswaCounselingProvider counseling) {
    final items = <ActivityItem>[];
    for (final a in academic.achievements.take(3)) {
      items.add(
        ActivityItem(
          description: '${a.title} (${a.status})',
          createdAt: a.date,
          type: 'achievement',
        ),
      );
    }
    for (final cs in counseling.counselingSessions.take(3)) {
      items.add(
        ActivityItem(
          description: '${cs.topic} — ${cs.psychologistName}',
          createdAt: cs.date,
          type: 'konseling',
        ),
      );
    }
    for (final m in academic.missions.take(3)) {
      items.add(
        ActivityItem(
          description: m.title ?? m.desc ?? 'Modul Kencana',
          createdAt: DateTime.now(),
          type: 'kencana',
        ),
      );
    }
    for (final asp in counseling.aspirations.take(3)) {
      items.add(
        ActivityItem(
          description: asp.title,
          createdAt: asp.date,
          type: 'voice',
        ),
      );
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(6).toList();
  }

  List<ScholarshipItem> _buildScholarshipItems(ScholarshipProvider scholarship) {
    return scholarship.scholarships.where((s) => s.status == 'Open').take(4).map((
      s,
    ) {
      final amount =
          double.tryParse(s.coverAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      final deadline = DateTime.tryParse(s.deadline);
      return ScholarshipItem(
        id: s.id,
        name: s.title,
        organizer: s.provider,
        category: s.category,
        amount: amount,
        deadline: deadline,
        status: s.status,
      );
    }).toList();
  }

  List<CalendarEvent> _buildCalendarEvents(AcademicProvider academic) {
    return academic.campusEvents.take(10).map((e) {
      return CalendarEvent(
        title: e.judul,
        date: e.tanggal,
        category: e.kategori,
      );
    }).toList();
  }
}
