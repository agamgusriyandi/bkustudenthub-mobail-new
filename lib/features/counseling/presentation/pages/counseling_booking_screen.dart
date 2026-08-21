import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

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

class CounselingBookingScreen extends StatefulWidget {
  final String? psikologId;
  final String? rescheduleBookingId;
  final String? initialCategory;
  final String? initialComplaint;

  const CounselingBookingScreen({
    super.key,
    this.psikologId,
    this.rescheduleBookingId,
    this.initialCategory,
    this.initialComplaint,
  });

  @override
  State<CounselingBookingScreen> createState() => _CounselingBookingScreenState();
}

class _CounselingBookingScreenState extends State<CounselingBookingScreen> {
  Map<String, dynamic>? _selectedSlot;
  final _complaintCtrl = TextEditingController();
  final _harapanCtrl = TextEditingController();
  String _selectedMode = 'Tatap Muka';
  String _selectedTopik = 'Psikologi';

  String _statusPernikahan = 'Belum menikah';
  int _anakKe = 1;
  int _jumlahBersaudara = 1;
  bool _pernahSakitKeras = false;
  final _detailSakitKerasCtrl = TextEditingController();
  final _namaOrtuCtrl = TextEditingController();
  final _noHpOrtuCtrl = TextEditingController();
  String _pekerjaanOrtu = 'Pegawai Swasta';
  final _noHpDosenPaCtrl = TextEditingController();
  bool _pernahKonseling = false;

