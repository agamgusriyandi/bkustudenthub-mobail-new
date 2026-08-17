import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
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

  Future<void> _pickDate(Color primaryColor) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart, required Color primaryColor}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedStartTime : _selectedEndTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
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

  Color _getStatusBg(String status, Color primary) {
    switch (status) {
      case 'berlangsung':
        return const Color(0xFFFEF3C7);
      case 'selesai':
        return const Color(0xFFD1FAE5);
      case 'dibatalkan':
        return const Color(0xFFFFE4E6);
      default:
        return primary.withAlpha(25);
    }
  }

  Color _getStatusColor(String status, Color primary) {
    switch (status) {
      case 'berlangsung':
        return const Color(0xFFB45309);
      case 'selesai':
        return const Color(0xFF047857);
      case 'dibatalkan':
        return const Color(0xFFBE123C);
      default:
        return primary;
    }
  }

  Widget _buildInputField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Edit Sesi Presensi',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NAMA SESI KEGIATAN *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        _buildInputField(_namaController, 'Nama kegiatan...'),
                        const SizedBox(height: 14),

                        const Text('TANGGAL PELAKSANAAN *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(primaryColor),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 15, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate),
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                                  const Text('MULAI *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _pickTime(isStart: true, primaryColor: primaryColor),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule_rounded, size: 15, color: primaryColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')} WIB',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                                  const Text('SELESAI *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _pickTime(isStart: false, primaryColor: primaryColor),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event_available_rounded, size: 15, color: primaryColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')} WIB',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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

                        const Text('STATUS SESI KEGIATAN *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
                              selectedItemBuilder: (context) {
                                return _statusOptions.map((opt) {
                                  final val = opt['value']!;
                                  final lbl = opt['label']!;
                                  final bg = _getStatusBg(val, primaryColor);
                                  final fg = _getStatusColor(val, primaryColor);
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lbl,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: fg),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              items: _statusOptions.map((opt) {
                                final val = opt['value']!;
                                final lbl = opt['label']!;
                                final bg = _getStatusBg(val, primaryColor);
                                final fg = _getStatusColor(val, primaryColor);
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: bg,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          lbl,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: fg),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text('LOKASI / RUANGAN', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        _buildInputField(_lokasiController, 'Contoh: Ruang Auditorium BKU...'),
                        const SizedBox(height: 14),

                        const Text('KETERANGAN & DESKRIPSI', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        _buildInputField(_deskripsiController, 'Keterangan agenda kegiatan...', maxLines: 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Batalkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text('Simpan Perubahan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
