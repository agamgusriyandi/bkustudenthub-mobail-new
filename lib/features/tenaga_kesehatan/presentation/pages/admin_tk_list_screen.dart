import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tenaga_kesehatan_provider.dart';

class AdminTkListScreen extends StatefulWidget {
  const AdminTkListScreen({super.key});

  @override
  State<AdminTkListScreen> createState() => _AdminTkListScreenState();
}

class _AdminTkListScreenState extends State<AdminTkListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenagaKesehatanProvider>().loadTenagaKesehatanList();
    });
  }

  List<TenagaKesehatan> _filterList(List<TenagaKesehatan> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((tk) {
      final name = (tk.nama ?? '').toLowerCase();
      final spec = (tk.spesialisasi ?? '').toLowerCase();
      return name.contains(q) || spec.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Daftar Tenaga Kesehatan',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
            onPressed: () => context.push('/tk/admin/create'),
          ),
        ],
      ),
      body: Consumer<TenagaKesehatanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tkList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 5, itemHeight: 80),
            );
          }

          final filteredList = _filterList(provider.tkList);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: BkuTextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  hint: 'Cari tenaga kesehatan...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 64,
                              color: AppColors.neutral300,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum ada data Tenaga Kesehatan',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tekan tombol + untuk menambah',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadTenagaKesehatanList(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) =>
                              _buildTkCard(filteredList[index], provider),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTkCard(TenagaKesehatan tk, TenagaKesehatanProvider provider) {
    final isActive = tk.isAktif ?? true;
    final initials = (tk.nama ?? 'TK')
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isActive
                ? context.appColors.success.withAlpha(30)
                : AppColors.neutral200,
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color:
                    isActive ? context.appColors.success : AppColors.neutral500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tk.nama ?? '-',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tk.spesialisasi ?? '-',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tk.lokasi ?? '-',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.neutral500),
            onSelected: (val) {
              if (val == 'edit') {
                context.push('/tk/admin/edit?id=${tk.id}');
              } else if (val == 'delete' && tk.id != null) {
                _confirmDelete(tk, provider);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TenagaKesehatan tk, TenagaKesehatanProvider provider) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Tenaga Kesehatan?',
      message: 'Apakah Anda yakin ingin menghapus ${tk.nama ?? "TK ini"}?',
      type: BkuDialogType.warning,
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => context.pop(),
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        context.pop();
        final success = await provider.deleteTenagaKesehatan(tk.id!);
        if (mounted) {
          if (success) {
            AppSnackbar.showSuccess(context, 'Tenaga kesehatan berhasil dihapus');
          } else {
            AppSnackbar.showError(context, provider.error ?? 'Gagal menghapus');
          }
        }
      },
    );
  }
}
