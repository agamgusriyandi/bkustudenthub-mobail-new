import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';

class MentorBandingDetailScreen extends StatefulWidget {
  final BandingModel banding;
  const MentorBandingDetailScreen({super.key, required this.banding});

  @override
  State<MentorBandingDetailScreen> createState() => _MentorBandingDetailScreenState();
}

class _MentorBandingDetailScreenState extends State<MentorBandingDetailScreen> {
  bool _isLoading = true;
  List<BandingScoreItemModel> _scoreItems = [];
  
  final Map<int, TextEditingController> _scoreControllers = {};
  final TextEditingController _responseController = TextEditingController();
  String _responseStatus = 'approved';

  @override
  void initState() {
    super.initState();
    _responseController.text = widget.banding.adminResponse ?? '';
    _responseStatus = widget.banding.status == 'pending' ? 'approved' : widget.banding.status;
    _loadScoreItems();
  }

  Future<void> _loadScoreItems() async {
    setState(() => _isLoading = true);
    final items = await context.read<MentorKencanaProvider>().fetchBandingScoreItems(widget.banding.id);
    for (var item in items) {
      _scoreControllers[item.id] = TextEditingController(text: item.score.toString());
    }
    setState(() {
      _scoreItems = items;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    _responseController.dispose();
    super.dispose();
  }

  void _submitResponse() async {
    final responseMsg = _responseController.text.trim();
    
    final itemsToSubmit = <Map<String, dynamic>>[];
    if (_responseStatus == 'approved') {
      for (var item in _scoreItems) {
        final val = double.tryParse(_scoreControllers[item.id]?.text ?? '') ?? 0.0;
        itemsToSubmit.add({
          'id': item.id,
          'score': val,
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await context.read<MentorKencanaProvider>().respondBanding(
      widget.banding.id,
      _responseStatus,
      responseMsg,
      itemsToSubmit,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggapan berhasil disimpan')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan tanggapan')),
      );
    }
  }

  Widget _buildInfoRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: content,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.banding.status == 'pending';

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Banding',
            showBackButton: true,
            variant: AppBarVariant.student,
            isExpandable: true,
            expandedHeight: 120,
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Mahasiswa',
                                Text('${widget.banding.studentName}\n(${widget.banding.studentNim})', 
                                  style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold)
                                ),
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                'Alasan Banding',
                                Text('"${widget.banding.reason}"', 
                                  style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic)
                                ),
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                'Status Saat Ini',
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.banding.status == 'approved' ? AppColors.success.withAlpha(25)
                                        : widget.banding.status == 'rejected' ? AppColors.error.withAlpha(25) 
                                        : AppColors.warning.withAlpha(25),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    widget.banding.status == 'approved' ? 'DISETUJUI'
                                        : widget.banding.status == 'rejected' ? 'DITOLAK'
                                        : 'MENUNGGU',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: widget.banding.status == 'approved' ? AppColors.success
                                        : widget.banding.status == 'rejected' ? AppColors.error 
                                        : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // KEPUTUSAN FASILITATOR
                        Text('Keputusan Fasilitator', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          initialValue: _responseStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'approved', child: Text('Setujui (Banding Diterima)')),
                            DropdownMenuItem(value: 'rejected', child: Text('Tolak (Banding Ditolak)')),
                          ],
                          onChanged: isPending ? (val) {
                            if (val != null) setState(() => _responseStatus = val);
                          } : null,
                        ),

                        if (_responseStatus == 'approved') ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              border: Border.all(color: AppColors.success.withAlpha(50)),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.success, size: 16),
                                    const SizedBox(width: 8),
                                    Text('Revisi Nilai Komponen', style: AppTextStyles.labelSm.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Silakan sesuaikan nilai masing-masing komponen penilaian pada tabel di bawah ini. Nilai akhir akan dihitung ulang secara otomatis.',
                                  style: AppTextStyles.labelSm.copyWith(color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_scoreItems.isEmpty)
                            const Center(child: Text('Tidak ada rincian komponen nilai.', style: TextStyle(fontStyle: FontStyle.italic)))
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.neutral200),
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Column(
                                children: _scoreItems.map((item) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: AppColors.neutral200)),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.itemName, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 2),
                                              Text('Bobot: ${(item.weight ?? 0).toInt()}%', style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller: _scoreControllers[item.id],
                                            keyboardType: TextInputType.number,
                                            enabled: isPending,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                              border: OutlineInputBorder(borderRadius: AppRadius.radiusSm),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                        
                        const SizedBox(height: AppSpacing.xl),
                        Text('Catatan Tanggapan (Opsional)', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _responseController,
                          maxLines: 4,
                          enabled: isPending,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            hintText: 'Berikan penjelasan terkait keputusan ini...',
                          ),
                        ),

                        if (isPending) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          BkuButton(
                            text: 'Simpan Tanggapan',
                            onPressed: _submitResponse,
                            fullWidth: true,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
