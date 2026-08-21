import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_program_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_application_detail_screen.dart';

class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  int _activeTab = 0;
  String _selectedCategory = 'Semua';
  String _selectedTingkat = 'Semua';
  String _selectedSort = 'deadline_asc';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _sortLabels = {
    'deadline_asc': 'Deadline Terdekat',
    'amount_desc': 'Bantuan Terbesar',
    'kuota_desc': 'Kuota Terbanyak',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScholarshipProvider>().loadScholarships();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getDaysDiff(String deadlineRaw) {
    if (deadlineRaw.isEmpty) return 999;
    try {
      final deadlineDate = DateTime.parse(deadlineRaw);
      final now = DateTime.now();
      return deadlineDate.difference(now).inDays;
    } catch (_) {
      return 999;
    }
  }

  String _formatCurrency(String amountStr) {
    try {
      final amount = double.tryParse(amountStr) ?? 0.0;
      if (amount == 0.0) return 'Bantuan Biaya';
      final formatted = amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return "Rp $formatted";
    } catch (_) {
      return amountStr;
    }
  }

  Map<String, dynamic> _getCategoryStyle(String category, String? skema) {
    final cat = '$category ${skema ?? ''}'.toLowerCase();
    if (cat.contains('prestasi') || cat.contains('excellence')) {
      return {
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'border': const Color(0xFFFDE68A),
      };
    } else if (cat.contains('tahfidz') || cat.contains('religi')) {
      return {
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
      };
    } else if (cat.contains('impact') || cat.contains('ormawa') || cat.contains('mitra')) {
      return {
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
      };
    } else if (cat.contains('hope') || cat.contains('sosial') || cat.contains('bantuan')) {
      return {
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFF3E8FF),
        'border': const Color(0xFFE9D5FF),
      };
    } else {
      return {
        'color': const Color(0xFF475569),
        'bg': const Color(0xFFF1F5F9),
        'border': const Color(0xFFE2E8F0),
      };
    }
  }

  Map<String, dynamic> _getTingkatStyle(String? tingkat) {
    final t = (tingkat ?? 'universitas').toLowerCase();
    if (t == 'fakultas') {
      return {
        'label': 'Fakultas',
        'icon': Icons.domain_rounded,
        'color': const Color(0xFF1D4ED8),
        'bg': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
      };
    } else if (t == 'prodi') {
      return {
        'label': 'Prodi',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF047857),
        'bg': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
      };
    } else {
      return {
        'label': 'Univ',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF7E22CE),
        'bg': const Color(0xFFF3E8FF),
        'border': const Color(0xFFE9D5FF),
      };
    }
  }

  Map<String, dynamic> _getStatusConfig(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase().trim();
    if (status == 'diterima' || status.contains('lulus') || status.contains('disetujui')) {
      return {
        'label': 'Diterima',
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
        'icon': Icons.check_circle_rounded,
      };
    } else if (status == 'ditolak') {
      return {
        'label': 'Ditolak',
        'color': const Color(0xFFE11D48),
        'bg': const Color(0xFFFFF1F2),
        'border': const Color(0xFFFFE4E6),
        'icon': Icons.cancel_rounded,
      };
    } else if (status.contains('substansi') || status.contains('proses')) {
      return {
        'label': 'Seleksi Substansi',
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'border': const Color(0xFFFDE68A),
        'icon': Icons.sync_rounded,
      };
    } else if (status.contains('wawancara') || status.contains('evaluasi') || status.contains('review')) {
      return {
        'label': 'Evaluasi & Wawancara',
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
        'icon': Icons.fact_check_rounded,
      };
    } else if (status.contains('berkas')) {
      return {
        'label': 'Seleksi Berkas',
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
        'icon': Icons.inventory_2_rounded,
      };
    } else {
      return {
        'label': 'Menunggu',
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
        'icon': Icons.hourglass_top_rounded,
      };
    }
  }

  List<Scholarship> _filterAndSortKatalog(List<Scholarship> list) {
    var result = list.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.provider.toLowerCase().contains(_searchQuery.toLowerCase());

      final sCat = '${s.category} ${s.skema ?? ''} ${s.title}'.toLowerCase();
      final matchesCat = _selectedCategory == 'Semua' ||
          sCat.contains(_selectedCategory.toLowerCase());

      final sTingkat = (s.tingkat ?? 'universitas').toLowerCase();
      final matchesTingkat = _selectedTingkat == 'Semua' ||
          sTingkat == _selectedTingkat.toLowerCase();

      return matchesSearch && matchesCat && matchesTingkat;
    }).toList();

    if (_selectedSort == 'deadline_asc') {
      result.sort((a, b) => _getDaysDiff(a.deadline).compareTo(_getDaysDiff(b.deadline)));
    } else if (_selectedSort == 'amount_desc') {
      result.sort((a, b) {
        final amtA = double.tryParse(a.coverAmount) ?? 0;
        final amtB = double.tryParse(b.coverAmount) ?? 0;
        return amtB.compareTo(amtA);
      });
    } else if (_selectedSort == 'kuota_desc') {
      result.sort((a, b) {
        final kA = int.tryParse(a.kuota ?? '0') ?? 0;
        final kB = int.tryParse(b.kuota ?? '0') ?? 0;
        return kB.compareTo(kA);
      });
    }

    return result;
  }

  List<String> _extractCategories(List<Scholarship> list) {
    final Set<String> cats = {'Semua'};
    for (final s in list) {
      if (s.category.isNotEmpty) cats.add(s.category);
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScholarshipProvider>();

    final katalogList = _filterAndSortKatalog(provider.availableScholarships);
    final riwayatList = provider.appliedScholarships;
    final categories = _extractCategories(provider.availableScholarships);

    int totalProses = 0;
    int totalDiterima = 0;
    for (final r in riwayatList) {
      final st = (r.applicationStatus ?? '').toLowerCase();
      if (st.contains('diterima') || st.contains('lulus')) {
        totalDiterima++;
      } else if (!st.contains('ditolak')) {
        totalProses++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BkuStaticAppBar(
        title: 'Pusat Beasiswa & Bantuan',
        subtitle: 'Eksplorasi dan pantau pengajuan beasiswamu',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadScholarships(),
        color: const Color(0xFF1E40AF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsDashboard(
                totalTersedia: katalogList.length,
                totalDiajukan: riwayatList.length,
                totalProses: totalProses,
                totalDiterima: totalDiterima,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildTabBar(katalogCount: katalogList.length, riwayatCount: riwayatList.length),
              const SizedBox(height: AppSpacing.lg),

              if (provider.isLoading) ...[
                const BkuShimmerList(itemCount: 4, itemHeight: 140),
              ] else if (_activeTab == 0) ...[
                _buildKatalogSection(katalogList, categories),
              ] else ...[
                _buildRiwayatSection(riwayatList),
              ],
              const SizedBox(height: AppSpacing.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsDashboard({
    required int totalTersedia,
    required int totalDiajukan,
    required int totalProses,
    required int totalDiterima,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF475569), size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATISTIK MAHASISWA',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Text(
                    'Pengajuan Beasiswa Saya',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Tersedia', '$totalTersedia', const Color(0xFF0F172A), const Color(0xFFF1F5F9)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem('Diajukan', '$totalDiajukan', const Color(0xFF0F172A), const Color(0xFFF8FAFC)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem('Proses', '$totalProses', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem('Diterima', '$totalDiterima', const Color(0xFF059669), const Color(0xFFECFDF5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.4),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar({required int katalogCount, required int riwayatCount}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              title: 'Katalog Aktif',
              badgeCount: katalogCount,
              icon: Icons.grid_view_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              title: 'Riwayat Saya',
              badgeCount: riwayatCount,
              icon: Icons.history_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required int badgeCount,
    required IconData icon,
  }) {
    final isSelected = _activeTab == index;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFCBD5E1) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.5,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: const Color(0xFFE2E8F0)) : null,
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKatalogSection(List<Scholarship> list, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchAndSortBar(),
        const SizedBox(height: AppSpacing.md),
        _buildTingkatFilterBar(),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryFilterPills(categories),
        const SizedBox(height: AppSpacing.lg),

        if (list.isEmpty)
          _buildEmptyState('Tidak ada program beasiswa yang sesuai dengan filter pencarian.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) => _buildKatalogCard(list[index]),
          ),
      ],
    );
  }

  Widget _buildSearchAndSortBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama beasiswa / instansi...',
                hintStyle: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: Colors.grey.shade600),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: _showSortBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sort_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  _sortLabels[_selectedSort] ?? 'Urutkan',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTingkatFilterBar() {
    final tingkats = [
      {'id': 'Semua', 'label': 'Semua Tingkat', 'icon': Icons.apps_rounded},
      {'id': 'universitas', 'label': 'Universitas', 'icon': Icons.account_balance_rounded},
      {'id': 'fakultas', 'label': 'Fakultas', 'icon': Icons.domain_rounded},
      {'id': 'prodi', 'label': 'Prodi', 'icon': Icons.school_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tingkats.map((t) {
          final isSelected = _selectedTingkat == t['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedTingkat = t['id'] as String),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t['icon'] as IconData,
                      size: 13,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t['label'] as String,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilterPills(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.2 : 1.0,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKatalogCard(Scholarship scholarship) {
    final daysDiff = _getDaysDiff(scholarship.deadline);
    final isClosed = daysDiff < 0;
    final isApplied = scholarship.status.toLowerCase() == 'applied' || scholarship.applicationStatus != null;

    final catStyle = _getCategoryStyle(scholarship.category, scholarship.skema);
    final tingkatStyle = _getTingkatStyle(scholarship.tingkat);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: catStyle['bg'],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: catStyle['border']),
                      ),
                      child: Text(
                        scholarship.category.isNotEmpty ? scholarship.category : 'Umum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: catStyle['color'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: tingkatStyle['bg'],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: tingkatStyle['border']),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tingkatStyle['icon'], size: 10, color: tingkatStyle['color']),
                          const SizedBox(width: 3),
                          Text(
                            scholarship.tingkat == 'fakultas' && scholarship.fakultasNama != null
                                ? 'Fak. ${scholarship.fakultasNama}'
                                : (scholarship.tingkat == 'prodi' && scholarship.prodiNama != null
                                    ? 'Prodi ${scholarship.prodiNama}'
                                    : tingkatStyle['label']),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: tingkatStyle['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF2563EB)),
                            SizedBox(width: 3),
                            Text(
                              'Terdaftar',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isClosed
                      ? const Color(0xFFFFF1F2)
                      : (daysDiff <= 7 ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isClosed
                        ? const Color(0xFFFFE4E6)
                        : (daysDiff <= 7 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isClosed ? Icons.lock_clock_rounded : Icons.timer_outlined,
                      size: 11,
                      color: isClosed
                          ? const Color(0xFFE11D48)
                          : (daysDiff <= 7 ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isClosed ? 'Ditutup' : '$daysDiff Hari Tersisa',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isClosed
                            ? const Color(0xFFE11D48)
                            : (daysDiff <= 7 ? const Color(0xFFD97706) : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            scholarship.title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  scholarship.provider,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem('Nilai Bantuan', _formatCurrency(scholarship.coverAmount)),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Kuota',
                  scholarship.kuota != null && scholarship.kuota!.isNotEmpty
                      ? '${scholarship.kuota} Mahasiswa'
                      : 'Terbuka',
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Syarat IPK',
                  scholarship.minIpk != null && scholarship.minIpk!.isNotEmpty
                      ? 'Min. ${scholarship.minIpk}'
                      : 'Bebas',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {
                if (isApplied) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScholarshipApplicationDetailScreen(
                        scholarship: scholarship,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScholarshipProgramDetailScreen(
                        programId: int.tryParse(scholarship.id) ?? 0,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                foregroundColor: isApplied ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isApplied ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isApplied) ...[
                    const Icon(Icons.timeline_rounded, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Lihat Progress Pengajuan',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ] else ...[
                    const Text(
                      'Detail & Daftar',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRiwayatSection(List<Scholarship> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        'Belum ada riwayat pengajuan beasiswa.',
        actionText: 'Lihat Katalog Beasiswa',
        onAction: () => setState(() => _activeTab = 0),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => _buildRiwayatCard(list[index]),
    );
  }

  Widget _buildRiwayatCard(Scholarship scholarship) {
    final statusConfig = _getStatusConfig(scholarship.applicationStatus);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                scholarship.nomorPendaftaran != null && scholarship.nomorPendaftaran!.isNotEmpty
                    ? 'No: ${scholarship.nomorPendaftaran}'
                    : 'Pengajuan Beasiswa',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusConfig['bg'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusConfig['border']),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusConfig['icon'], size: 11, color: statusConfig['color']),
                    const SizedBox(width: 4),
                    Text(
                      statusConfig['label'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusConfig['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            scholarship.title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  scholarship.provider,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal Pengajuan', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    scholarship.tanggalPengajuan != null && scholarship.tanggalPengajuan!.isNotEmpty
                        ? scholarship.tanggalPengajuan!
                        : 'Baru Diajukan',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Bantuan Biaya', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(scholarship.coverAmount),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScholarshipApplicationDetailScreen(
                      scholarship: scholarship,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF1D4ED8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline_rounded, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Lihat Progress Pengajuan',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, {String? actionText, VoidCallback? onAction}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_outlined, size: 24, color: Color(0xFF475569)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 14, color: Color(0xFF0F172A)),
                    const SizedBox(width: 6),
                    Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Urutkan Beasiswa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: AppSpacing.md),
              ..._sortLabels.entries.map((e) {
                final isSelected = _selectedSort == e.key;
                return ListTile(
                  title: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0F172A)) : null,
                  onTap: () {
                    setState(() => _selectedSort = e.key);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
