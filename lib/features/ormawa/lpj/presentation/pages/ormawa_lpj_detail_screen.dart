import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_lpj.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/edit_lpj_screen.dart';

class OrmawaLpjDetailScreen extends StatefulWidget {
  final dynamic lpj;

  const OrmawaLpjDetailScreen({super.key, required this.lpj});

  @override
  State<OrmawaLpjDetailScreen> createState() => _OrmawaLpjDetailScreenState();
}

class _OrmawaLpjDetailScreenState extends State<OrmawaLpjDetailScreen> {
  List<dynamic> _documents = [];
  bool _isLoadingDocs = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  String _getLpjId() {
    if (widget.lpj is OrmawaLPJ) {
      return (widget.lpj as OrmawaLPJ).id;
    }
    return (widget.lpj['id'] ?? widget.lpj['ID'] ?? '').toString();
  }

  Future<void> _loadDocuments() async {
    try {
      final id = _getLpjId();
      final docs = await context.read<OrmawaProvider>().repository.getLpjDocuments(id);
      if (mounted) {
        setState(() {
          _documents = docs;
          _isLoadingDocs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingDocs = false;
        });
      }
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_prodi':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return OrmawaBadgeVariant.success;
      case 'ditolak':
      case 'batal':
        return OrmawaBadgeVariant.danger;
      case 'revisi':
        return OrmawaBadgeVariant.warning;
      default:
        return OrmawaBadgeVariant.info;
    }
  }

  void _confirmDelete(BuildContext context, String lpjId, String title) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Berkas LPJ?',
      message: 'Apakah Anda yakin ingin menghapus laporan pertanggungjawaban "$title"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteLPJ(lpjId);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'LPJ berhasil dihapus');
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus LPJ: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final targetId = _getLpjId();

    final liveLpj = provider.lpjs.cast<OrmawaLPJ>().firstWhere(
      (l) => l.id.toString() == targetId,
      orElse: () => widget.lpj is OrmawaLPJ ? widget.lpj as OrmawaLPJ : OrmawaLPJ.fromJson(widget.lpj),
    );

    final statusStr = liveLpj.status;
    final title = liveLpj.judul;
    final proposalTitle = liveLpj.proposalTitle;
    final totalBudget = liveLpj.totalAnggaran;
    final realization = liveLpj.realisasiAnggaran;
    final sisa = totalBudget - realization;
    final catatan = liveLpj.catatan;
    final fileUrl = liveLpj.fileUrl;
    final absorptionPct = totalBudget > 0 ? ((realization / totalBudget) * 100).toStringAsFixed(1) : '0.0';

    final isLocked = statusStr.toLowerCase().contains('setuju') || statusStr.toLowerCase() == 'selesai';

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          BkuAppBar(
            title: title,
            subtitle: 'Rincian Pertanggungjawaban & Realisasi',
            variant: AppBarVariant.ormawa,
            expandedHeight: 135.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assignment_turned_in_rounded,
                                color: Color(0xFF2563EB),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: OrmawaTheme.textCardTitle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  if (proposalTitle != null && proposalTitle.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.corporate_fare_rounded, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Proposal: $proposalTitle',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            OrmawaBadge(
                              text: statusStr.toUpperCase(),
                              variant: _getBadgeVariant(statusStr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Pagu Disetujui',
                          value: _formatCurrency(totalBudget),
                          badgeText: 'Pagu',
                          icon: Icons.account_balance_wallet_rounded,
                          badgeColor: OrmawaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Realisasi Riil',
                          value: _formatCurrency(realization),
                          badgeText: 'Pengeluaran',
                          icon: Icons.payments_rounded,
                          badgeColor: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: sisa >= 0 ? 'Sisa Efisiensi' : 'Defisit Anggaran',
                          value: _formatCurrency(sisa.abs()),
                          badgeText: sisa >= 0 ? 'Hemat' : 'Over',
                          icon: sisa >= 0 ? Icons.savings_rounded : Icons.trending_down_rounded,
                          badgeColor: sisa >= 0 ? const Color(0xFF10B981) : const Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Tingkat Serapan',
                          value: '$absorptionPct%',
                          badgeText: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? 'Optimal' : 'Over',
                          icon: Icons.check_circle_rounded,
                          badgeColor: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? const Color(0xFF7C3AED) : const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calculate_rounded, color: Color(0xFF16A34A), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rincian Realisasi Keuangan', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Perbandingan alokasi pagu vs pengeluaran aktual yang terpakai.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildInfoRow('Pagu Anggaran Disetujui', _formatCurrency(totalBudget)),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildInfoRow('Realisasi Dana Digunakan', _formatCurrency(realization)),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildInfoRow(
                          sisa >= 0 ? 'Sisa Saldo Efisiensi (Hemat)' : 'Kekurangan Saldo (Defisit)',
                          _formatCurrency(sisa.abs()),
                          isHighlight: true,
                          highlightColor: sisa >= 0 ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (catatan.isNotEmpty) ...[
                    OrmawaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.note_alt_rounded, color: Color(0xFFD97706), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Catatan, Evaluasi & Kendala', style: OrmawaTheme.textSectionTitle),
                                    const Text(
                                      'Ringkasan hasil kegiatan serta catatan dari reviewer.',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              catatan,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.folder_zip_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dokumen Berkas LPJ', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Berkas laporan pertanggungjawaban dan nota transaksi.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (fileUrl != null && fileUrl.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE11D48), size: 28),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Berkas Utama Dokumen LPJ (PDF)',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      SizedBox(height: 2),
                                      Text('Klik untuk melihat / mengunduh dokumen', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download_rounded, color: Color(0xFF2563EB)),
                                  onPressed: () => launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication),
                                  tooltip: 'Unduh Berkas',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        if (_isLoadingDocs)
                          const Center(child: Padding(padding: EdgeInsets.all(12), child: BkuShimmerList(itemCount: 2, itemHeight: 36)))
                        else if (_documents.isNotEmpty)
                          ..._documents.map((doc) {
                            final docName = (doc['NamaFile'] ?? doc['nama_file'] ?? 'Lampiran LPJ').toString();
                            final docUrl = (doc['FileUrl'] ?? doc['file_url'] ?? '').toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file_rounded, size: 20, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      docName,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (docUrl.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.download_rounded, size: 18, color: Color(0xFF2563EB)),
                                      onPressed: () => launchUrl(Uri.parse(docUrl), mode: LaunchMode.externalApplication),
                                    ),
                                ],
                              ),
                            );
                          })
                        else if (fileUrl == null || fileUrl.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Belum ada berkas lampiran yang diunggah.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!isLocked) ...[
                    Row(
                      children: [
                        Expanded(
                          child: BkuBounceButton(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditLpjScreen(lpj: liveLpj),
                                ),
                              );
                              if (context.mounted) {
                                context.read<OrmawaProvider>().refreshData();
                              }
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: OrmawaTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit LPJ',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkuBounceButton(
                            onTap: () => _confirmDelete(context, targetId, title),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Hapus LPJ',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFE11D48)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isHighlight ? (highlightColor ?? OrmawaTheme.primaryDark) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}