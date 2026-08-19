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
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreateKegiatanScreen extends StatefulWidget {
  const CreateKegiatanScreen({super.key});

  @override
  State<CreateKegiatanScreen> createState() => _CreateKegiatanScreenState();
}

class _CreateKegiatanScreenState extends State<CreateKegiatanScreen> {
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _pjController = TextEditingController();
  final _estimasiDanaController = TextEditingController();
  final _sumberDanaController = TextEditingController();
  final _bentukKegiatanController = TextEditingController();
  final _mitraController = TextEditingController();
  final _sasaranController = TextEditingController();
  final _indikatorController = TextEditingController();
  final _landasanController = TextEditingController();
  final _latarBelakangController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _jadwalPelaksanaanController = TextEditingController();

  String _selectedStatus = 'Planned';
  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now();
  bool _isSubmitting = false;

  final List<Map<String, String>> _statuses = [
    {'value': 'Planned', 'label': 'Terjadwal (Planned)'},
    {'value': 'berlangsung', 'label': 'Sedang Berlangsung'},
    {'value': 'selesai', 'label': 'Selesai Terlaksana'},
    {'value': 'dibatalkan', 'label': 'Dibatalkan'},
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _pjController.dispose();
    _estimasiDanaController.dispose();
    _sumberDanaController.dispose();
    _bentukKegiatanController.dispose();
    _mitraController.dispose();
    _sasaranController.dispose();
    _indikatorController.dispose();
    _landasanController.dispose();
    _latarBelakangController.dispose();
    _tujuanController.dispose();
    _jadwalPelaksanaanController.dispose();
    super.dispose();
  }

