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
    final s = _scholarship;
    final isRejected = (s.applicationStatus ?? '').toLowerCase().contains('ditolak');
    final isAccepted = (s.applicationStatus ?? '').toLowerCase().contains('diterima') || (s.applicationStatus ?? '').toLowerCase().contains('lulus');

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

                  if (s.catatanVerifikator != null && s.catatanVerifikator!.isNotEmpty) ...[
                    _buildFeedbackBanner(s.catatanVerifikator!, isRejected),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildSectionCard(
                    title: 'Rincian Pengajuan',
                    icon: Icons.assignment_outlined,
                    children: [
                      _buildInfoRow('Program Beasiswa', s.title),
                      const Divider(height: 16, color: BkuTheme.borderSubtle),
                      _buildInfoRow('Penyelenggara', s.provider),
                      const Divider(height: 16, color: BkuTheme.borderSubtle),
                      _buildInfoRow('Nomor Registrasi', s.nomorPendaftaran != null && s.nomorPendaftaran!.isNotEmpty ? s.nomorPendaftaran! : '-'),
                      const Divider(height: 16, color: BkuTheme.borderSubtle),
                      _buildInfoRow('Tanggal Diajukan', s.tanggalPengajuan != null && s.tanggalPengajuan!.isNotEmpty ? s.tanggalPengajuan! : 'Baru Diajukan'),
                      const Divider(height: 16, color: BkuTheme.borderSubtle),
                      _buildInfoRow('Bantuan Biaya', _formatCurrency(s.coverAmount)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (s.motivasi != null && s.motivasi!.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Esai Motivasi & Rencana Studi',
                      icon: Icons.menu_book_rounded,
                      children: [
                        Text(
                          s.motivasi!,
                          style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5, height: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildSectionCard(
                    title: 'Dokumen Terlampir',
                    icon: Icons.attach_file_rounded,
                    children: [
                      if (s.ktmKtpUrl != null && s.ktmKtpUrl!.isNotEmpty)
                        _buildDocTile('KTM & KTP Mahasiswa', s.ktmKtpUrl!),
                      if (s.transkripUrl != null && s.transkripUrl!.isNotEmpty) ...[
                        const Divider(height: 16, color: BkuTheme.borderSubtle),
                        _buildDocTile('Transkrip Nilai SIAKAD', s.transkripUrl!),
                      ],
                      if (s.sertifikatUrl != null && s.sertifikatUrl!.isNotEmpty) ...[
                        const Divider(height: 16, color: BkuTheme.borderSubtle),
                        _buildDocTile('Sertifikat Prestasi / SK', s.sertifikatUrl!),
                      ],
                    ],
                  ),
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
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.category.isNotEmpty ? s.category : 'Beasiswa',
                style: BkuTheme.textBadge.copyWith(color: BkuTheme.primary, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Text(
                  s.nomorPendaftaran != null && s.nomorPendaftaran!.isNotEmpty ? s.nomorPendaftaran! : 'Pendaftaran Aktif',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: BkuTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            s.title,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            s.provider,
            style: BkuTheme.textCardSubtitle.copyWith(fontSize: 12),
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
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 18, color: BkuTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Alur Tahapan Seleksi (4 Tahap)',
                style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 22, color: BkuTheme.borderSubtle),
          ...stages.map((st) {
            final num = st['num'] as int;
            final isDone = num < currentIdx;
            final isCurrent = num == currentIdx;

            Color circleColor = BkuTheme.borderSubtle;
            Color iconColor = BkuTheme.textMuted;
            IconData icon = Icons.circle_outlined;

            if (isDone) {
              circleColor = BkuTheme.emeraldSoft;
              iconColor = BkuTheme.emerald;
              icon = Icons.check_circle_rounded;
            } else if (isCurrent) {
              if (isRejected && num == 4) {
                circleColor = BkuTheme.roseSoft;
                iconColor = BkuTheme.rose;
                icon = Icons.cancel_rounded;
              } else if (isAccepted && num == 4) {
                circleColor = BkuTheme.emeraldSoft;
                iconColor = BkuTheme.emerald;
                icon = Icons.verified_rounded;
              } else {
                circleColor = BkuTheme.primarySoft;
                iconColor = BkuTheme.primary;
                icon = Icons.sync_rounded;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      st['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? (isRejected && num == 4 ? BkuTheme.rose : BkuTheme.primary)
                            : (isDone ? BkuTheme.emerald : BkuTheme.textMuted),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isRejected && num == 4 ? BkuTheme.roseSoft : BkuTheme.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isRejected && num == 4 ? 'Selesai (Ditolak)' : (isAccepted && num == 4 ? 'Lulus' : 'Sedang Berjalan'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isRejected && num == 4 ? BkuTheme.rose : BkuTheme.primary,
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

  Widget _buildFeedbackBanner(String message, bool isRejected) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isRejected ? BkuTheme.roseSoft : BkuTheme.primarySoft,
        borderRadius: BkuTheme.r16,
        border: Border.all(
          color: isRejected ? BkuTheme.roseBorder : BkuTheme.primaryBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRejected ? Icons.info_rounded : Icons.campaign_rounded,
            color: isRejected ? BkuTheme.rose : BkuTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRejected ? 'Catatan Verifikator' : 'Informasi Seleksi',
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isRejected ? BkuTheme.rose : BkuTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: BkuTheme.textCaption.copyWith(
                    fontSize: 11,
                    color: BkuTheme.textHeading,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: BkuTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 22, color: BkuTheme.borderSubtle),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: BkuTheme.textCaption.copyWith(fontSize: 11.5, color: BkuTheme.textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocTile(String title, String url) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BkuTheme.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.description_rounded, size: 18, color: BkuTheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5)),
              Text('Ketuk untuk melihat berkas', style: BkuTheme.textCaption.copyWith(fontSize: 10)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.open_in_new_rounded, size: 18, color: BkuTheme.primary),
          onPressed: () => _launchUrl(url),
        ),
      ],
    );
  }
}
