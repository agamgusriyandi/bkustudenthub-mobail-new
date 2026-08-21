import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';

const List<String> kSubAkademikOptions = [
  'Kesulitan mengatur waktu belajar',
  'Kesulitan merencanakan studi',
  'Kesulitan dalam menyusun makalah, laporan, dan tugas akhir',
  'Kesulitan mempelajari referensi pembelajaran',
  'Kurang motivasi atau semangat belajar',
  'Kurangnya minat terhadap profesi',
];

const List<String> kSubNonAkademikOptions = [
  'Kesulitan menyesuaikan diri dengan teman mahasiswa / konflik dengan teman',
  'Kesulitan karena masalah-masalah keluarga',
  'Cemas / Depresi / Stres',
  'Masalah kepercayaan diri',
  'Home sickness (ingat rumah)',
  'Putus asa',
  'Manajemen keuangan',
  'Konflik dengan pasangan (pacar/istri/suami)',
  'Kesepian',
];

const List<String> kStatusPernikahanOpts = [
  'Belum menikah',
  'Menikah',
  'Pernah menikah (Cerai)',
];

const List<String> kPekerjaanOrtuOpts = [
  'Pegawai Swasta',
  'ASN / PNS',
  'Wiraswasta / Pengusaha',
  'TNI / Polri',
  'Buruh / Pekerja Lepas',
  'Tidak Bekerja',
  'Lainnya',
];

const List<String> kTopikOptions = [
  'Psikologi',
  'Akademik',
  'Karir',
  'Personal',
];

class CounselingEditScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const CounselingEditScreen({super.key, required this.booking});

  @override
  State<CounselingEditScreen> createState() => _CounselingEditScreenState();
}