  void _fillPreset() {
    setState(() {
      _judulController.text = 'Samudra Leadership';
      _lokasiController.text = 'Auditorium Utama UBK & Ruang Diskusi Kampus';
      _tanggalMulai = DateTime.now().add(const Duration(days: 7));
      _tanggalSelesai = DateTime.now().add(const Duration(days: 7));
      _selectedStatus = 'Planned';
      _pjController.text = 'Regina Felling Yuan Ananta';
      _estimasiDanaController.text = '10075000';
      _sumberDanaController.text = 'Internal Ormawa (Iuran ormawa) & Pagu Ormawa';
      _bentukKegiatanController.text = 'LKMM Dasar';
      _mitraController.text = 'Seluruh LK dan UKM KEMA UBK (kecuali LK fakultas farmasi)';
      _sasaranController.text = 'Lembaga Kemahasiswaan (LK), Unit Kegiatan Mahasiswa (UKM) dan Mahasiswa UBK';
      _jadwalPelaksanaanController.text = 'Sabtu, 08.00 - 16.00 WIB';
      _indikatorController.text = '1. Seluruh peserta mengikuti minimal 3 dari 4 sesi interaktif.\n2. Tercipta minimal 1 output nyata dari setiap kelompok peserta.\n3. Teridentifikasi minimal 15 mahasiswa berpotensi kaderisasi.';
      _landasanController.text = 'Arahan Kebijakan Kemahasiswaan Universitas Bhakti Kencana';
      _latarBelakangController.text = 'Mahasiswa sebagai calon pemimpin perlu dibekali karakter kepemimpinan, kemampuan manajemen dasar, serta pola pikir kritis dan berdaya saing.';
      _tujuanController.text = 'Mempersiapkan mahasiswa aktif untuk memiliki kemampuan dasar kepemimpinan, komunikasi, dan manajemen.';
      _deskripsiController.text = 'Samudra Leadership adalah program pembinaan kepemimpinan dan manajemen dasar mahasiswa Universitas Bhakti Kencana yang dirancang secara interaktif dan partisipatif.';
    });
    AppSnackbar.showSuccess(context, 'Contoh data (Samudra Leadership) berhasil diisikan!');
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

  void _handleSubmit() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final estimasi = double.tryParse(_estimasiDanaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

      final data = {
        'nama_kegiatan': _judulController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'tanggal_mulai': _tanggalMulai.toIso8601String(),
        'tanggal_selesai': _tanggalSelesai.toIso8601String(),
        'status': _selectedStatus,
        'deskripsi': _deskripsiController.text.trim(),
        'pj_kegiatan': _pjController.text.trim(),
        'estimasi_dana': estimasi,
        'sumber_dana': _sumberDanaController.text.trim(),
        'bentuk_kegiatan': _bentukKegiatanController.text.trim(),
        'mitra': _mitraController.text.trim(),
        'sasaran_kegiatan': _sasaranController.text.trim(),
        'indikator_keberhasilan': _indikatorController.text.trim(),
        'landasan_kegiatan': _landasanController.text.trim(),
        'latar_belakang': _latarBelakangController.text.trim(),
        'tujuan_kegiatan': _tujuanController.text.trim(),
        'jadwal_pelaksanaan': _jadwalPelaksanaanController.text.trim(),
      };

      await context.read<OrmawaProvider>().addAgenda(data);

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Agenda kegiatan berhasil ditambahkan!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Tambah Jadwal',
            subtitle: 'Agenda Kegiatan Ormawa',
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Butuh Contoh Isian Lengkap?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF92400E))),
                              SizedBox(height: 1),
                              Text('Klik tombol untuk mengisi otomatis data sampel.', style: TextStyle(fontSize: 9.5, color: Color(0xFFB45309))),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _fillPreset,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Isi Contoh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Informasi Utama Agenda',
                    icon: Icons.info_outline_rounded,
                    children: [
                      OrmawaTextField(
                        label: 'NAMA KEGIATAN *',
                        controller: _judulController,
                        hintText: 'Contoh: Samudra Leadership',
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'LOKASI PELAKSANAAN',
                        controller: _lokasiController,
                        hintText: 'Contoh: Auditorium Utama UBK',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PERIODE PELAKSANAAN *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: OrmawaTheme.textHeading,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDateRange,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: OrmawaTheme.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 15, color: OrmawaTheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${DateFormat('dd MMM yyyy', 'id').format(_tanggalMulai)} s/d ${DateFormat('dd MMM yyyy', 'id').format(_tanggalSelesai)}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OrmawaTheme.textHeading),
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: OrmawaTheme.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS AGENDA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: OrmawaTheme.textHeading,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: OrmawaTheme.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                isExpanded: true,
                                items: _statuses.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s['value'],
                                    child: Text(s['label']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OrmawaTheme.textHeading)),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedStatus = v ?? 'Planned'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'DESKRIPSI KEGIATAN',
                        controller: _deskripsiController,
                        hintText: 'Tuliskan deskripsi ringkas pelaksanaan kegiatan...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Teknis & Anggaran',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      OrmawaTextField(
                        label: 'PENANGGUNG JAWAB (PJ)',
                        controller: _pjController,
                        hintText: 'Nama lengkap ketua pelaksana / PJ...',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'ESTIMASI DANA (RP)',
                        controller: _estimasiDanaController,
                        hintText: 'Contoh: 5000000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'SUMBER PENDANAAN',
                        controller: _sumberDanaController,
                        hintText: 'Contoh: Pagu Ormawa & Iuran Peserta',
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'BENTUK KEGIATAN',
                        controller: _bentukKegiatanController,
                        hintText: 'Contoh: LKMM Dasar / Workshop / Seminar',
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'MITRA / KOLABORATOR',
                        controller: _mitraController,
                        hintText: 'Contoh: KSR PMI / Lembaga Kemahasiswaan',
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'WAKTU PELAKSANAAN SPESIFIK',
                        controller: _jadwalPelaksanaanController,
                        hintText: 'Contoh: Sabtu, 08.00 - 16.00 WIB',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Landasan & Sasaran Strategis',
                    icon: Icons.track_changes_rounded,
                    children: [
                      OrmawaTextField(
                        label: 'SASARAN KEGIATAN',
                        controller: _sasaranController,
                        hintText: 'Sasaran peserta atau target penerima manfaat...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'INDIKATOR KEBERHASILAN',
                        controller: _indikatorController,
                        hintText: 'Poin tolok ukur kesuksesan agenda...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'LANDASAN KEGIATAN',
                        controller: _landasanController,
                        hintText: 'Dasar hukum / arahan kebijakan kemahasiswaan...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'LATAR BELAKANG',
                        controller: _latarBelakangController,
                        hintText: 'Alasan urgensi diselenggarakannya kegiatan ini...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      OrmawaTextField(
                        label: 'TUJUAN KEGIATAN',
                        controller: _tujuanController,
                        hintText: 'Tujuan yang ingin dicapai melalui kegiatan ini...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  OrmawaButton(
                    text: 'Simpan Jadwal Kegiatan',
                    icon: Icons.save_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
                    width: double.infinity,
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

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return OrmawaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: OrmawaTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: OrmawaTheme.textSectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
