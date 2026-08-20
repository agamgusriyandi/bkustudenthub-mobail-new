import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

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
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _selectedStatus;
  bool _isSubmitting = false;

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'terjadwal', 'label': 'Terjadwal'},
    {'value': 'berlangsung', 'label': 'Berlangsung'},
    {'value': 'selesai', 'label': 'Selesai'},
    {'value': 'dibatalkan', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.absensiData;
    _namaController = TextEditingController(text: (data['Nama'] ?? data['nama'] ?? data['Judul'] ?? '').toString());
    _deskripsiController = TextEditingController(text: (data['Deskripsi'] ?? data['deskripsi'] ?? '').toString());
    _lokasiController = TextEditingController(text: (data['Lokasi'] ?? data['lokasi'] ?? '').toString());

    final statusRaw = (data['Status'] ?? data['status'] ?? 'terjadwal').toString().toLowerCase();
    if (statusRaw == 'berlangsung' || statusRaw == 'ongoing' || statusRaw == 'aktif') {
      _selectedStatus = 'berlangsung';
    } else if (statusRaw == 'selesai' || statusRaw == 'terlaksana' || statusRaw == 'completed') {
      _selectedStatus = 'selesai';
    } else if (statusRaw == 'dibatalkan' || statusRaw == 'batal' || statusRaw == 'cancelled') {
      _selectedStatus = 'dibatalkan';
    } else {
      _selectedStatus = 'terjadwal';
    }

    try {
      _selectedDate = DateTime.parse((data['Tanggal'] ?? data['tanggal'] ?? data['TanggalMulai'] ?? '').toString());
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
    super.dispose();
  }

  void _handleSubmit() async {
    if (_namaController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final startDt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );
      var endDt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );
      if (endDt.isBefore(startDt)) {
        endDt = startDt.add(const Duration(hours: 2));
      }

      final data = widget.absensiData;
      final payload = {
        'Judul': _namaController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'Lokasi': _lokasiController.text.trim().isNotEmpty ? _lokasiController.text.trim() : 'Kampus Utama',
        'TanggalMulai': startDt.toUtc().toIso8601String(),
        'TanggalSelesai': endDt.toUtc().toIso8601String(),
        'Status': _selectedStatus,
        'landasan_kegiatan': data['landasan_kegiatan'] ?? data['LandasanKegiatan'] ?? '',
        'bentuk_kegiatan': data['bentuk_kegiatan'] ?? data['BentukKegiatan'] ?? '',
        'mitra': data['mitra'] ?? data['Mitra'] ?? '',
        'latar_belakang': data['latar_belakang'] ?? data['LatarBelakang'] ?? '',
        'tujuan_kegiatan': data['tujuan_kegiatan'] ?? data['TujuanKegiatan'] ?? '',
        'jadwal_pelaksanaan': data['jadwal_pelaksanaan'] ?? data['JadwalPelaksanaan'] ?? '',
        'sasaran_kegiatan': data['sasaran_kegiatan'] ?? data['SasaranKegiatan'] ?? '',
        'indikator_keberhasilan': data['indikator_keberhasilan'] ?? data['IndikatorKeberhasilan'] ?? '',
        'sumber_dana': data['sumber_dana'] ?? data['SumberDana'] ?? '',
        'estimasi_dana': (data['estimasi_dana'] ?? data['EstimasiDana']) != null
            ? (data['estimasi_dana'] ?? data['EstimasiDana'] as num).toDouble()
            : 0.0,
        'pj_kegiatan': data['pj_kegiatan'] ?? data['PJKegiatan'] ?? '',
      };

      final provider = context.read<OrmawaProvider>();
      await provider.updateAgenda(widget.absensiId, payload);
      await provider.refreshData();

      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Sesi absensi berhasil diperbarui!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal memperbarui absensi: $e');
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
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F766E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
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
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F766E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
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
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Edit Sesi Presensi',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BkuTextField(
                          label: 'NAMA SESI KEGIATAN *',
                          hint: 'Nama kegiatan...',
                          controller: _namaController,
                          prefixIcon: const Icon(Icons.event_note_rounded, size: 18, color: BkuTheme.textPlaceholder),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'TANGGAL PELAKSANAAN *',
                          style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.textMuted, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BkuTheme.r12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: BkuTheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate),
                                  style: BkuTheme.textBodyRegular.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MULAI *',
                                    style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _pickTime(isStart: true),
                                    borderRadius: BkuTheme.r12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.borderSubtle,
                                        borderRadius: BkuTheme.r12,
                                        border: Border.all(color: BkuTheme.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule_rounded, size: 16, color: BkuTheme.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')} WIB',
                                            style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELESAI *',
                                    style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _pickTime(isStart: false),
                                    borderRadius: BkuTheme.r12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.borderSubtle,
                                        borderRadius: BkuTheme.r12,
                                        border: Border.all(color: BkuTheme.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event_available_rounded, size: 16, color: BkuTheme.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')} WIB',
                                            style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        BkuDropdown<String>(
                          label: 'STATUS SESI KEGIATAN *',
                          value: _selectedStatus,
                          items: _statusOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt['value']!,
                              child: Text(
                                opt['label']!,
                                style: BkuTheme.textBodyRegular.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        BkuTextField(
                          label: 'Lokasi / Ruangan',
                          hint: 'Contoh: Ruang Auditorium BKU...',
                          controller: _lokasiController,
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: BkuTheme.textPlaceholder),
                        ),
                        const SizedBox(height: 14),

                        BkuTextField(
                          label: 'Keterangan & Deskripsi',
                          hint: 'Keterangan agenda kegiatan...',
                          controller: _deskripsiController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: BkuButton.outline(
                          onPressed: () => Navigator.pop(context),
                          text: 'Batalkan',
                          height: 46,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkuButton.primary(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          isLoading: _isSubmitting,
                          icon: Icons.save_rounded,
                          text: 'Simpan Perubahan',
                          height: 46,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}