class _CounselingEditScreenState extends State<CounselingEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _mode;
  late String _topik;
  late TextEditingController _keluhanCtrl;
  late TextEditingController _harapanCtrl;

  late String _statusPernikahan;
  late int _anakKe;
  late int _jumlahBersaudara;
  late bool _pernahSakitKeras;
  late TextEditingController _detailSakitKerasCtrl;
  late TextEditingController _namaOrtuCtrl;
  late TextEditingController _noHpOrtuCtrl;
  late String _pekerjaanOrtu;
  late TextEditingController _noHpDosenPaCtrl;

  final Set<String> _selectedAkademik = {};
  final Set<String> _selectedNonAkademik = {};
  late TextEditingController _subLainnyaCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;

    _mode = b['mode']?.toString() ?? 'Tatap Muka';
    _topik = b['topic']?.toString() ?? b['topik']?.toString() ?? 'Psikologi';
    _keluhanCtrl = TextEditingController(text: b['complaint']?.toString() ?? b['keluhan']?.toString() ?? '');
    _harapanCtrl = TextEditingController(text: b['harapan_konseling']?.toString() ?? b['harapanKonseling']?.toString() ?? '');

    _statusPernikahan = b['status_pernikahan']?.toString() ?? 'Belum menikah';
    _anakKe = int.tryParse(b['anak_ke']?.toString() ?? '1') ?? 1;
    _jumlahBersaudara = int.tryParse(b['jumlah_bersaudara']?.toString() ?? '1') ?? 1;
    _pernahSakitKeras = b['pernah_sakit_keras'] == true || b['pernahSakitKeras'] == true;
    _detailSakitKerasCtrl = TextEditingController(text: b['detail_sakit_keras']?.toString() ?? '');
    _namaOrtuCtrl = TextEditingController(text: b['nama_ortu_wali']?.toString() ?? '');
    _noHpOrtuCtrl = TextEditingController(text: b['no_hp_ortu_wali']?.toString() ?? '');
    _pekerjaanOrtu = b['pekerjaan_ortu_wali']?.toString() ?? 'Pegawai Swasta';
    _noHpDosenPaCtrl = TextEditingController(text: b['no_hp_dosen_pa']?.toString() ?? '');

    if (b['sub_kategori_akademik'] is List) {
      _selectedAkademik.addAll((b['sub_kategori_akademik'] as List).map((e) => e.toString()));
    } else if (b['sub_kategori_akademik'] is String && b['sub_kategori_akademik'].toString().isNotEmpty) {
      _selectedAkademik.addAll(b['sub_kategori_akademik'].toString().split(',').map((e) => e.trim()));
    }

    if (b['sub_kategori_non_akademik'] is List) {
      _selectedNonAkademik.addAll((b['sub_kategori_non_akademik'] as List).map((e) => e.toString()));
    } else if (b['sub_kategori_non_akademik'] is String && b['sub_kategori_non_akademik'].toString().isNotEmpty) {
      _selectedNonAkademik.addAll(b['sub_kategori_non_akademik'].toString().split(',').map((e) => e.trim()));
    }

    _subLainnyaCtrl = TextEditingController(text: b['sub_kategori_lainnya']?.toString() ?? '');
  }

  @override
  void dispose() {
    _keluhanCtrl.dispose();
    _harapanCtrl.dispose();
    _detailSakitKerasCtrl.dispose();
    _namaOrtuCtrl.dispose();
    _noHpOrtuCtrl.dispose();
    _noHpDosenPaCtrl.dispose();
    _subLainnyaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_keluhanCtrl.text.trim().length < 10) {
      AppSnackbar.showError(context, 'Keluhan utama harus diisi minimal 10 karakter');
      return;
    }

    final bookingId = widget.booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'mode': _mode,
      'topic': _topik,
      'complaint': _keluhanCtrl.text.trim(),
      'keluhan': _keluhanCtrl.text.trim(),
      'harapan_konseling': _harapanCtrl.text.trim(),
      'status_pernikahan': _statusPernikahan,
      'anak_ke': _anakKe,
      'jumlah_bersaudara': _jumlahBersaudara,
      'nama_ortu_wali': _namaOrtuCtrl.text.trim(),
      'no_hp_ortu_wali': _noHpOrtuCtrl.text.trim(),
      'pekerjaan_ortu_wali': _pekerjaanOrtu,
      'pernah_sakit_keras': _pernahSakitKeras,
      'detail_sakit_keras': _pernahSakitKeras ? _detailSakitKerasCtrl.text.trim() : '',
      'no_hp_dosen_pa': _noHpDosenPaCtrl.text.trim(),
      'sub_kategori_akademik': _selectedAkademik.toList(),
      'sub_kategori_non_akademik': _selectedNonAkademik.toList(),
      'sub_kategori_lainnya': _subLainnyaCtrl.text.trim(),
    };

    final success = await context.read<StudentCounselingProvider>().updateBooking(
          bookingId: bookingId,
          payload: payload,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Data permohonan konseling berhasil diperbarui');
        Navigator.pop(context, true);
      } else {
        AppSnackbar.showError(context, 'Gagal memperbarui permohonan konseling');
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Edit Permohonan Konseling',
        subtitle: 'Perbarui Data & Instrumen SPMI',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Mode & Topik Konseling',
                icon: Icons.chat_bubble_outline_rounded,
                children: [
                  const Text('Metode Konseling', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _modeOptionTile(
                          'Tatap Muka',
                          'Ruang Konseling',
                          Icons.location_on_outlined,
                          _mode == 'Tatap Muka',
                          () => setState(() => _mode = 'Tatap Muka'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _modeOptionTile(
                          'Online',
                          'Google Meet',
                          Icons.videocam_outlined,
                          _mode == 'Online',
                          () => setState(() => _mode = 'Online'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Topik Konseling', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: kTopikOptions.contains(_topik) ? _topik : 'Psikologi',
                    items: kTopikOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (v) => setState(() => _topik = v ?? 'Psikologi'),
                    decoration: _inputDecoration(''),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Keluhan Utama *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _keluhanCtrl,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('Ceritakan situasi atau kendala yang sedang Anda hadapi...'),
                    validator: (v) => (v == null || v.trim().length < 10) ? 'Harap isi minimal 10 karakter' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Harapan terhadap Sesi Konseling', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _harapanCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('Harapan atau tujuan Anda dari konseling ini...'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildSectionCard(
                title: 'Sub-Kategori Masalah SPMI',
                icon: Icons.checklist_rounded,
                children: [
                  const Text('Isu Akademik', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  ...kSubAkademikOptions.map((opt) {
                    final isChecked = _selectedAkademik.contains(opt);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _selectedAkademik.remove(opt);
                          } else {
                            _selectedAkademik.add(opt);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: isChecked ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(opt, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)))),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Isu Non-Akademik / Personal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  ...kSubNonAkademikOptions.map((opt) {
                    final isChecked = _selectedNonAkademik.contains(opt);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _selectedNonAkademik.remove(opt);
                          } else {
                            _selectedNonAkademik.add(opt);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: isChecked ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(opt, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)))),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Sub-Kategori Lainnya', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _subLainnyaCtrl,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('Tuliskan kendala lain jika tidak tertera di atas...'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildSectionCard(
                title: 'Data Demografi & Keluarga (SPMI)',
                icon: Icons.family_restroom_rounded,
                children: [
                  const Text('Status Pernikahan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _statusPernikahan,
                    items: kStatusPernikahanOpts.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (v) => setState(() => _statusPernikahan = v ?? 'Belum menikah'),
                    decoration: _inputDecoration(''),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Anak Ke-', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: _anakKe.toString(),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                              decoration: _inputDecoration('1'),
                              onChanged: (v) => _anakKe = int.tryParse(v) ?? 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dari Bersaudara', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: _jumlahBersaudara.toString(),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                              decoration: _inputDecoration('1'),
                              onChanged: (v) => _jumlahBersaudara = int.tryParse(v) ?? 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Nama Orang Tua / Wali', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaOrtuCtrl,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('Nama lengkap orang tua / wali'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('No. HP Orang Tua / Wali', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noHpOrtuCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('08xxxxxxxxxx'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Pekerjaan Orang Tua / Wali', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: kPekerjaanOrtuOpts.contains(_pekerjaanOrtu) ? _pekerjaanOrtu : 'Pegawai Swasta',
                    items: kPekerjaanOrtuOpts.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (v) => setState(() => _pekerjaanOrtu = v ?? 'Pegawai Swasta'),
                    decoration: _inputDecoration(''),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('No. HP Dosen Pembimbing Akademik (Dosen PA)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noHpDosenPaCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: _inputDecoration('08xxxxxxxxxx'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Checkbox(
                        value: _pernahSakitKeras,
                        activeColor: const Color(0xFF0F172A),
                        onChanged: (v) => setState(() => _pernahSakitKeras = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Pernah Mengalami Sakit Keras / Riwayat Medis Khusus',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  if (_pernahSakitKeras) ...[
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _detailSakitKerasCtrl,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                      decoration: _inputDecoration('Jelaskan jenis penyakit dan tahun kejadian...'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BkuTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Perubahan Pendaftaran',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeOptionTile(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.4,
                ),
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
