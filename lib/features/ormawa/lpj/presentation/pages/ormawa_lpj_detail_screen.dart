import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_prodi':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return BkuTheme.emerald;
      case 'ditolak':
      case 'batal':
        return BkuTheme.rose;
      case 'revisi':
        return BkuTheme.amber;
      default:
        return BkuTheme.sky;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_prodi':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return BkuTheme.emeraldSoft;
      case 'ditolak':
      case 'batal':
        return BkuTheme.roseSoft;
      case 'revisi':
        return BkuTheme.amberSoft;
      default:
        return BkuTheme.skySoft;
    }
  }

  Color _getStatusBorder(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_prodi':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return BkuTheme.emeraldBorder;
      case 'ditolak':
      case 'batal':
        return BkuTheme.roseBorder;
      case 'revisi':
        return BkuTheme.amberBorder;
      default:
        return BkuTheme.skyBorder;
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
    final statusColor = _getStatusColor(statusStr);
    final statusBg = _getStatusBg(statusStr);
    final statusBorder = _getStatusBorder(statusStr);

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
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
                  BkuCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 16,
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
                                color: BkuTheme.primarySoft,
                                borderRadius: BkuTheme.r12,
                              ),
                              child: Icon(
                                Icons.assignment_turned_in_rounded,
                                color: BkuTheme.primary,
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
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  if (proposalTitle != null && proposalTitle.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.corporate_fare_rounded, size: 12, color: BkuTheme.textMuted),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Proposal: $proposalTitle',
                                            style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BkuTheme.r8,
                                border: Border.all(color: statusBorder),
                              ),
                              child: Text(
                                statusStr.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                              ),
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
                          badgeColor: BkuTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Realisasi Riil',
                          value: _formatCurrency(realization),
                          badgeText: 'Pengeluaran',
                          icon: Icons.payments_rounded,
                          badgeColor: BkuTheme.sky,
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
                          badgeColor: sisa >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Tingkat Serapan',
                          value: '$absorptionPct%',
                          badgeText: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? 'Optimal' : 'Over',
                          icon: Icons.check_circle_rounded,
                          badgeColor: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? BkuTheme.purple : BkuTheme.rose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.emeraldSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.calculate_rounded, color: BkuTheme.emerald, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rincian Realisasi Keuangan', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Perbandingan alokasi pagu vs pengeluaran aktual yang terpakai.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildInfoRow('Pagu Anggaran Disetujui', _formatCurrency(totalBudget)),
                        Divider(height: 20, color: BkuTheme.borderSubtle),
                        _buildInfoRow('Realisasi Dana Digunakan', _formatCurrency(realization)),
                        Divider(height: 20, color: BkuTheme.borderSubtle),
                        _buildInfoRow(
                          sisa >= 0 ? 'Sisa Saldo Efisiensi (Hemat)' : 'Kekurangan Saldo (Defisit)',
                          _formatCurrency(sisa.abs()),
                          isHighlight: true,
                          highlightColor: sisa >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (catatan.isNotEmpty) ...[
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: BkuTheme.amberSoft,
                                  borderRadius: BkuTheme.r8,
                                ),
                                child: const Icon(Icons.note_alt_rounded, color: BkuTheme.amber, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Catatan, Evaluasi & Kendala', style: BkuTheme.textSectionTitle),
                                    Text(
                                      'Ringkasan hasil kegiatan serta catatan dari reviewer.',
                                      style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
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
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Text(
                              catatan,
                              style: BkuTheme.textBodyRegular.copyWith(fontSize: 12, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.purpleSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.folder_zip_rounded, color: BkuTheme.purple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dokumen Berkas LPJ', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Berkas laporan pertanggungjawaban dan nota transaksi.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
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
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: BkuTheme.rose, size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Berkas Utama Dokumen LPJ (PDF)',
                                        style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Klik untuk melihat / mengunduh dokumen', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.download_rounded, color: BkuTheme.primary),
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
                                color: BkuTheme.borderSubtle,
                                borderRadius: BkuTheme.r10,
                                border: Border.all(color: BkuTheme.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.attach_file_rounded, size: 20, color: BkuTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      docName,
                                      style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (docUrl.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.download_rounded, size: 18, color: BkuTheme.primary),
                                      onPressed: () => launchUrl(Uri.parse(docUrl), mode: LaunchMode.externalApplication),
                                    ),
                                ],
                              ),
                            );
                          })
                        else if (fileUrl == null || fileUrl.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Belum ada berkas lampiran yang diunggah.',
                              style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textPlaceholder, fontStyle: FontStyle.italic),
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
                          child: BkuButton.primary(
                            text: 'Edit LPJ',
                            icon: Icons.edit_rounded,
                            height: 46,
                            onPressed: () async {
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
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkuButton.outline(
                            text: 'Hapus LPJ',
                            icon: Icons.delete_outline_rounded,
                            height: 46,
                            onPressed: () => _confirmDelete(context, targetId, title),
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
          style: BkuTheme.textCaption.copyWith(
            fontSize: 11.5,
            color: BkuTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isHighlight ? (highlightColor ?? BkuTheme.primary) : BkuTheme.textHeading,
          ),
        ),
      ],
    );
  }
}