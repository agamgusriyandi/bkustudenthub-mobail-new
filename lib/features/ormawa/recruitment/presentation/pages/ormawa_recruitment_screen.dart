import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';

import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

class OrmawaRecruitmentScreen extends StatefulWidget {
  const OrmawaRecruitmentScreen({super.key});

  @override
  State<OrmawaRecruitmentScreen> createState() =>
      _OrmawaRecruitmentScreenState();
}

class _OrmawaRecruitmentScreenState extends State<OrmawaRecruitmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFabExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().getRecruitmentApplicants();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showDetailModal(BuildContext context, Map<String, dynamic> applicant) {
    final provider = context.read<OrmawaProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RecruitmentApplicantDetailModal(
            applicant: RecruitmentApplicant(
              name: applicant['name'] ?? '',
              nim: applicant['nim'] ?? '',
              prodi: applicant['prodi'] ?? '',
              ipk: double.tryParse(applicant['ipk']?.toString() ?? '0') ?? 0.0,
              divisi1: applicant['divisi1'] ?? '',
              divisi2: applicant['divisi2'] ?? '',
              status: applicant['status'] ?? 'pending',
              alasan: applicant['alasan'] ?? '',
              cvUrl: applicant['cv_url'] ?? applicant['CVURL'] ?? '',
              customAnswers:
                  applicant['custom_answers'] is Map
                      ? Map<String, dynamic>.from(
                        applicant['custom_answers'] as Map,
                      )
                      : {},
            ),
            formFields: provider.recruitmentFormFields,
            onAccept: () async {
              try {
                await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
                  applicant['id'].toString(),
                  'accepted',
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context, 'Gagal menerima: $e');
                }
              }
            },
            onReject: () async {
              try {
                await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
                  applicant['id'].toString(),
                  'rejected',
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context, 'Gagal menolak: $e');
                }
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      floatingActionButton: _buildExpandableFab(),
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final allApplicants = provider.recruitmentApplicants;
          final applicants =
              allApplicants.where((a) {
                final matchesSearch =
                    _searchQuery.isEmpty ||
                    (a['name']?.toString().toLowerCase().contains(
                          _searchQuery,
                        ) ??
                        false) ||
                    (a['nim']?.toString().toLowerCase().contains(
                          _searchQuery,
                        ) ??
                        false);

                final status =
                    (a['status'] ?? 'pending').toString().toLowerCase();
                final matchesStatus =
                    _selectedStatusFilter == 'Semua' ||
                    (_selectedStatusFilter == 'Menunggu' &&
                        (status == 'pending' || status == 'menunggu')) ||
                    (_selectedStatusFilter == 'Diterima' &&
                        (status == 'accepted' || status == 'aktif')) ||
                    (_selectedStatusFilter == 'Ditolak' &&
                        (status == 'rejected' || status == 'ditolak'));

                return matchesSearch && matchesStatus;
              }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.getRecruitmentApplicants(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'OPEN RECRUITMENT',
                  subtitle: 'KELOLA PENDAFTARAN ANGGOTA BARU',
                  expandedHeight: 130.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: OrmawaListHeader(
                      title: 'DAFTAR PENDAFTAR (${applicants.length})',
                      searchHint: 'Cari nama atau NIM...',
                      searchController: _searchController,
                      onRefresh: () => provider.getRecruitmentApplicants(),
                      onFilterTap: _showFilterSheet,
                      onChanged:
                          (value) => setState(
                            () => _searchQuery = value.toLowerCase(),
                          ),
                    ),
                  ),
                ),
                if (provider.isLoading && allApplicants.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                    ),
                  )
                else if (applicants.isEmpty)
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_alt_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Belum Ada Pendaftar',
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daftar mahasiswa yang melamar ke ORMAWA ini akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  context
                                      .watch<ThemeProvider>()
                                      .colors
                                      .infoContainer,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: context
                                    .watch<ThemeProvider>()
                                    .colors
                                    .info
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color:
                                      context
                                          .watch<ThemeProvider>()
                                          .colors
                                          .info,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pastikan status Open Recruitment sudah dibuka pada menu Pengaturan.',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: AppColors.onInfoContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final applicant = applicants[index];
                        return RecruitmentApplicantCard(
                          applicant: RecruitmentApplicant(
                            name: applicant['name'] ?? '',
                            nim: applicant['nim'] ?? '',
                            prodi: applicant['prodi'] ?? '',
                            ipk:
                                double.tryParse(
                                  applicant['ipk']?.toString() ?? '0',
                                ) ??
                                0.0,
                            divisi1: applicant['divisi1'] ?? '',
                            divisi2: applicant['divisi2'] ?? '',
                            status: applicant['status'] ?? 'pending',
                            alasan: applicant['alasan'] ?? '',
                            cvUrl:
                                applicant['cv_url'] ?? applicant['CVURL'] ?? '',
                            customAnswers:
                                applicant['custom_answers'] is Map
                                    ? Map<String, dynamic>.from(
                                      applicant['custom_answers'] as Map,
                                    )
                                    : {},
                          ),
                          onReview: () => _showDetailModal(context, applicant),
                        );
                      }, childCount: applicants.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabOption(
            icon: Icons.history_rounded,
            label: 'Riwayat Keputusan',
            color: AppColors.success,
            onTap: () {
              _toggleFab();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecruitmentHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFabOption(
            icon: Icons.list_alt_rounded,
            label: 'Form Builder',
            color: Colors.purple,
            onTap: () {
              _toggleFab();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecruitmentFormScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFabOption(
            icon: Icons.settings_rounded,
            label: 'Pengaturan',
            color: AppColors.info,
            onTap: () {
              _toggleFab();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecruitmentSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton.extended(
          onPressed: _toggleFab,
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
            color: Colors.white,
          ),
          label: Text(
            _isFabExpanded ? 'Tutup' : 'Menu Utama',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusSm,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: label, // Prevent hero animation conflicts
          mini: true,
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Status',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...['Semua', 'Menunggu', 'Diterima', 'Ditolak'].map(
                (status) => ListTile(
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight:
                          _selectedStatusFilter == status
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          _selectedStatusFilter == status
                              ? Theme.of(context).colorScheme.primary
                              : AppColors.neutral900,
                    ),
                  ),
                  trailing:
                      _selectedStatusFilter == status
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : Icon(
                            Icons.circle_outlined,
                            color: AppColors.neutral300,
                          ),
                  onTap: () {
                    setState(() => _selectedStatusFilter = status);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class RecruitmentSettingsScreen extends StatefulWidget {
  const RecruitmentSettingsScreen({super.key});

  @override
  State<RecruitmentSettingsScreen> createState() =>
      _RecruitmentSettingsScreenState();
}

class _RecruitmentSettingsScreenState extends State<RecruitmentSettingsScreen> {
  bool _isOpenRecruitment = false;
  DateTime? _startDate;
  DateTime? _endDate;
  double _minIpk = 2.5;
  final _requirementsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentSettings();

    final settings = provider.recruitmentSettings;
    if (settings.isNotEmpty && mounted) {
      setState(() {
        _isOpenRecruitment = settings['isActive'] ?? false;
        _minIpk =
            double.tryParse(settings['minIpk']?.toString() ?? '2.5') ?? 2.5;
        _requirementsController.text = settings['requirements'] ?? '';

        if (settings['startDate'] != null) {
          _startDate = DateTime.tryParse(settings['startDate'].toString());
        }
        if (settings['endDate'] != null) {
          _endDate = DateTime.tryParse(settings['endDate'].toString());
        }
      });
    } else {
      _requirementsController.text =
          'Mahasiswa aktif\nMinimal IPK 2.50\nMengisi formulir pendaftaran';
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await context.read<OrmawaProvider>().updateRecruitmentSettings({
        'isActive': _isOpenRecruitment,
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'minIpk': _minIpk,
        'requirements': _requirementsController.text,
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengaturan berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      _isOpenRecruitment
                          ? [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ]
                          : [AppColors.neutral100, AppColors.neutral200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusXl,
                boxShadow:
                    _isOpenRecruitment
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                        : null,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendaftaran Anggota',
                          style: AppTextStyles.titleSm.copyWith(
                            color:
                                _isOpenRecruitment
                                    ? Colors.white
                                    : AppColors.neutral800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isOpenRecruitment
                              ? 'Pendaftaran saat ini sedang DIBUKA'
                              : 'Pendaftaran saat ini sedang DITUTUP',
                          style: AppTextStyles.labelMd.copyWith(
                            color:
                                _isOpenRecruitment
                                    ? Colors.white70
                                    : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOpenRecruitment,
                    onChanged:
                        (value) => setState(() => _isOpenRecruitment = value),
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.greenAccent.shade400,
                    inactiveThumbColor: AppColors.neutral400,
                    inactiveTrackColor: AppColors.neutral300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Periode & Syarat',
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Mulai',
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Selesai',
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral200.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'IPK Minimal',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          _minIpk.toStringAsFixed(2),
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      thumbColor: Theme.of(context).colorScheme.primary,
                      overlayColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _minIpk,
                      min: 0,
                      max: 4,
                      divisions: 40,
                      onChanged: (value) => setState(() => _minIpk = value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral200.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.2),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Persyaratan Utama',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _requirementsController,
                    maxLines: 4,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan persyaratan pendaftaran...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral400,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral100.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,

                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Pengaturan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class RecruitmentDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const RecruitmentDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : 'Pilih Tanggal',
                  style: AppTextStyles.bodyMd.copyWith(
                    color:
                        date != null
                            ? AppColors.neutral900
                            : AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecruitmentFormScreen extends StatefulWidget {
  const RecruitmentFormScreen({super.key});

  @override
  State<RecruitmentFormScreen> createState() => _RecruitmentFormScreenState();
}

class _RecruitmentFormScreenState extends State<RecruitmentFormScreen> {
  final List<RecruitmentFormField> _fields = [];
  bool _isLoading = false;

  final List<String> _fieldTypes = [
    'Teks Singkat',
    'Paragraf',
    'Dropdown',
    'Pilihan Ganda',
    'Upload File',
  ];

  @override
  void initState() {
    super.initState();
    _loadFormFields();
  }

  Future<void> _loadFormFields() async {
    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentFormFields();

    final fields = provider.recruitmentFormFields;
    if (fields.isNotEmpty && mounted) {
      setState(() {
        _fields.clear();
        for (var i = 0; i < fields.length; i++) {
          final f = fields[i];
          String displayType = 'Teks Singkat';
          final typeVal = (f['type'] ?? '').toString().toLowerCase();
          switch (typeVal) {
            case 'text':
              displayType = 'Teks Singkat';
              break;
            case 'paragraph':
              displayType = 'Paragraf';
              break;
            case 'select':
              displayType = 'Dropdown';
              break;
            case 'checkbox':
              displayType = 'Pilihan Ganda';
              break;
            case 'file':
              displayType = 'Upload File';
              break;
            default:
              if (_fieldTypes.contains(f['type'])) {
                displayType = f['type'];
              } else {
                displayType = 'Teks Singkat';
              }
          }
          _fields.add(
            RecruitmentFormField(
              id: i,
              label: f['label'] ?? '',
              type: displayType,
              options: f['options'] ?? '',
              required: f['required'] ?? false,
            ),
          );
        }
      });
    }
  }

  void _removeField(int index) {
    setState(() => _fields.removeAt(index));
  }

  Future<void> _saveForm() async {
    setState(() => _isLoading = true);
    try {
      final fieldsData =
          _fields.map((f) {
            String dbType = 'text';
            switch (f.type) {
              case 'Teks Singkat':
                dbType = 'text';
                break;
              case 'Paragraf':
                dbType = 'paragraph';
                break;
              case 'Dropdown':
                dbType = 'select';
                break;
              case 'Pilihan Ganda':
                dbType = 'checkbox';
                break;
              case 'Upload File':
                dbType = 'file';
                break;
              default:
                dbType = f.type.toLowerCase();
            }
            return {
              'label': f.label,
              'type': dbType,
              'options': f.options,
              'required': f.required,
            };
          }).toList();

      await context.read<OrmawaProvider>().saveRecruitmentFormFields(
        fieldsData,
      );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Form berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddFieldSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              Text(
                'Pilih Jenis Pertanyaan',
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._fieldTypes.map(
                (type) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Icon(
                      type == 'Teks Singkat'
                          ? Icons.short_text_rounded
                          : type == 'Paragraf'
                          ? Icons.notes_rounded
                          : type == 'Dropdown'
                          ? Icons.arrow_drop_down_circle_rounded
                          : type == 'Pilihan Ganda'
                          ? Icons.check_box_rounded
                          : Icons.upload_file_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _fields.add(
                        RecruitmentFormField(
                          id: DateTime.now().millisecondsSinceEpoch,
                          label: '',
                          type: type,
                          options: '',
                          required: false,
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(title: 'Form Builder'),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    _fields.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.dynamic_form_rounded,
                                size: 64,
                                color: AppColors.neutral300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada field',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.neutral600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tekan tombol + di bawah untuk membuat formulir',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ReorderableListView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 16,
                            bottom: 100,
                          ),
                          itemCount: _fields.length,
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final item = _fields.removeAt(oldIndex);
                              _fields.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              key: ValueKey(_fields[index].id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildFieldCard(_fields[index], index),
                            );
                          },
                        ),
              ),
              if (_fields.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,

                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Form',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: _fields.isEmpty ? 20 : 100,
            child: FloatingActionButton(
              heroTag: 'add_field_fab',
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: _showAddFieldSheet,
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(RecruitmentFormField field, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.drag_indicator_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusXs,
                  ),
                  child: Text(
                    'Field ${index + 1}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _removeField(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: field.label)
                    ..selection = TextSelection.collapsed(
                      offset: field.label.length,
                    ),
                  decoration: InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (value) => field.label = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: field.type,
                  decoration: InputDecoration(
                    labelText: 'Tipe Field',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  items:
                      _fieldTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    setState(() => field.type = value!);
                  },
                ),
                if (field.type == 'Dropdown' ||
                    field.type == 'Pilihan Ganda') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: field.options)
                      ..selection = TextSelection.collapsed(
                        offset: field.options.length,
                      ),
                    decoration: InputDecoration(
                      labelText: 'Opsi (pisahkan dengan koma)',
                      hintText: 'Opsi 1, Opsi 2, Opsi 3',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    onChanged: (value) => field.options = value,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: field.required,
                      onChanged: (val) {
                        setState(() => field.required = val);
                      },
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Wajib diisi',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecruitmentFormField {
  int id;
  String label;
  String type;
  String options;
  bool required;

  RecruitmentFormField({
    required this.id,
    required this.label,
    required this.type,
    required this.options,
    required this.required,
  });
}

class RecruitmentApplicantCard extends StatelessWidget {
  final RecruitmentApplicant applicant;
  final VoidCallback onReview;

  const RecruitmentApplicantCard({
    super.key,
    required this.applicant,
    required this.onReview,
  });

  Widget _buildStatusBadge(String status) {
    final String statusText;
    final Color badgeColor;
    final Color textColor;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        statusText = 'Diterima';
        badgeColor = AppColors.success.withAlpha(20);
        textColor = const Color(0xFF15803D);
        break;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        statusText = 'Ditolak';
        badgeColor = AppColors.error.withAlpha(20);
        textColor = const Color(0xFFB91C1C);
        break;
      case 'pending':
      case 'menunggu':
      default:
        statusText = 'Menunggu';
        badgeColor = AppColors.warning.withAlpha(20);
        textColor = const Color(0xFFC2410C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelSm.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onReview,
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withAlpha(150),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    applicant.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.titleSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${applicant.nim} • ${applicant.prodi}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(applicant.status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          applicant.ipk.toStringAsFixed(2),
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ],
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
}

class RecruitmentApplicant {
  final String name;
  final String nim;
  final String prodi;
  final double ipk;
  final String divisi1;
  final String divisi2;
  final String status;
  final String alasan;
  final String cvUrl;
  final Map<String, dynamic> customAnswers;

  RecruitmentApplicant({
    required this.name,
    required this.nim,
    required this.prodi,
    required this.ipk,
    required this.divisi1,
    required this.divisi2,
    required this.status,
    required this.alasan,
    required this.cvUrl,
    required this.customAnswers,
  });
}

// Tab 4: Riwayat Keputusan
class RecruitmentHistoryScreen extends StatelessWidget {
  const RecruitmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(title: 'Riwayat Keputusan'),
      body: Builder(
        builder: (context) {
          // Simulasi data riwayat
          final List<RecruitmentApplicant> history = [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.neutral300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Riwayat keputusan akan muncul di sini',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final applicant = history[index];
              return RecruitmentHistoryCard(applicant: applicant);
            },
          );
        },
      ),
    );
  }
}

class RecruitmentHistoryCard extends StatelessWidget {
  final RecruitmentApplicant applicant;

  const RecruitmentHistoryCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final isAccepted =
        applicant.status == 'aktif' || applicant.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color:
              isAccepted
                  ? AppColors.success.withAlpha(50)
                  : AppColors.error.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isAccepted
                    ? AppColors.success.withAlpha(20)
                    : AppColors.error.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isAccepted
                          ? [AppColors.success, Colors.greenAccent.shade700]
                          : [AppColors.error, Colors.redAccent.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isAccepted ? AppColors.success : AppColors.error)
                        .withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                applicant.name.substring(0, 1).toUpperCase(),
                style: AppTextStyles.titleSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant.name,
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${applicant.nim} • ${applicant.prodi}',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: (isAccepted ? AppColors.success : AppColors.error)
                    .withAlpha(20),
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: (isAccepted ? AppColors.success : AppColors.error)
                      .withAlpha(50),
                ),
              ),
              child: Text(
                isAccepted ? 'Diterima' : 'Ditolak',
                style: AppTextStyles.labelSm.copyWith(
                  color:
                      isAccepted
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB91C1C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal Detail Applicant
class RecruitmentApplicantDetailModal extends StatelessWidget {
  final RecruitmentApplicant applicant;
  final List<Map<String, dynamic>> formFields;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RecruitmentApplicantDetailModal({
    super.key,
    required this.applicant,
    required this.formFields,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        final isPending =
            applicant.status.toLowerCase() == 'pending' ||
            applicant.status.toLowerCase() == 'menunggu';
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: AppRadius.radiusXs,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Profile Avatar Modern
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(150),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(60),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              applicant.name.substring(0, 1).toUpperCase(),
                              style: AppTextStyles.displaySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            applicant.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Text(
                            '${applicant.nim} • ${applicant.prodi}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusBadge(applicant.status),
                        const SizedBox(height: 20),

                        // Detail Data
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IPK modern
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withAlpha(20),
                                        borderRadius: AppRadius.radiusXl,
                                        border: Border.all(
                                          color: AppColors.warning.withAlpha(
                                            50,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning
                                                  .withAlpha(40),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.star_rounded,
                                              color: AppColors.warning,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Indeks Prestasi',
                                                style: AppTextStyles.labelMd
                                                    .copyWith(
                                                      color: AppColors.warning,
                                                    ),
                                              ),
                                              Text(
                                                applicant.ipk.toStringAsFixed(
                                                  2,
                                                ),
                                                style: AppTextStyles.titleMd
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors
                                                              .onWarningContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              if (applicant.customAnswers.isEmpty) ...[
                                Text(
                                  'Divisi Pilihan',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 1',
                                        value: applicant.divisi1,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 2',
                                        value: applicant.divisi2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Alasan & Motivasi',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100.withAlpha(100),
                                    borderRadius: AppRadius.radiusXl,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withAlpha(50),
                                    ),
                                  ),
                                  child: Text(
                                    applicant.alasan,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Dokumen Pendukung',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (applicant.cvUrl.trim().isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final fullUrl = ApiGate.getImageUrl(
                                        applicant.cvUrl,
                                      );
                                      if (fullUrl.isNotEmpty) {
                                        final uri = Uri.parse(fullUrl);
                                        try {
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } else {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint(
                                            'Could not launch $uri: $e',
                                          );
                                        }
                                      }
                                    },
                                    borderRadius: AppRadius.radiusXl,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(10),
                                        borderRadius: AppRadius.radiusXl,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(30),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.description_rounded,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Lihat CV / Portofolio',
                                                  style: AppTextStyles.bodyMd
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                ),
                                                Text(
                                                  'Ketuk untuk membuka dokumen pendaftaran',
                                                  style: AppTextStyles.labelMd
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .neutral500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.lg,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: AppRadius.radiusXl,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withAlpha(30),
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Text(
                                          'Tidak ada dokumen tambahan.',
                                          style: AppTextStyles.bodyMd.copyWith(
                                            color: AppColors.neutral500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              if (applicant.customAnswers.isNotEmpty) ...[
                                Text(
                                  'Jawaban Tambahan',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...applicant.customAnswers.entries.map((entry) {
                                  final fieldId = entry.key;
                                  final answer = entry.value;

                                  // Find the field label from formFields
                                  final field = formFields.firstWhere(
                                    (f) =>
                                        (f['id'] ?? f['ID']).toString() ==
                                        fieldId,
                                    orElse: () => <String, dynamic>{},
                                  );

                                  final label =
                                      field.isNotEmpty
                                          ? (field['label'] ??
                                                  field['Label'] ??
                                                  'Pertanyaan Tambahan')
                                              .toString()
                                          : 'Pertanyaan Tambahan';

                                  final type =
                                      field.isNotEmpty
                                          ? (field['type'] ??
                                                  field['Type'] ??
                                                  'text')
                                              .toString()
                                              .toLowerCase()
                                          : 'text';

                                  final isFile = type == 'file';

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.neutral500,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (isFile &&
                                          answer.toString().isNotEmpty)
                                        InkWell(
                                          onTap: () async {
                                            final fullUrl = ApiGate.getImageUrl(
                                              answer.toString(),
                                            );
                                            if (fullUrl.isNotEmpty) {
                                              final uri = Uri.parse(fullUrl);
                                              try {
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(
                                                    uri,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                } else {
                                                  await launchUrl(
                                                    uri,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                }
                                              } catch (e) {
                                                debugPrint(
                                                  'Could not launch $uri: $e',
                                                );
                                              }
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.open_in_new_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Buka Dokumen',
                                                  style: AppTextStyles.bodyMd
                                                      .copyWith(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Text(
                                          answer is List
                                              ? (answer).join(', ')
                                              : (answer
                                                          ?.toString()
                                                          .trim()
                                                          .isEmpty ??
                                                      true
                                                  ? '—'
                                                  : answer.toString()),
                                          style: AppTextStyles.bodyMd.copyWith(
                                            color: AppColors.neutral800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      if (entry.key !=
                                          applicant
                                              .customAnswers
                                              .keys
                                              .last) ...[
                                        Divider(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline.withAlpha(30),
                                          height: 1,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                              SizedBox(height: isPending ? 120 : 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sticky Action Buttons
              if (isPending &&
                  context.read<OrmawaProvider>().hasPermission(
                    'manage_recruitment',
                  ))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text(
                              'Tolak',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Terima',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final String statusText;
    final Color badgeColor;
    final Color textColor;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        statusText = 'Diterima';
        badgeColor = AppColors.success.withAlpha(20);
        textColor = const Color(0xFF15803D);
        break;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        statusText = 'Ditolak';
        badgeColor = AppColors.error.withAlpha(20);
        textColor = const Color(0xFFB91C1C);
        break;
      case 'pending':
      case 'menunggu':
      default:
        statusText = 'Menunggu';
        badgeColor = AppColors.warning.withAlpha(20);
        textColor = const Color(0xFFC2410C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RecruitmentInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const RecruitmentInfoCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(10),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
