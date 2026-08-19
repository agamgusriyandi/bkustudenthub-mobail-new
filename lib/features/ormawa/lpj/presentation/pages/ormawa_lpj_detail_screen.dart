import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
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

  Future<void> _loadDocuments() async {
    try {
      final docs = await context.read<OrmawaProvider>().repository.getLpjDocuments(widget.lpj.id.toString());
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
      case 'selesai':
      case 'completed':
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

  @override
  Widget build(BuildContext context) {
    final statusStr = (widget.lpj.status ?? 'Menunggu').toString();
    final title = (widget.lpj.title ?? widget.lpj.judul ?? 'Detail LPJ').toString();
    final proposalTitle = widget.lpj.proposalTitle;
    final totalBudget = (widget.lpj.totalBudget ?? widget.lpj.totalAnggaran ?? 0.0) as double;
    final realization = (widget.lpj.realizationBudget ?? widget.lpj.realisasiAnggaran ?? 0.0) as double;
    final sisa = totalBudget - realization;
    final catatan = (widget.lpj.note ?? widget.lpj.catatan ?? '').toString();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail LPJ',
            subtitle: 'Laporan Pertanggungjawaban',
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: OrmawaTheme.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.assignment_turned_in_rounded,
                                color: OrmawaTheme.primary,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: OrmawaTheme.textHeading,
                                    ),
                                  ),
                                  if (proposalTitle != null && proposalTitle.toString().isNotEmpty) ...[
                                    SizedBox(height: 3),
                                    Text(
                                      'Proposal: $proposalTitle',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: OrmawaTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            OrmawaBadge(
                              text: statusStr.toUpperCase(),
                              variant: _getBadgeVariant(statusStr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle('Realisasi Anggaran'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      children: [
                        _buildInfoRow('Total Anggaran', _formatCurrency(totalBudget)),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        _buildInfoRow('Realisasi Digunakan', _formatCurrency(realization)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        _buildInfoRow('Sisa Anggaran', _formatCurrency(sisa), isHighlight: true),
                      ],
                    ),
                  ),
                  if (catatan.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Catatan Penguji / Verifikator'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OrmawaTheme.statusWarningBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: OrmawaTheme.statusWarningBorder),
                      ),
                      child: Text(
                        catatan,
                        style: TextStyle(
                          fontSize: 12,
                          color: OrmawaTheme.textHeading,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle('Dokumen Lampiran & Bukti'),
                  const SizedBox(height: 8),
                  _buildDocumentsCard(context),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission('edit_lpj')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditLpjScreen(lpj: widget.lpj),
                ),
              ).then((_) => provider.refreshData());
            },
            backgroundColor: OrmawaTheme.primary,
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: const Text(
              'Edit LPJ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: OrmawaTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: OrmawaTheme.textHeading,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: OrmawaTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isHighlight ? OrmawaTheme.primaryDark : OrmawaTheme.textHeading,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsCard(BuildContext context) {
    return OrmawaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingDocs)
            Center(child: Padding(padding: EdgeInsets.all(12), child: BkuShimmerList(itemCount: 2, itemHeight: 40)))
          else if (_documents.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tidak ada dokumen lampiran',
                style: TextStyle(
                  fontSize: 11.5,
                  color: OrmawaTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ..._documents.map((doc) {
              final fileName = (doc['NamaFile'] ?? doc['nama_file'] ?? 'Dokumen LPJ').toString();
              final fileUrl = (doc['FileUrl'] ?? doc['file_url'] ?? '').toString();
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: OrmawaTheme.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.insert_drive_file_outlined, color: OrmawaTheme.primary, size: 18),
                ),
                title: Text(
                  fileName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OrmawaTheme.textHeading),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.download_rounded, color: OrmawaTheme.primary, size: 20),
                  onPressed: () {
                    if (fileUrl.isNotEmpty) {
                      launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}
