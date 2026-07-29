import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class OrmawaAbsensiScreen extends StatefulWidget {
  final bool showBackButton;

  const OrmawaAbsensiScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaAbsensiScreen> createState() => _OrmawaAbsensiScreenState();
}

class _OrmawaAbsensiScreenState extends State<OrmawaAbsensiScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrmawaProvider>(context);
    if (!provider.hasPermission('view_attendance')) {
      return Scaffold(
        backgroundColor: AppColors.neutral100,
        body: CustomScrollView(
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'ABSENSI KEGIATAN',
              subtitle: 'AKSES DITOLAK',
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Akses Ditolak',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Anda tidak memiliki izin untuk mengelola atau melihat sistem absensi.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'ABSENSI KEGIATAN',
            subtitle: 'PRESENSI & KEHADIRAN',
            expandedHeight: 130.0,
            showBackButton: widget.showBackButton,
            isExpandable: false,
          ),
          Consumer<OrmawaProvider>(
            builder: (context, provider, child) {
              final allAgendas = provider.agendas;

              final agendas =
                  allAgendas.where((agenda) {
                      final now = DateTime.now();
                      final isPast = agenda.date.isBefore(
                        now.subtract(const Duration(days: 1)),
                      );
                      final status = isPast ? 'SELESAI' : 'AKTIF';

                      final matchesSearch = agenda.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                      final matchesFilter =
                          _statusFilter == 'Semua' ||
                          _statusFilter.toUpperCase() == status;

                      return matchesSearch && matchesFilter;
                    }).toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

              if (provider.isLoading && allAgendas.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: const [
                        BkuShimmer(
                          width: double.infinity,
                          height: 120,
                          borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
                        ),
                        SizedBox(height: AppSpacing.s20),
                        BkuShimmerList(itemCount: 3, itemHeight: 120),
                      ],
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  _buildQuickStats(provider),
                  _buildSearchAndFilter(),
                  if (agendas.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 64,
                              color: AppColors.neutral300,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum ada agenda kegiatan',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        AppSpacing.s20,
                        AppSpacing.s20,
                        100,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final agenda = agendas[index];
                          final now = DateTime.now();
                          final isPast = agenda.date.isBefore(
                            now.subtract(const Duration(days: 1)),
                          );
                          final status = isPast ? 'SELESAI' : 'AKTIF';
                          final statusColor =
                              isPast ? AppColors.info : AppColors.success;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: _buildAbsensiCard(
                              agenda.id,
                              agenda.title,
                              '${agenda.date.day}/${agenda.date.month}/${agenda.date.year} â€¢ ${agenda.date.hour}:${agenda.date.minute.toString().padLeft(2, '0')}',
                              status,
                              statusColor,
                            ),
                          );
                        }, childCount: agendas.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari nama kegiatan...',
                    hintStyle: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            InkWell(
              onTap: _showFilterBottomSheet,
              borderRadius: AppRadius.radiusLg,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      backgroundColor: context.appColors.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Filter Status',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Semua', 'Aktif', 'Selesai'].map((filter) {
                          final isSelected = _statusFilter == filter;
                          return ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? context.appColors.onPrimary
                                        : Theme.of(context).colorScheme.primary,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _statusFilter = filter);
                                setModalState(() => _statusFilter = filter);
                              }
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor: AppColors.neutral200,
                            side: BorderSide.none,

                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStats(OrmawaProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.layers_rounded,
                    title: 'Sesi Kegiatan',
                    value: provider.agendas.length.toString(),
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warning.withAlpha(15),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people_rounded,
                    title: 'Total Anggota',
                    value: provider.members.length.toString(),
                    iconColor: AppColors.neutral700,
                    iconBgColor: AppColors.neutral700.withAlpha(15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Hadir / Alpa',
                    value: '0 / 0',
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.success.withAlpha(15),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.percent_rounded,
                    title: 'Rasio Kehadiran',
                    value: '0%',
                    iconColor: AppColors.info,
                    iconBgColor: AppColors.info.withAlpha(15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiCard(
    String id,
    String title,
    String time,
    String status,
    Color statusColor,
  ) {
    final provider = Provider.of<OrmawaProvider>(context, listen: false);
    final canEditAttendance = provider.hasPermission('edit_attendance');
    final canSubmitAttendance = provider.hasPermission('submit_attendance');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      OrmawaAbsensiDetailScreen(title: title, eventId: id),
            ),
          );
        },
        borderRadius: AppRadius.radiusXl,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(10),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSm.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    time,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kehadiran',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontSize: 10,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OrmawaAbsensiDetailScreen(
                                      title: title,
                                      eventId: id,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            'Lihat Peserta',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (status.toUpperCase() != 'SELESAI' &&
                      (canEditAttendance || canSubmitAttendance))
                    Row(
                      children: [
                        if (AuthService().currentRole == UserRole.ormawa &&
                            canEditAttendance) ...[
                          OutlinedButton(
                            onPressed: () {
                              _showQrScannerDialog(context, id, title);
                            },

                            child: Text(
                              'Tampilkan QR',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        if (canSubmitAttendance)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OrmawaQrScanScreen(
                                        eventId: id,
                                        eventTitle: title,
                                      ),
                                ),
                              );
                            },

                            child: Text(
                              'Scan QR',
                              style: TextStyle(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrScannerDialog(
    BuildContext context,
    String eventId,
    String title,
  ) {
    final qrData = 'https://siakad.ubk.ac.id/student/presensi?eventId=$eventId';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _QrScannerDialogContent(
          eventId: eventId,
          title: title,
          qrData: qrData,
        );
      },
    );
  }
}

class _QrScannerDialogContent extends StatefulWidget {
  final String eventId;
  final String title;
  final String qrData;

  const _QrScannerDialogContent({
    required this.eventId,
    required this.title,
    required this.qrData,
  });

  @override
  State<_QrScannerDialogContent> createState() =>
      _QrScannerDialogContentState();
}

class _QrScannerDialogContentState extends State<_QrScannerDialogContent> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchAttendance(widget.eventId);
    });
    // Poll attendance list every 3 seconds to keep UI synced in real-time
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<OrmawaProvider>().fetchAttendance(widget.eventId);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusXl,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral500.withAlpha(10),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral500.withAlpha(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, child) {
                    final list = provider.attendanceList;
                    final attendedCount =
                        list.where((e) => e.status == 'hadir').length;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.neutral800,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Text(
                          'PEMINDAI QR PRESENSI',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral600,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s10),
                        Text(
                          widget.title,
                          style: AppTextStyles.titleLg.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Arahkan kamera mahasiswa ke kode QR di bawah ini untuk melakukan presensi secara mandiri.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(15),
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(
                              color: AppColors.success.withAlpha(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people_alt_rounded,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '$attendedCount Mahasiswa Hadir',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF166534),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color: AppColors.neutral200,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(10),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: widget.qrData,
                            version: QrVersions.auto,
                            size: 180.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),

                            child: const Text(
                              'TUTUP',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrmawaAbsensiDetailScreen extends StatefulWidget {
  final String title;
  final String eventId;
  const OrmawaAbsensiDetailScreen({
    super.key,
    required this.title,
    required this.eventId,
  });

  @override
  State<OrmawaAbsensiDetailScreen> createState() =>
      _OrmawaAbsensiDetailScreenState();
}

class _OrmawaAbsensiDetailScreenState extends State<OrmawaAbsensiDetailScreen> {
  bool _isSubmitting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchAttendance(widget.eventId);
    });
    // Start periodic polling for real-time check-in updates
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<OrmawaProvider>().fetchAttendance(widget.eventId);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _recordAttendance(String mahasiswaId, String status) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<OrmawaProvider>().submitAttendance(
        widget.eventId,
        mahasiswaId,
        status,
      );
      if (mounted) {
        AppSnackbar.showError(
          context,
          status == 'hadir'
              ? 'Kehadiran berhasil dicatat!'
              : 'Ketidakhadiran dicatat!',
        );
        // Refresh
        context.read<OrmawaProvider>().fetchAttendance(widget.eventId);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal mencatat kehadiran: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final list = provider.attendanceList;

          final attendedCount = list.where((e) => e.status == 'hadir').length;
          final absentCount =
              list.where((e) => e.status == 'tidak_hadir').length;

          return CustomScrollView(
            slivers: [
              BkuAppBar(
                title: 'Konfirmasi Kehadiran',
                variant: AppBarVariant.ormawa,
                showBackButton: true,
                isExpandable: false,
                showNotification: false,
                actions: [
                  IconButton(
                    onPressed: () => provider.fetchAttendance(widget.eventId),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: context.appColors.onPrimary,
                    ),
                  ),
                ],
              ),

              if (provider.isLoading && list.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: const [
                        BkuShimmer(
                          width: double.infinity,
                          height: 140,
                          borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
                        ),
                        SizedBox(height: AppSpacing.s20),
                        BkuShimmerList(itemCount: 4, itemHeight: 90),
                      ],
                    ),
                  ),
                )
              else ...[
                // Beautiful Header Card
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s10,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusXl,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          'Cek lis secara manual untuk memperbarui status kehadiran mahasiswa.',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral600,
                            height: 1.3,
                          ),
                        ),
                        if (list.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s18),
                          const Divider(color: AppColors.neutral200, height: 1),
                          const SizedBox(height: AppSpacing.s14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                    horizontal: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '$attendedCount Hadir',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: const Color(0xFF166534),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                    horizontal: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.cancel_rounded,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '$absentCount Alpa',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: const Color(0xFF991B1B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (list.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            size: 64,
                            color: AppColors.neutral300,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Belum ada data kehadiran',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s10,
                      AppSpacing.s20,
                      AppSpacing.s20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = list[index];
                        final isAttended = item.status == 'hadir';
                        final isAbsent = item.status == 'tidak_hadir';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              borderRadius: AppRadius.radiusXl,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    isAttended
                                        ? AppColors.success.withAlpha(80)
                                        : (isAbsent
                                            ? AppColors.error.withAlpha(80)
                                            : AppColors.neutral200),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Left status line
                                Container(
                                  width: 4,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color:
                                        isAttended
                                            ? AppColors.success
                                            : (isAbsent
                                                ? AppColors.error
                                                : AppColors.neutral300),
                                    borderRadius: AppRadius.radiusXs,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      isAttended
                                          ? AppColors.success.withAlpha(30)
                                          : (isAbsent
                                              ? AppColors.error.withAlpha(30)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(10)),
                                  child: Text(
                                    item.mahasiswaName?.isNotEmpty == true
                                        ? item.mahasiswaName!
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color:
                                          isAttended
                                              ? AppColors.success
                                              : (isAbsent
                                                  ? AppColors.error
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.primary),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.mahasiswaName ??
                                            'Mahasiswa #${item.mahasiswaId}',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s2),
                                      Text(
                                        'NIM. ${item.nim ?? item.mahasiswaId}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.neutral600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                () {
                                  final canEditAttendance = provider
                                      .hasPermission('edit_attendance');
                                  if (canEditAttendance) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap:
                                              () => _recordAttendance(
                                                item.mahasiswaId,
                                                'hadir',
                                              ),
                                          borderRadius: AppRadius.radiusMd,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isAttended
                                                      ? AppColors.success
                                                      : Colors.transparent,
                                              borderRadius: AppRadius.radiusMd,
                                              border: Border.all(
                                                color:
                                                    isAttended
                                                        ? AppColors.success
                                                        : const Color(
                                                          0xFFE2E8F0,
                                                        ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              color:
                                                  isAttended
                                                      ? context.appColors.onPrimary
                                                      : AppColors.neutral600,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        InkWell(
                                          onTap:
                                              () => _recordAttendance(
                                                item.mahasiswaId,
                                                'tidak_hadir',
                                              ),
                                          borderRadius: AppRadius.radiusMd,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isAbsent
                                                      ? AppColors.error
                                                      : Colors.transparent,
                                              borderRadius: AppRadius.radiusMd,
                                              border: Border.all(
                                                color:
                                                    isAbsent
                                                        ? AppColors.error
                                                        : const Color(
                                                          0xFFE2E8F0,
                                                        ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              color:
                                                  isAbsent
                                                      ? context.appColors.onPrimary
                                                      : AppColors.neutral600,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isAttended
                                                ? AppColors.success.withAlpha(
                                                  20,
                                                )
                                                : (isAbsent
                                                    ? AppColors.error.withAlpha(
                                                      20,
                                                    )
                                                    : AppColors.neutral500.withAlpha(
                                                      20,
                                                    )),
                                        borderRadius: AppRadius.radiusSm,
                                      ),
                                      child: Text(
                                        isAttended
                                            ? 'HADIR'
                                            : (isAbsent
                                                ? 'ALPA'
                                                : 'BELUM ABSEN'),
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              isAttended
                                                  ? AppColors.success
                                                  : (isAbsent
                                                      ? AppColors.error
                                                       : AppColors.neutral500),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }
                                }(),
                              ],
                            ),
                          ),
                        );
                      }, childCount: list.length),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
