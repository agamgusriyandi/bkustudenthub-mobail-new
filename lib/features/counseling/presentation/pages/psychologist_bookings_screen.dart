import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/session_note_screen.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class PsychologistBookingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PsychologistBookingsScreen({super.key, this.onBack});

  @override
  State<PsychologistBookingsScreen> createState() =>
      _PsychologistBookingsScreenState();
}

class _PsychologistBookingsScreenState
    extends State<PsychologistBookingsScreen> {
  int _selectedTabIndex = 0;
  int _currentPage = 1;
  final int _pageSize = 5;

  final List<Map<String, dynamic>> _statusTabs = [
    {
      'label': 'Semua',
      'icon': Icons.dashboard_rounded,
      'activeBg': AppColors.neutral50,
      'activeFg': AppColors.neutral900,
      'activeBorder': AppColors.neutral400,
    },
    {
      'label': 'Menunggu',
      'icon': Icons.hourglass_top_rounded,
      'activeBg': AppColors.warning.withAlpha(15),
      'activeFg': AppColors.warning,
      'activeBorder': AppColors.warning,
    },
    {
      'label': 'Dikonfirmasi',
      'icon': Icons.check_circle_rounded,
      'activeBg': AppColors.info.withAlpha(15),
      'activeFg': AppColors.info,
      'activeBorder': AppColors.info,
    },
    {
      'label': 'Selesai',
      'icon': Icons.task_alt_rounded,
      'activeBg': AppColors.success.withAlpha(15),
      'activeFg': AppColors.success,
      'activeBorder': AppColors.success,
    },
    {
      'label': 'Ditolak',
      'icon': Icons.cancel_rounded,
      'activeBg': AppColors.error.withAlpha(15),
      'activeFg': AppColors.error,
      'activeBorder': AppColors.error,
    },
  ];

  String _searchQuery = '';
  String _sortOrder = 'Terbaru';
  String? _selectedProdi;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingProvider>().loadBookings();
      _startPolling();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<CounselingProvider>().loadBookings(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredBookings(
    List<Map<String, dynamic>> bookings,
  ) {
    List<Map<String, dynamic>> result = List.from(bookings);

    // Filter Status
    if (_selectedTabIndex != 0) {
      final statusFilter =
          (_statusTabs[_selectedTabIndex]['label'] as String).toLowerCase();
      result =
          result.where((b) {
            final status = (b['status'] ?? '').toString().toLowerCase();
            if (statusFilter == 'menunggu') {
              return status == 'menunggu' || status == 'pending';
            } else if (statusFilter == 'dikonfirmasi') {
              return status == 'dikonfirmasi' || status == 'confirmed';
            } else if (statusFilter == 'selesai') {
              return status == 'selesai' || status == 'completed';
            }
            return status == statusFilter;
          }).toList();
    }

    // Filter Search (Nama / NIM)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result =
          result.where((b) {
            final name = (b['name']?.toString() ?? '').toLowerCase();
            final nim = (b['nim']?.toString() ?? '').toLowerCase();
            return name.contains(q) || nim.contains(q);
          }).toList();
    }

    // Filter Prodi
    if (_selectedProdi != null && _selectedProdi!.isNotEmpty) {
      result =
          result
              .where((b) => b['faculty']?.toString() == _selectedProdi)
              .toList();
    }

    // Sort (Menggunakan ID sebagai acuan Terbaru/Terlama, asumsi ID auto-increment)
    result.sort((a, b) {
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return _sortOrder == 'Terbaru' ? idB.compareTo(idA) : idA.compareTo(idB);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    _selectedTabIndex = context.watch<NavigationProvider>().bookingTabIndex;
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.bookings;
        final filtered = _filteredBookings(bookings);
        final waiting =
            bookings.where((b) {
              final s = (b['status'] ?? '').toString().toLowerCase();
              return s == 'menunggu' || s == 'pending';
            }).length;
        final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }
        final startIndex = filtered.isEmpty ? 0 : (_currentPage - 1) * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
        final pagedFiltered = filtered.isEmpty
            ? <Map<String, dynamic>>[]
            : filtered.sublist(startIndex, endIndex);

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Booking Masuk',
                variant: AppBarVariant.psychologist,
                showBackButton: true,
                onBack:
                    widget.onBack ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child:
                    provider.bookingsLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                        )
                        : provider.bookingsError != null
                        ? _buildError(provider.bookingsError!, provider)
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (waiting > 0) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _buildPendingBanner(waiting),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _buildSearchAndFilter(bookings),
                            const SizedBox(height: AppSpacing.lg),
                            _buildTabs(),
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${filtered.length} Permintaan',
                                    style: AppTextStyles.titleMd.copyWith(
                                      color: AppColors.neutral900,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (filtered.isNotEmpty)
                                    Text(
                                      '${startIndex + 1}-$endIndex dari ${filtered.length}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.neutral500,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (totalPages > 1) ...[
                              const SizedBox(height: AppSpacing.md),
                              _buildTopPagination(totalPages),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _buildBookingList(pagedFiltered, provider),
                            const SizedBox(height: AppSpacing.s120),
                          ],
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(String message, CounselingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: AppSpacing.xl,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: context.appColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: provider.loadBookings,

              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBanner(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.warning.withAlpha(30),
              AppColors.warning.withAlpha(10),
            ],
          ),
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.warning.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.pending_actions_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '$count permintaan booking menunggu konfirmasi kamu!',
                style: AppTextStyles.labelMd.copyWith(
                   color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(List<Map<String, dynamic>> allBookings) {
    final prodis =
        allBookings
            .map((b) => b['faculty']?.toString() ?? '')
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList();
    prodis.sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() {
              _searchQuery = val;
              _currentPage = 1;
            }),
            decoration: InputDecoration(
              hintText: 'Cari nama mahasiswa atau NIM...',
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: AppColors.neutral500.withAlpha(150),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: context.appColors.success),
              filled: true,
              fillColor: AppColors.neutral50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: context.appColors.success, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral500.withAlpha(40)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _sortOrder,
                      icon: Icon(
                        Icons.sort_rounded,
                        color: context.appColors.success,
                        size: 18,
                      ),
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w800,
                      ),
                      items:
                          ['Terbaru', 'Terlama'].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _sortOrder = val;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral500.withAlpha(40)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedProdi,
                      hint: Text(
                        'Seluruh Fakultas',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral800,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: Icon(
                        Icons.tune_rounded,
                        color: context.appColors.success,
                        size: 18,
                      ),
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w800,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Seluruh Fakultas'),
                        ),
                        ...prodis.map((e) {
                          return DropdownMenuItem<String?>(
                            value: e,
                            child: Text(e, overflow: TextOverflow.ellipsis),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedProdi = val;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusTabs.length,
        itemBuilder: (context, index) {
          final tab = _statusTabs[index];
          final isSelected = _selectedTabIndex == index;
          final activeBg = tab['activeBg'] as Color;
          final activeFg = tab['activeFg'] as Color;
          final activeBorder = tab['activeBorder'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage = 1;
                });
                context.read<NavigationProvider>().setBookingTabIndex(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : context.appColors.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: isSelected ? activeBorder : AppColors.neutral200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: activeFg.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isSelected ? activeFg : AppColors.neutral500,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      tab['label'] as String,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? activeFg : AppColors.neutral600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPagination(int totalPages) {
    final canPrev = _currentPage > 1;
    final canNext = _currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.br14,
          border: Border.all(color: AppColors.neutral300),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: canPrev ? AppColors.neutral50 : AppColors.neutral50,
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canPrev ? () => setState(() => _currentPage--) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 16,
                        color: canPrev ? AppColors.neutral800 : AppColors.neutral400,
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canPrev ? AppColors.neutral800 : AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Halaman $_currentPage dari $totalPages',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: canNext ? AppColors.neutral50 : AppColors.neutral50,
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canNext ? () => setState(() => _currentPage++) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canNext ? AppColors.neutral800 : AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: canNext ? AppColors.neutral800 : AppColors.neutral400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<Map<String, dynamic>> list,
    CounselingProvider provider,
  ) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 64,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Tidak ada booking',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildBookingCard(list[index], provider),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    CounselingProvider provider,
  ) {
    final status = booking['status']?.toString() ?? 'Menunggu';
    final statusStr = status.toLowerCase();
    final isWaiting = statusStr == 'menunggu' || statusStr == 'pending';
    final isDone = statusStr == 'selesai' || statusStr == 'completed';
    final isRejected =
        statusStr == 'ditolak' ||
        statusStr == 'cancelled' ||
        statusStr == 'canceled';

    Color statusColor;
    IconData statusIcon;
    if (isWaiting) {
      statusColor = AppColors.warning;
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (isDone) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = AppColors.primary;
      statusIcon = Icons.event_available_rounded;
    }

    final name = booking['name']?.toString() ?? '-';
    final nim = booking['nim']?.toString() ?? '-';
    final faculty = booking['faculty']?.toString() ?? '';
    final date =
        booking['date_full']?.toString() ?? booking['date']?.toString() ?? '-';
    final time = booking['time']?.toString() ?? '-';
    final issue =
        booking['issue']?.toString() ?? booking['topik']?.toString() ?? '-';
    final note =
        booking['note']?.toString() ?? booking['keluhan']?.toString() ?? '';
    final id = booking['id']?.toString() ?? '';
    final mode = booking['mode']?.toString() ?? 'Tatap Muka';
    final isOnline = mode == 'Online';

    // Generate avatar initials from name
    final parts = name.trim().split(' ');
    final avatar =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    final avatarUrl = () {
      final possibleKeys = [
        'FotoURL',
        'foto_url',
        'Foto',
        'foto',
        'FotoProfil',
        'foto_profil',
        'mahasiswa_avatar',
        'avatar_url',
      ];
      for (final key in possibleKeys) {
        if (booking[key] != null &&
            booking[key].toString().isNotEmpty &&
            booking[key].toString() != '-') {
          return booking[key].toString();
        }
      }
      final mhsData =
          booking['mahasiswa'] ??
          booking['Mahasiswa'] ??
          booking['pasien'] ??
          booking['Pasien'] ??
          booking['user'] ??
          booking['User'] ??
          booking['student'] ??
          booking['Student'];
      if (mhsData is Map) {
        for (final key in possibleKeys) {
          if (mhsData[key] != null &&
              mhsData[key].toString().isNotEmpty &&
              mhsData[key].toString() != '-') {
            return mhsData[key].toString();
          }
        }
        final user =
            mhsData['Pengguna'] ??
            mhsData['pengguna'] ??
            mhsData['User'] ??
            mhsData['user'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null &&
                user[key].toString().isNotEmpty &&
                user[key].toString() != '-') {
              return user[key].toString();
            }
          }
        }
      }
      return null;
    }();

    final avatarColors = [
      AppColors.info,
      AppColors.success,
      context.appColors.info,
      AppColors.warning,
      AppColors.error,
    ];
    final avatarColor = avatarColors[name.length % avatarColors.length];

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.radiusXl,
          onTap:
              () => _showBookingDetailsBottomSheet(
                context,
                booking,
                isWaiting,
                provider,
                id,
              ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: avatarColor.withAlpha(30),
                      backgroundImage:
                          avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(ApiGate.getImageUrl(avatarUrl))
                              : null,
                      child:
                          avatarUrl != null && avatarUrl.isNotEmpty
                              ? null
                              : Text(
                                avatar,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: avatarColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            '$nim${faculty.isNotEmpty ? ' • $faculty' : ''}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            status,
                            style: AppTextStyles.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(Icons.calendar_today_rounded, date),
                        const SizedBox(width: AppSpacing.md),
                        _buildInfoChip(Icons.access_time_rounded, time),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoChip(
                      Icons.psychology_rounded,
                      issue,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Badge mode Online/Tatap Muka
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isOnline
                                    ? AppColors.info.withAlpha(20)
                                    : context.appColors.info.withAlpha(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOnline
                                    ? Icons.videocam_rounded
                                    : Icons.location_on_rounded,
                                size: 11,
                                color: isOnline ? AppColors.info : context.appColors.info,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                mode,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isOnline ? AppColors.info : context.appColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        note,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? AppColors.neutral500),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: color ?? AppColors.neutral600,
            fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showBookingDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> booking,
    bool isWaiting,
    CounselingProvider provider,
    String id,
  ) {
    final name = booking['name']?.toString() ?? '-';
    final nim = booking['nim']?.toString() ?? '-';
    final faculty = booking['faculty']?.toString() ?? '';
    final prodi = booking['prodi']?.toString() ?? '';
    final semester = booking['semester']?.toString() ?? '';
    final date =
        booking['date_full']?.toString() ?? booking['date']?.toString() ?? '-';
    final time = booking['time']?.toString() ?? '-';
    final issue =
        booking['issue']?.toString() ?? booking['topik']?.toString() ?? '-';
    final category = booking['kategori']?.toString() ?? issue;
    final note =
        booking['note']?.toString() ?? booking['keluhan']?.toString() ?? '';
    final mode = booking['mode']?.toString() ?? 'Tatap Muka';
    final isOnline = mode == 'Online';
    final statusStr = (booking['status'] ?? '').toString().toLowerCase();
    final isConfirmed = statusStr == 'dikonfirmasi' || statusStr == 'confirmed';
    final isDone = statusStr == 'selesai' || statusStr == 'completed';
    final isRejected =
        statusStr == 'ditolak' ||
        statusStr == 'cancelled' ||
        statusStr == 'canceled';

    final linkCtrl = TextEditingController(
      text:
          booking['link_meeting']?.toString() ??
          booking['meeting_link']?.toString() ??
          '',
    );
    final notesCtrl = TextEditingController(
      text: booking['catatan_tambahan']?.toString() ?? '',
    );

    final avatarUrl = () {
      final possibleKeys = [
        'FotoURL',
        'foto_url',
        'Foto',
        'foto',
        'FotoProfil',
        'foto_profil',
        'mahasiswa_avatar',
        'avatar_url',
      ];
      for (final key in possibleKeys) {
        if (booking[key] != null &&
            booking[key].toString().isNotEmpty &&
            booking[key].toString() != '-') {
          return booking[key].toString();
        }
      }
      final mhsData =
          booking['mahasiswa'] ??
          booking['Mahasiswa'] ??
          booking['pasien'] ??
          booking['Pasien'] ??
          booking['user'] ??
          booking['User'] ??
          booking['student'] ??
          booking['Student'];
      if (mhsData is Map) {
        for (final key in possibleKeys) {
          if (mhsData[key] != null &&
              mhsData[key].toString().isNotEmpty &&
              mhsData[key].toString() != '-') {
            return mhsData[key].toString();
          }
        }
        final user =
            mhsData['Pengguna'] ??
            mhsData['pengguna'] ??
            mhsData['User'] ??
            mhsData['user'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null &&
                user[key].toString().isNotEmpty &&
                user[key].toString() != '-') {
              return user[key].toString();
            }
          }
        }
      }
      return null;
    }();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral500.withAlpha(80),
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Booking',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withAlpha(20),
                            backgroundImage:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(
                                      ApiGate.getImageUrl(avatarUrl),
                                    )
                                    : null,
                            child:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                    ? null
                                    : Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                    ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'NIM: $nim',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPatientInfoGrid(
                        faculty: faculty,
                        prodi: prodi,
                        semester: semester,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Detail Keluhan'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow(
                        Icons.category_rounded,
                        'Kategori',
                        category,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailRow(
                        Icons.description_rounded,
                        'Deskripsi',
                        note.isNotEmpty ? note : issue,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Jadwal Sesi'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'Tanggal',
                        date,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailRow(
                        Icons.access_time_rounded,
                        'Pukul',
                        time,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailRow(
                        isOnline
                            ? Icons.videocam_rounded
                            : Icons.location_on_rounded,
                        'Mode',
                        mode,
                        valueColor:
                            isOnline
                                ? AppColors.info
                                : context.appColors.info,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (!isDone && !isRejected) ...[
                        _buildSectionTitle('Link Meeting'),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: linkCtrl,
                          style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                          decoration: InputDecoration(
                            hintText:
                                isOnline
                                    ? 'https://meet.google.com/xxx-xxxx-xxx'
                                    : 'Opsional (untuk sesi Online)',
                            hintStyle: AppTextStyles.labelMd.copyWith(
                              color: AppColors.neutral500.withAlpha(120),
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.neutral50,
                            prefixIcon: const Icon(
                              Icons.link_rounded,
                              color: AppColors.info,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: AppColors.neutral500.withAlpha(40),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: AppColors.neutral500.withAlpha(40),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: context.appColors.success,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        _buildSectionTitle('Catatan Tambahan'),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          minLines: 3,
                          style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Tambahkan catatan untuk sesi ini...',
                            hintStyle: AppTextStyles.labelMd.copyWith(
                              color: AppColors.neutral500.withAlpha(120),
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.neutral50,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: AppColors.neutral500.withAlpha(40),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: AppColors.neutral500.withAlpha(40),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(
                                color: context.appColors.success,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      if (isWaiting || isConfirmed) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  _showRejectDialog(
                                    booking,
                                    id,
                                    provider,
                                  );
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                ),
                                label: const Text('Tolak'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.appColors.error,
                                  side: BorderSide(
                                    color: context.appColors.error,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (isWaiting) {
                                    Navigator.pop(sheetContext);
                                    _showActionDialog(
                                      booking,
                                      true,
                                      id,
                                      provider,
                                      linkCtrl: linkCtrl,
                                      notesCtrl: notesCtrl,
                                    );
                                  } else {
                                    Navigator.pop(sheetContext);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => SessionNoteScreen(
                                              studentName: name,
                                              studentId:
                                                  booking['mahasiswa_id']
                                                      ?.toString() ??
                                                  booking['student_id']
                                                      ?.toString() ??
                                                  booking['mahasiswa']?['id']
                                                      ?.toString() ??
                                                  booking['nim']?.toString() ??
                                                  '',
                                              bookingId: id,
                                            ),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isWaiting
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.assignment_turned_in_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  isWaiting ? 'Konfirmasi' : 'Sesi Selesai',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.appColors.success,
                                  side: BorderSide(
                                    color: context.appColors.success,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPatientInfoGrid({
    required String faculty,
    required String prodi,
    required String semester,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(8),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        children: [
          _buildPatientInfoRow(Icons.school_rounded, 'Program Studi', prodi),
          if (faculty.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildPatientInfoRow(
              Icons.account_balance_rounded,
              'Fakultas',
              faculty,
            ),
          ],
          if (semester.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildPatientInfoRow(
              Icons.layers_rounded,
              'Semester',
              semester,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
          ),
        ),
        Text(
          value.isNotEmpty ? value : '-',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.neutral800,
        fontSize: 14,
      ),
    );
  }

  void _showRejectDialog(
    Map<String, dynamic> booking,
    String id,
    CounselingProvider provider,
  ) {
    final name = booking['name']?.toString() ?? '-';
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            title: 'Tolak Booking?',
            content: 'Mahasiswa $name akan mendapat notifikasi penolakan.',
            cancelText: 'Batal',
            confirmText: 'Kirim Penolakan',
            isDestructive: true,
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: const Text('Alasan penolakan wajib diisi.'),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              BkuLoadingDialog.show(context);
              final success = await provider.rejectBooking(id, reason);
              if (success && mounted) {
                context
                    .read<PsychologistDashboardProvider>()
                    .loadDashboardData(silent: true);
              }
              if (!mounted) return;
              BkuLoadingDialog.hide(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Booking $name berhasil ditolak.'
                        : 'Gagal menolak booking.',
                  ),
                  backgroundColor:
                      success ? AppColors.error : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            customChild: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(10),
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.error.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Alasan Penolakan (Wajib)',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Jadwal bentrok, mohon ajukan ulang...',
                      hintStyle: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral500.withAlpha(120),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: AppColors.error.withAlpha(60),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: AppColors.error.withAlpha(60),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.neutral500),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showActionDialog(
    Map<String, dynamic> booking,
    bool isConfirm,
    String id,
    CounselingProvider provider, {
    TextEditingController? linkCtrl,
    TextEditingController? notesCtrl,
  }) {
    final name = booking['name']?.toString() ?? '-';
    final mode = booking['mode']?.toString() ?? 'Tatap Muka';
    final isOnline = mode == 'Online';

    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            title: isConfirm ? 'Konfirmasi Booking?' : 'Tolak Booking?',
            content:
                isConfirm
                    ? 'Mahasiswa $name akan mendapat notifikasi bahwa booking-nya dikonfirmasi.'
                    : 'Mahasiswa $name akan mendapat notifikasi bahwa booking-nya ditolak.',
            cancelText: 'Batal',
            confirmText: isConfirm ? 'Konfirmasi' : 'Ya, Tolak',
            isDestructive: !isConfirm,
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              if (isConfirm && isOnline && linkCtrl!.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Link meeting wajib diisi untuk sesi Online',
                    ),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              BkuLoadingDialog.show(context);

              final success = isConfirm
                  ? await provider.confirmBooking(
                      id,
                      meetingLink:
                          isOnline ? linkCtrl!.text.trim() : linkCtrl!.text.trim(),
                      notes: notesCtrl?.text.trim(),
                    )
                  : false;

              if (success && mounted) {
                context
                    .read<PsychologistDashboardProvider>()
                    .loadDashboardData(silent: true);
              }
              if (!mounted) return;
              BkuLoadingDialog.hide(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? (isConfirm
                            ? 'Booking $name dikonfirmasi! ${isOnline ? "Link meeting terkirim." : ""}'
                            : 'Booking $name berhasil ditolak.')
                        : 'Gagal mengubah status booking.',
                  ),
                  backgroundColor:
                      success
                          ? (isConfirm ? AppColors.primary : AppColors.error)
                          : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
    );
  }
}
