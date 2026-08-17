import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
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
      final double? parsedDana = double.tryParse(_estimasiDanaController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));

      final payload = {
        'Judul': _judulController.text.trim(),
        'Lokasi': _lokasiController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'Status': _selectedStatus,
        'TanggalMulai': _tanggalMulai.toIso8601String(),
        'TanggalSelesai': _tanggalSelesai.toIso8601String(),
        'landasan_kegiatan': _landasanController.text.trim(),
        'bentuk_kegiatan': _bentukKegiatanController.text.trim(),
        'mitra': _mitraController.text.trim(),
        'latar_belakang': _latarBelakangController.text.trim(),
        'tujuan_kegiatan': _tujuanController.text.trim(),
        'jadwal_pelaksanaan': _jadwalPelaksanaanController.text.trim(),
        'sasaran_kegiatan': _sasaranController.text.trim(),
        'indikator_keberhasilan': _indikatorController.text.trim(),
        'sumber_dana': _sumberDanaController.text.trim(),
        'estimasi_dana': parsedDana ?? 0.0,
        'pj_kegiatan': _pjController.text.trim(),
      };

      await context.read<OrmawaProvider>().addAgenda(payload);
      if (mounted) {
        BkuDialog.show(
          context: context,
          title: 'Kegiatan Dijadwalkan!',
          message: 'Jadwal kegiatan baru berhasil disimpan ke dalam kalender ormawa.',
          type: BkuDialogType.success,
          primaryButtonText: 'Selesai',
          onPrimaryPressed: () {
            context.pop();
            context.pop();
          },
        );
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal menyimpan kegiatan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Buat Jadwal Kegiatan',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withAlpha(150),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFD97706), size: 22),
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
                      _buildTextField(
                        label: 'NAMA KEGIATAN',
                        controller: _judulController,
                        hint: 'Contoh: Samudra Leadership',
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'LOKASI PELAKSANAAN',
                        controller: _lokasiController,
                        hint: 'Contoh: Auditorium Utama UBK',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PERIODE PELAKSANAAN *', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _pickDateRange,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${DateFormat('dd MMM yyyy', 'id').format(_tanggalMulai)} s/d ${DateFormat('dd MMM yyyy', 'id').format(_tanggalSelesai)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATUS AGENDA', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                isExpanded: true,
                                items: _statuses.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s['value'],
                                    child: Text(s['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedStatus = v ?? 'Planned'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'DESKRIPSI KEGIATAN',
                        controller: _deskripsiController,
                        hint: 'Tuliskan deskripsi ringkas pelaksanaan kegiatan...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Teknis & Anggaran',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      _buildTextField(
                        label: 'PENANGGUNG JAWAB (PJ)',
                        controller: _pjController,
                        hint: 'Nama lengkap ketua pelaksana / PJ...',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'ESTIMASI DANA (RP)',
                        controller: _estimasiDanaController,
                        hint: 'Contoh: 5000000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'SUMBER PENDANAAN',
                        controller: _sumberDanaController,
                        hint: 'Contoh: Pagu Ormawa & Iuran Peserta',
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'BENTUK KEGIATAN',
                        controller: _bentukKegiatanController,
                        hint: 'Contoh: LKMM Dasar / Workshop / Seminar',
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'MITRA / KOLABORATOR',
                        controller: _mitraController,
                        hint: 'Contoh: KSR PMI / Lembaga Kemahasiswaan',
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'WAKTU PELAKSANAAN SPESIFIK',
                        controller: _jadwalPelaksanaanController,
                        hint: 'Contoh: Sabtu, 08.00 - 16.00 WIB',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Landasan & Sasaran Strategis',
                    icon: Icons.track_changes_rounded,
                    children: [
                      _buildTextField(
                        label: 'SASARAN KEGIATAN',
                        controller: _sasaranController,
                        hint: 'Sasaran peserta atau target penerima manfaat...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'INDIKATOR KEBERHASILAN',
                        controller: _indikatorController,
                        hint: 'Poin tolok ukur kesuksesan agenda...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'LANDASAN KEGIATAN',
                        controller: _landasanController,
                        hint: 'Dasar hukum / arahan kebijakan kemahasiswaan...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'LATAR BELAKANG',
                        controller: _latarBelakangController,
                        hint: 'Alasan urgensi diselenggarakannya kegiatan ini...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'TUJUAN KEGIATAN',
                        controller: _tujuanController,
                        hint: 'Tujuan yang ingin dicapai melalui kegiatan ini...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Simpan Jadwal Kegiatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 12, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
            ],
            Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
            if (isRequired)
              const Text(' *', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFE11D48))),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
