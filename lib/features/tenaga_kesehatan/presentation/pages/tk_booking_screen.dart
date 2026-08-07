import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'dart:async';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_booking_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkBookingScreen extends StatefulWidget {
  const TkBookingScreen({super.key});

  @override
  State<TkBookingScreen> createState() => _TkBookingScreenState();
}

class _TkBookingScreenState extends State<TkBookingScreen> {
  int _selectedTabIndex = 0;

  List<Map<String, dynamic>> _buildTabs() => [
    {
      'label': 'Menunggu',
      'icon': Icons.hourglass_empty_rounded,
      'activeBg': context.appColors.warning.withAlpha(15),
      'activeFg': context.appColors.warning,
      'activeBorder': context.appColors.warning.withAlpha(50),
    },
    {
      'label': 'Dikonfirmasi',
      'icon': Icons.check_circle_outline_rounded,
      'activeBg': context.appColors.info.withAlpha(15),
      'activeFg': context.appColors.info,
      'activeBorder': context.appColors.info.withAlpha(50),
    },
    {
      'label': 'Selesai',
      'icon': Icons.task_alt_rounded,
      'activeBg': context.appColors.success.withAlpha(15),
      'activeFg': context.appColors.success,
      'activeBorder': context.appColors.success.withAlpha(50),
    },
    {
      'label': 'Ditolak',
      'icon': Icons.cancel_outlined,
      'activeBg': context.appColors.error.withAlpha(15),
      'activeFg': context.appColors.error,
      'activeBorder': context.appColors.error.withAlpha(50),
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
            color: context.appColors.surface,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(_buildTabs().length, (index) {
                  final tab = _buildTabs()[index];
                  final isSelected = _selectedTabIndex == index;
                  final activeBg = tab['activeBg'] as Color;
                  final activeFg = tab['activeFg'] as Color;
                  final activeBorder = tab['activeBorder'] as Color;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? activeBg : AppColors.neutral100,
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
                            const SizedBox(width: AppSpacing.s6),
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
                  color: context.appColors.warning.withAlpha(15),
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: context.appColors.warning.withAlpha(50), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.onSurface.withAlpha(8),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppSpacing.padding10,
                      decoration: BoxDecoration(
                        color: context.appColors.warning.withAlpha(20),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(Icons.pending_actions_rounded, color: context.appColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pendingCount Booking Menunggu Konfirmasi',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.appColors.warning,
                            ),
                          ),
                          Text(
                            'Segera proses booking untuk jadwal hari ini',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.warning.withAlpha(150),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.s80),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.appColors.success.withAlpha(70),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showManualBookingSheet,
          backgroundColor: context.appColors.success,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusXl,
          ),
          icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary, size: 20),
          label: Text(
            'Registrasi Manual',
            style: TextStyle(
              color: context.appColors.onPrimary,
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tidak ada booking',
              style: AppTextStyles.titleMd.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Booking akan muncul di sini',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.appColors.primary,
      onRefresh: () => context.read<TkBookingProvider>().loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          100,
        ),
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
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                      const SizedBox(width: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              _getBookingField(booking, 'nim'),
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s6),
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
                              const SizedBox(height: AppSpacing.s6),
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
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
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
                        const SizedBox(height: AppSpacing.xs),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.s14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleReject(bookingId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.appColors.error,
                              side: BorderSide(color: context.appColors.error.withAlpha(50)),
                              backgroundColor: context.appColors.error.withAlpha(15),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.br10,
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text(
                              'Tolak',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAccept(bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.success,
                              foregroundColor: context.appColors.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.br10,
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.s14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (mahasiswaId != 0)
                          SizedBox(
                            height: 34,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/tk/patient/$mahasiswaId'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.appColors.info,
                                side: BorderSide(color: context.appColors.info.withAlpha(50)),
                                backgroundColor: context.appColors.info.withAlpha(15),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.br10,
                                ),
                              ),
                              icon: const Icon(Icons.medical_services_rounded, size: 16),
                              label: const Text(
                                'Periksa Pasien',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        const SizedBox(width: AppSpacing.s10),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleComplete(bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.success,
                              foregroundColor: context.appColors.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.br10,
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.s14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/tk/patient/$mahasiswaId'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neutral700,
                              side: BorderSide(color: AppColors.neutral400),
                              backgroundColor: AppColors.neutral100,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.br10,
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
            ? '${parts[0][0]}${parts[1][0]}'
            : name.isNotEmpty
            ? name[0]
            : '?';

    final hasImage = fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-';

    return Container(
      padding: AppSpacing.padding2,
      decoration: BoxDecoration(
        color: AppColors.neutral600.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: AppSpacing.padding2,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child:
              hasImage
                  ? CachedNetworkImage(imageUrl: 
                    ApiGate.getImageUrl(fotoUrl),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget:
                        (_, url, error) => _buildInitialsAvatarSmall(avatarText),
                    placeholder: (context, url) => Container(color: AppColors.neutral200),
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
        const SizedBox(width: AppSpacing.xs),
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
        textColor = context.appColors.info;
        bgColor = context.appColors.info.withAlpha(15);
        borderColor = context.appColors.info.withAlpha(50);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'Menunggu Konfirmasi':
        textColor = context.appColors.warning;
        bgColor = context.appColors.warning.withAlpha(15);
        borderColor = context.appColors.warning.withAlpha(50);
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'Selesai':
        textColor = context.appColors.success;
        bgColor = context.appColors.success.withAlpha(15);
        borderColor = context.appColors.success.withAlpha(50);
        icon = Icons.task_alt_rounded;
        break;
      case 'Ditolak':
        textColor = context.appColors.error;
        bgColor = context.appColors.error.withAlpha(15);
        borderColor = context.appColors.error.withAlpha(50);
        icon = Icons.cancel_outlined;
        break;
      default:
        textColor = AppColors.neutral700;
        bgColor = AppColors.neutral100;
        borderColor = AppColors.neutral300;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: AppSpacing.xs),
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
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius20)),
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
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    'Tolak Booking',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Berikan alasan penolakan (opsional)',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed: () => Navigator.pop(context, false),
                          text: 'Batal',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
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
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.s20,
        right: AppSpacing.s20,
        top: AppSpacing.s20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Pendaftaran Pasien Manual (Walk-in)',
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s20),
          if (_selectedPatient == null) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Nama atau NIM...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500,
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
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Builder(
                builder: (context) {
                  if (_isSearching) {
                    return const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList());
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
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusXl,
                          border: Border.all(
                            color: AppColors.neutral200.withAlpha(150),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.onSurface.withAlpha(12),
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
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral200,
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        patient.fotoURL != null &&
                                                patient.fotoURL!.isNotEmpty
                                            ? CachedNetworkImage(imageUrl: 
                                              ApiGate.getImageUrl(
                                                patient.fotoURL!,
                                              ),
                                              fit: BoxFit.cover,
                                              errorWidget: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Center(
                                                  child: Text(
                                                    patient.initials,
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.neutral700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                                            )
                                            : Center(
                                              child: Text(
                                                patient.initials,
                                                style: TextStyle(
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
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'NIM: ${patient.nim}',
                                          style: TextStyle(
                                            color: AppColors.neutral500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.neutral400,
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
                color: context.appColors.success.withAlpha(15),
                borderRadius: AppRadius.radiusXl,
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.onSurface.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: context.appColors.success.withAlpha(50), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.appColors.success.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        _selectedPatient!.fotoURL != null &&
                                _selectedPatient!.fotoURL!.isNotEmpty
                            ? CachedNetworkImage(imageUrl: 
                              ApiGate.getImageUrl(_selectedPatient!.fotoURL!),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return Center(
                                  child: Text(
                                    _selectedPatient!.initials,
                                    style: TextStyle(
                                      color: context.appColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                            )
                            : Center(
                              child: Text(
                                _selectedPatient!.initials,
                                style: TextStyle(
                                  color: context.appColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _selectedPatient!.nama,
                                style: TextStyle(fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.neutral800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: context.appColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          'NIM: ${_selectedPatient!.nim}',
                          style: TextStyle(
                            color: AppColors.neutral600,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.neutral500,
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
            const SizedBox(height: AppSpacing.lg),
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
                  backgroundColor: context.appColors.success,
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                  ),
                ),
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.appColors.onPrimary,
                        ),
                      )
                    : Icon(Icons.check_circle_rounded, color: context.appColors.onPrimary),
                label: Text(
                  _isSubmitting ? 'Mendaftarkan...' : 'Daftarkan Pasien',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.onPrimary,
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
        context.pop();
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
