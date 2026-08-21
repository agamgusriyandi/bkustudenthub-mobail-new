import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:printing/printing.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/psychologist_list_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_edit_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/medical_record_detail_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/counseling_booking_screen.dart';

class CounselingScreen extends StatefulWidget {
  final int initialTabIndex;

  const CounselingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  late int _selectedTabIndex;
  String _filterBookingStatus = 'Semua';
  int _currentBookingPage = 1;
  static const int _bookingPerPage = 10;
  Timer? _pollingTimer;

  static const List<String> _statusFilterOptions = [
    'Semua',
    'Menunggu',
    'Dikonfirmasi',
    'Selesai',
    'Batal / Tolak',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
      context.read<StudentCounselingProvider>().loadPsychologists();
      context.read<StudentCounselingProvider>().loadAvailableSchedules();
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

  Future<void> _downloadPDF(String endpoint, String title) async {
    try {
      if (mounted) AppSnackbar.showInfo(context, 'Menyiapkan berkas $title...');
      final cleanPath = endpoint.startsWith('/api') ? endpoint.substring(4) : endpoint;
      final response = await ApiClient().client.get<List<int>>(
        cleanPath,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && response.data!.isNotEmpty) {
        final bytes = Uint8List.fromList(response.data!);
        await Printing.layoutPdf(
          name: '${title.replaceAll(' ', '_')}.pdf',
          onLayout: (format) async => bytes,
        );
      } else {
        if (mounted) AppSnackbar.showError(context, 'Berkas $title kosong atau tidak dapat diunduh.');
      }
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, 'Gagal mengunduh berkas $title');
    }
  }

