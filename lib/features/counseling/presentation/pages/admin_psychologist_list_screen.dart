import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class AdminPsychologistListScreen extends StatefulWidget {
  const AdminPsychologistListScreen({super.key});

  @override
  State<AdminPsychologistListScreen> createState() =>
      _AdminPsychologistListScreenState();
}

class _AdminPsychologistListScreenState
    extends State<AdminPsychologistListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPsychologistProvider>().loadPsychologists();
    });
  }

  List<Map<String, dynamic>> _filtered(
    List<Map<String, dynamic>> list,
  ) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((p) {
      final name = (p['name'] ?? p['nama'] ?? '').toString().toLowerCase();
      final spesialis =
          (p['spesialisasi'] ?? p['specialization'] ?? '').toString().toLowerCase();
      return name.contains(q) || spesialis.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPsychologistProvider>(
      builder: (context, provider, _) {
        final filtered = _filtered(provider.psychologists);
        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Daftar Psikolog',
                variant: AppBarVariant.psychologist,
                isExpandable: false,
                showBackButton: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () => context.push('/counseling/admin/psikolog/create'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau spesialisasi...',
                      hintStyle: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral500,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.appColors.primary,
                      ),
                      filled: true,
                      fillColor: context.appColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(
                          color: AppColors.neutral500.withAlpha(40),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(
                          color: AppColors.neutral500.withAlpha(40),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(
                          color: context.appColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (provider.loading && provider.psychologists.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 100),
                  ),
                )
              else if (provider.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.error.withAlpha(80),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            provider.error!,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: provider.loadPsychologists,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            size: 64,
                            color: AppColors.neutral300,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Belum ada psikolog',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.s120,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _buildCard(filtered[index]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> psikolog) {
    final name = (psikolog['name'] ?? psikolog['nama'] ?? '-').toString();
    final spesialis =
        (psikolog['spesialisasi'] ?? psikolog['specialization'] ?? '-').toString();
    final email = (psikolog['email'] ?? '-').toString();
    final isAktif =
        psikolog['is_aktif'] ?? psikolog['IsAktif'] ?? psikolog['is_active'] ?? true;
    final id = (psikolog['ID'] ?? psikolog['id'] ?? '').toString();

    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return BkuCard(
      child: InkWell(
        borderRadius: AppRadius.radiusXl,
        onTap: () => context.push('/counseling/admin/psikolog/$id'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: context.appColors.primary.withAlpha(20),
                child: Text(
                  initials,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      spesialis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isAktif == true
                      ? AppColors.success.withAlpha(20)
                      : AppColors.neutral200,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAktif == true
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      size: 12,
                      color: isAktif == true
                          ? AppColors.success
                          : AppColors.neutral500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      isAktif == true ? 'Aktif' : 'Nonaktif',
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAktif == true
                            ? AppColors.success
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
