import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/edit_lpj_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDocs = false;
        });
      }
    }
  }



  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Lpj',
            subtitle: 'Laporan Pertanggungjawaban',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkuCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.lpj.judul,
                                style: AppTextStyles.titleLg.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            BkuStatusBadge(
                              status: _mapStatusToBkuStatus(widget.lpj.status),
                              customText: widget.lpj.status,
                              showIcon: false,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs),
                            ),
                          ],
                        ),
                        if (widget.lpj.proposalTitle != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            widget.lpj.proposalTitle!,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(
                    context,
                    'ANGGARAN',
                    [
                      _buildInfoRow('Total Anggaran',
                          _formatCurrency(widget.lpj.totalAnggaran)),
                      _buildInfoRow('Realisasi',
                          _formatCurrency(widget.lpj.realisasiAnggaran)),
                      _buildInfoRow(
                          'Sisa',
                          _formatCurrency(
                              widget.lpj.totalAnggaran - widget.lpj.realisasiAnggaran)),
                    ],
                  ),
                  if (widget.lpj.catatan.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoCard(
                      context,
                      'CATATAN',
                      [
                        Text(
                          widget.lpj.catatan,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.lpj.createdAt != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoCard(
                      context,
                      'INFORMASI',
                      [
                        _buildInfoRow(
                            'Dibuat',
                            DateFormat('dd MMMM yyyy', 'id')
                                .format(widget.lpj.createdAt!)),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
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
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Edit LPJ',
              style: TextStyle(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context) {
    return BkuCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOKUMEN LAMPIRAN',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isLoadingDocs)
            const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
          else if (_documents.isEmpty)
            Text(
              'Tidak ada dokumen terlampir.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _documents.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final doc = _documents[index];
                final url = doc['file_url'] ?? doc['url'];
                final name = doc['file_name'] ?? doc['nama_dokumen'] ?? 'Dokumen ${index + 1}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: context.appColors.primary,
                  ),
                  title: Text(
                    name,
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.download_rounded, color: context.appColors.primary),
                  onTap: () async {
                    if (url != null) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return BkuCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.neutral600)),
          Text(value,
              style: AppTextStyles.bodyMd
                  .copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  BkuStatus _mapStatusToBkuStatus(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('setuju') || s.contains('selesai') || s.contains('acc')) {
      return BkuStatus.success;
    } else if (s.contains('tolak') || s.contains('batal')) {
      return BkuStatus.error;
    } else if (s.contains('revisi')) {
      return BkuStatus.warning;
    }
    return BkuStatus.info;
  }
}
