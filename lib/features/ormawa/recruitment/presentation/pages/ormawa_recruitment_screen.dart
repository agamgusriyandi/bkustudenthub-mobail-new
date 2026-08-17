import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaRecruitmentScreen extends StatefulWidget {
  const OrmawaRecruitmentScreen({super.key});

  @override
  State<OrmawaRecruitmentScreen> createState() => _OrmawaRecruitmentScreenState();
}

class _OrmawaRecruitmentScreenState extends State<OrmawaRecruitmentScreen> {
  int _activeTab = 0;
  bool _isLoading = true;
  bool _actionLoading = false;
  bool _settingsLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'semua';
  final Set<String> _selectedIds = {};

  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _minIpkController = TextEditingController();
  bool _openRecruitment = false;
  DateTime? _recruitmentStart;
  DateTime? _recruitmentEnd;

  List<Map<String, dynamic>> _formFields = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _requirementsController.dispose();
    _minIpkController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentApplicants();

    final settings = provider.recruitmentSettings;
    if (settings.isNotEmpty && mounted) {
      setState(() {
        _openRecruitment = settings['open_recruitment'] ?? settings['isActive'] ?? false;
        _requirementsController.text = settings['recruitment_requirements'] ?? settings['requirements'] ?? '';
        final ipkVal = settings['min_ipk'] ?? settings['minIpk'];
        _minIpkController.text = ipkVal != null ? ipkVal.toString() : '';

        final startStr = settings['recruitment_start'] ?? settings['startDate'];
        if (startStr != null) {
          _recruitmentStart = DateTime.tryParse(startStr.toString());
        }

        final endStr = settings['recruitment_end'] ?? settings['endDate'];
        if (endStr != null) {
          _recruitmentEnd = DateTime.tryParse(endStr.toString());
        }
      });
    }

