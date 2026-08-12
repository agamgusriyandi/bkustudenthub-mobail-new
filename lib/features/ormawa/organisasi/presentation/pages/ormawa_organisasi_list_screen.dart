import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/create_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/ormawa_organisasi_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/edit_organisasi_screen.dart';

class OrmawaOrganisasiListScreen extends StatefulWidget {
  const OrmawaOrganisasiListScreen({super.key});

  @override
  State<OrmawaOrganisasiListScreen> createState() => _OrmawaOrganisasiListScreenState();
}

class _OrmawaOrganisasiListScreenState extends State<OrmawaOrganisasiListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchOrganisasi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrmawaOrganisasi> _getFiltered(List<OrmawaOrganisasi> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((o) {
      return o.nama.toLowerCase().contains(_searchQuery) ||
          o.deskripsi.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _confirmDelete(OrmawaOrganisasi org) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Organisasi',
      message: 'Apakah Anda yakin ingin menghapus\n${org.nama}?',
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteOrganisasi(org.id.toString());
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Organisasi berhasil dihapus');
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filtered = _getFiltered(provider.organisasiList);

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: RefreshIndicator(
            onRefresh: () => provider.fetchOrganisasi(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Manajemen Organisasi',
                  subtitle: 'Database Organisasi',
                  expandedHeight: 115.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                if (provider.isLoading)
                  SliverFillRemaining(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        left: AppSpacing.s20,
                        right: AppSpacing.s20,
                        bottom: AppSpacing.s20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(provider),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSearchBar(),
                          const SizedBox(height: AppSpacing.s20),
                          if (filtered.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final org = filtered[index];
                                return _buildOrganisasiCard(org, provider);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrganisasiScreen()),
              );
            },
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.add_business_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Tambah Organisasi',
              style: TextStyle(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(OrmawaProvider provider) {
    final total = provider.organisasiList.length;
    final aktif = provider.organisasiList.where((o) => o.status.toLowerCase() == 'aktif').length;

    return BkuCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, color: context.appColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'STATISTIK ORGANISASI',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(total.toString(), 'Total'),
              _buildSummaryItem(aktif.toString(), 'Aktif'),
              _buildSummaryItem((total - aktif).toString(), 'Nonaktif'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.neutral500,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: BkuTextField(
        controller: _searchController,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: 'Cari organisasi...',
          prefixIcon: Icon(Icons.search_rounded, color: context.appColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.onSurface.withAlpha(10), blurRadius: 20),
                ],
              ),
              child: const Icon(Icons.business_outlined, size: 64, color: AppColors.neutral400),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Belum ada organisasi',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tambahkan organisasi baru untuk\nmemulai mengelola data.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganisasiCard(OrmawaOrganisasi org, OrmawaProvider provider) {
    final isAktif = org.status.toLowerCase() == 'aktif';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrmawaOrganisasiDetailScreen(organisasi: org)),
        );
      },
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.appColors.primary.withAlpha(15),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: context.appColors.primary.withAlpha(30)),
              ),
              child: Icon(
                Icons.business_rounded,
                color: context.appColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          org.nama,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.neutral500),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18, color: AppColors.info),
                                SizedBox(width: AppSpacing.s10),
                                Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                SizedBox(width: AppSpacing.s10),
                                Text('Hapus', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (val) {
                          if (val == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditOrganisasiScreen(organisasi: org)),
                            );
                          } else if (val == 'delete') {
                            _confirmDelete(org);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  if (org.deskripsi.isNotEmpty)
                    Text(
                      org.deskripsi,
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.s10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: isAktif
                              ? AppColors.success.withAlpha(15)
                              : AppColors.neutral500.withAlpha(15),
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(
                            color: isAktif
                                ? AppColors.success.withAlpha(30)
                                : AppColors.neutral500.withAlpha(30),
                          ),
                        ),
                        child: Text(
                          org.status,
                          style: AppTextStyles.labelSm.copyWith(
                            color: isAktif ? AppColors.success : AppColors.neutral500,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (org.tahunBerdiri != null && org.tahunBerdiri!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: context.appColors.primary.withAlpha(15),
                            borderRadius: AppRadius.radiusSm,
                            border: Border.all(color: context.appColors.primary.withAlpha(30)),
                          ),
                          child: Text(
                            'Berdiri ${org.tahunBerdiri}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
