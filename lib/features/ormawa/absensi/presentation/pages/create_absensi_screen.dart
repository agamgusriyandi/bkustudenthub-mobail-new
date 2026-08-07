import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class CreateAbsensiScreen extends StatefulWidget {
  const CreateAbsensiScreen({super.key});

  @override
  State<CreateAbsensiScreen> createState() => _CreateAbsensiScreenState();
}

class _CreateAbsensiScreenState extends State<CreateAbsensiScreen> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: 0);
  int _jumlahTotal = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_namaController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'Nama': _namaController.text,
        'Deskripsi': _deskripsiController.text,
        'Lokasi': _lokasiController.text,
        'Tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'WaktuMulai': '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
        'WaktuSelesai': '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
        'JumlahTotal': _jumlahTotal,
        'Status': 'aktif',
      };

      await context.read<OrmawaProvider>().createAbsensiManagement(data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'Absensi Dibuat!',
            content: 'Sesi absensi kegiatan berhasil dibuat.',
            cancelText: '',
            confirmText: 'Kembali',
            onCancel: () {},
            onConfirm: () {
              context.pop();
              context.pop();
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.appColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedStartTime : _selectedEndTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.appColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
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
          BkuAppBar(
            title: 'Buat Absensi Baru',
            subtitle: 'Kehadiran Kegiatan',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NAMA KEGIATAN'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(controller: _namaController, hint: 'Contoh: Rapat Koordinasi', icon: Icons.event_rounded),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('DESKRIPSI'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(controller: _deskripsiController, hint: 'Deskripsi kegiatan...', icon: Icons.description_rounded, maxLines: 3),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('LOKASI'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(controller: _lokasiController, hint: 'Contoh: Ruang Aula', icon: Icons.location_on_rounded),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('TANGGAL'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDatePicker(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('WAKTU'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildTimePicker(label: 'Mulai', time: _selectedStartTime, isStart: true)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTimePicker(label: 'Selesai', time: _selectedEndTime, isStart: false)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLabel('JUMLAH PESERTA'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: TextEditingController(text: _jumlahTotal > 0 ? _jumlahTotal.toString() : ''),
                    hint: '0',
                    icon: Icons.people_rounded,
                    isNumber: true,
                    onChanged: (v) => _jumlahTotal = int.tryParse(v) ?? 0,
                  ),
                  const SizedBox(height: AppSpacing.s48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: context.appColors.onPrimary, strokeWidth: 2),
                            )
                          : Text(
                              'SIMPAN ABSENSI',
                              style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: context.appColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: context.appColors.primary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate),
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({required String label, required TimeOfDay time, required bool isStart}) {
    return InkWell(
      onTap: () => _pickTime(isStart: isStart),
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
