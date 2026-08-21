import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:printing/printing.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_edit_screen.dart';

class CounselingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> initialBooking;

  const CounselingDetailScreen({super.key, required this.initialBooking});

  @override
  State<CounselingDetailScreen> createState() => _CounselingDetailScreenState();
}

class _CounselingDetailScreenState extends State<CounselingDetailScreen> {
  late Map<String, dynamic> _booking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
    _fetchLatestDetail();
  }

  Future<void> _fetchLatestDetail() async {
    final bookingId = _booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) return;

    setState(() => _isLoading = true);
    final detail = await context.read<StudentCounselingProvider>().loadBookingDetail(bookingId);
    if (mounted && detail != null) {
      setState(() {
        _booking = detail;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _val(List<String> keys, {String fallback = '-'}) {
    for (final k in keys) {
      final v = _booking[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return fallback;
  }

  List<String> _listVal(List<String> keys) {
    for (final k in keys) {
      final v = _booking[k];
      if (v is List) {
        return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      } else if (v is String && v.isNotEmpty) {
        return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return [];
  }

  Future<void> _downloadPDF(String endpoint, String title) async {
    final bookingId = _booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) return;

    try {
      if (mounted) AppSnackbar.showInfo(context, 'Menyiapkan berkas $title...');
      final cleanPath = endpoint.startsWith('/api') ? endpoint.substring(4) : endpoint;
      final response = await ApiClient().client.get<List<int>>(
        cleanPath,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && response.data!.isNotEmpty) {
        final bytes = Uint8List.fromList(response.data!);
        await Printing.layoutPdf(
          name: '${title.replaceAll(' ', '_')}_#$bookingId.pdf',
          onLayout: (format) async => bytes,
        );
      } else {
        if (mounted) AppSnackbar.showError(context, 'Berkas $title kosong atau tidak dapat diunduh.');
      }
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, 'Gagal mengunduh berkas $title');
    }
  }

  Future<void> _handleCancelBooking() async {
    final bookingId = _booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Jadwal Konseling?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pengajuan sesi konseling ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<StudentCounselingProvider>().cancelBooking(bookingId);
      if (mounted) {
        if (success) {
          AppSnackbar.showSuccess(context, 'Jadwal konseling berhasil dibatalkan');
          Navigator.pop(context, true);
        } else {
          AppSnackbar.showError(context, 'Gagal membatalkan jadwal konseling');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<ProfileProvider>();
    final bookingId = _booking['id']?.toString() ?? '-';
    final statusStr = _val(['status', 'Status'], fallback: 'Menunggu');
    final isEditable = statusStr == 'Menunggu' || statusStr == 'Draft' || statusStr == 'Pending';

    final psikolog = _booking['psychologist'] as Map<String, dynamic>?;
    final namaKonselor = psikolog?['name']?.toString() ?? _val(['nama_konselor', 'NamaKonselor', 'nama'], fallback: 'Psikolog BKU');
    final spesialisasi = psikolog?['specialization']?.toString() ?? _val(['spesialisasi', 'specialization'], fallback: 'Konselor Umum');
    final rawFoto = psikolog?['photo_url']?.toString() ?? _val(['foto_url', 'photo_url', 'avatar_url', 'foto_konselor']);
    final fotoUrl = rawFoto.isNotEmpty ? ApiGate.getImageUrl(rawFoto) : '';

    final dateStr = _val(['display_date', 'tanggal', 'date']);
    final jamMulai = _val(['jam_mulai', 'start', 'JamMulai']);
    final jamSelesai = _val(['jam_selesai', 'end', 'JamSelesai']);
    final timeStr = jamSelesai.isNotEmpty && jamSelesai != '-' ? '$jamMulai - $jamSelesai' : jamMulai;
    final mode = _val(['mode', 'Mode'], fallback: 'Tatap Muka');
    final linkMeeting = _val(['link_meeting', 'linkMeeting', 'link']);
    final queueNumber = _booking['queue_number']?.toString();

    final topik = _val(['topic', 'topik', 'tipe'], fallback: 'Personal');
    final keluhan = _val(['complaint', 'keluhan'], fallback: 'Tidak ada keluhan tertulis.');
    final harapan = _val(['harapan_konseling', 'harapanKonseling'], fallback: '-');

    final statusPernikahan = _val(['status_pernikahan', 'statusPernikahan'], fallback: 'Belum menikah');
    final anakKe = _val(['anak_ke', 'anakKe'], fallback: '1');
    final jumlahBersaudara = _val(['jumlah_bersaudara', 'jumlahBersaudara'], fallback: '1');
    final pernahSakitKeras = _booking['pernah_sakit_keras'] == true || _booking['pernahSakitKeras'] == true;
    final detailSakitKeras = _val(['detail_sakit_keras', 'detailSakitKeras'], fallback: '-');
    final namaOrtu = _val(['nama_ortu_wali', 'namaOrtuWali'], fallback: '-');
    final noHpOrtu = _val(['no_hp_ortu_wali', 'noHPOrtuWali'], fallback: '-');
    final pekerjaanOrtu = _val(['pekerjaan_ortu_wali', 'pekerjaanOrtuWali'], fallback: 'Pegawai Swasta');
    final noHpDosenPa = _val(['no_hp_dosen_pa', 'noHPDosenPA'], fallback: '-');
    final namaDosenPa = _val(['dosen_pa_nama', 'nama_dosen_pa'], fallback: student.dosenPa.isNotEmpty ? student.dosenPa : '-');
    final pernahKonseling = _booking['pernah_konseling_sebelumnya'] == true || _booking['pernahKonselingSebelumnya'] == true;

    final subAkademik = _listVal(['sub_kategori_akademik', 'subKategoriAkademik']);
    final subNonAkademik = _listVal(['sub_kategori_non_akademik', 'subKategoriNonAkademik']);
    final subLainnya = _val(['sub_kategori_lainnya', 'subKategoriLainnya']);
    final catatanEvaluasi = _val(['catatan', 'catatan_admin', 'catatan_konselor', 'catatan_psikolog']);

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);
    Color statusBorder = const Color(0xFFFDE68A);

    switch (statusStr.toLowerCase()) {
      case 'dikonfirmasi':
        statusBg = const Color(0xFFECFDF5);
        statusText = const Color(0xFF059669);
        statusBorder = const Color(0xFFA7F3D0);
        break;
      case 'selesai':
        statusBg = const Color(0xFFEFF6FF);
        statusText = const Color(0xFF2563EB);
        statusBorder = const Color(0xFFBFDBFE);
        break;
      case 'ditolak':
      case 'dibatalkan':
        statusBg = const Color(0xFFFFF1F2);
        statusText = const Color(0xFFE11D48);
        statusBorder = const Color(0xFFFECDD3);
        break;
    }

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: BkuStaticAppBar(
        title: 'Detail Pendaftaran Konseling',
        subtitle: 'No. Registrasi: #BKG-$bookingId',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSPMIBanner(bookingId, statusStr, statusBg, statusText, statusBorder, queueNumber),
                  const SizedBox(height: AppSpacing.lg),

                  _buildCounselorCard(namaKonselor, spesialisasi, fotoUrl, dateStr, timeStr, mode, linkMeeting),
                  const SizedBox(height: AppSpacing.lg),

                  _buildStudentIdentityCard(student, namaDosenPa, noHpDosenPa),
                  const SizedBox(height: AppSpacing.lg),

                  _buildProblemDetailCard(topik, keluhan, harapan, subAkademik, subNonAkademik, subLainnya),
                  const SizedBox(height: AppSpacing.lg),

                  _buildDemographicSPMICard(
                    statusPernikahan: statusPernikahan,
                    anakKe: anakKe,
                    jumlahBersaudara: jumlahBersaudara,
                    namaOrtu: namaOrtu,
                    noHpOrtu: noHpOrtu,
                    pekerjaanOrtu: pekerjaanOrtu,
                    pernahSakitKeras: pernahSakitKeras,
                    detailSakitKeras: detailSakitKeras,
                    pernahKonseling: pernahKonseling,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (catatanEvaluasi.isNotEmpty && catatanEvaluasi != '-') ...[
                    _buildEvaluationCard(catatanEvaluasi),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildActionButtons(isEditable, bookingId),
                  const SizedBox(height: AppSpacing.s48),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSPMIBanner(
    String bookingId,
    String statusStr,
    Color statusBg,
    Color statusText,
    Color statusBorder,
    String? queueNumber,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'No. #BKG-$bookingId',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ),
                  if (queueNumber != null && queueNumber.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Antrean #$queueNumber',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF2563EB)),
              SizedBox(width: 5),
              Text(
                'STANDAR SPMI: 02.01.00/FRM-4/KKA-SPMI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8), letterSpacing: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Pusat Bimbingan, Konseling & Karir Universitas Bhakti Kencana',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorCard(
    String name,
    String spec,
    String photoUrl,
    String dateStr,
    String timeStr,
    String mode,
    String linkMeeting,
  ) {
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
                child: const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'KONSELOR PENDAMPING & JADWAL',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF475569), size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Waktu Sesi', '$dateStr • $timeStr'),
                const SizedBox(height: 8),
                _buildInfoRow('Metode Konseling', mode),
                if (linkMeeting.isNotEmpty && linkMeeting != '-') ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Tautan Virtual / Ruang', linkMeeting),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentIdentityCard(ProfileProvider student, String namaDosenPa, String noHpDosenPa) {
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
                child: const Icon(Icons.school_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'IDENTITAS MAHASISWA & DOSEN PA',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Nama Lengkap', student.name.isNotEmpty ? student.name : 'Mahasiswa BKU'),
                const SizedBox(height: 8),
                _buildInfoRow('NIM / Prodi', '${student.nim.isNotEmpty ? student.nim : "-"} • ${student.prodi}'),
                const SizedBox(height: 8),
                _buildInfoRow('Dosen Pembimbing Akademik', namaDosenPa),
                if (noHpDosenPa.isNotEmpty && noHpDosenPa != '-') ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Kontak Dosen PA', noHpDosenPa),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemDetailCard(
    String topik,
    String keluhan,
    String harapan,
    List<String> subAkademik,
    List<String> subNonAkademik,
    String subLainnya,
  ) {
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
                child: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'URAIAN MASALAH & HARAPAN',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Topik Konseling', topik),
                const SizedBox(height: 10),
                const Text('Keluhan Utama Mahasiswa:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(keluhan, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.4, fontWeight: FontWeight.w600)),
                if (harapan.isNotEmpty && harapan != '-') ...[
                  const SizedBox(height: 10),
                  const Text('Harapan Pasca Konseling:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(harapan, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.4, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          if (subAkademik.isNotEmpty || subNonAkademik.isNotEmpty || (subLainnya.isNotEmpty && subLainnya != '-')) ...[
            const SizedBox(height: 12),
            const Text(
              'SUB-KATEGORI ISU YANG DIHADAPI (SPMI)',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.3),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...subAkademik.map((item) => _buildIssueChip(item, const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE))),
                ...subNonAkademik.map((item) => _buildIssueChip(item, const Color(0xFFFEF3C7), const Color(0xFFD97706), const Color(0xFFFDE68A))),
                if (subLainnya.isNotEmpty && subLainnya != '-')
                  _buildIssueChip(subLainnya, const Color(0xFFF1F5F9), const Color(0xFF475569), const Color(0xFFE2E8F0)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIssueChip(String text, Color bg, Color textColor, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  Widget _buildDemographicSPMICard({
    required String statusPernikahan,
    required String anakKe,
    required String jumlahBersaudara,
    required String namaOrtu,
    required String noHpOrtu,
    required String pekerjaanOrtu,
    required bool pernahSakitKeras,
    required String detailSakitKeras,
    required bool pernahKonseling,
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
                child: const Icon(Icons.family_restroom_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'DATA DEMOGRAFI & KELUARGA (SPMI)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Status Pernikahan', statusPernikahan),
                const SizedBox(height: 8),
                _buildInfoRow('Urutan Kelahiran', 'Anak ke-$anakKe dari $jumlahBersaudara bersaudara'),
                const SizedBox(height: 8),
                _buildInfoRow('Orang Tua / Wali', '$namaOrtu ($pekerjaanOrtu)'),
                if (noHpOrtu.isNotEmpty && noHpOrtu != '-') ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Kontak Ortu / Wali', noHpOrtu),
                ],
                const SizedBox(height: 8),
                _buildInfoRow('Riwayat Sakit Keras', pernahSakitKeras ? 'Pernah ($detailSakitKeras)' : 'Tidak Ada'),
                const SizedBox(height: 8),
                _buildInfoRow('Pernah Konseling Masa Lalu', pernahKonseling ? 'Ya' : 'Belum Pernah'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(String evaluation) {
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
                child: const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'CATATAN EVALUASI KONSELOR',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              evaluation,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.45, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isEditable, String bookingId) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => _downloadPDF(
              '/counseling/psychologist-bookings/$bookingId/export-registration-pdf',
              'Formulir Pendaftaran',
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Cetak Formulir Pendaftaran (PDF)',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: BkuTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (isEditable) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CounselingEditScreen(booking: _booking),
                        ),
                      );
                      if (updated == true) _fetchLatestDetail();
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF0F172A)),
                    label: const Text(
                      'Edit Data Sesi',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _handleCancelBooking,
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFE11D48)),
                    label: const Text(
                      'Batalkan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFE11D48)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                      backgroundColor: const Color(0xFFFFF1F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
