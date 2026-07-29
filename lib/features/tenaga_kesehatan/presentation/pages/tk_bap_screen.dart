import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/unified_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';

class TkBapScreen extends StatefulWidget {
  const TkBapScreen({super.key});

  @override
  State<TkBapScreen> createState() => _TkBapScreenState();
}

class _TkBapScreenState extends State<TkBapScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkHealthProvider>().fetchBAPs();
    });
  }

  Widget _buildTopPagination(int totalPages) {
    final bool canPrev = _currentPage > 1;
    final bool canNext = _currentPage < totalPages;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: canPrev ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: AppRadius.br10,
            child: InkWell(
              borderRadius: AppRadius.br10,
              onTap: canPrev ? () => setState(() => _currentPage--) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                              color:
                            canPrev
                                ? context.appColors.secondary
                                : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Sebelumnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            canPrev
                                ? context.appColors.secondary
                                : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.appColors.secondary,
            ),
          ),
          Material(
            color: canNext ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: AppRadius.br10,
            child: InkWell(
              borderRadius: AppRadius.br10,
              onTap: canNext ? () => setState(() => _currentPage++) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            canNext
                                ? context.appColors.secondary
                                : const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color:
                          canNext
                              ? context.appColors.secondary
                              : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.neutral100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tk/bap/form'),
        backgroundColor: context.appColors.success,
        elevation: 4,
        icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
        label: Text(
          'Buat BAP',
          style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: UnifiedBottomNavBar.tenagaKesehatan(
        currentIndex: 0,
        onTap: (index) => context.go('/tenagakes?tab=$index'),
      ),
      appBar: const BkuStaticAppBar(
        title: 'BAP Kesehatan',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Consumer<TkHealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.baps.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 4, itemHeight: 140),
            );
          }

          if (provider.error != null && provider.baps.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchBAPs(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildErrorState(provider.error!),
                  ),
                ],
              ),
            );
          }

          if (provider.baps.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchBAPs(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildEmptyState(),
                  ),
                ],
              ),
            );
          }

          final baps = provider.baps;
          final totalPages = (baps.length / _itemsPerPage).ceil();
          final safeTotalPages = totalPages > 0 ? totalPages : 1;
          final safePage = _currentPage.clamp(1, safeTotalPages);
          if (safePage != _currentPage) {
            _currentPage = safePage;
          }

          final startIndex = (safePage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, baps.length);
          final paginatedBaps =
              baps.isEmpty
                  ? <TkBapModel>[]
                  : baps.sublist(startIndex, endIndex);

          return Column(
            children: [
              _buildTopPagination(safeTotalPages),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchBAPs(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.s100,
                    ),
                    itemCount: paginatedBaps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _buildBapCard(context, paginatedBaps[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: context.appColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Gagal Memuat Data',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => context.read<TkHealthProvider>().fetchBAPs(),
                icon: Icon(Icons.refresh_rounded, color: context.appColors.onPrimary, size: 18),
                label: Text(
                  'Coba Lagi',
                  style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.br10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.appColors.success.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 64,
              color: context.appColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Belum ada BAP Kesehatan',
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Klik tombol "Buat BAP" untuk memulai',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildBapCard(BuildContext context, TkBapModel bap) {
    final isFinal = bap.status == 'FINAL';
    final statusColor = isFinal ? context.appColors.success : context.appColors.warning;
    final statusBg = isFinal ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/tk/bap/form', extra: bap),
        borderRadius: AppRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: statusBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFinal ? Icons.check_circle_rounded : Icons.edit_document,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bap.namaKegiatan.isEmpty ? 'BAP Kesehatan' : bap.namaKegiatan,
                          style: AppTextStyles.titleSm.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 12,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              DateFormat('dd MMM yyyy', 'id_ID').format(bap.tanggalPelaksanaan),
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                            if (bap.tempat.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.md),
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: AppColors.neutral400,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  bap.tempat,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStatusBadge(bap.status),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.appColors.background,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Peserta', bap.jumlahPeserta.toString()),
                    _buildStatDivider(),
                    _buildStatItem('Diperiksa', bap.jumlahDiperiksa.toString()),
                    _buildStatDivider(),
                    _buildStatItem(
                      'Layak',
                      bap.totalLayak.toString(),
                      color: context.appColors.success,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      'Pantauan',
                      bap.totalPantauan.toString(),
                      color: context.appColors.warning,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      'Tdk Layak',
                      bap.totalTidakLayak.toString(),
                      color: context.appColors.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s14),
              Row(
                children: [
                  if (!isFinal) ...[
                    BkuButton(
                      onPressed: () => _showDeleteConfirmation(context, bap),
                      text: 'Hapus',
                      icon: Icons.delete_outline_rounded,
                      variant: BkuButtonVariant.danger,
                      height: 40,
                      fontSize: 12,
                      fullWidth: false,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: BkuButton(
                      onPressed: () async {
                        if (isFinal) {
                          final provider = Provider.of<TkHealthProvider>(
                            context,
                            listen: false,
                          );
                          final url = await provider.downloadBAP(bap.id);
                          if (url != null && context.mounted) {
                            final uri = Uri.parse(url);
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.inAppBrowserView,
                              );
                              if (context.mounted) {
                                AppSnackbar.showSuccess(
                                  context,
                                  'Berhasil mengunduh dokumen BAP PDF',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackbar.showError(
                                  context,
                                  'Gagal membuka link download',
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              AppSnackbar.showError(context, 'Gagal mengunduh PDF');
                            }
                          }
                        } else {
                          context.push('/tk/bap/form', extra: bap);
                        }
                      },
                      icon: isFinal ? Icons.picture_as_pdf_rounded : Icons.edit_rounded,
                      text: isFinal ? 'Download PDF' : 'Lengkapi Dokumen',
                      variant: isFinal ? BkuButtonVariant.danger : BkuButtonVariant.success,
                      height: 40,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TkBapModel bap) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            title: 'Hapus BAP?',
            content:
                'Apakah Anda yakin ingin menghapus BAP "${bap.namaKegiatan}"? Tindakan ini tidak dapat dibatalkan.',
            cancelText: '',
            confirmText: 'Tutup',
            isDestructive: true,
            onCancel: () {},
            onConfirm: () => Navigator.pop(context, true),
          ),
    );
    if (result == true && context.mounted) {
      await context.read<TkHealthProvider>().deleteBAP(bap.id);
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => CustomDialog(
                title: 'Berhasil',
                content: 'BAP berhasil dihapus',
                cancelText: '',
                confirmText: 'Tutup',
                isSuccess: true,
                onCancel: () {},
                onConfirm: () => Navigator.pop(context),
              ),
        );
      }
    }
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: AppColors.neutral200);
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMd.copyWith(
            fontWeight: FontWeight.w900,
            color: color ?? AppColors.neutral800,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    final isFinal = s == 'final' || s == 'selesai';

    final color = isFinal ? const Color(0xFF15803D) : const Color(0xFFB45309);
    final bg = isFinal ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7);
    final border = isFinal ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D);
    final text = isFinal ? 'Selesai' : 'Menunggu';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.br6,
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}
