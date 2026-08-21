import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/apply_scholarship_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_application_detail_screen.dart';

class ScholarshipProgramDetailScreen extends StatefulWidget {
  final int programId;
  const ScholarshipProgramDetailScreen({super.key, required this.programId});

  @override
  State<ScholarshipProgramDetailScreen> createState() => _ScholarshipProgramDetailScreenState();
}

class _ScholarshipProgramDetailScreenState extends State<ScholarshipProgramDetailScreen> {
  Scholarship? _scholarship;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await context.read<ScholarshipProvider>().getScholarshipDetail(widget.programId.toString());
      if (mounted) {
        setState(() {
          _scholarship = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int _getDaysDiff(String deadlineRaw) {
    if (deadlineRaw.isEmpty) return 999;
    try {
      final deadlineDate = DateTime.parse(deadlineRaw);
      final now = DateTime.now();
      return deadlineDate.difference(now).inDays;
    } catch (_) {
      return 999;
    }
  }

  String _formatCurrency(String amountStr) {
    try {
      final amount = double.tryParse(amountStr) ?? 0.0;
      if (amount == 0.0) return 'Bantuan Biaya Pendidikan';
      final formatted = amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return "Rp $formatted";
    } catch (_) {
      return amountStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Detail Program Beasiswa',
        subtitle: 'Rincian Persyaratan & Pendaftaran',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: BkuShimmerList(itemCount: 4, itemHeight: 120),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _scholarship == null
                  ? _buildNotFoundState()
                  : _buildContent(_scholarship!),
      bottomNavigationBar: _scholarship != null && !_isLoading && _errorMessage == null
          ? _buildBottomBar(_scholarship!)
          : null,
    );
  }

  Widget _buildContent(Scholarship s) {
    final profile = context.watch<ProfileProvider>();
    final daysDiff = _getDaysDiff(s.deadline);
    final isClosed = daysDiff < 0;

    final studentIpk = profile.ipk;
    final minIpk = double.tryParse(s.minIpk ?? '0') ?? 0.0;
    final isIpkEligible = minIpk == 0.0 || studentIpk >= minIpk;
    final isApplied = s.status.toLowerCase() == 'applied' || s.applicationStatus != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(s, daysDiff, isClosed),
          const SizedBox(height: AppSpacing.lg),

          if (isApplied) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pendaftaran Telah Terkirim',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.applicationStatus ?? 'Sedang dalam peninjauan berkas admin',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScholarshipApplicationDetailScreen(scholarship: s),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                      ),
                    ),
                    child: const Text(
                      'Lihat Progres',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          _buildHighlightsGrid(s),
          const SizedBox(height: AppSpacing.lg),

          _buildEligibilityCard(studentIpk, minIpk, isIpkEligible),
          const SizedBox(height: AppSpacing.lg),

          _buildSectionCard(
            title: 'Deskripsi & Cakupan Beasiswa',
            icon: Icons.description_outlined,
            child: Text(
              s.description.isNotEmpty ? s.description : 'Tidak ada deskripsi rinci untuk program beasiswa ini.',
              style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5, height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildSectionCard(
            title: 'Dokumen Persyaratan',
            icon: Icons.folder_shared_outlined,
            child: Column(
              children: [
                _buildDocItem('KTM & KTP Mahasiswa', s.fileKtm == 'wajib', 'Format file PDF/JPG/PNG maks. 5MB'),
                const SizedBox(height: 10),
                _buildDocItem('Transkrip Nilai Terakhir (SIAKAD)', s.fileTranskrip == 'wajib', 'Memuat IPK semester terakhir'),
                const SizedBox(height: 10),
                _buildDocItem('Sertifikat Prestasi / SK Rekomendasi', s.fileSertifikat == 'wajib', 'Bukti prestasi pendukung atau surat rekomendasi fakultas'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s80),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Scholarship s, int daysDiff, bool isClosed) {
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
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        s.category.isNotEmpty ? s.category : 'Umum',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isClosed
                      ? const Color(0xFFFFF1F2)
                      : (daysDiff <= 7 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isClosed
                        ? const Color(0xFFFECDD3)
                        : (daysDiff <= 7 ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isClosed ? Icons.lock_clock_rounded : Icons.timer_outlined,
                      size: 13,
                      color: isClosed
                          ? const Color(0xFFE11D48)
                          : (daysDiff <= 7 ? const Color(0xFF475569) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isClosed ? 'Ditutup' : '$daysDiff Hari Tersisa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isClosed
                            ? const Color(0xFFE11D48)
                            : (daysDiff <= 7 ? const Color(0xFF0F172A) : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            s.title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.provider,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsGrid(Scholarship s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                  label: 'Nilai Bantuan',
                  value: _formatCurrency(s.coverAmount),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.groups_outlined,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                  label: 'Kuota Beasiswa',
                  value: s.kuota != null && s.kuota!.isNotEmpty ? '${s.kuota} Mahasiswa' : 'Terbuka',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.grade_outlined,
                  color: const Color(0xFF475569),
                  bg: const Color(0xFFF1F5F9),
                  label: 'Syarat IPK Min',
                  value: s.minIpk != null && s.minIpk!.isNotEmpty ? 'IPK ≥ ${s.minIpk}' : 'Semua IPK',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.school_outlined,
                  color: const Color(0xFF475569),
                  bg: const Color(0xFFF1F5F9),
                  label: 'Syarat Semester',
                  value: s.minSemester != null && s.minSemester!.isNotEmpty ? 'Min. Semester ${s.minSemester}' : 'Semua Semester',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required Color bg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard(double studentIpk, double minIpk, bool isIpkEligible) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isIpkEligible ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isIpkEligible ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isIpkEligible ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: isIpkEligible ? const Color(0xFF059669) : const Color(0xFFE11D48),
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIpkEligible ? 'Anda Memenuhi Syarat Beasiswa' : 'Perhatian Syarat Akademik',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isIpkEligible ? const Color(0xFF065F46) : const Color(0xFF9F1239),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isIpkEligible
                      ? 'IPK Anda ($studentIpk) memenuhi syarat minimum (${minIpk == 0.0 ? 'Bebas' : minIpk.toString()}). Silakan lengkapi berkas untuk mendaftar.'
                      : 'IPK Anda saat ini ($studentIpk) berada di bawah syarat minimum (${minIpk.toString()}). Pastikan data IPK terbaru sudah terupdate.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF475569)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: Color(0xFFF1F5F9)),
          child,
        ],
      ),
    );
  }

  Widget _buildDocItem(String name, bool isWajib, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF475569),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isWajib ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isWajib ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      isWajib ? 'Wajib' : 'Opsional',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isWajib ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Scholarship s) {
    final isApplied = s.status.toLowerCase() == 'applied' || s.applicationStatus != null;
    final isClosed = _getDaysDiff(s.deadline) < 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: isApplied
              ? BkuButton(
                  text: 'Lihat Progress Pengajuan',
                  variant: BkuButtonVariant.primary,
                  icon: Icons.timeline_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScholarshipApplicationDetailScreen(scholarship: s),
                      ),
                    );
                  },
                )
              : isClosed
                  ? BkuButton(
                      text: 'Pendaftaran Telah Ditutup',
                      variant: BkuButtonVariant.secondary,
                      icon: Icons.lock_clock_rounded,
                      onPressed: null,
                    )
                  : BkuButton(
                      text: 'Daftar Beasiswa Sekarang',
                      variant: BkuButtonVariant.primary,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplyScholarshipScreen(scholarship: s),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: BkuTheme.rose),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Gagal Memuat Detail Beasiswa',
              style: BkuTheme.textCardTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Terjadi kesalahan saat mengambil data.',
              textAlign: TextAlign.center,
              style: BkuTheme.textCardSubtitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.lg),
            BkuButton(
              text: 'Coba Lagi',
              variant: BkuButtonVariant.primary,
              onPressed: _fetchDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: BkuTheme.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('Program Beasiswa Tidak Ditemukan', style: BkuTheme.textCardTitle),
            const SizedBox(height: AppSpacing.lg),
            BkuButton(
              text: 'Kembali',
              variant: BkuButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
