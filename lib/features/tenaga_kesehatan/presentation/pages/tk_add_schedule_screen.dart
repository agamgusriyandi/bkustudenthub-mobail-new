import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_schedule_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';

class TkAddScheduleScreen extends StatefulWidget {
  const TkAddScheduleScreen({super.key});

  @override
  State<TkAddScheduleScreen> createState() => _TkAddScheduleScreenState();
}

class _TkAddScheduleScreenState extends State<TkAddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  int _kuota = 5;
  String _lokasi = '';
  String _tipeLayanan = 'Pemeriksaan Umum';
  String _catatan = '';
  bool _isSaving = false;

  final List<String> _tipeLayananOptions = [
    'Pemeriksaan Umum',
    'Konsultasi Gizi',
    'Screening Khusus',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Buat Jadwal Baru',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Tanggal
            _buildSectionLabel('Tanggal Praktik'),
            const SizedBox(height: AppSpacing.sm),
            _buildDatePicker(),
            const SizedBox(height: AppSpacing.s20),

            // Jam
            _buildSectionLabel('Jam Praktik'),
            const SizedBox(height: AppSpacing.sm),
            _buildTimePicker(),
            const SizedBox(height: AppSpacing.s20),

            // Kuota
            _buildSectionLabel('Kuota Peserta'),
            const SizedBox(height: AppSpacing.sm),
            _buildKuotaSelector(),
            const SizedBox(height: AppSpacing.s20),

            // Lokasi
            _buildSectionLabel('Lokasi'),
            const SizedBox(height: AppSpacing.sm),
            BkuTextField(
              decoration: InputDecoration(
                hintText: 'Contoh: Klinik Kampus Lt.1',
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
                prefixIcon: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.neutral500,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasi harus diisi';
                }
                return null;
              },
              onSaved: (value) => _lokasi = value ?? '',
            ),
            const SizedBox(height: AppSpacing.s20),

            // Tipe Layanan
            _buildSectionLabel('Tipe Layanan'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _tipeLayanan,
              decoration: InputDecoration(
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
              ),
              items:
                  _tipeLayananOptions.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipeLayanan = value ?? 'Pemeriksaan Umum';
                });
              },
            ),
            const SizedBox(height: AppSpacing.s20),

            // Catatan
            _buildSectionLabel('Catatan (Opsional)'),
            const SizedBox(height: AppSpacing.sm),
            BkuTextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan untuk mahasiswa...',
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
              ),
              onSaved: (value) => _catatan = value ?? '',
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Submit Button (Green Emerald)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                  ),
                ),
                icon: _isSaving
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
                  _isSaving ? 'Menyimpan...' : 'Simpan Jadwal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.neutral700),
            const SizedBox(width: AppSpacing.md),
            Text(
              _formatDate(_selectedDate),
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(color: AppColors.neutral200.withAlpha(150)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Mulai',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.neutral700,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(_startTime),
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '-',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(color: AppColors.neutral200.withAlpha(150)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Selesai',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.neutral700,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(_endTime),
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKuotaSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.people_rounded, color: AppColors.neutral700),
          const SizedBox(width: AppSpacing.md),
          const Text('Kuota:', style: TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          IconButton(
            onPressed: _kuota > 1 ? () => setState(() => _kuota--) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.neutral700,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral700.withAlpha(15),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              '$_kuota',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _kuota++),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.neutral700,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    _formKey.currentState!.save();

    final provider = context.read<TkScheduleProvider>();
    final success = await provider.createSchedule(
      tanggal: _selectedDate.toIso8601String().split('T')[0],
      jamMulai: _formatTime(_startTime),
      jamSelesai: _formatTime(_endTime),
      kuota: _kuota,
      lokasi: _lokasi,
      tipeLayanan: _tipeLayanan,
      catatan: _catatan.isNotEmpty ? _catatan : null,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Berhasil',
              content: 'Jadwal berhasil dibuat',
              cancelText: '',
              confirmText: 'Tutup',
              isSuccess: true,
              onCancel: () {},
              onConfirm: () => Navigator.pop(context),
            ),
      ).then((_) {
        if (mounted) context.pop();
      });
    } else if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Gagal',
              content: provider.error ?? 'Gagal membuat jadwal',
              cancelText: '',
              confirmText: 'Tutup',
              isDestructive: true,
              onCancel: () {},
              onConfirm: () => Navigator.pop(context),
            ),
      );
    }
  }
}
