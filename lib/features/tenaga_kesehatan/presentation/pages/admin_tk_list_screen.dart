import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';

class AdminTkListScreen extends StatefulWidget {
  const AdminTkListScreen({super.key});

  @override
  State<AdminTkListScreen> createState() => _AdminTkListScreenState();
}

class _AdminTkListScreenState extends State<AdminTkListScreen> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<TenagaKesehatan> _tkList = [];

  @override
  void initState() {
    super.initState();
    _loadTkList();
  }

  Future<void> _loadTkList() async {
    setState(() => _isLoading = true);
    // Simulated - in production would call repository
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      _tkList = [];
    });
  }

  List<TenagaKesehatan> get _filteredList {
    if (_searchQuery.isEmpty) return _tkList;
    final q = _searchQuery.toLowerCase();
    return _tkList.where((tk) {
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
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 5, itemHeight: 80),
            )
          : Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: BkuTextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    hint: 'Cari tenaga kesehatan...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutral500),
                  ),
                ),

                // List
                Expanded(
                  child: _filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medical_services_outlined, size: 64, color: AppColors.neutral300),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Belum ada data TK',
                                style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Tekan tombol + untuk menambah',
                                style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTkList,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) => _buildTkCard(_filteredList[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTkCard(TenagaKesehatan tk) {
    final isActive = tk.isAktif ?? true;
    final initials = (tk.nama ?? 'TK').split(' ').map((s) => s.isNotEmpty ? s[0] : '').join();

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
                color: isActive ? context.appColors.success : AppColors.neutral500,
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
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tk.spesialisasi ?? '-',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tk.lokasi ?? '-',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? context.read<ThemeProvider>().colors.success.withAlpha(20)
                  : AppColors.neutral200,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Text(
              isActive ? 'AKTIF' : 'NONAKTIF',
              style: AppTextStyles.labelSm.copyWith(
                color: isActive ? context.read<ThemeProvider>().colors.success : AppColors.neutral500,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
