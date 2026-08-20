import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreateKegiatanScreen extends StatefulWidget {
  const CreateKegiatanScreen({super.key});

  @override
  State<CreateKegiatanScreen> createState() => _CreateKegiatanScreenState();
}

class _CreateKegiatanScreenState extends State<CreateKegiatanScreen> {
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

  void _fillPreset() {
    setState(() {
      _judulController.text = 'Samudra Leadership 2026';
      _kategoriController.text = 'LKMM Dasar';
      _lokasiController.text = 'Auditorium Utama UBK & Ruang Diskusi Kampus';
      _tanggalMulai = DateTime.now().add(const Duration(days: 7));
      _tanggalSelesai = DateTime.now().add(const Duration(days: 7));
      _waktuMulaiController.text = '08:00';
      _waktuSelesaiController.text = '16:00';
      _selectedStatus = 'terjadwal';
      _pjController.text = 'Regina Felling Yuan Ananta';
      _estimasiDanaController.text = '10075000';
      _sumberDanaController.text = 'Kas Internal Ormawa & Pagu Anggaran Kampus';
      _mitraController.text = 'Seluruh LK dan UKM KEMA UBK';
      _sasaranController.text = 'Lembaga Kemahasiswaan (LK), UKM dan Mahasiswa Aktif UBK';
      _indikatorController.text = '1. Seluruh peserta mengikuti minimal 3 dari 4 sesi interaktif.\n2. Tercipta minimal 1 output rencana kerja dari setiap kelompok.\n3. Teridentifikasi minimal 15 calon kader pengurus.';
      _landasanController.text = 'Arahan Kebijakan Kemahasiswaan Universitas Bhakti Kencana';
      _latarBelakangController.text = 'Mahasiswa sebagai calon pemimpin bangsa perlu dibekali karakter kepemimpinan, kemampuan manajerial organisasi, serta integritas yang tangguh.';
      _tujuanController.text = 'Mempersiapkan mahasiswa aktif untuk memiliki kompetensi kepemimpinan dan manajemen organisasi yang adaptif.';
      _deskripsiController.text = 'Samudra Leadership adalah program pelatihan kepemimpinan dan manajemen organisasi mahasiswa Universitas Bhakti Kencana yang dirancang secara terstruktur dan aplikatif.';
    });
    AppSnackbar.showSuccess(context, 'Contoh data (Samudra Leadership) berhasil dimuat!');
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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              onSurface: BkuTheme.textHeading,
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
                            color: BkuTheme.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Pilih Penanggung Jawab (PJ)',
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Pilih dari daftar anggota aktif organisasi.',
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

      await context.read<OrmawaProvider>().addAgenda(payload);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Jadwal kegiatan berhasil disimpan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal menambahkan kegiatan: $e');
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
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Tambah Jadwal Kegiatan',
            subtitle: 'Formulir Rencana Agenda Ormawa',
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
                    onTap: _fillPreset,
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
                                  'Muat Contoh Data Cepat',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: BkuTheme.sky,
                                  ),
                                ),
                                Text(
                                  'Isi otomatis form dengan preset Samudra Leadership',
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
                                    'Informasi Dasar Kegiatan',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Topik utama, bentuk kegiatan, dan status agenda.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'Nama / Topik Kegiatan *',
                          hint: 'e.g. Samudra Leadership 2026',
                          controller: _judulController,
                          prefixIcon: Icon(Icons.event_note_rounded, size: 16, color: BkuTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Bentuk / Kategori Kegiatan',
                          hint: 'e.g. LKMM Dasar, Webinar, Workshop, Raker',
                          controller: _kategoriController,
                          prefixIcon: Icon(Icons.category_rounded, size: 16, color: BkuTheme.purple),
                        ),
                        const SizedBox(height: 12),
                        BkuDropdown<String>(
                          label: 'Status Agenda',
                          value: _selectedStatus,
                          items: _statuses.map((s) {
                            return DropdownMenuItem<String>(
                              value: s['value']!,
                              child: Text(
                                s['label']!,
                                style: BkuTheme.textBodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
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
                              child: Icon(Icons.access_time_rounded, color: BkuTheme.emerald, size: 18),
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
                                    'Jadwal tanggal, jam pelaksanaan WIB, dan venue.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Rentang Tanggal Pelaksanaan',
                          style: BkuTheme.textBadge.copyWith(fontSize: 10.5, fontWeight: FontWeight.w900, color: BkuTheme.textHeading),
                        ),
                        const SizedBox(height: 6),
                        BkuBounceButton(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 18, color: BkuTheme.emerald),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isSameDate ? startFormat : '$startFormat s/d $endFormat',
                                    style: BkuTheme.textBodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  'Ubah',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: BkuTheme.emerald),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: BkuTextField(
                                label: 'Jam Mulai (WIB)',
                                hint: '08:00',
                                controller: _waktuMulaiController,
                                prefixIcon: Icon(Icons.schedule_rounded, size: 16, color: BkuTheme.emerald),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BkuTextField(
                                label: 'Jam Selesai (WIB)',
                                hint: '16:00',
                                controller: _waktuSelesaiController,
                                prefixIcon: Icon(Icons.timelapse_rounded, size: 16, color: BkuTheme.emerald),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Lokasi / Venue Kegiatan',
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
                                    'Penanggung Jawab & Struktur',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Penanggung jawab acara, mitra kolaborasi, dan target peserta.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'PENANGGUNG JAWAB KEGIATAN (PJ) *',
                          hint: 'Pilih atau ketik nama penanggung jawab...',
                          controller: _pjController,
                          prefixIcon: Icon(Icons.person_rounded, size: 16, color: BkuTheme.purple),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.group_add_rounded, color: BkuTheme.purple, size: 20),
                            onPressed: _showMemberPicker,
                            tooltip: 'Pilih dari Anggota',
                          ),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Mitra Kerja Sama / Kolaborator',
                          hint: 'e.g. BEM Fakultas, UKM Musik, Pihak Eksternal',
                          controller: _mitraController,
                          prefixIcon: Icon(Icons.handshake_rounded, size: 16, color: BkuTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Sasaran Peserta',
                          hint: 'e.g. Seluruh Mahasiswa Baru, Pengurus Ormawa',
                          controller: _sasaranController,
                          prefixIcon: Icon(Icons.groups_rounded, size: 16, color: BkuTheme.sky),
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
                                    'Anggaran & Rincian Strategis',
                                    style: BkuTheme.textSectionTitle,
                                  ),
                                  Text(
                                    'Estimasi biaya, sumber dana, dan indikator keberhasilan.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'Estimasi Dana (Rp)',
                          hint: 'e.g. 10075000',
                          controller: _estimasiDanaController,
                          prefixIcon: Icon(Icons.payments_rounded, size: 16, color: BkuTheme.emerald),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Sumber Dana',
                          hint: 'e.g. Kas Internal Ormawa & Pagu Anggaran Kampus',
                          controller: _sumberDanaController,
                          prefixIcon: Icon(Icons.savings_rounded, size: 16, color: BkuTheme.amber),
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Landasan & Latar Belakang Kegiatan',
                          hint: 'Tuliskan urgensi dan latar belakang diadakannya kegiatan...',
                          controller: _latarBelakangController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Tujuan Kegiatan',
                          hint: 'Tuliskan output dan tujuan yang diharapkan...',
                          controller: _tujuanController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Indikator Keberhasilan',
                          hint: 'Parameter ketercapaian kegiatan (pisahkan dengan nomor / baris)...',
                          controller: _indikatorController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BkuTextField(
                          label: 'Deskripsi Lengkap Kegiatan',
                          hint: 'Uraian detail rangkaian acara dan agenda pelaksanaan...',
                          controller: _deskripsiController,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: BkuButton.primary(
                      text: 'Simpan Jadwal Kegiatan',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: Icons.save_rounded,
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