  String _formatDateNice(String rawDate) {
    if (rawDate.isEmpty || rawDate == '-') return '-';
    try {
      final dt = DateTime.parse(rawDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _getStatusGroup(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'menunggu' || s == 'menunggu konfirmasi' || s == 'pending' || s == 'draft') return 'Menunggu';
    if (s == 'dikonfirmasi' || s == 'confirmed' || s == 'perlu kontrol') return 'Dikonfirmasi';
    if (s == 'selesai' || s == 'completed') return 'Selesai';
    if (s == 'dibatalkan' || s == 'cancelled' || s == 'canceled' || s == 'ditolak' || s == 'rejected') return 'Batal / Tolak';
    return 'Lainnya';
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> list) {
    if (_filterBookingStatus == 'Semua') return list;
    return list.where((b) {
      final group = _getStatusGroup(b['status']?.toString() ?? '');
      return group == _filterBookingStatus;
    }).toList();
  }

  Future<void> _handleCancelBooking(Map<String, dynamic> booking) async {
    final bookingId = booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Jadwal Konseling?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pengajuan sesi konseling ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<StudentCounselingProvider>().cancelBooking(bookingId);
      if (mounted) {
        if (success) {
          AppSnackbar.showSuccess(context, 'Jadwal konseling berhasil dibatalkan');
          context.read<StudentCounselingProvider>().loadMyBookings();
        } else {
          AppSnackbar.showError(context, 'Gagal membatalkan jadwal konseling');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = context.read<StudentCounselingProvider>();
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CounselingBookingScreen(),
            ),
          );
          if (res == true) {
            provider.loadMyBookings();
          }
        },
        backgroundColor: BkuTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Daftar Konseling',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        color: BkuTheme.primary,
        onRefresh: () async {
          await Future.wait([
            context.read<ProfileProvider>().fetchProfile(),
            context.read<StudentCounselingProvider>().loadPsychologists(),
            context.read<StudentCounselingProvider>().loadAvailableSchedules(),
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
              subtitle: 'Care & Support Mahasiswa BKU',
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
                                'Psikolog & Konselor Kampus',
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
                      child: _buildDashboardSection(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeInAnimation(
                      delay: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, 'Antrean'),
                            _buildTabItem(1, 'Rekam Medis'),
                            _buildTabItem(2, 'Surat Rujukan'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_selectedTabIndex == 0) ...[
                      _buildStatusFilterChips(),
                      const SizedBox(height: AppSpacing.md),
                      Consumer<StudentCounselingProvider>(
                        builder: (context, provider, _) {
                          if (provider.myBookingsLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          final filtered = _filterBookings(provider.myBookings);
                          if (filtered.isEmpty) {
                            return _buildEmptyState(
                              _filterBookingStatus == 'Semua'
                                  ? 'Belum ada antrean konseling aktif.'
                                  : 'Tidak ada sesi dengan status "$_filterBookingStatus".',
                            );
                          }

                          final totalBookings = filtered.length;
                          final totalPages = (totalBookings / _bookingPerPage).ceil();
                          final validPage = _currentBookingPage.clamp(1, totalPages > 0 ? totalPages : 1);
                          final startIndex = (validPage - 1) * _bookingPerPage;
                          final endIndex = (startIndex + _bookingPerPage < totalBookings)
                              ? startIndex + _bookingPerPage
                              : totalBookings;
                          final paginatedBookings = filtered.sublist(startIndex, endIndex);

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
                                      label: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
                                    ),
                                    Text('Halaman $validPage / $totalPages', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                    TextButton.icon(
                                      onPressed: validPage < totalPages
                                          ? () => setState(() => _currentBookingPage = validPage + 1)
                                          : null,
                                      icon: const Icon(Icons.chevron_right_rounded, size: 16),
                                      label: const Text('Berikutnya', style: TextStyle(fontSize: 12)),
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
                          if (provider.medicalRecordLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          final records = (provider.myMedicalRecord['records'] as List?)
                                  ?.cast<Map<String, dynamic>>() ??
                              const [];
                          if (records.isEmpty) {
                            return _buildEmptyState('Belum ada riwayat rekam medis atau sesi selesai.');
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
                    ] else ...[
                      Consumer<StudentCounselingProvider>(
                        builder: (context, provider, _) {
                          if (provider.myReferralsLoading) {
                            return const BkuShimmerList(itemCount: 2, itemHeight: 120);
                          }
                          final referrals = provider.myReferrals;
                          if (referrals.isEmpty) {
                            return _buildEmptyState('Belum ada surat rujukan konseling.');
                          }
                          return Column(
                            children: List.generate(
                              referrals.length,
                              (index) => FadeInAnimation(
                                delay: 0.05 + (index * 0.04),
                                child: _buildReferralCard(context, referrals[index]),
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

  Widget _buildStatusFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _statusFilterOptions.map((status) {
          final isSelected = _filterBookingStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() {
                _filterBookingStatus = status;
                _currentBookingPage = 1;
              }),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTabIndex = index;
          _currentBookingPage = 1;
        }),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: const Color(0xFFCBD5E1)) : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
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
        final totalSlot = provider.availableSchedules.length.toString();
        final total = bookings.length.toString();
        final pending = bookings
            .where((s) => _getStatusGroup(s['status']?.toString() ?? '') == 'Menunggu' || _getStatusGroup(s['status']?.toString() ?? '') == 'Dikonfirmasi')
            .length
            .toString();
        final completed = (provider.myMedicalRecord['records'] as List?)?.length.toString() ??
            bookings.where((s) => s['status'] == 'Selesai').length.toString();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Total Slot', totalSlot, Icons.calendar_month_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              _buildMiniStat('Riwayat', total, Icons.history_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
              _buildMiniStat('Antrean', pending, Icons.pending_actions_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              _buildMiniStat('Rekam Medis', completed, Icons.verified_user_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive
              ? () => context.push('${AppRoutes.counselingBooking}?psikolog_id=$id')
              : null,
          borderRadius: BorderRadius.circular(16),
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
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF1F5F9),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
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
                          color: isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  spec.split('&')[0].trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? BkuTheme.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Booking' : 'Off',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
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
    final bookingId = session['id']?.toString() ?? '-';
    final psikolog = session['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? session['nama_konselor']?.toString() ?? 'Psikolog BKU';
    final topic = session['topic']?.toString() ?? session['topik']?.toString() ?? 'Personal';
    final start = session['start']?.toString() ?? session['jam_mulai']?.toString() ?? '-';
    final end = session['end']?.toString() ?? session['jam_selesai']?.toString() ?? '';
    final timeStr = end.isNotEmpty ? '$start - $end' : start;
    final statusStr = session['status']?.toString() ?? 'Menunggu';
    final rawDate = session['display_date']?.toString() ?? session['date']?.toString() ?? '-';
    final displayDate = _formatDateNice(rawDate);
    final mode = session['mode']?.toString() ?? 'Tatap Muka';
    final queueNumber = session['queue_number']?.toString();
    final keluhan = session['complaint']?.toString() ?? session['keluhan']?.toString() ?? '';

    final isEditable = statusStr == 'Menunggu' || statusStr == 'Draft' || statusStr == 'Pending';

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);
    Color statusBorder = const Color(0xFFFDE68A);

    switch (statusStr.toLowerCase()) {
      case 'dikonfirmasi':
        statusBg = const Color(0xFFECFDF5);
        statusText = const Color(0xFF059669);
        statusBorder = const Color(0xFFA7F3D0);
        break;
      case 'selesai':
        statusBg = const Color(0xFFEFF6FF);
        statusText = const Color(0xFF2563EB);
        statusBorder = const Color(0xFFBFDBFE);
        break;
      case 'ditolak':
      case 'dibatalkan':
        statusBg = const Color(0xFFFFF1F2);
        statusText = const Color(0xFFE11D48);
        statusBorder = const Color(0xFFFECDD3);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (queueNumber != null && queueNumber.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Antrean #$queueNumber',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      mode,
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      topic,
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(
                    color: statusText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            psikologName,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(displayDate, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(timeStr, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
          if (keluhan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              keluhan,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () async {
                      final provider = context.read<StudentCounselingProvider>();
                      final res = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CounselingDetailScreen(initialBooking: session),
                        ),
                      );
                      if (res == true) {
                        provider.loadMyBookings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF1D4ED8),
                      elevation: 0,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Detail Sesi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isEditable) ...[
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () async {
                      final provider = context.read<StudentCounselingProvider>();
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CounselingEditScreen(booking: session),
                        ),
                      );
                      if (updated == true) {
                        provider.loadMyBookings();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF334155)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () => _handleCancelBooking(session),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                      backgroundColor: const Color(0xFFFFF1F2),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    child: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFE11D48)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: () => _downloadPDF(
                    '/counseling/psychologist-bookings/$bookingId/export-registration-pdf',
                    'Formulir Pendaftaran',
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  child: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, Map<String, dynamic> ref) {
    final referralId = ref['id']?.toString() ?? '';
    final type = ref['type'] ?? ref['tipe'] ?? 'Medis';
    final target = ref['target_party'] ?? ref['pihak_tujuan'] ?? 'Rumah Sakit / Dokter';
    final rawStatus = (ref['status'] ?? 'Menunggu Approval').toString();
    final reason = ref['reason'] ?? ref['alasan'] ?? 'Evaluasi klinis lanjutan';
    final rawDate = ref['display_date'] ?? ref['created_at'] ?? '-';
    final createdAtStr = _formatDateNice(rawDate.toString());

    final statusLower = rawStatus.toLowerCase().trim();
    final String statusDisplay = statusLower.contains('approval') || statusLower == 'pending'
        ? 'Menunggu Approval'
        : (statusLower == 'disetujui' || statusLower == 'approved'
            ? 'Disetujui'
            : (statusLower == 'ditolak' || statusLower == 'rejected' ? 'Ditolak' : rawStatus));

    Color statusBg = const Color(0xFFEFF6FF);
    Color statusText = const Color(0xFF1D4ED8);
    Color statusBorder = const Color(0xFFBFDBFE);

    if (statusDisplay == 'Menunggu Approval') {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF1D4ED8);
      statusBorder = const Color(0xFFBFDBFE);
    } else if (statusDisplay == 'Disetujui') {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
      statusBorder = const Color(0xFFA7F3D0);
    } else if (statusDisplay == 'Ditolak') {
      statusBg = const Color(0xFFFFF1F2);
      statusText = const Color(0xFFE11D48);
      statusBorder = const Color(0xFFFECDD3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(createdAtStr, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  statusDisplay,
                  style: TextStyle(color: statusText, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tujuan: $target',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Tipe: $type • Alasan: $reason',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPDF('/counseling/referrals/$referralId/export-pdf', 'Surat Rujukan'),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Unduh Surat Rujukan (PDF)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(BuildContext context, Map<String, dynamic> record) {
    final title = record['title'] ?? record['judul'] ?? 'Rekam Medis Sesi Konseling';
    final rawDate = (record['date'] ?? record['tanggal'] ?? '').toString();
    final date = _formatDateNice(rawDate);
    final psychologist = record['psychologist'] ?? record['psikolog'] ?? 'Psikolog Universitas';
    final rawStatus = (record['status'] ?? record['mood'] ?? 'Selesai').toString();
    final summary = record['summary'] ?? record['ringkasan'] ?? '';
    final recordId = record['id']?.toString() ?? '';

    Color badgeBg = const Color(0xFFECFDF5);
    Color badgeText = const Color(0xFF059669);
    Color badgeBorder = const Color(0xFFA7F3D0);

    final statusLower = rawStatus.toLowerCase();
    if (statusLower == 'cemas' || statusLower == 'stres' || statusLower == 'depresi' || statusLower == 'waspada') {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFD97706);
      badgeBorder = const Color(0xFFFDE68A);
    } else if (statusLower == 'perlu kontrol' || statusLower == 'lanjutan') {
      badgeBg = const Color(0xFFEFF6FF);
      badgeText = const Color(0xFF1D4ED8);
      badgeBorder = const Color(0xFFBFDBFE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  rawStatus,
                  style: TextStyle(color: badgeText, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text('Psikolog: $psychologist', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          if (summary.toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              summary.toString(),
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicalRecordDetailScreen(record: record),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF1D4ED8),
                      elevation: 0,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                      ),
                    ),
                    child: const Text('Detail Rekam Medis', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadPDF('/counseling/session-notes/$recordId/export-pdf', 'Rekam Medis'),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('PDF', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    foregroundColor: const Color(0xFF0F172A),
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_outlined, size: 28, color: Color(0xFF475569)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
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
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Text(
                    'CARE & SUPPORT',
                    style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Kamu Tidak Sendirian.',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.2),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Konsultasi nyaman dan rahasia bersama psikolog kampus.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}