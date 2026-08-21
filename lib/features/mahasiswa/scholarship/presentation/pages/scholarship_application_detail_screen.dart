import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';

class ScholarshipApplicationDetailScreen extends StatefulWidget {
  final Scholarship scholarship;

  const ScholarshipApplicationDetailScreen({
    super.key,
    required this.scholarship,
  });

  @override
  State<ScholarshipApplicationDetailScreen> createState() => _ScholarshipApplicationDetailScreenState();
}

class _ScholarshipApplicationDetailScreenState extends State<ScholarshipApplicationDetailScreen> {
  late Scholarship _scholarship;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scholarship = widget.scholarship;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await context.read<ScholarshipProvider>().getPengajuanDetail(_scholarship.id);
      if (mounted) {
        setState(() {
          _scholarship = detail;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;

    final String fullUrl = ApiGate.getImageUrl(urlString.trim());
    final Uri? url = Uri.tryParse(fullUrl.replaceAll(' ', '%20'));
    if (url == null) return;

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {}
  }

  int _getStageIndex(String? rawStatus) {
    final s = (rawStatus ?? '').toLowerCase().trim();
    if (s == 'dikirim' || s == 'menunggu' || s.contains('berkas')) {
      return 1;
    } else if (s.contains('substansi') || s.contains('proses')) {
      return 2;
    } else if (s.contains('wawancara') || s.contains('evaluasi') || s.contains('review') || s.contains('penetapan')) {
      return 3;
    } else if (s == 'diterima' || s == 'ditolak' || s.contains('lulus') || s.contains('hasil')) {
      return 4;
    }
    return 1;
  }

  String _formatCurrency(String amountStr) {
    try {
      final amount = double.tryParse(amountStr) ?? 0.0;
      if (amount == 0.0) return 'Bantuan Biaya';
      final formatted = amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return "Rp $formatted";
    } catch (_) {
      return amountStr;
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '21 Agu 2026';
    try {
      final dt = DateTime.parse(rawDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  Map<String, dynamic> _parseCustomAnswers(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  bool _isFilePath(dynamic val) {
    if (val is! String) return false;
    final s = val.toLowerCase();
    return s.startsWith('/uploads/') ||
        s.startsWith('http://') ||
        s.startsWith('https://') ||
        s.contains('/scholarship/upload') ||
        s.endsWith('.pdf') ||
        s.endsWith('.jpg') ||
        s.endsWith('.jpeg') ||
        s.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    final s = _scholarship;
    final isRejected = (s.applicationStatus ?? '').toLowerCase().contains('ditolak');
    final isAccepted = (s.applicationStatus ?? '').toLowerCase().contains('diterima') || (s.applicationStatus ?? '').toLowerCase().contains('lulus');
    final customAnswers = _parseCustomAnswers(s.customAnswersRaw);

    final List<Map<String, String>> customDocList = [];
    customAnswers.forEach((key, value) {
      if (_isFilePath(value)) {
        customDocList.add({
          'label': 'SYARAT KHUSUS: $key',
          'url': value.toString(),
        });
      }
    });

    final logs = s.logs ?? [];

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Detail Pengajuan Beasiswa',
        subtitle: 'Pantau Status Seleksi & Berkas',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: BkuShimmerList(itemCount: 4, itemHeight: 120),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(s),
                  const SizedBox(height: AppSpacing.lg),

                  _buildTimelineStepper(s, isRejected, isAccepted),
                  const SizedBox(height: AppSpacing.lg),

                  _buildInformasiDasarGrid(s),
                  const SizedBox(height: AppSpacing.lg),

                  _buildCatatanEvaluasiSection(s, logs, isRejected),
                  const SizedBox(height: AppSpacing.lg),

                  if (s.motivasi != null && s.motivasi!.isNotEmpty) ...[
                    _buildMotivasiDiriCard(s.motivasi!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildDokumenTerlampirCard(s, customDocList),
                  const SizedBox(height: AppSpacing.lg),

                  if (customAnswers.isNotEmpty) ...[
                    _buildPersyaratanKhususCard(customAnswers),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  const SizedBox(height: AppSpacing.s48),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(Scholarship s) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  s.category.isNotEmpty ? s.category : 'Beasiswa',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  s.nomorPendaftaran != null && s.nomorPendaftaran!.isNotEmpty ? s.nomorPendaftaran! : 'Pendaftaran Aktif',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            s.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.provider,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepper(Scholarship s, bool isRejected, bool isAccepted) {
    final stages = [
      {'num': 1, 'label': '1. Seleksi Berkas'},
      {'num': 2, 'label': '2. Seleksi Substansi'},
      {'num': 3, 'label': '3. Evaluasi & Wawancara'},
      {'num': 4, 'label': isRejected ? '4. Ditolak' : (isAccepted ? '4. Diterima' : '4. Hasil Akhir')},
    ];

    final currentIdx = _getStageIndex(s.applicationStatus);

    return Container(
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
                child: const Icon(Icons.timeline_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Alur Tahapan Seleksi (4 Tahap)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...stages.map((st) {
            final num = st['num'] as int;
            final isDone = num < currentIdx;
            final isCurrent = num == currentIdx;

            Color circleColor = const Color(0xFFF1F5F9);
            Color iconColor = const Color(0xFF94A3B8);
            IconData icon = Icons.circle_outlined;

            if (isDone) {
              circleColor = const Color(0xFFECFDF5);
              iconColor = const Color(0xFF059669);
              icon = Icons.check_circle_rounded;
            } else if (isCurrent) {
              if (isRejected && num == 4) {
                circleColor = const Color(0xFFFFF1F2);
                iconColor = const Color(0xFFE11D48);
                icon = Icons.cancel_rounded;
              } else if (isAccepted && num == 4) {
                circleColor = const Color(0xFFECFDF5);
                iconColor = const Color(0xFF059669);
                icon = Icons.verified_rounded;
              } else {
                circleColor = const Color(0xFFEFF6FF);
                iconColor = const Color(0xFF2563EB);
                icon = Icons.sync_rounded;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 15, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      st['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent || isDone ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent
                            ? (isRejected && num == 4 ? const Color(0xFFE11D48) : const Color(0xFF0F172A))
                            : (isDone ? const Color(0xFF059669) : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isRejected && num == 4 ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isRejected && num == 4 ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        isRejected && num == 4 ? 'Selesai (Ditolak)' : (isAccepted && num == 4 ? 'Lulus' : 'Sedang Berjalan'),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isRejected && num == 4 ? const Color(0xFFE11D48) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInformasiDasarGrid(Scholarship s) {
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
                child: const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'INFORMASI DASAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoGridTile(
                  'NILAI BANTUAN',
                  _formatCurrency(s.coverAmount),
                  valueColor: const Color(0xFF1B3A6B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoGridTile(
                  'MIN. IPK',
                  s.minIpk != null && s.minIpk!.isNotEmpty ? s.minIpk! : '2.75',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoGridTile(
                  'STATUS EKONOMI',
                  s.category.toLowerCase().contains('sktm') || s.category.toLowerCase().contains('ekonomi')
                      ? 'SKTM'
                      : 'Umum',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoGridTile(
                  'TANGGAL PENGAJUAN',
                  _formatDate(s.tanggalPengajuan),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGridTile(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanEvaluasiSection(Scholarship s, List<dynamic> logs, bool isRejected) {
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
                child: const Icon(Icons.history_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'CATATAN EVALUASI & LOG STATUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (logs.isNotEmpty)
            ...logs.map((log) {
              final status = (log['status'] ?? log['stage'] ?? 'PENGAJUAN TERKIRIM').toString().toUpperCase();
              final timestamp = log['created_at'] ?? log['CreatedAt'] ?? '21 Agu, 20.19';
              final message = log['catatan'] ?? log['catatan_admin'] ?? 'Pendaftaran berhasil diajukan oleh mahasiswa';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E40AF),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 3),
                              Text(
                                timestamp.toString().contains('T')
                                    ? timestamp.toString().split('T').first
                                    : timestamp.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.toString(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Text(
                          'PENGAJUAN TERKIRIM',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E40AF),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 3),
                          Text(
                            _formatDate(s.tanggalPengajuan),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.catatanVerifikator != null && s.catatanVerifikator!.isNotEmpty
                        ? s.catatanVerifikator!
                        : 'Pendaftaran berhasil diajukan oleh mahasiswa',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMotivasiDiriCard(String motivasi) {
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
                child: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'MOTIVASI DIRI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '"$motivasi"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenTerlampirCard(Scholarship s, List<Map<String, String>> customDocs) {
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
                child: const Icon(Icons.folder_open_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'DOKUMEN TERLAMPIR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (s.ktmKtpUrl != null && s.ktmKtpUrl!.isNotEmpty)
            _buildDocTile('KTM & KTP', s.ktmKtpUrl!),
          if (s.transkripUrl != null && s.transkripUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDocTile('TRANSKRIP NILAI (SIAKAD)', s.transkripUrl!),
          ],
          if (s.sertifikatUrl != null && s.sertifikatUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDocTile('SERTIFIKAT PRESTASI / SK', s.sertifikatUrl!),
          ],
          ...customDocs.map((doc) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildDocTile(doc['label']!, doc['url']!),
              )),
        ],
      ),
    );
  }

  Widget _buildPersyaratanKhususCard(Map<String, dynamic> customAnswers) {
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
                child: const Icon(Icons.fact_check_rounded, size: 16, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              const Text(
                'PERSYARATAN KHUSUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...customAnswers.entries.map((entry) {
            final label = entry.key;
            final val = entry.value;
            final isFile = _isFilePath(val);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: isFile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Lampiran File Tambahan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _launchUrl(val.toString()),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'BUKA',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1B3A6B),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF1B3A6B)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            val.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.description_rounded, size: 18, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'PDF / JPG',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _launchUrl(url),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Icon(Icons.open_in_new_rounded, size: 15, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }
}
