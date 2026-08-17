import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

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
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isSubmitting = false;
  OrmawaAgenda? _selectedExistingEvent;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _onSelectEvent(OrmawaAgenda? agenda) {
    setState(() {
      _selectedExistingEvent = agenda;
      if (agenda != null) {
        _namaController.text = 'Presensi - ${agenda.title}';
        _selectedDate = agenda.date;
        _selectedStartTime = TimeOfDay(hour: agenda.date.hour, minute: agenda.date.minute);
        _selectedEndTime = TimeOfDay(hour: agenda.endDate.hour, minute: agenda.endDate.minute);
        _lokasiController.text = agenda.location;
        _deskripsiController.text = agenda.description;
      }
    });
  }

  void _handleSubmit() async {
    if (_namaController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan / sesi wajib diisi');
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

      final payload = {
        'Judul': _namaController.text.trim(),
        'TanggalMulai': startDt.toUtc().toIso8601String(),
        'TanggalSelesai': endDt.toUtc().toIso8601String(),
        'Lokasi': _lokasiController.text.trim().isNotEmpty ? _lokasiController.text.trim() : 'Kampus Utama',
        'Status': 'terjadwal',
        'Deskripsi': _deskripsiController.text.trim(),
        'PJKegiatan': _selectedExistingEvent?.pjKegiatan,
      };

      await context.read<OrmawaProvider>().addAgenda(payload);

      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Sesi absensi kegiatan berhasil dibuat!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal membuat sesi absensi: $e');
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

  @override
  Widget build(BuildContext context) {
    final agendas = context.watch<OrmawaProvider>().agendas;
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Tambah Sesi Presensi',
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
                        const Text('PILIH DARI KEGIATAN TERJADWAL (OPSIONAL)', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<OrmawaAgenda?>(
                              value: _selectedExistingEvent,
                              isExpanded: true,
                              hint: const Text('Pilih kegiatan untuk auto-fill data...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              items: [
                                DropdownMenuItem<OrmawaAgenda?>(
                                  value: null,
                                  child: Text('— Buat Sesi Baru (Manual) —', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                                ),
                                ...agendas.map(
                                  (a) => DropdownMenuItem<OrmawaAgenda?>(
                                    value: a,
                                    child: Text(
                                      '${a.title} (${DateFormat('dd/MM/yyyy').format(a.date)})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _onSelectEvent,
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        const Text('NAMA SESI KEGIATAN *', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        _buildInputField(_namaController, 'Contoh: Rapat Pleno Bulanan...'),
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
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Simpan Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
