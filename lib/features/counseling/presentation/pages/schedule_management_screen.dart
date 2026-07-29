import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  DateTime selectedDate = DateTime.now();

  // State lokal slot — TIDAK pernah di-overwrite setelah user edit
  Map<String, List<Map<String, dynamic>>> _slotsByDay = {};
  bool _isDirty = false;
  bool _isSaving = false;
  bool _initialLoaded = false;

  String get _selectedDayName => _indonesianDayName(selectedDate.weekday);
  List<Map<String, dynamic>> get _slotsForSelectedDate =>
      _slotsByDay[_selectedDayName] ?? [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CounselingProvider>();
      await provider.loadSchedules();
      if (mounted && !_initialLoaded) {
        _loadFromBackend(provider.schedules);
      }
    });
  }

  /// Hanya dipanggil SEKALI saat pertama load, atau saat user refresh manual
  void _loadFromBackend(List<Map<String, dynamic>> schedules) {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final dayData in schedules) {
      final day = dayData['day']?.toString() ?? '';
      final slots = dayData['slots'];
      if (slots is List) {
        map[day] =
            slots.map((slot) {
              final s = Map<String, dynamic>.from(slot as Map<String, dynamic>);
              // is_available dari backend (field is_available atau fallback ke true)
              if (!s.containsKey('is_available')) {
                s['is_available'] = true;
              }
              return s;
            }).toList();
      } else {
        map[day] = [];
      }
    }
    if (mounted) {
      setState(() {
        _slotsByDay = map;
        _initialLoaded = true;
        _isDirty = false;
      });
    }
  }

  /// Build payload untuk dikirim ke backend
  List<Map<String, dynamic>> _buildPayload() {
    const allDays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return allDays.map((day) {
      final slots = _slotsByDay[day] ?? [];
      final hasActive = slots.any((s) => s['is_available'] == true);
      return {
        'day': day,
        'enabled': hasActive,
        'slots':
            slots
                .map(
                  (slot) => {
                    'kategori': slot['kategori'] ?? 'Personal',
                    'start': slot['start'] ?? '',
                    'end': slot['end'] ?? '',
                    'lokasi': slot['lokasi'] ?? '',
                    'kuota': slot['kuota'] ?? 1,
                    'is_available': slot['is_available'] ?? true,
                  },
                )
                .toList(),
      };
    }).toList();
  }

  Future<void> _saveSchedules() async {
    setState(() => _isSaving = true);
    final provider = context.read<CounselingProvider>();
    final payload = _buildPayload();
    final success = await provider.saveSchedules(payload);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      // JANGAN sync dari provider — state lokal sudah benar
      // Hanya tandai tidak dirty kalau berhasil
      if (success) _isDirty = false;
    });

    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: success ? 'Berhasil' : 'Gagal',
            content:
                success
                    ? 'Jadwal berhasil disimpan!'
                    : 'Gagal menyimpan jadwal.',
            cancelText: '',
            confirmText: 'Tutup',
            isSuccess: success,
            confirmColor: const Color(0xFF16A34A),
            onCancel: () {},
            onConfirm: () => Navigator.pop(context),
          ),
    );
  }

  void _toggleSlotAvailability(int index, bool value) {
    setState(() {
      final slots = List<Map<String, dynamic>>.from(_slotsForSelectedDate);
      slots[index] = {...slots[index], 'is_available': value};
      _slotsByDay = {..._slotsByDay, _selectedDayName: slots};
      _isDirty = true;
    });
  }

  void _deleteSlot(int index) {
    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: 'Hapus Slot',
            content: 'Yakin ingin menghapus slot waktu ini?',
            cancelText: 'Batal',
            confirmText: 'Hapus',
            isDestructive: true,
            onCancel: () {},
            onConfirm: () {
              Navigator.pop(context);
              setState(() {
                final slots = List<Map<String, dynamic>>.from(
                  _slotsForSelectedDate,
                );
                slots.removeAt(index);
                _slotsByDay = {..._slotsByDay, _selectedDayName: slots};
                _isDirty = true;
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        if (provider.schedulesLoading && !_initialLoaded) {
          return Scaffold(
            backgroundColor: AppColors.neutral100,
            body: CustomScrollView(
              slivers: [
                const BkuAppBar(
                  title: 'Kelola Jadwal',
                  isExpandable: false,
                  variant: AppBarVariant.psychologist,
                  showBackButton: true,
                  showNotification: true,
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                title: 'Kelola Jadwal',
                isExpandable: false,
                variant: AppBarVariant.psychologist,
                showBackButton: true,
                showNotification: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarHeader(),
                    _buildCalendarStrip(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Slot Waktu'),
                              Material(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: AppRadius.radiusMd,
                                child: InkWell(
                                  borderRadius: AppRadius.radiusMd,
                                  onTap: () async {
                                    final p =
                                        context.read<CounselingProvider>();
                                    await context.push(
                                      AppRoutes.addScheduleSlot,
                                    );
                                    if (!mounted) return;
                                    _initialLoaded = false;
                                    _loadFromBackend(p.schedules);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.radiusMd,
                                      border: Border.all(
                                        color: const Color(0xFFBFDBFE),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 7,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                          color: Color(0xFF2563EB),
                                        ),
                                        SizedBox(width: AppSpacing.xs),
                                        Text(
                                          'Tambah Slot',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s20),
                          _buildTimeSlotsList(),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildBulkActions(),
                          const SizedBox(height: AppSpacing.s120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton:
              _isDirty
                  ? FadeInAnimation(
                    delay: 0.2,
                    child: FloatingActionButton.extended(
                      onPressed: _isSaving ? null : _saveSchedules,
                      backgroundColor: const Color(0xFF16A34A),
                      elevation: 4,
                      icon:
                          _isSaving
                               ? SizedBox(
                                 width: 20,
                                 height: 20,
                                 child: CircularProgressIndicator(
                                   color: context.appColors.onPrimary,
                                   strokeWidth: 2,
                                 ),
                               )
                               : Icon(
                                 Icons.check_circle_rounded,
                                 color: context.appColors.onPrimary,
                                size: 20,
                              ),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: context.appColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    const monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${monthNames[selectedDate.month]} ${selectedDate.year}',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Pilih tanggal untuk mengatur slot',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          Material(
            color: context.appColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFF16A34A),
                          onPrimary: context.appColors.onPrimary,
                          onSurface: AppColors.neutral900,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral500.withAlpha(40)),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              date.day == selectedDate.day && date.month == selectedDate.month;
          final dayName = _indonesianDayName(date.weekday);
          final slots = _slotsByDay[dayName] ?? [];
          final hasActiveSlot = slots.any((s) => s['is_available'] == true);

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 72,
              margin: const EdgeInsets.only(right: AppSpacing.md, top: AppSpacing.xs, bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: isSelected ? null : context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(0xFF0D9488).withAlpha(90),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                border:
                    isSelected
                        ? null
                        : Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _shortDay(date.weekday),
                    style: AppTextStyles.labelMd.copyWith(
                      color:
                          isSelected
                              ? context.appColors.onPrimary.withAlpha(220)
                              : AppColors.neutral600,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.titleLg.copyWith(
                      color: isSelected ? context.appColors.onPrimary : AppColors.neutral900,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? context.appColors.onPrimary
                              : hasActiveSlot
                              ? AppColors.success
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow:
                          hasActiveSlot || isSelected
                              ? [
                                BoxShadow(
                                  color: context.appColors.onPrimary.withAlpha(150),
                                  blurRadius: 4,
                                ),
                              ]
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotsList() {
    final slots = _slotsForSelectedDate;

    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral500.withAlpha(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Jadwal Kosong',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tidak ada slot untuk $_selectedDayName. Ketuk "Tambah Slot" untuk menjadwalkan sesi konseling.',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final start = slot['start']?.toString() ?? '';
        final end = slot['end']?.toString() ?? '';
        final kategori = slot['kategori']?.toString() ?? 'Personal';
        final lokasi = slot['lokasi']?.toString() ?? '';
        final kuota = (slot['kuota'] as num?)?.toInt() ?? 1;
        final isAvailable = slot['is_available'] == true;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            boxShadow:
                isAvailable
                    ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                    : [],
            border: Border.all(
              color:
                  isAvailable
                      ? AppColors.neutral500.withAlpha(30)
                      : AppColors.neutral500.withAlpha(50),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Time and Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color:
                              isAvailable
                                  ? AppColors.success.withAlpha(20)
                                  : AppColors.neutral200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color:
                              isAvailable
                                  ? AppColors.success
                                  : AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Text(
                        '$start - $end',
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.w800,
                          color:
                              isAvailable
                                  ? AppColors.neutral800
                                  : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _deleteSlot(index),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSlotChip(kategori, isAvailable),
                  if (lokasi.isNotEmpty) _buildSlotChip(lokasi, isAvailable),
                  _buildSlotChip(
                    kuota == 1 ? '1 Pasien' : 'Maks $kuota',
                    isAvailable,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Footer Row: Status Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAvailable ? 'Sesi Aktif' : 'Sesi Ditutup',
                    style: AppTextStyles.labelMd.copyWith(
                      color:
                          isAvailable
                              ? AppColors.success
                              : AppColors.neutral500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 24, // Control height for tighter layout
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: isAvailable,
                        activeTrackColor: AppColors.success,
                        onChanged:
                            (value) => _toggleSlotAvailability(index, value),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulkActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Aksi Cepat Harian',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral500.withAlpha(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionTile(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                title: 'Aktifkan Semua Slot',
                subtitle: 'Buka semua slot jadwal di hari ini',
                onTap: () {
                  setState(() {
                    final slots = List<Map<String, dynamic>>.from(
                      _slotsForSelectedDate,
                    );
                    _slotsByDay = {
                      ..._slotsByDay,
                      _selectedDayName:
                          slots
                              .map((s) => {...s, 'is_available': true})
                              .toList(),
                    };
                    _isDirty = true;
                  });
                },
                isTop: true,
              ),
              Divider(height: 1, color: AppColors.neutral500.withAlpha(20)),
              _buildActionTile(
                icon: Icons.block_rounded,
                color: AppColors.error,
                title: 'Nonaktifkan Semua Slot',
                subtitle: 'Tutup sementara semua slot hari ini',
                onTap: () {
                  setState(() {
                    final slots = List<Map<String, dynamic>>.from(
                      _slotsForSelectedDate,
                    );
                    _slotsByDay = {
                      ..._slotsByDay,
                      _selectedDayName:
                          slots
                              .map((s) => {...s, 'is_available': false})
                              .toList(),
                    };
                    _isDirty = true;
                  });
                },
                isTop: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTop,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(AppRadius.lg) : Radius.zero,
        bottom: !isTop ? const Radius.circular(AppRadius.lg) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral800,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500.withAlpha(100),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        color: AppColors.neutral900,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildSlotChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.neutral200 : AppColors.neutral500.withAlpha(20),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: isActive ? AppColors.neutral700 : AppColors.neutral500,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _shortDay(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[weekday - 1];
  }

  String _indonesianDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }
}
