import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class EditKegiatanScreen extends StatefulWidget {
  final dynamic kegiatan;

  const EditKegiatanScreen({super.key, required this.kegiatan});

  @override
  State<EditKegiatanScreen> createState() => _EditKegiatanScreenState();
}

class _EditKegiatanScreenState extends State<EditKegiatanScreen> {
  final _judulController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _pjController = TextEditingController();
  final _estimasiDanaController = TextEditingController();
  final _sumberDanaController = TextEditingController();
  final _mitraController = TextEditingController();
  final _sasaranController = TextEditingController();
  final _indikatorController = TextEditingController();
  final _landasanController = TextEditingController();
  final _latarBelakangController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _waktuMulaiController = TextEditingController(text: '09:00');
  final _waktuSelesaiController = TextEditingController(text: '16:00');

  String _selectedStatus = 'terjadwal';
  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now();
  bool _isSubmitting = false;
  String _eventId = '';

  final List<String> _venueSuggestions = [
    'Auditorium Utama UBK',
    'Ruang Rapat Ormawa Lt. 2',
    'Ruang Kelas Teori & Lab',
    'Virtual (Zoom / Google Meet)',
  ];

  final List<Map<String, String>> _statuses = [
    {'value': 'terjadwal', 'label': 'Terjadwal (Planned)'},
    {'value': 'berlangsung', 'label': 'Sedang Berlangsung'},
    {'value': 'selesai', 'label': 'Selesai Terlaksana'},
    {'value': 'dibatalkan', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final k = widget.kegiatan;
    if (k is OrmawaAgenda) {
      _eventId = k.id;
      _judulController.text = k.title;
      _kategoriController.text = k.bentukKegiatan ?? '';
      _lokasiController.text = k.location;
      _deskripsiController.text = k.description;
      _selectedStatus = k.status.toLowerCase();
      _tanggalMulai = k.date;
      _tanggalSelesai = k.endDate;
      _waktuMulaiController.text = DateFormat('HH:mm').format(k.date);
      _waktuSelesaiController.text = DateFormat('HH:mm').format(k.endDate);
      _pjController.text = k.pjKegiatan ?? '';
      _estimasiDanaController.text = k.estimasiDana != null && k.estimasiDana! > 0 ? k.estimasiDana!.toInt().toString() : '';
      _sumberDanaController.text = k.sumberDana ?? '';
      _mitraController.text = k.mitra ?? '';
      _sasaranController.text = k.sasaranKegiatan ?? '';
      _landasanController.text = k.landasanKegiatan ?? '';
      _latarBelakangController.text = k.latarBelakang ?? '';
      _tujuanController.text = k.tujuanKegiatan ?? '';
      _indikatorController.text = k.indikatorKeberhasilan ?? '';
    } else if (k is Map<String, dynamic>) {
      _eventId = (k['ID'] ?? k['id'] ?? '').toString();
      _judulController.text = (k['Judul'] ?? k['judul'] ?? '').toString();
      _kategoriController.text = (k['BentukKegiatan'] ?? k['bentuk_kegiatan'] ?? '').toString();
      _lokasiController.text = (k['Lokasi'] ?? k['lokasi'] ?? '').toString();
      _deskripsiController.text = (k['Deskripsi'] ?? k['deskripsi'] ?? '').toString();
      _selectedStatus = (k['Status'] ?? k['status'] ?? 'terjadwal').toString().toLowerCase();
      if (k['TanggalMulai'] != null) {
        try {
          _tanggalMulai = DateTime.parse(k['TanggalMulai'].toString());
          _waktuMulaiController.text = DateFormat('HH:mm').format(_tanggalMulai);
        } catch (_) {}
      }
      if (k['TanggalSelesai'] != null) {
        try {
          _tanggalSelesai = DateTime.parse(k['TanggalSelesai'].toString());
          _waktuSelesaiController.text = DateFormat('HH:mm').format(_tanggalSelesai);
        } catch (_) {}
      }
      _pjController.text = (k['PJKegiatan'] ?? k['pj_kegiatan'] ?? '').toString();
      _mitraController.text = (k['Mitra'] ?? k['mitra'] ?? '').toString();
      _sasaranController.text = (k['SasaranKegiatan'] ?? k['sasaran_kegiatan'] ?? '').toString();
      _estimasiDanaController.text = (k['EstimasiDana'] ?? k['estimasi_dana'] ?? '').toString();
      _sumberDanaController.text = (k['SumberDana'] ?? k['sumber_dana'] ?? '').toString();
      _landasanController.text = (k['LandasanKegiatan'] ?? k['landasan_kegiatan'] ?? '').toString();
      _latarBelakangController.text = (k['LatarBelakang'] ?? k['latar_belakang'] ?? '').toString();
      _tujuanController.text = (k['TujuanKegiatan'] ?? k['tujuan_kegiatan'] ?? '').toString();
      _indikatorController.text = (k['IndikatorKeberhasilan'] ?? k['indikator_keberhasilan'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kategoriController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _pjController.dispose();
    _estimasiDanaController.dispose();
    _sumberDanaController.dispose();
    _mitraController.dispose();
    _sasaranController.dispose();
    _indikatorController.dispose();
    _landasanController.dispose();
    _latarBelakangController.dispose();
    _tujuanController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _tanggalMulai, end: _tanggalSelesai),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

    if (range != null) {
      setState(() {
        _tanggalMulai = range.start;
        _tanggalSelesai = range.end;
      });
    }
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
                        'Pilih Penanggung Jawab (PJ)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'Pilih dari daftar anggota aktif organisasi.',
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
                                        _pjController.text = m.name;
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

  Future<void> _handleSubmit() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama / Topik kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final startIso = DateTime(
        _tanggalMulai.year,
        _tanggalMulai.month,
        _tanggalMulai.day,
        int.tryParse(_waktuMulaiController.text.split(':').firstOrNull ?? '9') ?? 9,
        int.tryParse(_waktuMulaiController.text.split(':').lastOrNull ?? '0') ?? 0,
      ).toIso8601String();

      final endIso = DateTime(
        _tanggalSelesai.year,
        _tanggalSelesai.month,
        _tanggalSelesai.day,
        int.tryParse(_waktuSelesaiController.text.split(':').firstOrNull ?? '16') ?? 16,
        int.tryParse(_waktuSelesaiController.text.split(':').lastOrNull ?? '0') ?? 0,
      ).toIso8601String();

      final payload = {
        'Judul': _judulController.text.trim(),
        'judul': _judulController.text.trim(),
        'BentukKegiatan': _kategoriController.text.trim(),
        'bentuk_kegiatan': _kategoriController.text.trim(),
        'Lokasi': _lokasiController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'Status': _selectedStatus,
        'status': _selectedStatus,
        'TanggalMulai': startIso,
        'tanggal_mulai': startIso,
        'TanggalSelesai': endIso,
        'tanggal_selesai': endIso,
        'PJKegiatan': _pjController.text.trim(),
        'pj_kegiatan': _pjController.text.trim(),
        'Mitra': _mitraController.text.trim(),
        'mitra': _mitraController.text.trim(),
        'SasaranKegiatan': _sasaranController.text.trim(),
        'sasaran_kegiatan': _sasaranController.text.trim(),
        'EstimasiDana': double.tryParse(_estimasiDanaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        'estimasi_dana': double.tryParse(_estimasiDanaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        'SumberDana': _sumberDanaController.text.trim(),
        'sumber_dana': _sumberDanaController.text.trim(),
        'LandasanKegiatan': _landasanController.text.trim(),
        'landasan_kegiatan': _landasanController.text.trim(),
        'LatarBelakang': _latarBelakangController.text.trim(),
        'latar_belakang': _latarBelakangController.text.trim(),
        'TujuanKegiatan': _tujuanController.text.trim(),
        'tujuan_kegiatan': _tujuanController.text.trim(),
        'IndikatorKeberhasilan': _indikatorController.text.trim(),
        'indikator_keberhasilan': _indikatorController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'JadwalPelaksanaan': _buildJadwalText(),
        'jadwal_pelaksanaan': _buildJadwalText(),
      };

      await context.read<OrmawaProvider>().updateAgenda(_eventId, payload);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Perubahan kegiatan berhasil disimpan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal memperbarui kegiatan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startFormat = DateFormat('dd MMM yyyy', 'id').format(_tanggalMulai);
    final endFormat = DateFormat('dd MMM yyyy', 'id').format(_tanggalSelesai);
    final isSameDate = _tanggalMulai.year == _tanggalSelesai.year &&
        _tanggalMulai.month == _tanggalSelesai.month &&
        _tanggalMulai.day == _tanggalSelesai.day;

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Edit Jadwal Kegiatan',
            subtitle: 'Pembaruan Data & Pelaksanaan Agenda',
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
                              child: const Icon(Icons.event_note_rounded, color: Color(0xFF2563EB), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Dasar Kegiatan',
                                    style: OrmawaTheme.textSectionTitle,
                                  ),
                                  const Text(
                                    'Topik utama, bentuk kegiatan, dan status agenda.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Nama / Topik Kegiatan *',
                          hintText: 'e.g. Samudra Leadership 2026',
                          controller: _judulController,
                          prefixIcon: Icons.event_note_rounded,
                          prefixIconColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Bentuk / Kategori Kegiatan',
                          hintText: 'e.g. LKMM Dasar, Webinar, Workshop, Raker',
                          controller: _kategoriController,
                          prefixIcon: Icons.category_rounded,
                          prefixIconColor: const Color(0xFF7C3AED),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Status Agenda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
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
                              value: _selectedStatus,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                              items: _statuses.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s['value'],
                                  child: Text(
                                    s['label']!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
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
                              child: const Icon(Icons.access_time_rounded, color: Color(0xFF059669), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Waktu & Lokasi Pelaksanaan',
                                    style: OrmawaTheme.textSectionTitle,
                                  ),
                                  const Text(
                                    'Jadwal tanggal, jam pelaksanaan WIB, dan venue.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Rentang Tanggal Pelaksanaan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        BkuBounceButton(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: OrmawaTheme.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF059669)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isSameDate ? startFormat : '$startFormat s/d $endFormat',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                const Text(
                                  'Ubah',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OrmawaTextField(
                                label: 'Jam Mulai (WIB)',
                                hintText: '08:00',
                                controller: _waktuMulaiController,
                                prefixIcon: Icons.schedule_rounded,
                                prefixIconColor: const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OrmawaTextField(
                                label: 'Jam Selesai (WIB)',
                                hintText: '16:00',
                                controller: _waktuSelesaiController,
                                prefixIcon: Icons.timelapse_rounded,
                                prefixIconColor: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Lokasi / Venue Kegiatan',
                          hintText: 'e.g. Auditorium Utama UBK',
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
                              child: const Icon(Icons.people_alt_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penanggung Jawab & Struktur',
                                    style: OrmawaTheme.textSectionTitle,
                                  ),
                                  const Text(
                                    'Penanggung jawab acara, mitra kolaborasi, dan target peserta.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Penanggung Jawab Kegiatan (PJ) *',
                          hintText: 'Pilih atau ketik nama penanggung jawab...',
                          controller: _pjController,
                          prefixIcon: Icons.person_rounded,
                          prefixIconColor: const Color(0xFF7C3AED),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.group_add_rounded, color: Color(0xFF7C3AED), size: 20),
                            onPressed: _showMemberPicker,
                            tooltip: 'Pilih dari Anggota',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Mitra Kerja Sama / Kolaborator',
                          hintText: 'e.g. BEM Fakultas, UKM Musik, Pihak Eksternal',
                          controller: _mitraController,
                          prefixIcon: Icons.handshake_rounded,
                          prefixIconColor: const Color(0xFF0D9488),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Sasaran Peserta',
                          hintText: 'e.g. Seluruh Mahasiswa Baru, Pengurus Ormawa',
                          controller: _sasaranController,
                          prefixIcon: Icons.groups_rounded,
                          prefixIconColor: const Color(0xFF0284C7),
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
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFD97706), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Anggaran & Rincian Strategis',
                                    style: OrmawaTheme.textSectionTitle,
                                  ),
                                  const Text(
                                    'Estimasi biaya, sumber dana, dan indikator keberhasilan.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Estimasi Dana (Rp)',
                          hintText: 'e.g. 10075000',
                          controller: _estimasiDanaController,
                          prefixIcon: Icons.payments_rounded,
                          prefixIconColor: const Color(0xFF059669),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Sumber Dana',
                          hintText: 'e.g. Kas Internal Ormawa & Pagu Anggaran Kampus',
                          controller: _sumberDanaController,
                          prefixIcon: Icons.savings_rounded,
                          prefixIconColor: const Color(0xFFD97706),
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Landasan & Latar Belakang Kegiatan',
                          hintText: 'Tuliskan urgensi dan latar belakang diadakannya kegiatan...',
                          controller: _latarBelakangController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Tujuan Kegiatan',
                          hintText: 'Tuliskan output dan tujuan yang diharapkan...',
                          controller: _tujuanController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Indikator Keberhasilan',
                          hintText: 'Parameter ketercapaian kegiatan (pisahkan dengan nomor / baris)...',
                          controller: _indikatorController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Deskripsi Lengkap Kegiatan',
                          hintText: 'Uraian detail rangkaian acara dan agenda pelaksanaan...',
                          controller: _deskripsiController,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OrmawaButton(
                      text: 'SIMPAN PERUBAHAN KEGIATAN',
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