    final fields = provider.recruitmentFormFields;
    if (mounted) {
      setState(() {
        _formFields = fields.map((f) => Map<String, dynamic>.from(f)).toList();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _computeOprecStatus() {
    if (!_openRecruitment) {
      return {
        'label': 'Pendaftaran Ditutup',
        'color': AppColors.neutral600,
        'bg': AppColors.neutral200,
        'icon': Icons.lock_outline_rounded,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_recruitmentStart != null && _recruitmentEnd != null) {
      final start = DateTime(_recruitmentStart!.year, _recruitmentStart!.month, _recruitmentStart!.day);
      final end = DateTime(_recruitmentEnd!.year, _recruitmentEnd!.month, _recruitmentEnd!.day);

      if (today.isBefore(start)) {
        return {
          'label': 'Dibuka ${DateFormat('d MMM', 'id_ID').format(start)}',
          'color': AppColors.warning,
          'bg': AppColors.warning.withAlpha(25),
          'icon': Icons.schedule_rounded,
        };
      }
      if (today.isAfter(end)) {
        return {
          'label': 'Periode Berakhir',
          'color': AppColors.error,
          'bg': AppColors.error.withAlpha(25),
          'icon': Icons.event_busy_rounded,
        };
      }
      final diffDays = end.difference(today).inDays;
      return {
        'label': 'Buka (Sisa $diffDays hari)',
        'color': AppColors.success,
        'bg': AppColors.success.withAlpha(25),
        'icon': Icons.how_to_reg_rounded,
      };
    }

    return {
      'label': 'Pendaftaran Dibuka',
      'color': AppColors.success,
      'bg': AppColors.success.withAlpha(25),
      'icon': Icons.check_circle_outline_rounded,
    };
  }

  Future<void> _handleAccept(String id, Map<String, dynamic> applicant) async {
    setState(() => _actionLoading = true);
    try {
      final divisi = applicant['Divisi']?.toString() ?? applicant['divisi']?.toString() ?? 'Umum';
      await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
        id,
        'aktif',
        role: 'Anggota',
        divisi: divisi,
      );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pendaftar berhasil diterima sebagai Anggota!');
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memproses: $e');
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  void _openRejectDialog(Map<String, dynamic> applicant) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Tolak Berkas',
              style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuliskan alasan penolakan berkas calon anggota:',
              style: AppTextStyles.bodySm.copyWith(color: context.appColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Alasan penolakan...',
                hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
                filled: true,
                fillColor: AppColors.neutral100,
                border: OutlineInputBorder(borderRadius: AppRadius.radiusLg, borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              final id = (applicant['ID'] ?? applicant['id']).toString();
              setState(() => _actionLoading = true);
              try {
                final divisi = applicant['Divisi']?.toString() ?? applicant['divisi']?.toString() ?? 'Umum';
                await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
                  id,
                  'tidak_aktif',
                  role: 'Anggota',
                  divisi: divisi,
                  rejectionReason: reason.isNotEmpty ? reason : 'Penolakan berkas oleh pengurus',
                );
                if (mounted) {
                  AppSnackbar.showSuccess(context, 'Pendaftar berhasil ditolak');
                  Navigator.of(context, rootNavigator: true).maybePop();
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.showError(context, 'Gagal memproses: $e');
                }
              } finally {
                if (mounted) setState(() => _actionLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            child: const Text('Tolak Berkas'),
          ),
        ],
      ),
    );
  }

  void _openBulkActionDialog(String action) {
    final count = _selectedIds.length;
    final isAccept = action == 'accept';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Text(
          isAccept ? 'Terima Massal' : 'Tolak Massal',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
        ),
        content: Text(
          isAccept
              ? 'Yakin ingin menerima $count pendaftar terpilih sebagai anggota?'
              : 'Yakin ingin menolak $count berkas pendaftar terpilih?',
          style: AppTextStyles.bodySm.copyWith(color: context.appColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _actionLoading = true);
              final ids = _selectedIds.toList();
              final status = isAccept ? 'aktif' : 'tidak_aktif';
              final reason = isAccept ? null : 'Penolakan massal oleh pengurus';
              try {
                await context.read<OrmawaProvider>().bulkReviewApplicants(
                  ids,
                  status,
                  rejectionReason: reason,
                );
                if (mounted) {
                  setState(() => _selectedIds.clear());
                  AppSnackbar.showSuccess(
                    context,
                    '$count pendaftar berhasil ${isAccept ? 'diterima' : 'ditolak'}',
                  );
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.showError(context, 'Gagal memproses: $e');
                }
              } finally {
                if (mounted) setState(() => _actionLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? AppColors.success : AppColors.error,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            child: Text(isAccept ? 'Terima ($count)' : 'Tolak ($count)'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final provider = context.read<OrmawaProvider>();
    final ormawaId = provider.ormawaId;
    if (ormawaId == null) return;

    setState(() => _settingsLoading = true);
    try {
      final minIpk = double.tryParse(_minIpkController.text.trim()) ?? 0.0;
      final payload = {
        'open_recruitment': _openRecruitment,
        'recruitment_requirements': _requirementsController.text.trim(),
        'min_ipk': minIpk,
        'recruitment_start': _recruitmentStart?.toIso8601String(),
        'recruitment_end': _recruitmentEnd?.toIso8601String(),
      };
      await provider.updateRecruitmentSettings(payload);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengaturan berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _settingsLoading = false);
    }
  }

  Future<void> _saveFormFields() async {
    final provider = context.read<OrmawaProvider>();
    final ormawaId = provider.ormawaId;
    if (ormawaId == null) return;

    setState(() => _settingsLoading = true);
    try {
      final payload = _formFields.asMap().entries.map((entry) {
        final idx = entry.key;
        final f = entry.value;
        return {
          'id': 0,
          'label': f['label'] ?? '',
          'type': f['type'] ?? 'text',
          'options': f['options'] ?? '',
          'required': f['required'] ?? false,
          'order': idx,
        };
      }).toList();

      await provider.saveRecruitmentFormFields(payload);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Formulir kustom berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan formulir: $e');
      }
    } finally {
      if (mounted) setState(() => _settingsLoading = false);
    }
  }

  void _addFormField(String type) {
    setState(() {
      _formFields.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'label': '',
        'type': type,
        'options': '',
        'required': false,
        'order': _formFields.length,
      });
    });
  }

  void _removeFormField(int index) {
    setState(() {
      _formFields.removeAt(index);
    });
  }

  void _moveFormField(int index, int direction) {
    final target = index + direction;
    if (target < 0 || target >= _formFields.length) return;
    setState(() {
      final item = _formFields.removeAt(index);
      _formFields.insert(target, item);
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? (_recruitmentStart ?? DateTime.now()) : (_recruitmentEnd ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _recruitmentStart = picked;
        } else {
          _recruitmentEnd = picked;
        }
      });
    }
  }

  void _showReviewModal(Map<String, dynamic> applicant) {
    final m = applicant['Mahasiswa'] is Map
        ? applicant['Mahasiswa'] as Map<String, dynamic>
        : (applicant['mahasiswa'] is Map ? applicant['mahasiswa'] as Map<String, dynamic> : {});

    final name = m['Nama'] ?? m['nama'] ?? applicant['Nama'] ?? applicant['name'] ?? '—';
    final nim = m['NIM'] ?? m['nim'] ?? applicant['NIM'] ?? applicant['nim'] ?? '—';
    final prodi = m['ProgramStudi'] is Map
        ? m['ProgramStudi']['Nama']
        : (m['Prodi'] is Map ? m['Prodi']['Nama'] : applicant['prodi'] ?? 'Mahasiswa BKU');
    final isMaba = (m['SemesterSekarang'] ?? m['semester_sekarang']) == 1;
    final ipkVal = applicant['IPK'] ?? applicant['ipk'] ?? m['IPK'];
    final statusStr = (applicant['Status'] ?? applicant['status'] ?? 'pending').toString().toLowerCase();

    final divisi1 = applicant['Divisi'] ?? applicant['divisi'] ?? 'Umum';
    final divisi2 = applicant['divisi_pilihan_dua'] ?? applicant['DivisiPilihanDua'] ?? applicant['divisi2'] ?? '—';
    final alasan = applicant['alasan'] ?? applicant['Alasan'] ?? 'Tidak menyertakan motivasi tertulis.';
    final rejectionReason = applicant['rejection_reason'] ?? applicant['RejectionReason'];
    final cvUrl = applicant['cv_url'] ?? applicant['CVURL'];

    dynamic customAnswersRaw = applicant['CustomAnswers'] ?? applicant['custom_answers'];
    Map<String, dynamic> customAnswers = {};
    if (customAnswersRaw is Map) {
      customAnswers = Map<String, dynamic>.from(customAnswersRaw);
    }

    final id = (applicant['ID'] ?? applicant['id']).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: AppRadius.radiusSm,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Review Berkas Pendaftar',
                    style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded, color: context.appColors.outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(20),
                              borderRadius: AppRadius.radiusLg,
                            ),
                            child: Center(
                              child: Text(
                                (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                                style: AppTextStyles.titleLg.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString(),
                                  style: AppTextStyles.titleMd.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.s2),
                                Text(
                                  '$nim • $prodi',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusXl,
                        border: Border.all(color: AppColors.neutral300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IPK',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.outline,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                    Text(
                                      isMaba ? 'MABA' : (ipkVal != null ? double.tryParse(ipkVal.toString())?.toStringAsFixed(2) ?? '—' : '—'),
                                      style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1.5, height: 25, color: AppColors.neutral300),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PILIHAN 1',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.outline,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                    Text(
                                      divisi1.toString().toUpperCase(),
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.info,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (divisi2 != '—' && divisi2.toString().isNotEmpty) ...[
                            const Divider(height: 20),
                            Row(
                              children: [
                                Text(
                                  'PILIHAN 2: ',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.outline,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  divisi2.toString().toUpperCase(),
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (rejectionReason != null && rejectionReason.toString().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(15),
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(color: AppColors.error.withAlpha(40)),
                        ),
                        child: Text(
                          'Alasan Penolakan: $rejectionReason',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    Text(
                      'Motivasi Bergabung:',
                      style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: Text(
                        alasan.toString(),
                        style: AppTextStyles.bodySm.copyWith(height: 1.4),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (customAnswers.isNotEmpty) ...[
                      Text(
                        'Jawaban Formulir Kustom:',
                        style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...customAnswers.entries.map((entry) {
                        final val = entry.value;
                        final isFile = val.toString().startsWith('http') || val.toString().endsWith('.pdf');

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              if (isFile)
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.tryParse(val.toString());
                                    if (uri != null && await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Text(
                                    'Buka Berkas Lampiran',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  val.toString(),
                                  style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (cvUrl != null && cvUrl.toString().isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final uri = Uri.tryParse(cvUrl.toString());
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.description_rounded, color: AppColors.info, size: 22),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Curriculum Vitae / Portofolio',
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                              const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.info),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (statusStr == 'pending')
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  border: Border(top: BorderSide(color: AppColors.neutral300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _actionLoading ? null : () => _openRejectDialog(applicant),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        child: const Text('Tolak Berkas'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _actionLoading ? null : () => _handleAccept(id, applicant),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        child: _actionLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Terima Anggota'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _tabPillColors = [
    AppColors.info,
    AppColors.success,
    AppColors.info,
  ];

  Widget _buildTabPill(int index, String label) {
    final isActive = _activeTab == index;
    final activeColor = _tabPillColors[index % _tabPillColors.length];

    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.neutral200,
          borderRadius: AppRadius.br20,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(70),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? context.appColors.surface : AppColors.neutral600,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: AppSpacing.sm),
            Text(
              count,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.neutral800,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final allApplicants = provider.recruitmentApplicants;

          final pendingCount = allApplicants.where((a) => (a['Status'] ?? a['status'])?.toString().toLowerCase() == 'pending').length;
          final acceptedCount = allApplicants.where((a) => (a['Status'] ?? a['status'])?.toString().toLowerCase() == 'aktif').length;
          final rejectedCount = allApplicants.where((a) {
            final s = (a['Status'] ?? a['status'])?.toString().toLowerCase();
            return s == 'tidak_aktif' || s == 'ditolak';
          }).length;
          final totalCount = allApplicants.length;

          final filteredApplicants = allApplicants.where((a) {
            final m = a['Mahasiswa'] is Map ? a['Mahasiswa'] as Map<String, dynamic> : (a['mahasiswa'] is Map ? a['mahasiswa'] as Map<String, dynamic> : {});
            final name = (m['Nama'] ?? m['nama'] ?? a['Nama'] ?? a['name'] ?? '').toString().toLowerCase();
            final nim = (m['NIM'] ?? m['nim'] ?? a['NIM'] ?? a['nim'] ?? '').toString().toLowerCase();

            final matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery) || nim.contains(_searchQuery);

            final status = (a['Status'] ?? a['status'] ?? 'pending').toString().toLowerCase();
            bool matchesStatus = true;
            if (_filterStatus == 'pending') {
              matchesStatus = status == 'pending';
            } else if (_filterStatus == 'aktif') {
              matchesStatus = status == 'aktif';
            } else if (_filterStatus == 'tidak_aktif') {
              matchesStatus = status == 'tidak_aktif' || status == 'ditolak';
            }

            return matchesSearch && matchesStatus;
          }).toList();

          final oprecStatus = _computeOprecStatus();

          return RefreshIndicator(
            onRefresh: () => _loadAllData(),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                const BkuAppBar(
                  title: 'Open Recruitment',
                  subtitle: 'Pusat Rekrutmen Anggota Baru',
                  variant: AppBarVariant.student,
                  expandedHeight: 130,
                  showBackButton: true,
                  isExpandable: false,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        FadeInAnimation(
                          delay: 0.2,
                          child: BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral100,
                                        borderRadius: AppRadius.radiusSm,
                                      ),
                                      child: Text(
                                        'RECRUITMENT DASHBOARD',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.neutral800,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: oprecStatus['bg'] as Color,
                                        borderRadius: AppRadius.radiusSm,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(oprecStatus['icon'] as IconData, size: 12, color: oprecStatus['color'] as Color),
                                          const SizedBox(width: 4),
                                          Text(
                                            oprecStatus['label'] as String,
                                            style: AppTextStyles.labelSm.copyWith(
                                              color: oprecStatus['color'] as Color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Pusat Rekrutmen\n& Seleksi Anggota',
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: AppColors.neutral800,
                                    fontSize: 22,
                                    height: 1.2,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Kelola formulir kustom, verifikasi berkas pelamar, dan atur jadwal penerimaan anggota.',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        FadeInAnimation(
                          delay: 0.3,
                          child: Row(
                            children: [
                              _buildStatItem('$totalCount', 'Total Pelamar', Icons.groups_rounded, AppColors.info),
                              const SizedBox(width: AppSpacing.md),
                              _buildStatItem('$pendingCount', 'Menunggu', Icons.hourglass_top_rounded, AppColors.warning),
                              const SizedBox(width: AppSpacing.md),
                              _buildStatItem('$acceptedCount', 'Diterima', Icons.check_circle_rounded, AppColors.success),
                              const SizedBox(width: AppSpacing.md),
                              _buildStatItem('$rejectedCount', 'Ditolak', Icons.cancel_rounded, AppColors.error),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        FadeInAnimation(
                          delay: 0.4,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTabPill(0, 'Daftar Pendaftar ($totalCount)'),
                                const SizedBox(width: AppSpacing.sm),
                                _buildTabPill(1, 'Form Builder (${_formFields.length})'),
                                const SizedBox(width: AppSpacing.sm),
                                _buildTabPill(2, 'Pengaturan & Jadwal'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        if (_isLoading && allApplicants.isEmpty)
                          const BkuShimmerList(itemCount: 3, itemHeight: 120)
                        else if (_activeTab == 0)
                          _buildTabPendaftarContent(filteredApplicants)
                        else if (_activeTab == 1)
                          _buildTabFormBuilderContent()
                        else
                          _buildTabPengaturanContent(),

                        const SizedBox(height: AppSpacing.s120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabPendaftarContent(List<Map<String, dynamic>> applicants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Cari nama atau NIM pendaftar...',
            hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.neutral400),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral100,
            border: OutlineInputBorder(borderRadius: AppRadius.radiusLg, borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Semua', 'semua'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('Menunggu', 'pending'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('Diterima', 'aktif'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('Ditolak', 'tidak_aktif'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (_selectedIds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(20),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedIds.length} Dipilih',
                  style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900, color: AppColors.info),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _openBulkActionDialog('accept'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: AppRadius.radiusSm),
                    child: Text('Terima Semua', style: AppTextStyles.labelSm.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                InkWell(
                  onTap: () => _openBulkActionDialog('reject'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: AppRadius.radiusSm),
                    child: Text('Tolak Semua', style: AppTextStyles.labelSm.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        if (applicants.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(color: AppColors.neutral300),
            ),
            alignment: Alignment.center,
            child: Text(
              'Belum ada data pendaftar yang sesuai.',
              style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
            ),
          )
        else
          ...applicants.map((item) {
            final m = item['Mahasiswa'] is Map ? item['Mahasiswa'] as Map<String, dynamic> : (item['mahasiswa'] is Map ? item['mahasiswa'] as Map<String, dynamic> : {});
            final name = m['Nama'] ?? m['nama'] ?? item['Nama'] ?? item['name'] ?? '—';
            final nim = m['NIM'] ?? m['nim'] ?? item['NIM'] ?? item['nim'] ?? '—';
            final prodi = m['ProgramStudi'] is Map ? m['ProgramStudi']['Nama'] : (m['Prodi'] is Map ? m['Prodi']['Nama'] : item['prodi'] ?? 'Mahasiswa BKU');
            final isMaba = (m['SemesterSekarang'] ?? m['semester_sekarang']) == 1;
            final ipkVal = item['IPK'] ?? item['ipk'] ?? m['IPK'];
            final status = (item['Status'] ?? item['status'] ?? 'pending').toString().toLowerCase();
            final divisi = item['Divisi'] ?? item['divisi'] ?? 'Umum';
            final id = (item['ID'] ?? item['id']).toString();
            final isSelected = _selectedIds.contains(id);

            Color statusBgColor = AppColors.neutral500.withAlpha(20);
            Color statusTextColor = context.appColors.outline;
            String statusLabel = 'Menunggu';

            if (status == 'aktif') {
              statusBgColor = AppColors.success.withAlpha(20);
              statusTextColor = AppColors.success;
              statusLabel = 'Diterima';
            } else if (status == 'pending') {
              statusBgColor = AppColors.warning.withAlpha(20);
              statusTextColor = AppColors.warning;
              statusLabel = 'Menunggu';
            } else {
              statusBgColor = AppColors.error.withAlpha(20);
              statusTextColor = AppColors.error;
              statusLabel = 'Ditolak';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: BkuCard(
                child: InkWell(
                  onTap: () => _showReviewModal(item),
                  borderRadius: AppRadius.radiusXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(id);
                                  } else {
                                    _selectedIds.remove(id);
                                  }
                                });
                              },
                              activeColor: AppColors.info,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                            ),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.info.withAlpha(15),
                                borderRadius: AppRadius.radiusLg,
                              ),
                              child: Text(
                                (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                                style: AppTextStyles.titleLg.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: AppTextStyles.titleLg.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.s2),
                                  Text(
                                    '$nim • $prodi',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: statusTextColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(color: AppColors.neutral300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PILIHAN DIVISI',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.outline,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s2),
                                  Text(
                                    divisi.toString().toUpperCase(),
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neutral800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1.5, height: 25, color: AppColors.neutral300),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IPK',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.outline,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s2),
                                  Text(
                                    isMaba ? 'MABA' : (ipkVal != null ? double.tryParse(ipkVal.toString())?.toStringAsFixed(2) ?? '—' : '—'),
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.info : AppColors.neutral100,
          borderRadius: AppRadius.radiusSm,
          border: Border.all(color: isSelected ? AppColors.info : AppColors.neutral300),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabFormBuilderContent() {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formulir Pendaftaran Kustom',
            style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Rancang pertanyaan tambahan yang wajib diisi oleh calon pendaftar.',
            style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAddChip('Teks Singkat', 'text'),
                const SizedBox(width: AppSpacing.sm),
                _buildAddChip('Paragraf', 'paragraph'),
                const SizedBox(width: AppSpacing.sm),
                _buildAddChip('Pilihan Dropdown', 'select'),
                const SizedBox(width: AppSpacing.sm),
                _buildAddChip('Upload File', 'file'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          if (_formFields.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusLg,
              ),
              alignment: Alignment.center,
              child: Text(
                'Belum ada pertanyaan tambahan.',
                style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
              ),
            )
          else
            ..._formFields.asMap().entries.map((entry) {
              final idx = entry.key;
              final field = entry.value;
              final type = field['type']?.toString() ?? 'text';

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.info,
                          child: Text('${idx + 1}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: field['label']?.toString() ?? '')..selection = TextSelection.collapsed(offset: (field['label']?.toString() ?? '').length),
                            onChanged: (val) => field['label'] = val,
                            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Tulis judul pertanyaan...',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _moveFormField(idx, -1),
                          icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          onPressed: () => _moveFormField(idx, 1),
                          icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          onPressed: () => _removeFormField(idx),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral800),
                              items: const [
                                DropdownMenuItem(value: 'text', child: Text('Teks Singkat')),
                                DropdownMenuItem(value: 'paragraph', child: Text('Paragraf')),
                                DropdownMenuItem(value: 'select', child: Text('Dropdown')),
                                DropdownMenuItem(value: 'file', child: Text('Upload File')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => field['type'] = val);
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: field['required'] == true,
                              onChanged: (val) => setState(() => field['required'] = val ?? false),
                              activeColor: AppColors.info,
                            ),
                            Text('Wajib', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    if (type == 'select') ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: TextEditingController(text: field['options']?.toString() ?? '')..selection = TextSelection.collapsed(offset: (field['options']?.toString() ?? '').length),
                        onChanged: (val) => field['options'] = val,
                        style: AppTextStyles.bodySm,
                        decoration: InputDecoration(
                          hintText: 'Opsi (pisah koma): Divisi Acara, Humas...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: AppRadius.radiusMd, borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(AppSpacing.sm),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

          const SizedBox(height: AppSpacing.xl),
          BkuButton(
            text: _settingsLoading ? 'Menyimpan...' : 'Simpan Formulir',
            onPressed: _settingsLoading ? null : _saveFormFields,
            variant: BkuButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddChip(String label, String type) {
    return InkWell(
      onTap: () => _addFormField(type),
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.info.withAlpha(15),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Text(
          '+ $label',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.info,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabPengaturanContent() {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Open Recruitment',
                    style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Tampilkan pendaftaran di portal mahasiswa',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurfaceVariant),
                  ),
                ],
              ),
              Switch(
                value: _openRecruitment,
                onChanged: (val) => setState(() => _openRecruitment = val),
                activeTrackColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TGL BUKA', style: AppTextStyles.labelSm.copyWith(fontSize: 8, color: context.appColors.outline, fontWeight: FontWeight.w900)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _recruitmentStart != null ? DateFormat('d MMM yyyy', 'id_ID').format(_recruitmentStart!) : 'Pilih Tgl',
                          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TGL TUTUP', style: AppTextStyles.labelSm.copyWith(fontSize: 8, color: context.appColors.outline, fontWeight: FontWeight.w900)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _recruitmentEnd != null ? DateFormat('d MMM yyyy', 'id_ID').format(_recruitmentEnd!) : 'Pilih Tgl',
                          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Batas IPK Minimal:', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _minIpkController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0.00 (Tanpa Batas)',
              filled: true,
              fillColor: AppColors.neutral100,
              border: OutlineInputBorder(borderRadius: AppRadius.radiusLg, borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Persyaratan & Ketentuan Khusus:', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _requirementsController,
            maxLines: 4,
            style: AppTextStyles.bodySm,
            decoration: InputDecoration(
              hintText: 'Syarat administratif atau komitmen...',
              filled: true,
              fillColor: AppColors.neutral100,
              border: OutlineInputBorder(borderRadius: AppRadius.radiusLg, borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          BkuButton(
            text: _settingsLoading ? 'Menyimpan...' : 'Simpan Pengaturan',
            onPressed: _settingsLoading ? null : _saveSettings,
            variant: BkuButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