  final Set<String> _selectedAkademik = {};
  final Set<String> _selectedNonAkademik = {};
  final _subLainnyaCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && kTopikOptions.contains(widget.initialCategory)) {
      _selectedTopik = widget.initialCategory!;
    }
    if (widget.initialComplaint != null && widget.initialComplaint!.isNotEmpty) {
      _complaintCtrl.text = widget.initialComplaint!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<StudentCounselingProvider>();
      if (widget.psikologId != null && widget.psikologId!.isNotEmpty) {
        p.loadPsychologistSchedules(widget.psikologId!);
      } else {
        p.loadAvailableSchedules();
      }

      final student = context.read<ProfileProvider>();
      if (_noHpDosenPaCtrl.text.isEmpty && student.dosenPa.isNotEmpty) {
        // Pre-fill if available
      }
    });
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _harapanCtrl.dispose();
    _detailSakitKerasCtrl.dispose();
    _namaOrtuCtrl.dispose();
    _noHpOrtuCtrl.dispose();
    _noHpDosenPaCtrl.dispose();
    _subLainnyaCtrl.dispose();
    super.dispose();
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
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        final slots = widget.psikologId != null
            ? provider.psychologistSlots
            : provider.availableSchedules;
        final psikologDetail = widget.psikologId != null
            ? provider.psychologistDetail
            : <String, dynamic>{};

        return Scaffold(
          backgroundColor: BkuTheme.scaffoldBg,
          appBar: BkuStaticAppBar(
            title: widget.rescheduleBookingId != null ? 'Reschedule Konseling' : 'Pendaftaran Konseling Baru',
            subtitle: 'Standar SPMI: 02.01.00/FRM-4/KKA-SPMI',
            variant: AppBarVariant.student,
            showBackButton: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.psikologId != null && widget.psikologId!.isNotEmpty) {
                await provider.loadPsychologistSchedules(widget.psikologId!);
              } else {
                await provider.loadAvailableSchedules();
              }
            },
            color: BkuTheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.rescheduleBookingId != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Anda sedang melakukan penjadwalan ulang (Reschedule) untuk sesi konseling.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  if (psikologDetail.isNotEmpty) ...[
                    _buildPsychologistBrief(psikologDetail),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildSectionCard(
                    title: '1. Pilih Slot Jadwal Konseling',
                    icon: Icons.calendar_month_rounded,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pilih waktu yang sesuai. Slot abu-abu berarti kuota telah penuh.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSlotList(slots),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionCard(
                    title: '2. Mode & Topik Konseling',
                    icon: Icons.chat_bubble_outline_rounded,
                    children: [
                      const Text('Metode Pertemuan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _modeOptionTile(
                              'Tatap Muka',
                              'Ruang Konseling',
                              Icons.location_on_outlined,
                              _selectedMode == 'Tatap Muka',
                              () => setState(() => _selectedMode = 'Tatap Muka'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _modeOptionTile(
                              'Online',
                              'Google Meet',
                              Icons.videocam_outlined,
                              _selectedMode == 'Online' || _selectedMode == 'Daring',
                              () => setState(() => _selectedMode = 'Online'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Topik Utama Konseling', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTopik,
                        items: kTopikOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12.5)))).toList(),
                        onChanged: (v) => setState(() => _selectedTopik = v ?? 'Psikologi'),
                        decoration: _inputDecoration(''),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionCard(
                    title: '3. Uraian Keluhan & Harapan',
                    icon: Icons.edit_note_rounded,
                    children: [
                      const Text('Ceritakan Keluhan Utama Anda * (Min. 10 Karakter)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _complaintCtrl,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        decoration: _inputDecoration('Ceritakan situasi, masalah, atau beban pikiran yang Anda rasakan...'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Harapan Setelah Mengikuti Konseling', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _harapanCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        decoration: _inputDecoration('Tuliskan harapan atau target yang ingin Anda capai...'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionCard(
                    title: '4. Sub-Kategori Masalah (SPMI)',
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
                    title: '5. Data Demografi & Keluarga (SPMI)',
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
                        initialValue: _pekerjaanOrtu,
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
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Checkbox(
                            value: _pernahKonseling,
                            activeColor: const Color(0xFF0F172A),
                            onChanged: (v) => setState(() => _pernahKonseling = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Pernah Mengikuti Sesi Konseling Sebelumnya',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null || _isSubmitting ? null : () => _submit(provider),
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
                          : Text(
                              widget.rescheduleBookingId != null ? 'Konfirmasi Reschedule' : 'Lanjutkan Pendaftaran',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPsychologistBrief(Map<String, dynamic> p) {
    final name = p['name']?.toString() ?? '-';
    final spec = p['specialization']?.toString() ?? '-';
    final rawPhoto = p['photo_url']?.toString() ?? p['foto_url']?.toString() ?? '';
    final photoUrl = rawPhoto.isNotEmpty ? ApiGate.getImageUrl(rawPhoto) : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF475569), size: 28),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  spec,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotList(List<Map<String, dynamic>> slots) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Belum ada jadwal slot yang tersedia untuk psikolog ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Column(
      children: slots.map((slot) {
        final isSelected = _selectedSlot?['id'] == slot['id'];
        final hari = slot['hari']?.toString() ?? slot['day']?.toString() ?? '-';
        final start = slot['jam_mulai']?.toString() ?? slot['start']?.toString() ?? '-';
        final end = slot['jam_selesai']?.toString() ?? slot['end']?.toString() ?? '-';
        final sisaKuotaRaw = slot['sisa_kuota'] ?? slot['quota'];
        final sisaKuota = sisaKuotaRaw != null ? (sisaKuotaRaw as num).toInt() : 1;
        final displayDate = slot['display_date']?.toString() ?? slot['date']?.toString() ?? '';
        final isFull = sisaKuota <= 0;
        final alreadyBooked = slot['already_booked'] == true;
        final isDisabled = isFull || alreadyBooked;

        final psikolog = slot['psychologist'] as Map<String, dynamic>?;
        final psikologName = psikolog?['name']?.toString() ?? '';

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () => setState(() => _selectedSlot = isSelected ? null : slot),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEFF6FF)
                  : (isDisabled ? const Color(0xFFF8FAFC) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : (isDisabled ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  alreadyBooked
                      ? Icons.check_circle_outline_rounded
                      : (isFull ? Icons.block_rounded : Icons.schedule_rounded),
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$hari, $start - $end',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        ),
                      ),
                      if (displayDate.isNotEmpty || psikologName.isNotEmpty)
                        Text(
                          [
                            if (displayDate.isNotEmpty) displayDate,
                            if (psikologName.isNotEmpty) psikologName,
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDisabled ? const Color(0xFFE2E8F0) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alreadyBooked ? 'Terdaftar' : (isFull ? 'Penuh' : 'Sisa $sisaKuota'),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: isDisabled ? const Color(0xFF64748B) : const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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

  Future<void> _submit(StudentCounselingProvider provider) async {
    if (_selectedSlot == null) return;
    if (_complaintCtrl.text.trim().length < 10) {
      AppSnackbar.showError(context, 'Keluhan utama wajib diisi minimal 10 karakter');
      return;
    }

    setState(() => _isSubmitting = true);

    final slot = _selectedSlot!;

    dynamic rawPsikologId = slot['psikolog_id'] ??
        slot['psychologist_id'] ??
        slot['dosen_id'] ??
        slot['DosenID'] ??
        slot['PsikologID'] ??
        slot['psychologistId'];

    if ((rawPsikologId == null || rawPsikologId == 0 || rawPsikologId == '0') && slot['psychologist'] is Map) {
      final psych = slot['psychologist'] as Map<String, dynamic>;
      rawPsikologId = psych['id'] ?? psych['ID'] ?? psych['dosen_id'];
    }

    if (rawPsikologId == null || rawPsikologId == 0 || rawPsikologId == '0') {
      rawPsikologId = widget.psikologId ?? provider.psychologistDetail['id'] ?? provider.psychologistDetail['ID'];
    }

    final int psikologId = int.tryParse(rawPsikologId?.toString() ?? '') ?? 0;
    final int slotId = int.tryParse((slot['id'] ?? slot['ID'] ?? slot['slot_id'] ?? slot['SlotID'])?.toString() ?? '') ?? 0;

    final date = slot['tanggal']?.toString() ?? slot['next_date']?.toString() ?? slot['date']?.toString() ?? '';
    final start = slot['jam_mulai']?.toString() ?? slot['start']?.toString() ?? '';
    final end = slot['jam_selesai']?.toString() ?? slot['end']?.toString() ?? '';

    final isReschedule = widget.rescheduleBookingId != null;

    if (!isReschedule) {
      final agreed = await _showInformedConsent();
      if (!agreed) {
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final spmiPayload = {
      'harapan_konseling': _harapanCtrl.text.trim(),
      'status_pernikahan': _statusPernikahan,
      'anak_ke': _anakKe,
      'jumlah_bersaudara': _jumlahBersaudara,
      'nama_ortu_wali': _namaOrtuCtrl.text.trim(),
      'no_hp_ortu_wali': _noHpOrtuCtrl.text.trim(),
      'pekerjaan_ortu_wali': _pekerjaanOrtu,
      'no_hp_dosen_pa': _noHpDosenPaCtrl.text.trim(),
      'pernah_sakit_keras': _pernahSakitKeras,
      'detail_sakit_keras': _pernahSakitKeras ? _detailSakitKerasCtrl.text.trim() : '',
      'pernah_konseling_sebelumnya': _pernahKonseling,
      'sub_kategori_akademik': _selectedAkademik.toList(),
      'sub_kategori_non_akademik': _selectedNonAkademik.toList(),
      'sub_kategori_lainnya': _subLainnyaCtrl.text.trim(),
    };

    bool success = false;

    if (isReschedule) {
      success = await provider.rescheduleBooking(
        bookingId: widget.rescheduleBookingId!,
        date: date,
        start: start,
        end: end,
      );
    } else {
      success = await provider.createBooking(
        psikologId: psikologId,
        slotId: slotId,
        date: date,
        start: start,
        end: end,
        topic: _selectedTopik,
        complaint: _complaintCtrl.text.trim(),
        mode: _selectedMode,
        spmi: spmiPayload,
      );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppSnackbar.showSuccess(
          context,
          isReschedule ? 'Jadwal konseling berhasil diperbarui' : 'Pendaftaran konseling SPMI berhasil diajukan',
        );
        Navigator.pop(context, true);
      } else {
        AppSnackbar.showError(
          context,
          provider.bookingError ?? (isReschedule ? 'Gagal mereschedule booking' : 'Gagal mengajukan konseling'),
        );
      }
    }
  }

  Future<bool> _showInformedConsent() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InformedConsentSheet(
        onAgree: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }
}

class _InformedConsentSheet extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onCancel;

  const _InformedConsentSheet({
    required this.onAgree,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Color(0xFF0F172A),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Informed Consent Digital',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Harap baca dan setujui lembar persetujuan layanan konseling di bawah ini sebelum melanjutkan pendaftaran.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildClauseItem(
                  '1. Kerahasiaan Informasi',
                  'Semua informasi yang Anda bagikan selama sesi konseling bersifat rahasia dan dilindungi, kecuali jika terdapat indikasi yang membahayakan diri sendiri atau orang lain.',
                ),
                const SizedBox(height: 10),
                _buildClauseItem(
                  '2. Keterbukaan & Kerjasama',
                  'Proses konseling berjalan efektif apabila Anda bersedia menyampaikan keluhan dengan jujur dan bekerja sama secara aktif dengan konselor/psikolog.',
                ),
                const SizedBox(height: 10),
                _buildClauseItem(
                  '3. Penjadwalan & Kehadiran',
                  'Anda diharapkan hadir tepat waktu sesuai jadwal slot yang dipilih. Jika ingin melakukan pembatalan atau penjadwalan ulang, harap lakukan sebelum sesi dimulai.',
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              top: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: const Color(0xFF334155),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BkuTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Saya Setuju',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClauseItem(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
