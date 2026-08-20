import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class EditProposalScreen extends StatefulWidget {
  final OrmawaProposal proposal;

  const EditProposalScreen({super.key, required this.proposal});

  @override
  State<EditProposalScreen> createState() => _EditProposalScreenState();
}

class _EditProposalScreenState extends State<EditProposalScreen> {
  final _judulController = TextEditingController();
  final _bentukController = TextEditingController();
  final _sasaranController = TextEditingController();
  final _mitraController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final _pjController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _anggaranController = TextEditingController();
  final _waktuMulaiController = TextEditingController(text: '08:00');
  final _waktuSelesaiController = TextEditingController(text: '16:00');

  final _latarBelakangController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _landasanController = TextEditingController();
  final _indikatorController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now();
  String _selectedSumberDana = 'Pagu Ormawa';
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  final List<String> _sumberDanaOptions = [
    'Pagu Ormawa',
    'Dana Kas Mandiri',
    'Dana Kemahasiswaan Universitas',
    'Sponsorship / Mitra',
    'Swadana / Iuran Peserta',
    'Pagu Ormawa & Internal',
    'Lainnya',
  ];

  final List<String> _venueSuggestions = [
    'Auditorium Utama UBK',
    'Ruang Rapat Ormawa Lantai 2',
    'Ruang Kelas Teori & Lab',
    'Virtual (Zoom Meeting / Google Meet)',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  DateTime? _parseIndonesianDate(String text) {
    try {
      final months = {
        'januari': 1, 'jan': 1,
        'februari': 2, 'feb': 2,
        'maret': 3, 'mar': 3,
        'april': 4, 'apr': 4,
        'mei': 5, 'may': 5,
        'juni': 6, 'jun': 6,
        'juli': 7, 'jul': 7,
        'agustus': 8, 'agu': 8, 'agt': 8, 'aug': 8,
        'september': 9, 'sep': 9,
        'oktober': 10, 'okt': 10, 'oct': 10,
        'november': 11, 'nov': 11,
        'desember': 12, 'des': 12, 'dec': 12,
      };
      final m = RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})').firstMatch(text);
      if (m != null) {
        final day = int.tryParse(m.group(1)!) ?? 1;
        final monthStr = m.group(2)!.toLowerCase();
        final month = months[monthStr] ?? 1;
        final year = int.tryParse(m.group(3)!) ?? DateTime.now().year;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  void _initData() {
    final p = widget.proposal;
    _judulController.text = p.title;
    _bentukController.text = p.bentukKegiatan ?? '';
    _sasaranController.text = p.sasaranKegiatan ?? '';
    _mitraController.text = p.mitra ?? '';
    _deskripsiController.text = p.description ?? '';
    _pjController.text = p.pjKegiatan ?? '';
    _anggaranController.text = p.budget > 0 ? p.budget.toInt().toString() : '';
    _tanggalMulai = p.date;
    _tanggalSelesai = p.tanggalSelesai ?? p.date;

    final jadwal = p.jadwalPelaksanaan ?? '';
    if (jadwal.isNotEmpty) {
      if (jadwal.contains(' s/d ')) {
        final parts = jadwal.split(' s/d ');
        if (parts.isNotEmpty) {
          final parsedStart = _parseIndonesianDate(parts[0]);
          if (parsedStart != null) _tanggalMulai = parsedStart;
        }
        if (parts.length > 1) {
          final parsedEnd = _parseIndonesianDate(parts[1]);
          if (parsedEnd != null) _tanggalSelesai = parsedEnd;
        }
      } else {
        final parsed = _parseIndonesianDate(jadwal);
        if (parsed != null) {
          _tanggalMulai = parsed;
          if (p.tanggalSelesai == null) {
            _tanggalSelesai = parsed;
          }
        }
      }
      final diMatch = RegExp(r'\bdi\s+(.+)$', caseSensitive: false).firstMatch(jadwal);
      if (diMatch != null && diMatch.group(1) != null) {
        _lokasiController.text = diMatch.group(1)!.trim();
      }
      final timeMatch = RegExp(r'\((\d{1,2}[:.]\d{2})\s*(?:-|s/d)?\s*(\d{1,2}[:.]\d{2})?\s*WIB\)', caseSensitive: false).firstMatch(jadwal);
      if (timeMatch != null) {
        if (timeMatch.group(1) != null) {
          _waktuMulaiController.text = timeMatch.group(1)!.replaceAll('.', ':').padLeft(5, '0');
        }
        if (timeMatch.group(2) != null) {
          _waktuSelesaiController.text = timeMatch.group(2)!.replaceAll('.', ':').padLeft(5, '0');
        }
      }
    }

    final incomingSumberDana = (p.sumberDana ?? '').trim();
    if (incomingSumberDana.isNotEmpty) {
      if (!_sumberDanaOptions.contains(incomingSumberDana)) {
        _sumberDanaOptions.insert(0, incomingSumberDana);
      }
      _selectedSumberDana = incomingSumberDana;
    } else {
      _selectedSumberDana = 'Pagu Ormawa';
    }
    _latarBelakangController.text = p.latarBelakang ?? '';
    _tujuanController.text = p.tujuanKegiatan ?? '';
    _landasanController.text = p.landasanKegiatan ?? '';
    _indikatorController.text = p.indikatorKeberhasilan ?? '';
    _catatanController.text = p.catatan ?? '';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _bentukController.dispose();
    _sasaranController.dispose();
    _mitraController.dispose();
    _deskripsiController.dispose();
    _pjController.dispose();
    _lokasiController.dispose();
    _anggaranController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    _latarBelakangController.dispose();
    _tujuanController.dispose();
    _landasanController.dispose();
    _indikatorController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickTanggalMulai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
                      ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
        if (_tanggalSelesai.isBefore(_tanggalMulai)) {
          _tanggalSelesai = _tanggalMulai;
        }
      });
    }
  }

  Future<void> _pickWaktuMulai() async {
    final currentParts = _waktuMulaiController.text.replaceAll('.', ':').split(':');
    final initialHour = currentParts.isNotEmpty ? int.tryParse(currentParts[0]) ?? 8 : 8;
    final initialMinute = currentParts.length > 1 ? int.tryParse(currentParts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
                      ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _waktuMulaiController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickTanggalSelesai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalSelesai.isBefore(_tanggalMulai) ? _tanggalMulai : _tanggalSelesai,
      firstDate: _tanggalMulai,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
                      ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalSelesai = picked;
      });
    }
  }

  Future<void> _pickWaktuSelesai() async {
    final currentParts = _waktuSelesaiController.text.replaceAll('.', ':').split(':');
    final initialHour = currentParts.isNotEmpty ? int.tryParse(currentParts[0]) ?? 16 : 16;
    final initialMinute = currentParts.length > 1 ? int.tryParse(currentParts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              onSurface: OrmawaTheme.textHeading,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _waktuSelesaiController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime date,
    required String timeStr,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(date);
    final cleanTime = timeStr.trim();
    final timeDisplay = cleanTime.isNotEmpty ? cleanTime.replaceAll(':', '.') : '08.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF43F5E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: BkuBounceButton(
                onTap: onDateTap,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BkuBounceButton(
                onTap: onTimeTap,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          timeDisplay,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Color(0xFF0F172A),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberPicker() {
    final hasPJ = _pjController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PENANGGUNG JAWAB (ANGGOTA ORMAWA)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF43F5E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (hasPJ)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Center(
                    child: Text(
                      _pjController.text.trim().isNotEmpty
                          ? _pjController.text.trim()[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pjController.text.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Penanggung Jawab Usulan',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                BkuBounceButton(
                  onTap: _showMemberPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'Ganti',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                BkuBounceButton(
                  onTap: () => setState(() => _pjController.clear()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFE11D48)),
                  ),
                ),
              ],
            ),
          )
        else
          BkuBounceButton(
            onTap: _showMemberPicker,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_search_rounded, size: 18, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pilih Penanggung Jawab dari Anggota Ormawa...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showMemberPicker() {
    final provider = context.read<OrmawaProvider>();
    final members = provider.members;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = members.where((m) {
              final name = m.name.toLowerCase();
              final nim = m.nim.toLowerCase();
              final role = m.role.toLowerCase();
              final q = query.toLowerCase();
              return name.contains(q) || nim.contains(q) || role.contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Pilih Penanggung Jawab Usulan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'Pilih dari daftar anggota aktif organisasi mahasiswa.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (val) => setModalState(() => query = val),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, NIM, atau jabatan...',
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'Anggota tidak ditemukan',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (context, idx) {
                                  final m = filtered[idx];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFFEFF6FF),
                                      child: Text(
                                        m.name.isNotEmpty ? m.name[0].toUpperCase() : 'A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      m.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${m.nim} • ${m.role}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _pjController.text = '${m.name} (${m.nim})';
                                      });
                                      Navigator.pop(ctx);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'xlsx', 'xls', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            AppSnackbar.showWarning(context, 'Ukuran file "${file.name}" melebihi batas 10MB');
          }
          return;
        }
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih dokumen lampiran');
      }
    }
  }

  String _buildJadwalText() {
    final startStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(_tanggalMulai);
    final endStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(_tanggalSelesai);
    final isSame = _tanggalMulai.year == _tanggalSelesai.year &&
        _tanggalMulai.month == _tanggalSelesai.month &&
        _tanggalMulai.day == _tanggalSelesai.day;

    final dateText = isSame ? startStr : '$startStr s/d $endStr';
    final wMulai = _waktuMulaiController.text.trim();
    final wSelesai = _waktuSelesaiController.text.trim();
    final timeText = wMulai.isNotEmpty ? ' ($wMulai - $wSelesai WIB)' : '';
    final locText = _lokasiController.text.trim().isNotEmpty ? ' di ${_lokasiController.text.trim()}' : '';
    return '$dateText$timeText$locText';
  }

  String _formatIso(DateTime d, String timeStr, String defaultTime) {
    final clean = timeStr.trim();
    int h = 8, m = 0;
    if (clean.isNotEmpty) {
      final parts = clean.split(':');
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 8;
      if (parts.length > 1) m = int.tryParse(parts[1]) ?? 0;
    }
    final dateStr = DateFormat('yyyy-MM-dd').format(d);
    final timeFormatted = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
    return '${dateStr}T$timeFormatted+07:00';
  }

  Future<void> _handleSubmit() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama / Judul Kegiatan usulan wajib diisi');
      return;
    }

    if (_lokasiController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Lokasi kegiatan wajib diisi');
      return;
    }

    final provider = context.read<OrmawaProvider>();
    final setting = provider.financialSetting;
    final anggaranVal = double.tryParse(_anggaranController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    if (setting != null && setting.active && setting.enforceLimit && anggaranVal > setting.remainingBudget) {
      final selisih = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(anggaranVal - setting.remainingBudget);
      AppSnackbar.showWarning(context, 'Anggaran melebihi sisa pagu sebesar $selisih');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final startIso = _formatIso(_tanggalMulai, _waktuMulaiController.text, '08:00');
      final endIso = _formatIso(_tanggalSelesai, _waktuSelesaiController.text, '16:00');

      final payload = <String, dynamic>{
        'Judul': _judulController.text.trim(),
        'judul': _judulController.text.trim(),
        'BentukKegiatan': _bentukController.text.trim(),
        'bentuk_kegiatan': _bentukController.text.trim(),
        'SasaranKegiatan': _sasaranController.text.trim(),
        'sasaran_kegiatan': _sasaranController.text.trim(),
        'Mitra': _mitraController.text.trim(),
        'mitra': _mitraController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'PJKegiatan': _pjController.text.trim(),
        'pj_kegiatan': _pjController.text.trim(),
        'Lokasi': _lokasiController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'TanggalKegiatan': startIso,
        'tanggal_kegiatan': startIso,
        'TanggalMulai': startIso,
        'tanggal_mulai': startIso,
        'TanggalSelesai': endIso,
        'tanggal_selesai': endIso,
        'SumberDana': _selectedSumberDana,
        'sumber_dana': _selectedSumberDana,
        'Anggaran': double.tryParse(_anggaranController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        'anggaran': double.tryParse(_anggaranController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        'LandasanKegiatan': _landasanController.text.trim(),
        'landasan_kegiatan': _landasanController.text.trim(),
        'LatarBelakang': _latarBelakangController.text.trim(),
        'latar_belakang': _latarBelakangController.text.trim(),
        'TujuanKegiatan': _tujuanController.text.trim(),
        'tujuan_kegiatan': _tujuanController.text.trim(),
        'IndikatorKeberhasilan': _indikatorController.text.trim(),
        'indikator_keberhasilan': _indikatorController.text.trim(),
        'Catatan': _catatanController.text.trim(),
        'catatan': _catatanController.text.trim(),
        'JadwalPelaksanaan': _buildJadwalText(),
        'jadwal_pelaksanaan': _buildJadwalText(),
      };

      String? finalFileUrl = widget.proposal.fileUrl;
      if (_selectedFile != null && _selectedFile!.path != null) {
        final uploaded = await provider.uploadFile(_selectedFile!.path!);
        if (uploaded != null && uploaded.isNotEmpty) {
          finalFileUrl = uploaded;
        }
      }
      if (finalFileUrl != null && finalFileUrl.isNotEmpty) {
        payload['FileURL'] = finalFileUrl;
        payload['file_url'] = finalFileUrl;
      }

      final ormawaId = widget.proposal.ormawaId ?? provider.ormawaId;
      if (ormawaId != null && ormawaId.isNotEmpty) {
        final parsedOrmawaId = int.tryParse(ormawaId) ?? 0;
        if (parsedOrmawaId > 0) {
          payload['OrmawaID'] = parsedOrmawaId;
          payload['ormawa_id'] = parsedOrmawaId;
        }
      }
      if (widget.proposal.mahasiswaId != null && widget.proposal.mahasiswaId!.isNotEmpty) {
        final parsedMahasiswaId = int.tryParse(widget.proposal.mahasiswaId!) ?? 0;
        if (parsedMahasiswaId > 0) {
          payload['MahasiswaID'] = parsedMahasiswaId;
          payload['mahasiswa_id'] = parsedMahasiswaId;
        }
      }

      await provider.updateProposal(widget.proposal.id, payload);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Perubahan proposal berhasil disimpan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        var msg = 'Gagal memperbarui proposal: $e';
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            msg = data['message'].toString();
          }
        }
        AppSnackbar.showError(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRevisi = widget.proposal.status.toLowerCase() == 'revisi';
    final effectiveOptions = List<String>.from(_sumberDanaOptions);
    if (_selectedSumberDana.isNotEmpty && !effectiveOptions.contains(_selectedSumberDana)) {
      effectiveOptions.insert(0, _selectedSumberDana);
    }

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Edit Usulan Proposal',
            subtitle: 'Pembaruan Data & Naskah Kegiatan',
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRevisi) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status: Butuh Revisi Pengajuan',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.proposal.catatan != null && widget.proposal.catatan!.isNotEmpty
                                      ? 'Catatan Reviewer: "${widget.proposal.catatan}"'
                                      : 'Silakan lakukan penyesuaian naskah, anggaran, atau berkas sesuai arahan reviewer, lalu ajukan kembali.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Informasi Utama Usulan', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Nama kegiatan, bentuk program kerja, sasaran, dan mitra.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Nama / Judul Kegiatan Usulan *',
                          hintText: 'Contoh: Samudra Leadership / LKMM Dasar...',
                          controller: _judulController,
                          prefixIcon: Icons.title_rounded,
                          prefixIconColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Bentuk / Kategori Kegiatan',
                          hintText: 'Contoh: LKMM Dasar, Seminar Nasional, Workshop...',
                          controller: _bentukController,
                          prefixIcon: Icons.category_rounded,
                          prefixIconColor: const Color(0xFF7C3AED),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Sasaran Kegiatan & Peserta',
                          hintText: 'Contoh: Mahasiswa Baru & Pengurus Ormawa...',
                          controller: _sasaranController,
                          prefixIcon: Icons.groups_rounded,
                          prefixIconColor: const Color(0xFF0284C7),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Mitra / Instansi Kolaborasi',
                          hintText: 'Contoh: BEM Fakultas, UKM Musik, Pihak Eksternal...',
                          controller: _mitraController,
                          prefixIcon: Icons.handshake_rounded,
                          prefixIconColor: const Color(0xFF0D9488),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Deskripsi Ringkas Usulan',
                          hintText: 'Tuliskan gambaran umum konsep pelaksanaan dan target output kegiatan...',
                          controller: _deskripsiController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.payments_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Penanggung Jawab & Anggaran', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'PIC anggota ormawa, jadwal, sumber alokasi dana, dan biaya.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildMemberPicker(),
                        const SizedBox(height: 12),
                        _buildDateTimeRow(
                          label: 'Tanggal Pelaksanaan',
                          date: _tanggalMulai,
                          timeStr: _waktuMulaiController.text,
                          onDateTap: _pickTanggalMulai,
                          onTimeTap: _pickWaktuMulai,
                        ),
                        const SizedBox(height: 12),
                        _buildDateTimeRow(
                          label: 'Selesai Pelaksanaan',
                          date: _tanggalSelesai,
                          timeStr: _waktuSelesaiController.text,
                          onDateTap: _pickTanggalSelesai,
                          onTimeTap: _pickWaktuSelesai,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Lokasi / Venue Kegiatan *',
                          hintText: 'Contoh: Auditorium Utama UBK',
                          controller: _lokasiController,
                          prefixIcon: Icons.location_on_rounded,
                          prefixIconColor: const Color(0xFFE11D48),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _venueSuggestions.map((v) {
                            return BkuBounceButton(
                              onTap: () => setState(() => _lokasiController.text = v),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  v,
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sumber Alokasi Dana',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: OrmawaTheme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSumberDana,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                              items: effectiveOptions.map((opt) {
                                return DropdownMenuItem<String>(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSumberDana = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Estimasi Total Anggaran (Rp) *',
                          hintText: 'Contoh: 12500000',
                          controller: _anggaranController,
                          prefixIcon: Icons.monetization_on_rounded,
                          prefixIconColor: const Color(0xFF059669),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.article_rounded, color: Color(0xFF059669), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Naskah Kerangka Acuan Kerja (KAK / TOR)', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Latar belakang, tujuan, landasan, dan indikator keberhasilan.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Latar Belakang Kegiatan',
                          hintText: 'Uraikan urgensi dan alasan strategis diadakannya kegiatan...',
                          controller: _latarBelakangController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Tujuan & Manfaat Kegiatan',
                          hintText: 'Tuliskan tujuan spesifik dan output yang diharapkan...',
                          controller: _tujuanController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Landasan Hukum & Kebijakan',
                          hintText: 'Contoh: AD/ART Organisasi, SK Rektor, atau Program Kerja Tahunan...',
                          controller: _landasanController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Indikator Keberhasilan (Output & Outcome)',
                          hintText: 'Tuliskan poin tolok ukur keberhasilan kegiatan...',
                          controller: _indikatorController,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.attach_file_rounded, color: Color(0xFFD97706), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Berkas Lampiran & Catatan', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Unggah naskah dokumen proposal dan catatan pengantar.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Dokumen Proposal & Lampiran',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        BkuBounceButton(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF2563EB), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFile != null
                                            ? _selectedFile!.name
                                            : (widget.proposal.fileUrl != null && widget.proposal.fileUrl!.isNotEmpty
                                                ? 'Dokumen lampiran tersimpan'
                                                : 'Pilih file dokumen lampiran baru'),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _selectedFile != null
                                            ? '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB'
                                            : 'PDF, DOCX, XLSX (Maks. 10MB)',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _selectedFile != null ? 'Ganti' : 'Pilih File',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Catatan Tambahan Pengajuan',
                          hintText: 'Pesan atau catatan khusus untuk verifikator prodi / fakultas / universitas...',
                          controller: _catatanController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OrmawaButton(
                      text: 'SIMPAN PERUBAHAN PROPOSAL',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: Icons.save_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}