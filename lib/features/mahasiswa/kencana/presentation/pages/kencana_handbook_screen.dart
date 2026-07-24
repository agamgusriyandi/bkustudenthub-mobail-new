import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';

class KencanaHandbookScreen extends StatefulWidget {
  const KencanaHandbookScreen({super.key});

  @override
  State<KencanaHandbookScreen> createState() => _KencanaHandbookScreenState();
}

class _KencanaHandbookScreenState extends State<KencanaHandbookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _refleksiController = TextEditingController();
  final _komitmenController = TextEditingController();
  final _rencanaController = TextEditingController();

  String _currentScope = 'university';
  Map<String, dynamic>? _selectedHandbookData;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _refleksiController.dispose();
    _komitmenController.dispose();
    _rencanaController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentScope = _tabController.index == 0 ? 'university' : 'faculty';
      _populateFormForCurrentScope();
    });
  }

  Future<void> _loadData() async {
    await context.read<KencanaProvider>().fetchHandbook();
    _populateFormForCurrentScope();
    if (mounted) {
      setState(() {
        _isInit = false;
      });
    }
  }

  void _populateFormForCurrentScope() {
    final provider = context.read<KencanaProvider>();
    final resp = provider.handbookResponse;
    if (resp == null) return;

    final history = resp['history'] as List? ?? [];
    final matching = history.firstWhere(
      (h) => h['scope_type'] == _currentScope,
      orElse: () => null,
    );

    setState(() {
      _selectedHandbookData = matching;
      if (matching != null && matching['content_json'] != null) {
        final content = matching['content_json'] as Map<String, dynamic>? ?? {};
        _refleksiController.text = content['refleksi']?.toString() ?? '';
        _komitmenController.text = content['komitmen']?.toString() ?? '';
        _rencanaController.text = content['rencana']?.toString() ?? '';
      } else {
        _refleksiController.clear();
        _komitmenController.clear();
        _rencanaController.clear();
      }
    });
  }

  Future<void> _saveDraft() async {
    BkuLoadingDialog.show(context, message: 'Menyimpan draft...');
    final provider = context.read<KencanaProvider>();
    final success = await provider.saveHandbookDraft(
      _currentScope,
      _refleksiController.text.trim(),
      _komitmenController.text.trim(),
      _rencanaController.text.trim(),
    );
    if (!mounted) return;
    BkuLoadingDialog.hide(context);

    if (success) {
      AppSnackbar.showSuccess(context, 'Draft berhasil disimpan');
      _populateFormForCurrentScope();
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? 'Gagal menyimpan draft',
      );
    }
  }

  void _confirmSubmit() {
    if (_refleksiController.text.trim().isEmpty ||
        _komitmenController.text.trim().isEmpty ||
        _rencanaController.text.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        'Semua kolom isian wajib diisi sebelum mengirim',
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => CustomDialog(
            title: 'Konfirmasi Kirim',
            content:
                'Apakah Anda yakin ingin mengirim handbook ini? Anda tidak dapat mengubahnya lagi setelah dikirim.',
            cancelText: 'Batal',
            confirmText: 'Kirim',
            onCancel: () => Navigator.pop(ctx),
            onConfirm: () {
              Navigator.pop(ctx);
              _submit();
            },
          ),
    );
  }

  Future<void> _submit() async {
    BkuLoadingDialog.show(context, message: 'Mengirim handbook...');
    final provider = context.read<KencanaProvider>();
    final success = await provider.submitHandbook(
      _currentScope,
      _refleksiController.text.trim(),
      _komitmenController.text.trim(),
      _rencanaController.text.trim(),
    );
    if (!mounted) return;
    BkuLoadingDialog.hide(context);

    if (success) {
      AppSnackbar.showSuccess(context, 'Handbook berhasil dikumpulkan');
      _populateFormForCurrentScope();
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? 'Gagal mengirim handbook',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaProvider>();

    final String status = _selectedHandbookData?['status'] ?? 'not_started';
    final String? feedback = _selectedHandbookData?['feedback'];
    final bool isReadOnly = status == 'submitted' || status == 'approved';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'HANDBOOK MAHASISWA',
            subtitle: 'KENCANA',
            variant: AppBarVariant.student,
            expandedHeight: 100,
            showBackButton: true,
            isExpandable: false,
          ),
          if (provider.isLoading && _isInit)
            const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: BkuShimmerList(itemCount: 4, itemHeight: 100),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Universitas'),
                        Tab(text: 'Fakultas'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusCard(status, feedback),
                  const SizedBox(height: 24),
                  _buildField(
                    'Refleksi Kencana',
                    _refleksiController,
                    isReadOnly,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    'Komitmen Mahasiswa',
                    _komitmenController,
                    isReadOnly,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    'Rencana Pengembangan Diri',
                    _rencanaController,
                    isReadOnly,
                  ),
                  const SizedBox(height: 32),
                  if (!isReadOnly) ...[
                    Row(
                      children: [
                        Expanded(
                          child: BkuButton(
                            onPressed: _saveDraft,
                            text: 'SIMPAN DRAFT',
                            variant: BkuButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BkuButton(
                            onPressed: _confirmSubmit,
                            text: 'KIRIM HANDBOOK',
                            variant: BkuButtonVariant.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(15),
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(
                          color: AppColors.success.withAlpha(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Handbook telah dikirim dan dikunci.',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, String? feedback) {
    Color textColor = Colors.grey[600]!;
    IconData icon = Icons.info_outline_rounded;
    String statusText = 'Belum Dikerjakan';

    if (status == 'submitted') {
      textColor = AppColors.warning;
      icon = Icons.pending_actions_rounded;
      statusText = 'Menunggu Review Mentor';
    } else if (status == 'approved') {
      textColor = AppColors.success;
      icon = Icons.verified_rounded;
      statusText = 'Disetujui';
    } else if (status == 'rejected') {
      textColor = AppColors.error;
      icon = Icons.error_outline_rounded;
      statusText = 'Perlu Perbaikan';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: textColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS EVALUASI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: textColor.withAlpha(200),
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: AppTextStyles.labelMd.copyWith(
                      color: Colors.grey[850],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (status == 'rejected' &&
            feedback != null &&
            feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(15),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.warning.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.feedback_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Catatan Revisi Mentor:',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedback,
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    bool isReadOnly,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(200),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            enabled: !isReadOnly,
            style: AppTextStyles.bodyMd.copyWith(
              color:
                  isReadOnly ? Colors.grey[600] : theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis ${label.toLowerCase()} di sini...',
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: theme.colorScheme.outlineVariant,
              ),
              filled: true,
              fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
              contentPadding: const EdgeInsets.all(AppSpacing.lg),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
