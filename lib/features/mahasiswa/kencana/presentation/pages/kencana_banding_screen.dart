import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class KencanaBandingScreen extends StatefulWidget {
  const KencanaBandingScreen({super.key});

  @override
  State<KencanaBandingScreen> createState() => _KencanaBandingScreenState();
}

class _KencanaBandingScreenState extends State<KencanaBandingScreen> {
  final _reasonController = TextEditingController();
  final _linkBuktiController = TextEditingController();
  String _selectedType = 'universitas';
  String? _fileUrl;
  String? _fileName;
  bool _isUploadingFile = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaProvider>().fetchBandingList();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _linkBuktiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isUploadingFile = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result == null || result.files.single.path == null) {
        setState(() => _isUploadingFile = false);
        return;
      }
      final path = result.files.single.path!;
      final name = result.files.single.name;
      if (!mounted) return;
      final provider = context.read<KencanaProvider>();
      final uploadedUrl = await provider.uploadBandingFile(path, name);
      if (!mounted) return;
      if (uploadedUrl != null) {
        setState(() {
          _fileUrl = uploadedUrl;
          _fileName = name;
        });
        AppSnackbar.showSuccess(context, 'File bukti berhasil diunggah');
      } else {
        AppSnackbar.showError(
          context,
          provider.errorMessage ?? 'Gagal mengunggah file bukti',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file');
      }
    } finally {
      if (mounted) setState(() => _isUploadingFile = false);
    }
  }

  Future<void> _submitBanding() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      AppSnackbar.showError(context, 'Alasan banding tidak boleh kosong');
      return;
    }
    if (_fileUrl == null) {
      AppSnackbar.showError(context, 'File bukti pendukung wajib diunggah');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    final provider = context.read<KencanaProvider>();
    final success = await provider.submitBanding(
      reason,
      type: _selectedType,
      fileUrl: _fileUrl,
      linkBukti: _linkBuktiController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    BkuLoadingDialog.hide(context);

    if (success) {
      _reasonController.clear();
      _linkBuktiController.clear();
      setState(() {
        _fileUrl = null;
        _fileName = null;
        _selectedType = 'universitas';
      });
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Pengajuan banding berhasil dikirim');
    } else {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Gagal Mengirim Data',
              content: provider.errorMessage ?? 'Gagal mengajukan banding',
              cancelText: '',
              confirmText: 'Tutup',
              onCancel: () {},
              onConfirm: () => context.pop(),
              isDestructive: true,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const BkuAppBar(
            title: 'PENGAJUAN BANDING',
            subtitle: 'KENCANA',
            variant: AppBarVariant.clean,
            expandedHeight: 100,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              left: AppSpacing.s20,
              right: AppSpacing.s20,
              bottom: AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Ajukan Banding',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.appColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Jika ada nilai yang tidak sesuai atau kamu merasa telah menyelesaikan syarat yang diminta, silakan ajukan banding di sini.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.appColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildTypeSelector(),
                const SizedBox(height: AppSpacing.lg),
                _buildReasonField(),
                const SizedBox(height: AppSpacing.lg),
                _buildFilePicker(),
                const SizedBox(height: AppSpacing.lg),
                _buildLinkBuktiField(),
                const SizedBox(height: AppSpacing.lg),
                BkuButton(
                  onPressed: _submitBanding,
                  text: 'KIRIM BANDING',
                  isLoading: _isSubmitting,
                  variant: BkuButtonVariant.primary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Consumer<KencanaProvider>(
                  builder: (context, provider, _) {
                    if (provider.bandingList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: AppRadius.radiusLg,
                        ),
                        child: Text(
                          'Belum ada riwayat banding',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children:
                          provider.bandingList.map((banding) {
                            final rawStatus = banding['status'] ?? 'pending';
                            final alasan = banding['alasan'] ?? '';
                            final type = banding['type']?.toString();
                            Color statusColor = AppColors.warning;

                            String mappedStatus = rawStatus;
                            if (rawStatus.toLowerCase() == 'pending') {
                              mappedStatus = 'Menunggu';
                            }
                            if (rawStatus.toLowerCase() == 'approved') {
                              mappedStatus = 'Disetujui';
                            }
                            if (rawStatus.toLowerCase() == 'rejected') {
                              mappedStatus = 'Ditolak';
                            }

                            String statusLabel =
                                mappedStatus.toString().toTitleCase();

                            if (rawStatus.toLowerCase() == 'approved') {
                              statusColor = AppColors.success;
                            } else if (rawStatus.toLowerCase() == 'rejected') {
                              statusColor = AppColors.error;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: context.appColors.surface,
                                borderRadius: AppRadius.radiusLg,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withAlpha(50),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        banding['created_at']
                                                ?.toString()
                                                .split('T')
                                                .first ??
                                            '',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(20),
                                          borderRadius: AppRadius.radiusSm,
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (type != null && type.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.appColors.infoContainer,
                                        borderRadius: AppRadius.radiusXs,
                                      ),
                                      child: Text(
                                        type,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.info,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    alasan,
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return BkuCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeChip(
              label: 'Universitas',
              icon: Icons.school_rounded,
              value: 'universitas',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildTypeChip(
              label: 'Fakultas',
              icon: Icons.groups_rounded,
              value: 'fakultas',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withAlpha(15)
                  : Colors.transparent,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : context.appColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isSelected
                      ? AppColors.primary
                      : context.appColors.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    isSelected
                        ? AppColors.primary
                        : context.appColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan Banding',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w700,
            color: context.appColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuCard(
          child: TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Saya sudah mengumpulkan tugas di e-learning namun nilainya masih 0...',
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: context.appColors.outlineVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.lg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'File Bukti Pendukung',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: context.appColors.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '*',
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'PDF, JPG, atau PNG (maks 10MB)',
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _isUploadingFile ? null : _pickFile,
          borderRadius: AppRadius.radiusMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color:
                    _fileUrl != null
                        ? context.appColors.success
                        : context.appColors.outlineVariant,
                style:
                    _fileUrl != null ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: _isUploadingFile
                ? Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.appColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Mengunggah file...',
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.appColors.outline,
                        ),
                      ),
                    ],
                  )
                : _fileUrl != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: context.appColors.success,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileName ?? 'File terunggah',
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.appColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'File berhasil diunggah',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.success,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: context.appColors.outline,
                            ),
                            onPressed: () {
                              setState(() {
                                _fileUrl = null;
                                _fileName = null;
                              });
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Pilih file bukti',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.appColors.outline,
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkBuktiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Link Bukti Pendukung',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: context.appColors.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(opsional)',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _linkBuktiController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://drive.google.com/...',
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: context.appColors.outlineVariant,
              ),
              prefixIcon: Icon(
                Icons.link_rounded,
                color: context.appColors.outline,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
