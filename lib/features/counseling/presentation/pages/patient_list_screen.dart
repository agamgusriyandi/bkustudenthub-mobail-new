import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:dio/dio.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/session_note_screen.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class PatientListScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  const PatientListScreen({super.key, this.showBackButton = true, this.onBack});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  int _currentPage = 1;
  final int _pageSize = 5;

  final List<Map<String, dynamic>> _statusFilters = [
    {
      'label': 'Semua',
      'icon': Icons.dashboard_rounded,
      'activeBg': AppColors.neutral50,
      'activeFg': AppColors.neutral900,
      'activeBorder': AppColors.neutral400,
    },
    {
      'label': 'Aktif',
      'icon': Icons.autorenew_rounded,
      'activeBg': AppColors.success.withAlpha(15),
      'activeFg': AppColors.success,
      'activeBorder': AppColors.success,
    },
    {
      'label': 'Selesai',
      'icon': Icons.task_alt_rounded,
      'activeBg': AppColors.info.withAlpha(15),
      'activeFg': AppColors.info,
      'activeBorder': AppColors.info,
    },
    {
      'label': 'Baru',
      'icon': Icons.fiber_new_rounded,
      'activeBg': AppColors.warning.withAlpha(15),
      'activeFg': AppColors.warning,
      'activeBorder': AppColors.warning,
    },
  ];

  String _sortOrder = 'Terbaru';
  String? _selectedProdi;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingProvider>().loadPatients();
      _startPolling();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<CounselingProvider>().loadPatients(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredPatients(
    List<Map<String, dynamic>> patients,
  ) {
    List<Map<String, dynamic>> result = List.from(patients);

    // Filter Status
    if (_selectedFilter != 'Semua') {
      result = result.where((p) => p['status'] == _selectedFilter).toList();
    }

    // Filter Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result =
          result.where((p) {
            final name = (p['name']?.toString() ?? '').toLowerCase();
            final nim = (p['nim']?.toString() ?? '').toLowerCase();
            return name.contains(q) || nim.contains(q);
          }).toList();
    }

    // Filter Prodi
    if (_selectedProdi != null && _selectedProdi!.isNotEmpty) {
      result =
          result
              .where((p) => p['faculty']?.toString() == _selectedProdi)
              .toList();
    }

    // Sort
    result.sort((a, b) {
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return _sortOrder == 'Terbaru' ? idB.compareTo(idA) : idA.compareTo(idB);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final patients = provider.patients;
        final filtered = _filteredPatients(patients);
        final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }
        final startIndex = filtered.isEmpty ? 0 : (_currentPage - 1) * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
        final pagedFiltered = filtered.isEmpty
            ? <Map<String, dynamic>>[]
            : filtered.sublist(startIndex, endIndex);

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Daftar Pasien',
                variant: AppBarVariant.psychologist,
                showBackButton: true,
                onBack:
                    widget.onBack ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                isExpandable: false,
                showNotification: true,
              ),
              SliverToBoxAdapter(
                child:
                    provider.patientsLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 90),
                        )
                        : provider.patientsError != null
                        ? _buildError(provider.patientsError!, provider)
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: _buildSummaryCard(filtered),
                            ),
                            const SizedBox(height: AppSpacing.s20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: _buildSearchAndFilter(patients),
                            ),
                            const SizedBox(height: AppSpacing.s20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Row(
                                children: [
                                  _buildSectionTitle('Daftar Mahasiswa'),
                                  const Spacer(),
                                  _buildExportButton(provider),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: _buildFilterChips(),
                            ),
                            if (totalPages > 1) ...[
                              const SizedBox(height: AppSpacing.md),
                              _buildTopPagination(totalPages),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: _buildPatientList(pagedFiltered, provider),
                            ),
                            const SizedBox(height: AppSpacing.s120),
                          ],
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton(CounselingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.error),
      ),
      child: IconButton(
        onPressed: () async {
          final url = await provider.exportPatientsRecapPDF();
          if (url != null && mounted) {
            try {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              );
              final response = await ApiClient().client.get<List<int>>(
                url,
                options: Options(responseType: ResponseType.bytes),
              );
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              final bytes = Uint8List.fromList(response.data!);
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'rekap_pasien.pdf',
              );
            } catch (e) {
              if (mounted) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst || route is! DialogRoute);
                String errorMsg = 'Gagal mengunduh PDF rekap pasien';
                if (e is DioException) {
                  var resData = e.response?.data;
                  if (resData is List<int>) {
                    try {
                      resData = jsonDecode(utf8.decode(resData));
                    } catch (_) {}
                  }
                  if (resData is Map && resData.containsKey('message')) {
                    errorMsg = resData['message'].toString();
                  } else if (e.response?.statusCode == 500) {
                    errorMsg = 'Server Error (500): Gagal generate PDF';
                  }
                }
                AppSnackbar.showError(context, errorMsg);
              }
            }
          } else {
            if (mounted) {
              AppSnackbar.showError(
                context,
                'Gagal mendapatkan tautan unduhan',
              );
            }
          }
        },
        icon: Icon(Icons.picture_as_pdf_rounded, color: context.appColors.error, size: 20),
        tooltip: 'Ekspor PDF Rekap Pasien',
      ),
    );
  }

  Widget _buildError(String message, CounselingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: AppSpacing.xl,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: context.appColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: provider.loadPatients,

              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(List<Map<String, dynamic>> allPatients) {
    final prodis =
        allPatients
            .map((p) => p['faculty']?.toString() ?? '')
            .where((f) => f.isNotEmpty)
            .toSet()
            .toList();
    prodis.sort();

    return Column(
      children: [
        BkuTextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            labelText: 'Cari pasien',
            hintText: 'Cari nama mahasiswa atau NIM...',
            hintStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.neutral500.withAlpha(150),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutral500),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral300.withAlpha(40)),
                ),
                child: DropdownButtonHideUnderline(
                  child: BkuDropdown<String>(
                    isExpanded: true,
                    value: _sortOrder,
                    icon: Icon(
                      Icons.sort_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral800,
                      fontWeight: FontWeight.w800,
                    ),
                    items:
                        ['Terbaru', 'Terlama'].map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _sortOrder = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral500.withAlpha(40)),
                ),
                child: DropdownButtonHideUnderline(
                  child: BkuDropdown<String?>(
                    isExpanded: true,
                    value: _selectedProdi,
                    hint: 'Seluruh Fakultas',
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral800,
                      fontWeight: FontWeight.w800,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: const Text('Seluruh Fakultas'),
                      ),
                      ...prodis.map((e) {
                        return DropdownMenuItem<String?>(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedProdi = val);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> filteredPatients) {
    final total = filteredPatients.length;
    final aktif = filteredPatients.where((p) => p['status'] == 'Aktif').length;
    final baru = filteredPatients.where((p) => p['status'] == 'Baru').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: context.appColors.success.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  size: 16,
                  color: context.appColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Text(
                'Ringkasan Analitik',
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildScrollableStatCard(
                'Total',
                '$total',
                context.appColors.info,
                AppColors.info.withAlpha(15),
                Icons.groups_rounded,
                true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildScrollableStatCard(
                'Aktif',
                '$aktif',
                context.appColors.success,
                AppColors.success.withAlpha(15),
                Icons.autorenew_rounded,
                false,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildScrollableStatCard(
                'Baru',
                '$baru',
                context.appColors.warning,
                AppColors.warning.withAlpha(15),
                Icons.fiber_new_rounded,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollableStatCard(
    String label,
    String value,
    Color primaryColor,
    Color bgColor,
    IconData icon,
    bool isPrimary,
  ) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final filterLabel = filter['label'] as String;
          final isSelected = _selectedFilter == filterLabel;
          final activeBg = filter['activeBg'] as Color;
          final activeFg = filter['activeFg'] as Color;
          final activeBorder = filter['activeBorder'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filterLabel;
                  _currentPage = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : context.appColors.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: isSelected ? activeBorder : AppColors.neutral200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: activeFg.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected ? activeFg : AppColors.neutral500,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      filterLabel,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? activeFg : AppColors.neutral600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPagination(int totalPages) {
    final canPrev = _currentPage > 1;
    final canNext = _currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.br14,
          border: Border.all(color: AppColors.neutral300),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: canPrev ? AppColors.neutral50 : AppColors.neutral50,
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canPrev ? () => setState(() => _currentPage--) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 16,
                        color: canPrev ? AppColors.neutral800 : AppColors.neutral400,
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canPrev ? AppColors.neutral800 : AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Halaman $_currentPage dari $totalPages',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: canNext ? AppColors.neutral50 : AppColors.neutral50,
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canNext ? () => setState(() => _currentPage++) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canNext ? AppColors.neutral800 : AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: canNext ? AppColors.neutral800 : AppColors.neutral400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList(
    List<Map<String, dynamic>> list,
    CounselingProvider provider,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Tidak Ada Data',
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _searchQuery.isNotEmpty || _selectedProdi != null
                    ? 'Tidak ada mahasiswa yang cocok dengan filter.'
                    : 'Belum ada data pasien saat ini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildPatientCard(list[index], provider),
    );
  }

  Widget _buildPatientCard(
    Map<String, dynamic> p,
    CounselingProvider provider,
  ) {
    final status = p['status']?.toString() ?? 'Baru';
    final statusColor =
        status == 'Aktif'
            ? AppColors.success
            : status == 'Baru'
            ? AppColors.warning
            : status == 'Selesai'
            ? context.appColors.info
            : status == 'Perlu Perhatian'
            ? AppColors.error
            : AppColors.neutral600;

    final name = p['name']?.toString() ?? '-';
    final nim = p['nim']?.toString() ?? '-';
    final prodi = p['program_studi']?.toString() ?? '';
    // //     final semester = p['semester']?.toString() ?? '';
    final sessions = p['sessions']?.toString() ?? '0';
    final lastVisit = p['lastVisit']?.toString() ?? '-';
    final id = p['id']?.toString() ?? '';

    final avatarUrl = () {
      final possibleKeys = [
        'FotoURL',
        'foto_url',
        'Foto',
        'foto',
        'FotoProfil',
        'foto_profil',
        'mahasiswa_avatar',
        'avatar_url',
      ];
      for (final key in possibleKeys) {
        if (p[key] != null &&
            p[key].toString().isNotEmpty &&
            p[key].toString() != '-') {
          return p[key].toString();
        }
      }
      final mhsData =
          p['mahasiswa'] ??
          p['Mahasiswa'] ??
          p['pasien'] ??
          p['Pasien'] ??
          p['user'] ??
          p['User'] ??
          p['student'] ??
          p['Student'];
      if (mhsData is Map) {
        for (final key in possibleKeys) {
          if (mhsData[key] != null &&
              mhsData[key].toString().isNotEmpty &&
              mhsData[key].toString() != '-') {
            return mhsData[key].toString();
          }
        }
        final user =
            mhsData['Pengguna'] ??
            mhsData['pengguna'] ??
            mhsData['User'] ??
            mhsData['user'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null &&
                user[key].toString().isNotEmpty &&
                user[key].toString() != '-') {
              return user[key].toString();
            }
          }
        }
      }
      return null;
    }();

    // Color from name hash
    const colors = [
      AppColors.warning,
      AppColors.info,
      AppColors.neutral700,
      AppColors.neutral500,
      AppColors.error,
    ];
    final color = colors[name.length % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral500.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.radiusMd,
        child: InkWell(
          onTap: () => _showPatientDetails(p, provider, id),
          borderRadius: AppRadius.radiusMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Initial
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withAlpha(30),
                          width: 1.5,
                        ),
                        image:
                            avatarUrl != null && avatarUrl.isNotEmpty
                                ? DecorationImage(
                                  image: NetworkImage(
                                    ApiGate.getImageUrl(avatarUrl),
                                  ),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          avatarUrl != null && avatarUrl.isNotEmpty
                              ? null
                              : Center(
                                child: Text(
                                  name.isNotEmpty ? name[0] : '?',
                                  style: AppTextStyles.titleLg.copyWith(
                                    color: color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Main Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral200,
                                  borderRadius: AppRadius.radiusXs,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.assignment_ind_outlined,
                                      size: 10,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      status,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: statusColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // NIM & Prodi
                          Text(
                            '$nim${prodi.isNotEmpty ? ' • $prodi' : ''}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Visit Info
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Text(
                                lastVisit,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Text(
                                '$sessions Sesi',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.neutral900,
      ),
    );
  }

  // _buildFilterAction() removed

  void _showPatientDetails(
    Map<String, dynamic> p,
    CounselingProvider provider,
    String id,
  ) {
    // Load medical record when opening details
    provider.loadMedicalRecord(id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _PatientDetailsSheet(patient: p, provider: provider),
    );
  }
}

// ─── Patient Details Bottom Sheet ────────────────────────────────────────────

class _PatientDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> patient;
  final CounselingProvider provider;

  const _PatientDetailsSheet({required this.patient, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius36)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.neutral500.withAlpha(50),
              borderRadius: AppRadius.radiusMd,
            ),
          ),
          Expanded(
            child: Consumer<CounselingProvider>(
              builder: (context, prov, _) {
                final record = prov.medicalRecord;
                final records = record['records'];
                final List<Map<String, dynamic>> visits =
                    records is List ? records.cast<Map<String, dynamic>>() : [];

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoGrid(context),
                    const SizedBox(height: AppSpacing.lg),
                    prov.medicalRecordLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 90),
                        )
                        : _buildTimelineSection(context, visits),
                  ],
                );
              },
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = patient['name']?.toString() ?? '-';
    final faculty = patient['faculty']?.toString() ?? '';
    final prodi = patient['program_studi']?.toString() ?? '';
    final colors = [
      AppColors.warning,
      AppColors.info,
      AppColors.info,
      AppColors.success,
    ];
    final color = colors[name.length % colors.length];

    final nim = patient['nim']?.toString() ?? '-';

    final avatarUrl = () {
      final possibleKeys = [
        'FotoURL',
        'foto_url',
        'Foto',
        'foto',
        'FotoProfil',
        'foto_profil',
        'mahasiswa_avatar',
        'avatar_url',
      ];
      for (final key in possibleKeys) {
        if (patient[key] != null &&
            patient[key].toString().isNotEmpty &&
            patient[key].toString() != '-') {
          return patient[key].toString();
        }
      }
      final mhsData =
          patient['mahasiswa'] ??
          patient['Mahasiswa'] ??
          patient['pasien'] ??
          patient['Pasien'] ??
          patient['user'] ??
          patient['User'] ??
          patient['student'] ??
          patient['Student'];
      if (mhsData is Map) {
        for (final key in possibleKeys) {
          if (mhsData[key] != null &&
              mhsData[key].toString().isNotEmpty &&
              mhsData[key].toString() != '-') {
            return mhsData[key].toString();
          }
        }
        final user =
            mhsData['Pengguna'] ??
            mhsData['pengguna'] ??
            mhsData['User'] ??
            mhsData['user'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null &&
                user[key].toString().isNotEmpty &&
                user[key].toString() != '-') {
              return user[key].toString();
            }
          }
        }
      }
      return null;
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Premium Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(30), width: 4),
            image:
                avatarUrl != null && avatarUrl.isNotEmpty
                    ? DecorationImage(
                      image: NetworkImage(ApiGate.getImageUrl(avatarUrl)),
                      fit: BoxFit.cover,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? null
                  : Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: AppTextStyles.titleLg.copyWith(
                        color: color,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Name
        Text(
          name,
          style: AppTextStyles.titleLg.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.neutral900,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s2),

        // NIM
        BkuCard(
          backgroundColor: AppColors.neutral200.withAlpha(150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 6,
          ),
          child: Text(
            nim,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s2),

        // Faculty / Prodi
        Text(
          [faculty, prodi].where((s) => s.isNotEmpty).join(' • '),
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final sessions = patient['sessions']?.toString() ?? '0';
    final status = patient['status']?.toString() ?? '-';
    final lastVisit = patient['lastVisit']?.toString() ?? '-';

    return BkuCard(
      backgroundColor: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Total Sesi', '${sessions}x'),
          _buildStatItem('Status', status),
          _buildStatItem('Kunjungan', lastVisit),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.titleSm.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral800,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    List<Map<String, dynamic>> visits,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: themeProvider.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 16,
                color: themeProvider.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Riwayat Kunjungan',
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (visits.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                'Belum ada catatan sesi',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ),
          )
        else
          ...visits.asMap().entries.map((entry) {
            final v = entry.value;
            final isLast = entry.key == visits.length - 1;
            return _buildTimelineItem(context, v, isLast);
          }),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> v,
    bool isLast,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    final date = v['date']?.toString() ?? '-';
    final type = v['type']?.toString() ?? 'Sesi Konseling';
    final complaint = v['complaint']?.toString() ?? '';
    final mood = v['mood']?.toString() ?? '';
    final note = complaint.isNotEmpty ? complaint : mood;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Timeline Node & Line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themeProvider.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primary.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.history_edu_rounded,
                    color: context.appColors.onPrimary,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      color: themeProvider.primary.withAlpha(30),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Timeline Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(                  color: AppColors.neutral300.withAlpha(20)),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.onSurface.withAlpha(3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date & Download
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: AppColors.neutral600,
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              date,
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (v['id'] != null)
                          GestureDetector(
                            onTap: () async {
                              final provider =
                                  context.read<CounselingProvider>();
                              final url = await provider.exportSessionNotePDF(
                                v['id'].toString(),
                              );
                              if (url != null && context.mounted) {
                                try {
                                  BkuLoadingDialog.show(context, message: 'Mengunduh catatan...');
                                  final response = await ApiClient().client
                                      .get<List<int>>(
                                        url,
                                        options: Options(
                                          responseType: ResponseType.bytes,
                                        ),
                                      );
                                    if (!context.mounted) return;
                                    BkuLoadingDialog.hide(context);
                                  final bytes = Uint8List.fromList(
                                    response.data!,
                                  );
                                  await Printing.sharePdf(
                                    bytes: bytes,
                                    filename: 'session_note_${v['id']}.pdf',
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).popUntil(
                                      (route) =>
                                          route.isFirst ||
                                          route is! DialogRoute,
                                    );
                                    String errorMsg = 'Gagal mengunduh PDF';
                                    if (e is DioException) {
                                      var resData = e.response?.data;
                                      if (resData is List<int>) {
                                        try {
                                          resData = jsonDecode(
                                            utf8.decode(resData),
                                          );
                                        } catch (_) {}
                                      }
                                      if (resData is Map &&
                                          resData.containsKey('message')) {
                                        errorMsg =
                                            resData['message'].toString();
                                      } else if (e.response?.statusCode ==
                                          500) {
                                        errorMsg =
                                            'Server Error (500): Gagal generate PDF';
                                      }
                                    }
                                    AppSnackbar.showError(context, errorMsg);
                                  }
                                }
                              }
                            },
                            child: Container(
                              padding: AppSpacing.padding6,
                              decoration: BoxDecoration(
                                color: themeProvider.primary.withAlpha(15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.download_rounded,
                                color: themeProvider.primary,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Title
                    Text(
                      type,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                    ),
                    // Note Box
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          note,
                          style: AppTextStyles.bodySm.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final name = patient['name']?.toString() ?? '-';
    final id = patient['id']?.toString() ?? '';
    final sessions = int.tryParse(patient['sessions']?.toString() ?? '0') ?? 0;
    final status = patient['status']?.toString() ?? 'Baru';
    final hasActiveBooking = patient['has_active_booking'] == true;
    final isLocked = status == 'Selesai' && !hasActiveBooking;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(30),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Kasus/Episode selesai. Mahasiswa harus membuat booking baru untuk memulai sesi konseling baru.',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Main Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.neutral300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                      ),
                    ),
                    child: Text(
                      'Tutup',
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        isLocked
                            ? null
                            : () {
                              context.pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SessionNoteScreen(
                                        studentName: name,
                                        studentId: id,
                                        sessionNumber: sessions + 1,
                                      ),
                                ),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.neutral200,
                      disabledForegroundColor: AppColors.neutral500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Buat Catatan Sesi',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
