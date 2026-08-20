import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreateProposalScreen extends StatefulWidget {
  final OrmawaProposal? initialProposal;

  const CreateProposalScreen({super.key, this.initialProposal});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
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
    if (widget.initialProposal != null) {
      _initFromProposal(widget.initialProposal!);
    }
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

  void _initFromProposal(OrmawaProposal p) {
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

  void _loadSampleData() {
    setState(() {
      _judulController.text = 'Latihan Keterampilan Manajemen Mahasiswa Tingkat Dasar (LKMM-TD) 2026';
      _bentukController.text = 'Pelatihan & Kaderisasi Kepemimpinan Mahasiswa';
      _sasaranController.text = 'Seluruh Mahasiswa Baru & Calon Pengurus Ormawa Angkatan 2025/2026';
      _mitraController.text = 'BEM Universitas, Himpunan Mahasiswa Jurusan, & UKM KEMA UBK';
      _deskripsiController.text =
          'Program kaderisasi kepemimpinan komprehensif yang dirancang untuk membekali mahasiswa dengan wawasan organisasi, manajemen konflik, komunikasi publik, dan etika kepemimpinan transformatif.';
      _lokasiController.text = 'Auditorium Utama UBK & Ruang Kelas Teori Kampus';
      _selectedSumberDana = 'Pagu Ormawa';
      _anggaranController.text = '12500000';
      _latarBelakangController.text =
          'Pentingnya regenerasi kepemimpinan yang berintegritas dan memiliki kecakapan manajerial modern dalam menggerakkan roda organisasi mahasiswa di lingkungan civitas akademika Universitas Bung Karno.';
      _tujuanController.text =
          '1. Meningkatkan kapabilitas manajerial pengurus organisasi.\n2. Menanamkan nilai-nilai kepemimpinan Pancasila dan integritas akademis.\n3. Membangun sinergi kolaboratif antar elemen lembaga kemahasiswaan.';
      _landasanController.text =
          'AD/ART Organisasi Mahasiswa, Keputusan Rektor UBK No. 042/SK/UBK/2025, dan Program Kerja Tahunan Divisi Kaderisasi.';
      _indikatorController.text =
          '1. Partisipasi aktif minimal 120 mahasiswa terdaftar.\n2. Kelulusan evaluasi kaderisasi mencapai 95% peserta.\n3. Terbentuknya 10 portofolio rencana aksi program mahasiswa baru.';
      _catatanController.text =
          'Mohon arahan dan verifikasi dari Wadek III Kemahasiswaan agar pagu alokasi dapat segera dicairkan untuk persiapan logistik.';
    });
    AppSnackbar.showSuccess(context, 'Contoh usulan LKMM-TD 2026 berhasil dimuat!');
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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: BkuTheme.textHeading,
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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: BkuTheme.textHeading,
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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: BkuTheme.textHeading,
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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              onSurface: BkuTheme.textHeading,
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
              style: BkuTheme.textBadge.copyWith(fontSize: 10, fontWeight: FontWeight.w900, color: BkuTheme.textMuted),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: BkuTheme.rose,
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
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: BkuTheme.textBodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: BkuTheme.textHeading,
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
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          timeDisplay,
                          style: BkuTheme.textBodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: BkuTheme.textHeading,
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
            Text(
              'Penanggung Jawab (Anggota Ormawa)',
              style: BkuTheme.textBadge.copyWith(fontSize: 10.5, fontWeight: FontWeight.w900, color: BkuTheme.textHeading),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: BkuTheme.rose,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (hasPJ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.primaryBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: BkuTheme.primary,
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pjController.text.trim(),
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Penanggung Jawab Usulan',
                        style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
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
                      borderRadius: BkuTheme.r8,
                      border: Border.all(color: BkuTheme.border),
                    ),
                    child: Text(
                      'Ganti',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: BkuTheme.primary,
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
                      color: BkuTheme.roseSoft,
                      borderRadius: BkuTheme.r8,
                      border: Border.all(color: BkuTheme.roseBorder),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: BkuTheme.rose),
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
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_search_rounded, size: 18, color: BkuTheme.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pilih Penanggung Jawab dari Anggota Ormawa...',
                      style: BkuTheme.textBodyRegular.copyWith(
                        fontSize: 12,
                        color: BkuTheme.textPlaceholder,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: BkuTheme.textPlaceholder),
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
                            color: BkuTheme.border,
                            borderRadius: BkuTheme.r8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Pilih Penanggung Jawab Usulan',
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Pilih dari daftar anggota aktif organisasi mahasiswa.',
                        style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                      ),
                      const SizedBox(height: 12),
                      BkuTextField(
                        hint: 'Cari nama, NIM, atau jabatan...',
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: BkuTheme.textPlaceholder),
                        onChanged: (val) => setModalState(() => query = val),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'Anggota tidak ditemukan',
                                  style: TextStyle(fontSize: 12, color: BkuTheme.textPlaceholder),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: BkuTheme.borderSubtle),
                                itemBuilder: (context, idx) {
                                  final m = filtered[idx];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: BkuTheme.primarySoft,
                                      child: Text(
                                        m.name.isNotEmpty ? m.name[0].toUpperCase() : 'A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: BkuTheme.primary,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      m.name,
                                      style: BkuTheme.textCardTitle.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${m.nim} • ${m.role}',
                                      style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
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
        'Status': 'diajukan',
        'status': 'diajukan',
      };

      if (_selectedFile != null && _selectedFile!.path != null) {
        final uploaded = await provider.uploadFile(_selectedFile!.path!);
        if (uploaded != null && uploaded.isNotEmpty) {
          payload['FileURL'] = uploaded;
          payload['file_url'] = uploaded;
        }
      }

      await provider.createProposal(payload);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Usulan proposal berhasil diajukan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal mengajukan proposal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Buat Proposal Baru',
            subtitle: 'Formulir Usulan Kegiatan & Pagu Ormawa',
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
                  BkuBounceButton(
                    onTap: _loadSampleData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: BkuTheme.skySoft,
                        borderRadius: BkuTheme.r12,
                        border: Border.all(color: BkuTheme.skyBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 16, color: BkuTheme.sky),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Muat Contoh Usulan Cepat',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: BkuTheme.sky,
                                  ),
                                ),
                                Text(
                                  'Isi otomatis form dengan data simulasi LKMM-TD 2026',
                                  style: TextStyle(fontSize: 9.5, color: BkuTheme.sky.withAlpha(200)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: BkuTheme.sky),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.primarySoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.event_note_rounded, color: BkuTheme.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Dasar Usulan',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Judul proposal, bentuk kegiatan, dan target sasaran.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'Nama / Judul Kegiatan Usulan *',
                          hint: 'e.g. LKMM Tingkat Dasar Ormawa 2026',
                          controller: _judulController,
                          prefixIcon: Icon(Icons.description_rounded, size: 16, color: BkuTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Bentuk / Kategori Kegiatan',
                          hint: 'e.g. Pelatihan & Kaderisasi Mahasiswa',
                          controller: _bentukController,
                          prefixIcon: Icon(Icons.category_rounded, size: 16, color: BkuTheme.purple),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Sasaran Peserta Kegiatan',
                          hint: 'e.g. Mahasiswa Baru & Calon Pengurus Ormawa',
                          controller: _sasaranController,
                          prefixIcon: Icon(Icons.groups_rounded, size: 16, color: BkuTheme.sky),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Mitra Kerja Sama / Kolaborator',
                          hint: 'e.g. BEM Universitas, HMJ, Pihak Eksternal',
                          controller: _mitraController,
                          prefixIcon: Icon(Icons.handshake_rounded, size: 16, color: BkuTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Deskripsi Lengkap Usulan',
                          hint: 'Tuliskan gambaran umum dan ringkasan eksekutif kegiatan...',
                          controller: _deskripsiController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.emeraldSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.access_time_rounded, color: BkuTheme.emerald, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Waktu & Lokasi Pelaksanaan',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Jadwal tanggal mulai, selesai, jam WIB, dan venue kegiatan.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDateTimeRow(
                          label: 'Tanggal & Jam Mulai',
                          date: _tanggalMulai,
                          timeStr: _waktuMulaiController.text,
                          onDateTap: _pickTanggalMulai,
                          onTimeTap: _pickWaktuMulai,
                        ),
                        const SizedBox(height: 12),
                        _buildDateTimeRow(
                          label: 'Tanggal & Jam Selesai',
                          date: _tanggalSelesai,
                          timeStr: _waktuSelesaiController.text,
                          onDateTap: _pickTanggalSelesai,
                          onTimeTap: _pickWaktuSelesai,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'LOKASI / VENUE KEGIATAN *',
                          hint: 'e.g. Auditorium Utama UBK',
                          controller: _lokasiController,
                          prefixIcon: Icon(Icons.location_on_rounded, size: 16, color: BkuTheme.rose),
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
                                  color: BkuTheme.borderSubtle,
                                  borderRadius: BkuTheme.r8,
                                  border: Border.all(color: BkuTheme.border),
                                ),
                                child: Text(
                                  v,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.purpleSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.people_alt_rounded, color: BkuTheme.purple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penanggung Jawab Usulan',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Pilih penanggung jawab dari daftar anggota resmi.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildMemberPicker(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.amberSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.account_balance_wallet_rounded, color: BkuTheme.amber, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Anggaran & Dokumen KAK',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Estimasi biaya, sumber pendanaan, dan lampiran berkas.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'Estimasi Anggaran Biaya (Rp)',
                          hint: 'e.g. 12500000',
                          controller: _anggaranController,
                          prefixIcon: const Icon(Icons.payments_rounded, size: 16, color: BkuTheme.emerald),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        BkuDropdown<String>(
                          label: 'Sumber Alokasi Dana',
                          value: _selectedSumberDana,
                          items: _sumberDanaOptions.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(
                                s,
                                style: BkuTheme.textBodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSumberDana = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dokumen Lampiran KAK / TOR (Maks 10MB)',
                          style: BkuTheme.textBadge.copyWith(fontSize: 10.5, fontWeight: FontWeight.w900, color: BkuTheme.textHeading),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BkuTheme.borderSubtle,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(color: BkuTheme.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedFile != null ? Icons.insert_drive_file_rounded : Icons.cloud_upload_outlined,
                                size: 24,
                                color: _selectedFile != null ? BkuTheme.primary : BkuTheme.textPlaceholder,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedFile != null
                                      ? '${_selectedFile!.name} (${(_selectedFile!.size / 1024).round()} KB)'
                                      : 'Pilih file KAK (PDF, Word, Excel, atau Gambar)...',
                                  style: BkuTheme.textCaption.copyWith(
                                    fontSize: 11,
                                    color: _selectedFile != null ? BkuTheme.textHeading : BkuTheme.textPlaceholder,
                                    fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              BkuButton.outline(
                                text: _selectedFile != null ? 'Ganti' : 'Pilih File',
                                height: 32,
                                onPressed: _pickFile,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Latar Belakang Kegiatan',
                          hint: 'Uraikan urgensi dan dasar pemikiran kegiatan...',
                          controller: _latarBelakangController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Tujuan & Manfaat Kegiatan',
                          hint: 'Uraikan tujuan strategis dan output yang diharapkan...',
                          controller: _tujuanController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Landasan Hukum & Kebijakan',
                          hint: 'Landasan yuridis / AD-ART / SK Kepengurusan...',
                          controller: _landasanController,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Indikator Keberhasilan',
                          hint: 'Target kuantitatif & kualitatif pelaksanaan...',
                          controller: _indikatorController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Catatan Tambahan untuk Reviewer',
                          hint: 'Catatan pengantar usulan bila diperlukan...',
                          controller: _catatanController,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: BkuButton.primary(
                      text: 'Ajukan Proposal Kegiatan',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: Icons.send_rounded,
                      height: 48,
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