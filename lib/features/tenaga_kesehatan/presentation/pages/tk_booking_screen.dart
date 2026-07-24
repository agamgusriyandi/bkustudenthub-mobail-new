import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'dart:async';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_booking_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

class TkBookingScreen extends StatefulWidget {
  const TkBookingScreen({super.key});

  @override
  State<TkBookingScreen> createState() => _TkBookingScreenState();
}

class _TkBookingScreenState extends State<TkBookingScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'label': 'Menunggu',
      'icon': Icons.hourglass_empty_rounded,
      'activeBg': const Color(0xFFFEF3C7),
      'activeFg': const Color(0xFFB45309),
      'activeBorder': const Color(0xFFFCD34D),
    },
    {
      'label': 'Dikonfirmasi',
      'icon': Icons.check_circle_outline_rounded,
      'activeBg': const Color(0xFFEFF6FF),
      'activeFg': const Color(0xFF1D4ED8),
      'activeBorder': const Color(0xFF93C5FD),
    },
    {
      'label': 'Selesai',
      'icon': Icons.task_alt_rounded,
      'activeBg': const Color(0xFFF0FDF4),
      'activeFg': const Color(0xFF15803D),
      'activeBorder': const Color(0xFF86EFAC),
    },
    {
      'label': 'Ditolak',
      'icon': Icons.cancel_outlined,
      'activeBg': const Color(0xFFFEF2F2),
      'activeFg': const Color(0xFFB91C1C),
      'activeBorder': const Color(0xFFFCA5A5),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkBookingProvider>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Booking Kesehatan',
        showBackButton: true,
        onBack: () {
          final mainState =
              context.findAncestorStateOfType<TkMainScreenState>();
          if (mainState != null) {
            mainState.setSelectedIndex(0);
          } else if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/tenagakes?tab=0');
          }
        },
        variant: AppBarVariant.nakes,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTabIndex == index;
                  final activeBg = tab['activeBg'] as Color;
                  final activeFg = tab['activeFg'] as Color;
                  final activeBorder = tab['activeBorder'] as Color;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? activeBg : const Color(0xFFF8FAFC),
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(
                            color: isSelected ? activeBorder : AppColors.neutral200,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab['icon'] as IconData,
                              size: 16,
                              color: isSelected ? activeFg : AppColors.neutral500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? activeFg : AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Pending Booking Banner
          Consumer<TkBookingProvider>(
            builder: (context, provider, child) {
              final pendingCount = provider.pendingBookings.length;
              if (pendingCount == 0) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCD34D), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        color: Color(0xFFB45309),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pendingCount Booking Menunggu Konfirmasi',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                          Text(
                            'Segera proses booking untuk jadwal hari ini',
                            style: AppTextStyles.labelSm.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Booking List
          Expanded(
            child: Consumer<TkBookingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  );
                }

                final bookings = _getFilteredBookings(provider);
                return _buildBookingList(bookings);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withAlpha(70),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showManualBookingSheet,
          backgroundColor: const Color(0xFF16A34A),
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Registrasi Manual',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  void _showManualBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const ManualBookingSheet();
      },
    );
  }

  List<Booking> _getFilteredBookings(TkBookingProvider provider) {
    switch (_selectedTabIndex) {
      case 0:
        return provider.pendingBookings;
      case 1:
        return provider.confirmedBookings;
      case 2:
        return provider.completedBookings;
      case 3:
        return provider.rejectedBookings;
      default:
        return provider.allBookings;
    }
  }

  int _getBookingId(dynamic booking) {
    if (booking is Map) return booking['id'] as int? ?? 0;
    return booking.id as int? ?? 0;
  }

  int _getMahasiswaId(dynamic booking) {
    if (booking is Map) return booking['mahasiswa_id'] as int? ?? 0;
    return booking.mahasiswaId as int? ?? 0;
  }

  String _getBookingField(dynamic booking, String field) {
    if (booking is Map) return booking[field]?.toString() ?? '-';
    switch (field) {
      case 'name':
        return booking.nama;
      case 'nim':
        return booking.nim;
      case 'status':
        return booking.status;
      case 'date':
        return booking.jadwalTanggal ?? '-';
      case 'time':
        return booking.waktu ?? '-';
      case 'tipe_layanan':
        return booking.tipeLayanan ?? '-';
      case 'keluhan':
        return booking.keluhan ?? '';
      case 'foto_url':
        return booking.fotoURL ?? '-';
      default:
        return '-';
    }
  }

  Widget _buildBookingList(List bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 72,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada booking',
              style: AppTextStyles.titleMd.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking akan muncul di sini',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<TkBookingProvider>().loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final bookingId = _getBookingId(booking);
          final mahasiswaId = _getMahasiswaId(booking);
          final status = _getBookingField(booking, 'status');
          final isPending = status == 'Menunggu Konfirmasi';
          final isRejected = status == 'Ditolak';
          final isCompleted = status == 'Selesai';
          final keluhan = _getBookingField(booking, 'keluhan');

          return BkuCard(
            onTap: () {
              if (mahasiswaId != 0) {
                context.push('/tk/patient/$mahasiswaId');
              }
            },
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(
                        _getBookingField(booking, 'name'),
                        _getBookingField(booking, 'foto_url'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getBookingField(booking, 'name'),
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.neutral800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getBookingField(booking, 'nim'),
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildInfoChip(
                                  Icons.calendar_today_rounded,
                                  _getBookingField(booking, 'date'),
                                ),
                                _buildInfoChip(
                                  Icons.access_time_rounded,
                                  _getBookingField(booking, 'time'),
                                ),
                              ],
                            ),
                            if (_getBookingField(booking, 'tipe_layanan') !=
                                '-') ...[
                              const SizedBox(height: 6),
                              _buildInfoChip(
                                Icons.medical_services_rounded,
                                _getBookingField(booking, 'tipe_layanan'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                ),

                if (keluhan.isNotEmpty && keluhan != '-')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keluhan',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          keluhan,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                if (isPending)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleReject(bookingId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              backgroundColor: const Color(0xFFFEF2F2),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text(
                              'Tolak',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAccept(bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text(
                              'Terima',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!isPending && !isRejected && !isCompleted && bookingId != 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (mahasiswaId != 0)
                          SizedBox(
                            height: 34,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/tk/patient/$mahasiswaId'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1D4ED8),
                                side: const BorderSide(color: Color(0xFF93C5FD)),
                                backgroundColor: const Color(0xFFEFF6FF),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.medical_services_rounded, size: 16),
                              label: const Text(
                                'Periksa Pasien',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleComplete(bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text(
                              'Tandai Selesai',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if ((isCompleted || isRejected) && mahasiswaId != 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/tk/patient/$mahasiswaId'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              backgroundColor: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.person_rounded, size: 16),
                            label: const Text(
                              'Detail Pasien',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name, String? fotoUrl) {
    final parts = name.trim().split(' ');
    final avatarText =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    final hasImage = fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-';

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.neutral600.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child:
              hasImage
                  ? Image.network(
                    ApiGate.getImageUrl(fotoUrl),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => _buildInitialsAvatarSmall(avatarText),
                  )
                  : _buildInitialsAvatarSmall(avatarText),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatarSmall(String text) {
    final primary = context.read<ThemeProvider>().primary;
    return Container(
      width: 44,
      height: 44,
      color: primary.withAlpha(25),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.neutral500),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    IconData icon;

    switch (status) {
      case 'Dikonfirmasi':
        textColor = const Color(0xFF1D4ED8);
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF93C5FD);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'Menunggu Konfirmasi':
        textColor = const Color(0xFFB45309);
        bgColor = const Color(0xFFFEF3C7);
        borderColor = const Color(0xFFFCD34D);
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'Selesai':
        textColor = const Color(0xFF15803D);
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF86EFAC);
        icon = Icons.task_alt_rounded;
        break;
      case 'Ditolak':
        textColor = const Color(0xFFB91C1C);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFCA5A5);
        icon = Icons.cancel_outlined;
        break;
      default:
        textColor = const Color(0xFF475569);
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFE2E8F0);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(int id) async {
    if (id == 0) return;
    final provider = context.read<TkBookingProvider>();
    final success = await provider.acceptBooking(id);
    if (success && mounted) {
      AppSnackbar.showSuccess(context, 'Booking berhasil dikonfirmasi');
    }
  }

  Future<void> _handleReject(int id) async {
    if (id == 0) return;
    final provider = context.read<TkBookingProvider>();

    final alasanController = TextEditingController();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: AppRadius.radiusXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tolak Booking',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berikan alasan penolakan (opsional)',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: alasanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Jadwal penuh, perlu reschedule...',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(color: AppColors.neutral300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(color: AppColors.neutral300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed: () => Navigator.pop(context, false),
                          text: 'Batal',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BkuButton(
                          onPressed: () => Navigator.pop(context, true),
                          text: 'Tolak',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (result == true) {
      final success = await provider.rejectBooking(
        id,
        alasan: alasanController.text.isNotEmpty ? alasanController.text : null,
      );
      if (success && mounted) {
        AppSnackbar.showError(context, 'Booking ditolak');
      }
    }
  }

  Future<void> _handleComplete(int id) async {
    if (id == 0) return;
    final provider = context.read<TkBookingProvider>();
    final success = await provider.completeBooking(id);
    if (success && mounted) {
      AppSnackbar.showSuccess(context, 'Booking ditandai selesai');
    }
  }
}

class ManualBookingSheet extends StatefulWidget {
  const ManualBookingSheet({super.key});

  @override
  State<ManualBookingSheet> createState() => _ManualBookingSheetState();
}

class _ManualBookingSheetState extends State<ManualBookingSheet> {
  final _searchController = TextEditingController();
  final _keluhanController = TextEditingController();
  Patient? _selectedPatient;
  bool _isSubmitting = false;
  Timer? _debounce;
  List<Patient>? _searchResults;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkPatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _keluhanController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'Pendaftaran Pasien Manual (Walk-in)',
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_selectedPatient == null) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Nama atau NIM...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.neutral500,
                ),
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusXl,
                  borderSide: BorderSide(
                    color: AppColors.neutral200.withAlpha(150),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusXl,
                  borderSide: BorderSide(
                    color: AppColors.neutral200.withAlpha(150),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.radiusXl,
                  borderSide: BorderSide(color: AppColors.neutral400),
                ),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () async {
                  if (val.isNotEmpty) {
                    setState(() => _isSearching = true);
                    final results = await context
                        .read<TkPatientProvider>()
                        .searchPatients(val);
                    if (mounted) {
                      setState(() {
                        _searchResults = results;
                        _isSearching = false;
                      });
                    }
                  } else {
                    setState(() {
                      _searchResults = null;
                      _isSearching = false;
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Builder(
                builder: (context) {
                  if (_isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final displayList =
                      _searchResults ??
                      context.watch<TkPatientProvider>().recentPatients;

                  if (displayList.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(
                        'Mahasiswa tidak ditemukan',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final patient = displayList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(
                            color: AppColors.neutral200.withAlpha(150),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: AppRadius.radiusXl,
                            onTap: () {
                              setState(() {
                                _selectedPatient = patient;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.neutral200,
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        patient.fotoURL != null &&
                                                patient.fotoURL!.isNotEmpty
                                            ? Image.network(
                                              ApiGate.getImageUrl(
                                                patient.fotoURL!,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Center(
                                                  child: Text(
                                                    patient.initials,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.neutral700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                            : Center(
                                              child: Text(
                                                patient.initials,
                                                style: const TextStyle(
                                                  color: AppColors.neutral700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient.nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'NIM: ${patient.nim}',
                                          style: const TextStyle(
                                            color: AppColors.neutral500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.neutral400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: AppRadius.radiusXl,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        _selectedPatient!.fotoURL != null &&
                                _selectedPatient!.fotoURL!.isNotEmpty
                            ? Image.network(
                              ApiGate.getImageUrl(_selectedPatient!.fotoURL!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    _selectedPatient!.initials,
                                    style: const TextStyle(
                                      color: Color(0xFF15803D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Text(
                                _selectedPatient!.initials,
                                style: const TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _selectedPatient!.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIM: ${_selectedPatient!.nim}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedPatient = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keluhanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Keluhan Utama Pasien...',
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  _isSubmitting ? 'Mendaftarkan...' : 'Daftarkan Pasien',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedPatient == null || _keluhanController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final success = await context.read<TkBookingProvider>().createManualBooking(
      _selectedPatient!.id,
      _keluhanController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (success) {
        Navigator.pop(context);
        AppSnackbar.showSuccess(
          context,
          'Berhasil mendaftarkan pasien secara manual',
        );
      } else {
        AppSnackbar.showError(context, 'Gagal mendaftarkan pasien');
      }
    }
  }
}
