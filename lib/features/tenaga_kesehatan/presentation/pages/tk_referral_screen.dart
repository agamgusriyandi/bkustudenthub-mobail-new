import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';

class TkReferralScreen extends StatefulWidget {
  const TkReferralScreen({super.key});

  @override
  State<TkReferralScreen> createState() => _TkReferralScreenState();
}

class _TkReferralScreenState extends State<TkReferralScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _referrals = [];
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<TkPatientProvider>();
      if (provider.patients.isEmpty) {
        await provider.loadPatients();
      }
      final data = await provider.repository.getReferrals();
      setState(() {
        _referrals = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, String> _extractStudentData(Map<String, dynamic> ref) {
    final provider = context.read<TkPatientProvider>();

    // 1. Try matching with patients list via IDs
    final rawId = ref['mahasiswa_id'] ??
        ref['MahasiswaID'] ??
        ref['pasien_id'] ??
        ref['student_id'] ??
        ref['user_id'] ??
        ref['mahasiswa']?['id'] ??
        ref['pasien']?['id'];

    Patient? matchedPatient;
    if (rawId != null) {
      final targetIdStr = rawId.toString();
      for (final p in provider.patients) {
        if (p.id.toString() == targetIdStr) {
          matchedPatient = p;
          break;
        }
      }
    }

    // 2. Also try matching by NIM if ID didn't match
    final rawNim = ref['mahasiswa_nim'] ??
        ref['nim'] ??
        ref['NIM'] ??
        ref['Nim'] ??
        ref['mahasiswa']?['nim'] ??
        ref['pasien']?['nim'] ??
        ref['user']?['nim'];

    if (matchedPatient == null && rawNim != null && rawNim.toString().isNotEmpty) {
      final targetNim = rawNim.toString().trim();
      for (final p in provider.patients) {
        if (p.nim.trim() == targetNim) {
          matchedPatient = p;
          break;
        }
      }
    }

    // Extract Nama
    String nama = matchedPatient?.nama ?? '';
    if (nama.isEmpty) {
      final nameKeys = [
        ref['mahasiswa_nama'],
        ref['nama_mahasiswa'],
        ref['mahasiswa_name'],
        ref['NamaMahasiswa'],
        ref['nama_pasien'],
        ref['nama'],
        ref['name'],
        ref['mahasiswa']?['nama'],
        ref['mahasiswa']?['name'],
        ref['pasien']?['nama'],
        ref['user']?['nama'],
        ref['pengguna']?['nama'],
      ];
      for (final k in nameKeys) {
        if (k != null &&
            k.toString().trim().isNotEmpty &&
            k.toString().toLowerCase() != 'null') {
          nama = k.toString().trim();
          break;
        }
      }
    }
    if (nama.isEmpty) nama = 'Mahasiswa';

    // Extract NIM
    String nim = matchedPatient?.nim ?? '';
    if (nim.isEmpty) {
      final nimKeys = [
        rawNim,
        ref['mahasiswa']?['nim'],
        ref['pasien']?['nim'],
        ref['user']?['nim'],
      ];
      for (final k in nimKeys) {
        if (k != null &&
            k.toString().trim().isNotEmpty &&
            k.toString().toLowerCase() != 'null') {
          nim = k.toString().trim();
          break;
        }
      }
    }
    if (nim.isEmpty) nim = '-';

    // Extract Prodi
    String prodi = matchedPatient?.prodi ?? '';
    if (prodi.isEmpty) {
      final prodiKeys = [
        ref['prodi'],
        ref['Prodi'],
        ref['mahasiswa_prodi'],
        ref['mahasiswa']?['prodi'],
        ref['pasien']?['prodi'],
        ref['user']?['prodi'],
      ];
      for (final k in prodiKeys) {
        if (k != null &&
            k.toString().trim().isNotEmpty &&
            k.toString().toLowerCase() != 'null') {
          prodi = k.toString().trim();
          break;
        }
      }
    }
    if (prodi.isEmpty) prodi = '-';

    // Extract Fakultas
    String fakultas = matchedPatient?.fakultas ?? '';
    if (fakultas.isEmpty) {
      final fakultasKeys = [
        ref['fakultas'],
        ref['Fakultas'],
        ref['mahasiswa_fakultas'],
        ref['mahasiswa']?['fakultas'],
        ref['pasien']?['fakultas'],
        ref['user']?['fakultas'],
      ];
      for (final k in fakultasKeys) {
        if (k != null &&
            k.toString().trim().isNotEmpty &&
            k.toString().toLowerCase() != 'null') {
          fakultas = k.toString().trim();
          break;
        }
      }
    }
    if (fakultas.isEmpty) fakultas = '-';

    // Extract Foto / Avatar
    String foto = matchedPatient?.fotoURL ?? '';
    if (foto.isEmpty) {
      final fotoKeys = [
        ref['foto'],
        ref['foto_url'],
        ref['FotoURL'],
        ref['Foto'],
        ref['foto_profil'],
        ref['avatar_url'],
        ref['mahasiswa_avatar'],
        ref['mahasiswa']?['foto'],
        ref['mahasiswa']?['foto_url'],
        ref['mahasiswa']?['Foto'],
        ref['pasien']?['foto'],
        ref['user']?['foto'],
        ref['pengguna']?['foto'],
        ref['mahasiswa']?['pengguna']?['foto'],
        ref['mahasiswa']?['user']?['foto'],
      ];
      for (final k in fotoKeys) {
        if (k != null &&
            k.toString().trim().isNotEmpty &&
            k.toString().toLowerCase() != 'null') {
          foto = k.toString().trim();
          break;
        }
      }
    }

    return {
      'nama': nama,
      'nim': nim,
      'prodi': prodi,
      'fakultas': fakultas,
      'foto': foto,
    };
  }

  List<Map<String, dynamic>> get _filteredReferrals {
    if (_searchQuery.trim().isEmpty) return _referrals;
    final q = _searchQuery.toLowerCase().trim();
    return _referrals.where((r) {
      final student = _extractStudentData(r);
      final nama = student['nama']!.toLowerCase();
      final nim = student['nim']!.toLowerCase();
      final prodi = student['prodi']!.toLowerCase();
      final fakultas = student['fakultas']!.toLowerCase();
      final faskes = (r['faskes_tujuan'] ?? r['faskes'] ?? '')
          .toString()
          .toLowerCase();
      final diagnosis = (r['diagnosis_sementara'] ?? r['diagnosis'] ?? '')
          .toString()
          .toLowerCase();
      final alasan = (r['alasan_rujukan'] ?? r['alasan'] ?? '')
          .toString()
          .toLowerCase();
      return nama.contains(q) ||
          nim.contains(q) ||
          prodi.contains(q) ||
          fakultas.contains(q) ||
          faskes.contains(q) ||
          diagnosis.contains(q) ||
          alasan.contains(q);
    }).toList();
  }

  void _showReferralDetail(Map<String, dynamic> ref) {
    final student = _extractStudentData(ref);
    final nama = student['nama']!;
    final nim = student['nim']!;
    final prodi = student['prodi']!;
    final fakultas = student['fakultas']!;
    final foto = student['foto']!;
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'M';
    final faskes = ref['faskes_tujuan'] ?? ref['faskes'] ?? 'Faskes Tujuan';
    final diagnosis = ref['diagnosis_sementara'] ?? ref['diagnosis'] ?? '-';
    final tanggal = ref['created_at']?.toString().split('T').first ?? '-';
    final pdfUrl = ref['pdf_url'] ?? ref['document_url'];
    final alasan = ref['alasan_rujukan'] ?? '-';
    final keluhan = ref['keluhan_utama'] ?? '-';
    final asuransi = ref['rekomendasi_asuransi'] ?? '-';

    final bool hasFoto =
        foto.trim().isNotEmpty && foto.trim().toLowerCase() != 'null';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Text(
                      'Detail Surat Rujukan',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Student Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                              image: hasFoto
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        ApiGate.getImageUrl(foto),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !hasFoto
                                ? Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIM: $nim',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                                ),
                                Text(
                                  'Prodi: $prodi',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                                ),
                                Text(
                                  'Fakultas: $fakultas',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem(
                      Icons.local_hospital_rounded,
                      'Faskes Tujuan',
                      faskes,
                      const Color(0xFF2563EB),
                    ),
                    _buildDetailItem(
                      Icons.calendar_today_rounded,
                      'Tanggal Rujukan',
                      tanggal,
                      const Color(0xFFD97706),
                    ),
                    _buildDetailItem(
                      Icons.coronavirus_rounded,
                      'Diagnosis Sementara',
                      diagnosis,
                      const Color(0xFFDC2626),
                    ),
                    _buildDetailItem(
                      Icons.medical_services_rounded,
                      'Keluhan Utama',
                      keluhan,
                      const Color(0xFF9333EA),
                    ),
                    _buildDetailItem(
                      Icons.description_rounded,
                      'Alasan Rujukan',
                      alasan,
                      const Color(0xFF0D9488),
                    ),
                    _buildDetailItem(
                      Icons.shield_rounded,
                      'Rekomendasi Asuransi',
                      asuransi,
                      const Color(0xFF059669),
                    ),
                    if (pdfUrl != null && pdfUrl.toString().isNotEmpty) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(
                              ApiGate.getImageUrl(pdfUrl.toString()),
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                              if (context.mounted) {
                                AppSnackbar.showSuccess(
                                  context,
                                  'Berhasil mengunduh Surat Rujukan PDF',
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Download Surat Rujukan PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPagination(int totalPages) {
    final bool canPrev = _currentPage > 1;
    final bool canNext = _currentPage < totalPages;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: canPrev ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: canPrev ? () => setState(() => _currentPage--) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sebelumnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          Material(
            color: canNext ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: canNext ? () => setState(() => _currentPage++) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReferrals;
    final totalPages = (filtered.length / _itemsPerPage).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;
    final safePage = _currentPage.clamp(1, safeTotalPages);
    if (safePage != _currentPage) {
      _currentPage = safePage;
    }

    final startIndex = (safePage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    final paginatedList =
        filtered.isEmpty ? <Map<String, dynamic>>[] : filtered.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Surat Rujukan Medis',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReferrals,
        child: Column(
          children: [
            // Header Search
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 1;
                }),
                decoration: InputDecoration(
                  hintText: 'Cari nama mahasiswa, NIM, Faskes, atau Diagnosis...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.neutral500,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.neutral500),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _currentPage = 1;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            if (!_isLoading && filtered.isNotEmpty) _buildTopPagination(safeTotalPages),
            Expanded(
              child: _isLoading
                  ? const BkuShimmerList()
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Surat Rujukan',
                            style: AppTextStyles.titleSm.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                      ),
                      itemCount: paginatedList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ref = paginatedList[index];
                        final student = _extractStudentData(ref);
                        final nama = student['nama']!;
                        final nim = student['nim']!;
                        final foto = student['foto']!;
                        final faskes = ref['faskes_tujuan'] ??
                            ref['faskes'] ??
                            'Faskes Tujuan';
                        final diagnosis = ref['diagnosis_sementara'] ??
                            ref['diagnosis'] ??
                            '-';
                        final tanggal =
                            ref['created_at']?.toString().split('T').first ??
                            '-';
                        final initial =
                            nama.isNotEmpty ? nama[0].toUpperCase() : 'M';

                        final bool hasFoto = foto.trim().isNotEmpty &&
                            foto.trim().toLowerCase() != 'null';

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showReferralDetail(ref),
                            borderRadius: AppRadius.radiusLg,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.radiusLg,
                                border: Border.all(color: AppColors.neutral200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(
                                            20,
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary.withAlpha(
                                              50,
                                            ),
                                            width: 1.5,
                                          ),
                                          image: hasFoto
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    ApiGate.getImageUrl(foto),
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: !hasFoto
                                            ? Center(
                                                child: Text(
                                                  initial,
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nama,
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.neutral900,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'NIM: $nim',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: AppColors.neutral600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 12,
                                                  color: AppColors.neutral500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tanggal,
                                                  style: AppTextStyles.labelSm
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .neutral500,
                                                        fontSize: 11,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.neutral400,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_hospital_rounded,
                                              size: 14,
                                              color: Color(0xFF2563EB),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Faskes Tujuan: $faskes',
                                                style: AppTextStyles.bodyMd.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.neutral800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Diagnosa: $diagnosis',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.neutral700,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
