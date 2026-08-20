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
    final agendas = context.watch<OrmawaProvider>().agendas;

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Tambah Sesi Presensi',
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
                        BkuDropdown<OrmawaAgenda?>(
                          label: 'Pilih dari Kegiatan Terjadwal (Opsional)',
                          value: _selectedExistingEvent,
                          hint: 'Pilih kegiatan untuk auto-fill data...',
                          items: [
                            DropdownMenuItem<OrmawaAgenda?>(
                              value: null,
                              child: Text(
                                '— Buat Sesi Baru (Manual) —',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ),
                            ...agendas.map(
                              (a) => DropdownMenuItem<OrmawaAgenda?>(
                                value: a,
                                child: Text(
                                  '${a.title} (${DateFormat('dd/MM/yyyy').format(a.date)})',
                                  style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: _onSelectEvent,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: BkuTheme.borderSubtle),
                        ),

                        BkuTextField(
                          label: 'NAMA SESI KEGIATAN *',
                          hint: 'Contoh: Rapat Pleno Bulanan...',
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
                          icon: Icons.check_rounded,
                          text: 'Simpan Sesi',
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