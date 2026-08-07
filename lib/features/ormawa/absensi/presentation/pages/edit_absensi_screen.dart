import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class EditAbsensiScreen extends StatefulWidget {
  final String absensiId;
  final Map<String, dynamic> absensiData;

  const EditAbsensiScreen({
    super.key,
    required this.absensiId,
    required this.absensiData,
  });

  @override
  State<EditAbsensiScreen> createState() => _EditAbsensiScreenState();
}

class _EditAbsensiScreenState extends State<EditAbsensiScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _jumlahTotalController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.absensiData;
    _namaController = TextEditingController(text: (data['Nama'] ?? data['nama'] ?? '').toString());
    _deskripsiController = TextEditingController(text: (data['Deskripsi'] ?? data['deskripsi'] ?? '').toString());
    _lokasiController = TextEditingController(text: (data['Lokasi'] ?? data['lokasi'] ?? '').toString());
    _jumlahTotalController = TextEditingController(text: (data['JumlahTotal'] ?? data['jumlah_total'] ?? 0).toString());
    _selectedStatus = (data['Status'] ?? data['status'] ?? 'aktif').toString();

    try {
      _selectedDate = DateTime.parse((data['Tanggal'] ?? data['tanggal'] ?? '').toString());
    } catch (_) {
      _selectedDate = DateTime.now();
    }

    final startStr = (data['WaktuMulai'] ?? data['waktu_mulai'] ?? '09:00').toString();
    final startParts = startStr.split(':');
    _selectedStartTime = TimeOfDay(
      hour: int.tryParse(startParts.isNotEmpty ? startParts[0] : '9') ?? 9,
      minute: int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0,
    );

    final endStr = (data['WaktuSelesai'] ?? data['waktu_selesai'] ?? '11:00').toString();
    final endParts = endStr.split(':');
    _selectedEndTime = TimeOfDay(
      hour: int.tryParse(endParts.isNotEmpty ? endParts[0] : '11') ?? 11,
      minute: int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0,
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _jumlahTotalController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_namaController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'Nama': _namaController.text,
        'Deskripsi': _deskripsiController.text,
        'Lokasi': _lokasiController.text,
        'Tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'WaktuMulai': '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
        'WaktuSelesai': '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
        'JumlahTotal': int.tryParse(_jumlahTotalController.text) ?? 0,
        'Status': _selectedStatus,
      };

      await context.read<OrmawaProvider>().updateAbsensiManagement(widget.absensiId, data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Absensi berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal: $e');
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
      appBar: const BkuStaticAppBar(
        title: 'Edit Absensi',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('NAMA KEGIATAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _namaController, hint: 'Nama kegiatan'),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _deskripsiController, hint: 'Deskripsi...', maxLines: 3),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('LOKASI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _lokasiController, hint: 'Lokasi kegiatan'),
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
            _buildTextField(controller: _jumlahTotalController, hint: '0', isNumber: true),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('STATUS'),
            const SizedBox(height: AppSpacing.md),
            _buildStatusDropdown(),
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
                        'SIMPAN PERUBAHAN',
                        style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
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
    bool isNumber = false,
    int maxLines = 1,
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
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
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

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          items: ['aktif', 'selesai', 'dibatalkan'].map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedStatus = val);
          },
        ),
      ),
    );
  }
}
