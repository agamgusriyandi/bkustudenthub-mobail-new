import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/psychologist_list_screen.dart';

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({super.key});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  int _selectedTabIndex = 0;
  int _currentBookingPage = 1;
  static const int _bookingPerPage = 10;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
      context.read<StudentCounselingProvider>().loadPsychologists();
      context.read<StudentCounselingProvider>().loadMyReferrals();
      context.read<StudentCounselingProvider>().loadMyBookings();
      context.read<StudentCounselingProvider>().loadMyMedicalRecord();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<StudentCounselingProvider>().loadMyBookings(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        color: BkuTheme.primary,
        onRefresh: () async {
          await Future.wait([
            context.read<ProfileProvider>().fetchProfile(),
            context.read<StudentCounselingProvider>().loadPsychologists(),
            context.read<StudentCounselingProvider>().loadMyReferrals(),
            context.read<StudentCounselingProvider>().loadMyBookings(),
            context.read<StudentCounselingProvider>().loadMyMedicalRecord(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'Layanan Konseling',
              subtitle: 'Care & Support Mahasiswa',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PsychologistListScreen(autoFocusSearch: true),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const FadeInAnimation(
                      delay: 0.1,
                      child: _CounselingBanner(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeInAnimation(
                      delay: 0.15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Psikolog Kampus',
                                style: BkuTheme.textSectionTitle.copyWith(
                                  fontSize: 14,
                                  color: BkuTheme.textHeading,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PsychologistListScreen(),
                                  ),
                                ),
                                borderRadius: BkuTheme.rPill,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    'Lihat Semua',
                                    style: BkuTheme.textBadge.copyWith(
                                      color: BkuTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Consumer<StudentCounselingProvider>(
                            builder: (context, counselingProvider, _) {
                              if (counselingProvider.psychologistsLoading) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Row(
                                    children: List.generate(
                                      2,
                                      (index) => const Padding(
                                        padding: EdgeInsets.only(right: AppSpacing.md),
                                        child: BkuShimmer(
                                          width: 140,
                                          height: 190,
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final psychologists = counselingProvider.psychologists;
                              if (psychologists.isEmpty) {
                                return Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.cardSurface,
                                    borderRadius: BkuTheme.r16,
                                    border: Border.all(color: BkuTheme.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Belum ada psikolog tersedia',
                                      style: BkuTheme.textCaption,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: psychologists.length,
                                  itemBuilder: (context, index) => FadeInAnimation(
                                    delay: 0.2 + (index * 0.05),
                                    child: _buildPsychologistCardFromMap(
                                      context,
                                      psychologists[index],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeInAnimation(
                      delay: 0.25,
                      child: student.isLoading
                          ? const BkuShimmer(
                              width: double.infinity,
                              height: 100,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            )
                          : _buildDashboardSection(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeInAnimation(
                      delay: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: BkuTheme.borderSubtle,
                          borderRadius: BkuTheme.r12,
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, 'Sesi Konseling'),
                            _buildTabItem(1, 'Surat Rujukan'),
                            _buildTabItem(2, 'Rekam Medis'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_selectedTabIndex == 0) ...[
                      Consumer<StudentCounselingProvider>(
                        builder: (context, provider, _) {
                          if (provider.myBookingsLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          if (provider.myBookings.isEmpty) {
                            return _buildEmptyState('Belum ada riwayat sesi konseling');
                          }

                          final totalBookings = provider.myBookings.length;
                          final totalPages = (totalBookings / _bookingPerPage).ceil();
                          final validPage = _currentBookingPage.clamp(1, totalPages > 0 ? totalPages : 1);
                          final startIndex = (validPage - 1) * _bookingPerPage;
                          final endIndex = (startIndex + _bookingPerPage < totalBookings)
                              ? startIndex + _bookingPerPage
                              : totalBookings;
                          final paginatedBookings = provider.myBookings.sublist(startIndex, endIndex);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(paginatedBookings.length, (index) {
                                final booking = paginatedBookings[index];
                                return FadeInAnimation(
                                  delay: 0.05 + (index * 0.04),
                                  child: _buildRealSessionCard(context, booking),
                                );
                              }),
                              if (totalPages > 1) ...[
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: validPage > 1
                                          ? () => setState(() => _currentBookingPage = validPage - 1)
                                          : null,
                                      icon: const Icon(Icons.chevron_left_rounded, size: 16),
                                      label: Text('Sebelumnya', style: BkuTheme.textCaption),
                                    ),
                                    Text('Halaman $validPage / $totalPages', style: BkuTheme.textCaption),
                                    TextButton.icon(
                                      onPressed: validPage < totalPages
                                          ? () => setState(() => _currentBookingPage = validPage + 1)
                                          : null,
                                      icon: const Icon(Icons.chevron_right_rounded, size: 16),
                                      label: Text('Berikutnya', style: BkuTheme.textCaption),
                                      iconAlignment: IconAlignment.end,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ] else if (_selectedTabIndex == 1) ...[
                      Consumer<StudentCounselingProvider>(
                        builder: (context, provider, _) {
                          if (provider.myReferralsLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          if (provider.myReferrals.isEmpty) {
                            return _buildEmptyState('Belum ada surat rujukan konseling');
                          }
                          return Column(
                            children: List.generate(
                              provider.myReferrals.length,
                              (index) => FadeInAnimation(
                                delay: 0.05 + (index * 0.04),
                                child: _buildReferralCard(context, provider.myReferrals[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Consumer<StudentCounselingProvider>(
                        builder: (context, provider, _) {
                          if (provider.medicalRecordLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          final records = (provider.myMedicalRecord['records'] as List?)
                                  ?.cast<Map<String, dynamic>>() ??
                              const [];
                          if (records.isEmpty) {
                            return _buildEmptyState('Belum ada riwayat rekam medis');
                          }
                          return Column(
                            children: List.generate(
                              records.length,
                              (index) => FadeInAnimation(
                                delay: 0.05 + (index * 0.04),
                                child: _buildMedicalRecordCard(context, records[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? BkuTheme.cardSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? BkuTheme.cardShadow : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: BkuTheme.textCaption.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? BkuTheme.textHeading : BkuTheme.textMuted,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.myBookings;
        final total = bookings.length.toString();
        final pending = bookings
            .where((s) => s['status'] == 'Menunggu' || s['status'] == 'Dikonfirmasi')
            .length
            .toString();
        final completed = bookings.where((s) => s['status'] == 'Selesai').length.toString();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r16,
            border: Border.all(color: BkuTheme.border),
            boxShadow: BkuTheme.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Total Sesi', total, Icons.history_rounded, BkuTheme.indigo, BkuTheme.indigoSoft),
              _buildMiniStat('Menunggu', pending, Icons.pending_actions_rounded, BkuTheme.amber, BkuTheme.amberSoft),
              _buildMiniStat('Selesai', completed, Icons.check_circle_rounded, BkuTheme.emerald, BkuTheme.emeraldSoft),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: BkuTheme.textKpiValue.copyWith(fontSize: 16),
        ),
        Text(
          label,
          style: BkuTheme.textBadge.copyWith(
            color: BkuTheme.textMuted,
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPsychologistCardFromMap(
    BuildContext context,
    Map<String, dynamic> p,
  ) {
    final name = p['Nama']?.toString() ??
        p['nama']?.toString() ??
        p['name']?.toString() ??
        '-';
    final spec = p['Spesialisasi']?.toString() ??
        p['spesialisasi']?.toString() ??
        p['specialization']?.toString() ??
        '-';
    final id = (p['id'] ?? p['ID'] ?? p['dosen_id'] ?? p['DosenID'])?.toString() ?? '';
    final isActive = p['IsAktif'] == true ||
        p['is_aktif'] == true ||
        p['is_active'] == true ||
        p['isAvailable'] == true;
    final initials = name.trim().isEmpty
        ? 'P'
        : name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0])
            .join();

    final rawPhoto = () {
      final possibleKeys = [
        'foto_url',
        'photo_url',
        'photoUrl',
        'FotoURL',
        'foto',
        'Foto',
        'avatar_url',
        'avatar',
      ];
      for (final key in possibleKeys) {
        if (p[key] != null && p[key].toString().trim().isNotEmpty) {
          return p[key].toString().trim();
        }
      }
      final user = p['user'] ?? p['User'] ?? p['Pengguna'] ?? p['pengguna'];
      if (user is Map) {
        for (final key in possibleKeys) {
          if (user[key] != null && user[key].toString().trim().isNotEmpty) {
            return user[key].toString().trim();
          }
        }
      }
      return '';
    }();
    final photoUrl = rawPhoto.isNotEmpty ? ApiGate.getImageUrl(rawPhoto) : '';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive
              ? () => context.push('${AppRoutes.counselingBooking}?psikolog_id=$id')
              : null,
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: photoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    initials,
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 18),
                                  ),
                                ),
                              )
                            : Container(
                                color: BkuTheme.indigoSoft,
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: BkuTheme.textCardTitle.copyWith(
                                      fontSize: 18,
                                      color: BkuTheme.indigo,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive ? BkuTheme.emerald : BkuTheme.textPlaceholder,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name.split(',')[0],
                  textAlign: TextAlign.center,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  spec.split('&')[0].trim(),
                  textAlign: TextAlign.center,
                  style: BkuTheme.textCaption.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? BkuTheme.emerald : BkuTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Booking' : 'Off',
                    textAlign: TextAlign.center,
                    style: BkuTheme.textBadge.copyWith(
                      color: isActive ? Colors.white : BkuTheme.textMuted,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealSessionCard(BuildContext context, dynamic map) {
    final session = map as Map<String, dynamic>;
    final psikolog = session['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? '-';
    final topic = session['topic']?.toString() ?? '-';
    final start = session['start']?.toString() ?? '-';
    final end = session['end']?.toString() ?? '';
    final timeStr = end.isNotEmpty ? '$start - $end' : start;
    final statusStr = session['status']?.toString() ?? 'Menunggu';
    final displayDate = session['display_date']?.toString() ?? '-';

    Color statusBg = BkuTheme.statusWarningBg;
    Color statusText = BkuTheme.statusWarningText;
    Color statusBorder = BkuTheme.statusWarningBorder;
    IconData cardIcon = Icons.hourglass_top_rounded;

    switch (statusStr.toLowerCase()) {
      case 'dikonfirmasi':
        statusBg = BkuTheme.indigoSoft;
        statusText = BkuTheme.indigo;
        statusBorder = BkuTheme.indigoBorder;
        cardIcon = Icons.event_available_rounded;
        break;
      case 'selesai':
        statusBg = BkuTheme.statusSuccessBg;
        statusText = BkuTheme.statusSuccessText;
        statusBorder = BkuTheme.statusSuccessBorder;
        cardIcon = Icons.task_alt_rounded;
        break;
      case 'ditolak':
      case 'dibatalkan':
        statusBg = BkuTheme.statusDangerBg;
        statusText = BkuTheme.statusDangerText;
        statusBorder = BkuTheme.statusDangerBorder;
        cardIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRealSessionDetail(context, session),
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: statusBorder),
                  ),
                  child: Icon(cardIcon, color: statusText, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        psikologName,
                        style: BkuTheme.textCaption.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: BkuTheme.textPlaceholder),
                          const SizedBox(width: 3),
                          Text(timeStr, style: BkuTheme.textCaption.copyWith(fontSize: 10)),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today_rounded, size: 11, color: BkuTheme.textPlaceholder),
                          const SizedBox(width: 3),
                          Text(displayDate, style: BkuTheme.textCaption.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BkuTheme.rPill,
                    border: Border.all(color: statusBorder),
                  ),
                  child: Text(
                    statusStr,
                    style: BkuTheme.textBadge.copyWith(
                      color: statusText,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRealSessionDetail(BuildContext context, Map<String, dynamic> session) {
    final statusStr = session['status']?.toString() ?? 'Menunggu';
    final isCompleted = statusStr.toLowerCase() == 'selesai';
    final psikolog = session['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? '-';
    final topic = session['topic']?.toString() ?? '-';
    final start = session['start']?.toString() ?? '-';
    final end = session['end']?.toString() ?? '';
    final timeStr = end.isNotEmpty ? '$start - $end' : start;
    final displayDate = session['display_date']?.toString() ?? '-';
    final mode = session['mode']?.toString() ?? 'Tatap Muka';
    final linkMeeting = session['link_meeting']?.toString() ?? '';
    final hasMedicalRecord = session['has_medical_record'] == true ||
        (session['medical_record_count'] != null &&
            (session['medical_record_count'] as num) > 0);

    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Sesi Konseling', style: BkuTheme.textPageTitle.copyWith(fontSize: 16)),
            Text(statusStr, style: BkuTheme.textCardSubtitle),
            const SizedBox(height: AppSpacing.xl),
            _buildDetailItem('Topik', topic, Icons.topic_rounded),
            _buildDetailItem('Psikolog', psikologName, Icons.person_rounded),
            _buildDetailItem('Jadwal', '$displayDate • $timeStr', Icons.access_time_rounded),
            _buildDetailItem('Mode', mode, Icons.devices_rounded),
            if (linkMeeting.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: BkuButton(
                  text: 'Gabung Sesi Online',
                  icon: Icons.videocam_rounded,
                  onPressed: () async {
                    final uri = Uri.parse(linkMeeting);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                    }
                  },
                ),
              ),
            ],
            if (hasMedicalRecord) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: BkuButton(
                  text: 'Unduh Laporan Konseling (PDF)',
                  icon: Icons.download_rounded,
                  variant: BkuButtonVariant.danger,
                  onPressed: () async {
                    final token = AuthService().token;
                    final bId = session['id']?.toString() ?? '';
                    final uri = Uri.parse('${ApiGate.baseUrl}/counseling/psychologist-bookings/$bId/export-pdf?token=$token');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: BkuButton(
                text: isCompleted ? 'Konseling Lanjutan' : 'Reschedule Jadwal',
                variant: BkuButtonVariant.success,
                onPressed: () {
                  context.pop();
                  final psychId = (session['psychologist_id'] ?? session['id'])?.toString() ?? '';
                  context.push('${AppRoutes.counselingBooking}?psikolog_id=$psychId');
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: BkuButton(
                text: 'Tutup',
                variant: BkuButtonVariant.outline,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 16, color: BkuTheme.indigo),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: BkuTheme.textCardSubtitle),
          const Spacer(),
          Text(value, style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, Map<String, dynamic> ref) {
    final type = ref['type'] ?? ref['tipe'] ?? '-';
    final target = ref['target_party'] ?? ref['pihak_tujuan'] ?? '-';
    final status = ref['status'] ?? 'Menunggu';
    final reason = ref['reason'] ?? ref['alasan'] ?? '-';
    final createdAtStr = ref['display_date'] ?? ref['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(createdAtStr, style: BkuTheme.textCaption),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.rPill,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: Text(
                  status.toString(),
                  style: BkuTheme.textBadge.copyWith(color: BkuTheme.indigo, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tujuan: $target', style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5)),
          const SizedBox(height: 2),
          Text('Tipe: $type • Alasan: $reason', style: BkuTheme.textCaption),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(BuildContext context, Map<String, dynamic> record) {
    final title = record['title'] ?? record['judul'] ?? 'Rekam Medis';
    final date = record['date'] ?? record['tanggal'] ?? '';
    final psychologist = record['psychologist'] ?? record['psikolog'] ?? '-';
    final status = record['status'] ?? 'Selesai';
    final summary = record['summary'] ?? record['ringkasan'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date.toString(), style: BkuTheme.textCaption),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: BkuTheme.emeraldSoft,
                  borderRadius: BkuTheme.rPill,
                  border: Border.all(color: BkuTheme.emeraldBorder),
                ),
                child: Text(
                  status.toString(),
                  style: BkuTheme.textBadge.copyWith(color: BkuTheme.emerald, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title.toString(), style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5)),
          const SizedBox(height: 2),
          Text('Psikolog: $psychologist', style: BkuTheme.textCaption),
          if (summary.toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              summary.toString(),
              style: BkuTheme.textCaption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.psychology_outlined, size: 48, color: BkuTheme.textPlaceholder),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: BkuTheme.textCaption),
          ],
        ),
      ),
    );
  }
}

class _CounselingBanner extends StatelessWidget {
  const _CounselingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BkuTheme.indigoSoft,
                    borderRadius: BkuTheme.rPill,
                    border: Border.all(color: BkuTheme.indigoBorder),
                  ),
                  child: Text(
                    'CARE & SUPPORT',
                    style: BkuTheme.textBadge.copyWith(
                      color: BkuTheme.indigo,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Kamu Tidak Sendirian.',
                  style: BkuTheme.textPageTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 3),
                Text(
                  'Konsultasi nyaman dan rahasia bersama psikolog kampus.',
                  style: BkuTheme.textCardSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BkuTheme.indigoSoft,
              borderRadius: BkuTheme.r16,
              border: Border.all(color: BkuTheme.indigoBorder),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: BkuTheme.indigo,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}