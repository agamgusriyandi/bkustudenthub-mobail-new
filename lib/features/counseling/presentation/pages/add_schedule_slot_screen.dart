import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AddScheduleSlotScreen extends StatefulWidget {
  const AddScheduleSlotScreen({super.key});

  @override
  State<AddScheduleSlotScreen> createState() => _AddScheduleSlotScreenState();
}

class _AddScheduleSlotScreenState extends State<AddScheduleSlotScreen> {
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 0);
  String selectedDay = 'Senin';
  int selectedKuota = 1;
  final TextEditingController roomController = TextEditingController(
    text: 'Ruang Konseling A',
  );
  bool isRecurring = false;

  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: context.appColors.onPrimary,
              onSurface: AppColors.neutral800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
          if (endTime.hour < startTime.hour ||
              (endTime.hour == startTime.hour &&
                  endTime.minute <= startTime.minute)) {
            endTime = TimeOfDay(
              hour: (startTime.hour + 1) % 24,
              minute: startTime.minute,
            );
          }
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Tambah Slot',
            isExpandable: false,
            variant: AppBarVariant.psychologist,
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSection('Informasi Dasar', [
                    _buildLabel('Pilih Hari'),
                    _buildDayDropdown(),
                    const SizedBox(height: AppSpacing.s20),
                    _buildLabel('Lokasi / Ruangan'),
                    _buildRoomTextField(),
                    const SizedBox(height: AppSpacing.s20),
                    _buildLabel('Kuota (maks mahasiswa per slot)'),
                    _buildKuotaSelector(),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildFormSection('Pengaturan Waktu', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePickerField(
                            'Mulai',
                            startTime.format(context),
                            () => _selectTime(context, true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildTimePickerField(
                            'Selesai',
                            endTime.format(context),
                            () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildFormSection('Opsi Lainnya', [
                    _buildOptionTile(
                      'Ulangi Setiap Minggu',
                      'Aktifkan ketersediaan otomatis',
                      isRecurring,
                      (val) => setState(() => isRecurring = val),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDayDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: AppRadius.radiusMd,
      ),
      child: DropdownButtonHideUnderline(
        child: BkuDropdown<String>(
          value: selectedDay,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items:
              days.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: AppTextStyles.bodyLg),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => selectedDay = newValue);
          },
        ),
      ),
    );
  }

  Widget _buildRoomTextField() {
    return BkuTextField(
      controller: roomController,
      style: AppTextStyles.bodyLg,
      decoration: InputDecoration(
        labelText: 'Cari jadwal',
        hintText: 'Misal: Ruang Konseling A',
        filled: true,
        fillColor: AppColors.neutral200,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.meeting_room_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: AppRadius.radiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  time,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String desc,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                desc,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildKuotaSelector() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (selectedKuota > 1) setState(() => selectedKuota--);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  selectedKuota > 1
                      ? AppColors.primary.withAlpha(15)
                       : AppColors.neutral200.withAlpha(10),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(
              Icons.remove_rounded,
              color: selectedKuota > 1 ? AppColors.primary : AppColors.neutral500,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(
          '$selectedKuota mahasiswa',
          style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: AppSpacing.lg),
        GestureDetector(
          onTap: () {
            if (selectedKuota < 10) setState(() => selectedKuota++);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            selectedKuota == 1
                ? '(1 slot = 1 mahasiswa)'
                : '(maks $selectedKuota mahasiswa)',
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(30),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BkuButton(
          text: 'Simpan Slot Jadwal',
          onPressed: () => _saveSlot(context),
          variant: BkuButtonVariant.success,
          height: 48,
        ),
      ),
    );
  }

  Future<void> _saveSlot(BuildContext context) async {
    // Validasi waktu
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) {
      BkuDialog.show(
        context: context,
        title: 'Waktu Tidak Valid',
        message: 'Jam selesai harus lebih dari jam mulai',
        primaryButtonText: 'Tutup',
        type: BkuDialogType.error,
        onPrimaryPressed: () => context.pop(),
      );
      return;
    }

    final provider = context.read<CounselingProvider>();

    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final currentSchedules =
        provider.schedules.map((d) => Map<String, dynamic>.from(d)).toList();

    final newSlot = {
      'kategori': '',
      'start': formatTime(startTime),
      'end': formatTime(endTime),
      'lokasi': roomController.text.trim(),
      'kuota': selectedKuota,
      'is_recurring': isRecurring,
    };

    final dayIdx = currentSchedules.indexWhere((d) => d['day'] == selectedDay);
    if (dayIdx != -1) {
      final existingSlots =
          (currentSchedules[dayIdx]['slots'] as List? ?? [])
              .cast<Map<String, dynamic>>();
      final isDuplicate = existingSlots.any(
        (s) => s['start'] == newSlot['start'] && s['end'] == newSlot['end'],
      );
      if (isDuplicate) {
        if (context.mounted) {
          BkuDialog.show(
            context: context,
            title: 'Perhatian',
            message: 'Slot dengan jam yang sama sudah ada di hari ini',
            primaryButtonText: 'Tutup',
            type: BkuDialogType.warning,
            onPrimaryPressed: () => context.pop(),
          );
        }
        return;
      }
      final slots = List<Map<String, dynamic>>.from(existingSlots);
      slots.add(newSlot);
      slots.sort(
        (a, b) => (a['start'] as String).compareTo(b['start'] as String),
      );
      currentSchedules[dayIdx] = {
        ...currentSchedules[dayIdx],
        'enabled': true,
        'slots': slots,
      };
    } else {
      currentSchedules.add({
        'day': selectedDay,
        'enabled': true,
        'slots': [newSlot],
      });
    }

    final success = await provider.saveSchedules(currentSchedules);
    if (context.mounted) {
      BkuDialog.show(
        context: context,
        title: success ? 'Berhasil' : 'Gagal',
        message:
            success
                ? 'Slot jadwal berhasil ditambahkan!'
                : 'Gagal menyimpan slot. Coba lagi.',
        primaryButtonText: 'Tutup',
        type: success ? BkuDialogType.success : BkuDialogType.error,
        onPrimaryPressed: () {
          context.pop();
          if (success) context.pop();
        },
      );
    }
  }
}
