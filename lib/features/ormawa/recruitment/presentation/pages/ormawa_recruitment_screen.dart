import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_date_field.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_info_card.dart';

class OrmawaRecruitmentScreen extends StatefulWidget {
  final bool showBackButton;

  const OrmawaRecruitmentScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<OrmawaRecruitmentScreen> createState() => _OrmawaRecruitmentScreenState();
}

class _OrmawaRecruitmentScreenState extends State<OrmawaRecruitmentScreen> {
  String _activeTab = 'pendaftar';
  bool _isLoading = false;
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

  double _extractIpk(Map a, Map m) {
    final candidates = [
      m['IPK'],
      m['ipk'],
      m['Ipk'],
      a['IPK'],
      a['ipk'],
      a['Ipk'],
    ];

    for (final val in candidates) {
      if (val != null) {
        final parsed = double.tryParse(val.toString()) ?? 0.0;
        if (parsed > 0.0) {
          return parsed;
        }
      }
    }
    return 0.0;
  }

  Future<void> _loadAllData([bool isRefresh = false]) async {
    if (!mounted) return;
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }

    try {
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
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _computeOprecStatus() {
    if (!_openRecruitment) {
      return {
        'label': 'Pendaftaran Ditutup',
        'color': BkuTheme.textMuted,
        'bg': BkuTheme.borderSubtle,
        'border': BkuTheme.border,
        'icon': Icons.lock_outline_rounded,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_recruitmentStart != null && _recruitmentEnd != null) {
      final start = DateTime(_recruitmentStart!.year, _recruitmentStart!.month, _recruitmentStart!.day);
      final end = DateTime(_recruitmentEnd!.year, _recruitmentEnd!.month, _recruitmentEnd!.day);

      if (today.isBefore(start)) {
        String dateStr = '';
        try {
          dateStr = DateFormat('d MMM').format(start);
        } catch (_) {
          dateStr = '${start.day}/${start.month}';
        }
        return {
          'label': 'Dibuka $dateStr',
          'color': BkuTheme.amber,
          'bg': BkuTheme.amberSoft,
          'border': BkuTheme.amberBorder,
          'icon': Icons.schedule_rounded,
        };
      }
      if (today.isAfter(end)) {
        return {
          'label': 'Periode Berakhir',
          'color': BkuTheme.rose,
          'bg': BkuTheme.roseSoft,
          'border': BkuTheme.roseBorder,
          'icon': Icons.event_busy_rounded,
        };
      }
      final diffDays = end.difference(today).inDays;
      return {
        'label': 'Buka (Sisa $diffDays hari)',
        'color': BkuTheme.emerald,
        'bg': BkuTheme.emeraldSoft,
        'border': BkuTheme.emeraldBorder,
        'icon': Icons.how_to_reg_rounded,
      };
    }

    return {
      'label': 'Pendaftaran Dibuka',
      'color': BkuTheme.emerald,
      'bg': BkuTheme.emeraldSoft,
      'border': BkuTheme.emeraldBorder,
      'icon': Icons.check_circle_outline_rounded,
    };
  }

  Future<void> _handleExportCsv() async {
    final provider = context.read<OrmawaProvider>();
    final ormawaId = provider.ormawaId;
    if (ormawaId == null) {
      AppSnackbar.showError(context, 'Data Ormawa tidak valid');
      return;
    }

    setState(() => _actionLoading = true);
    try {
      final statusParam = _filterStatus != 'semua' ? '?status=$_filterStatus' : '';
      final response = await ApiClient().client.get<List<int>>(
        '/ormawa/recruitment/export$statusParam',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'text/csv, application/json',
          },
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) AppSnackbar.showError(context, 'Data export kosong');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      String dateSuffix = '';
      try {
        dateSuffix = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      } catch (_) {
        dateSuffix = '${DateTime.now().millisecondsSinceEpoch}';
      }
      final fileName = 'rekrutmen_ormawa_$dateSuffix.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Export CSV berhasil!');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Data Rekrutmen Calon Anggota Ormawa',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal mengekspor data: $e');
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
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
        AppSnackbar.showError(context, 'Gagal memproses pendaftaran: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BkuTheme.r20),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BkuTheme.roseSoft,
                borderRadius: BkuTheme.r10,
              ),
              child: const Icon(Icons.cancel_rounded, color: BkuTheme.rose, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tolak Berkas Pelamar',
                style: BkuTheme.textCardTitle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuliskan alasan penolakan berkas calon anggota ini:',
              style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
            ),
            const SizedBox(height: 12),
            BkuTextField(
              controller: reasonController,
              label: 'Alasan Penolakan',
              hint: 'Contoh: IPK belum memenuhi standar / kuota penuh...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          BkuButton.outline(
            text: 'Batal',
            height: 38,
            onPressed: () => Navigator.pop(ctx),
          ),
          BkuButton(
            variant: BkuButtonVariant.danger,
            text: 'Tolak Berkas',
            height: 38,
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
                  rejectionReason: reason.isNotEmpty ? reason : 'Penolakan berkas oleh pengurus ormawa',
                );
                if (mounted) {
                  AppSnackbar.showSuccess(context, 'Pendaftar berhasil ditolak!');
                  Navigator.of(context, rootNavigator: true).maybePop();
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.showError(context, 'Gagal memproses penolakan: $e');
                }
              } finally {
                if (mounted) setState(() => _actionLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _openBulkActionDialog(String action) {
    final count = _selectedIds.length;
    final isAccept = action == 'accept';

    BkuDialog.show(
      context: context,
      title: isAccept ? 'Terima Massal' : 'Tolak Massal',
      message: isAccept
          ? 'Yakin ingin menerima $count pendaftar yang dipilih sebagai anggota resmi ormawa?'
          : 'Yakin ingin menolak $count berkas pendaftar yang dipilih?',
      type: isAccept ? BkuDialogType.success : BkuDialogType.error,
      primaryButtonText: isAccept ? 'Terima ($count)' : 'Tolak ($count)',
      onPrimaryPressed: () async {
        Navigator.pop(context);
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
              '$count pendaftar berhasil ${isAccept ? 'diterima' : 'ditolak'}!',
            );
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal memproses aksi massal: $e');
          }
        } finally {
          if (mounted) setState(() => _actionLoading = false);
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
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
        'recruitment_start': _recruitmentStart != null
            ? DateTime.utc(
                _recruitmentStart!.year,
                _recruitmentStart!.month,
                _recruitmentStart!.day,
              ).toIso8601String()
            : null,
        'recruitment_end': _recruitmentEnd != null
            ? DateTime.utc(
                _recruitmentEnd!.year,
                _recruitmentEnd!.month,
                _recruitmentEnd!.day,
                23,
                59,
                59,
              ).toIso8601String()
            : null,
      };
      await provider.updateRecruitmentSettings(payload);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengaturan Open Recruitment berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan pengaturan: $e');
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
        AppSnackbar.showSuccess(context, 'Formulir kustom berhasil disimpan!');
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

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? (_recruitmentStart ?? DateTime.now()) : (_recruitmentEnd ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: BkuTheme.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: BkuTheme.textHeading,
          ),
        ),
        child: child!,
      ),
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
    final rawProdi = (m['ProgramStudi'] is Map
            ? (m['ProgramStudi']['Nama'] ?? m['ProgramStudi']['nama'])
            : (m['Prodi'] is Map
                ? (m['Prodi']['Nama'] ?? m['Prodi']['nama'])
                : (m['Prodi'] ?? m['prodi'] ?? applicant['prodi'])))
        ?.toString();
    final prodiText = (rawProdi != null && rawProdi.trim().isNotEmpty && rawProdi != 'null') ? rawProdi.trim() : '—';
    final ipkNum = _extractIpk(applicant, m);
    final statusStr = (applicant['Status'] ?? applicant['status'] ?? 'pending').toString().toLowerCase();

    final rawDivisi1 = applicant['Divisi'] ?? applicant['divisi'] ?? applicant['divisi_pilihan_satu'] ?? applicant['DivisiPilihanSatu'] ?? applicant['divisi1'];
    final divisi1 = (rawDivisi1 != null && rawDivisi1.toString().trim().isNotEmpty && rawDivisi1.toString() != 'null')
        ? rawDivisi1.toString().trim()
        : '—';
    final rawDivisi2 = applicant['divisi_pilihan_dua'] ?? applicant['DivisiPilihanDua'] ?? applicant['divisi2'];
    final divisi2 = (rawDivisi2 != null && rawDivisi2.toString().trim().isNotEmpty && rawDivisi2.toString() != 'null')
        ? rawDivisi2.toString().trim()
        : '—';

    final alasan = applicant['alasan'] ?? applicant['Alasan'] ?? '—';
    final cvUrl = applicant['cv_url'] ?? applicant['CVURL'];

    dynamic customAnswersRaw = applicant['CustomAnswers'] ?? applicant['custom_answers'];
    Map<String, dynamic> customAnswers = {};
    if (customAnswersRaw is Map) {
      customAnswers = Map<String, dynamic>.from(customAnswersRaw);
    }

    final id = (applicant['ID'] ?? applicant['id']).toString();
    final canManage = context.read<OrmawaProvider>().hasPermission('manage_recruitment');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: BkuTheme.scaffoldBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: BkuTheme.border,
                borderRadius: BkuTheme.r8,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BkuTheme.primarySoft,
                      borderRadius: BkuTheme.r10,
                    ),
                    child: Icon(Icons.person_search_rounded, size: 20, color: BkuTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Berkas Pendaftar',
                          style: BkuTheme.textCardTitle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'KUALIFIKASI AKADEMIK & PILIHAN DIVISI',
                          style: BkuTheme.textCaption.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded, size: 20, color: BkuTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BkuCard(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: BkuTheme.primarySoft,
                              borderRadius: BkuTheme.r16,
                              border: Border.all(color: BkuTheme.primaryBorder),
                            ),
                            child: Center(
                              child: Text(
                                (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BkuStatusBadge(
                                  status: statusStr == 'aktif'
                                      ? BkuStatus.success
                                      : statusStr == 'pending'
                                          ? BkuStatus.warning
                                          : BkuStatus.error,
                                  customText: statusStr == 'aktif'
                                      ? 'Diterima'
                                      : statusStr == 'pending'
                                          ? 'Menunggu Review'
                                          : 'Ditolak',
                                  showIcon: false,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name.toString(),
                                  style: BkuTheme.textCardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      nim.toString(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('•', style: TextStyle(color: BkuTheme.textMuted)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        prodiText,
                                        style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: BkuCard(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 14,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: BkuTheme.amberSoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.star_rounded, color: BkuTheme.amber, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('IPK Kumulatif', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                                      Text(
                                        ipkNum.toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: BkuTheme.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text('Divisi Pilihan', style: BkuTheme.textSectionTitle),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RecruitmentInfoCard(
                            label: 'PILIHAN 1',
                            value: divisi1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RecruitmentInfoCard(
                            label: 'PILIHAN 2',
                            value: divisi2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text('Alasan & Motivasi', style: BkuTheme.textSectionTitle),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BkuTheme.r16,
                        border: Border.all(color: BkuTheme.border),
                      ),
                      child: Text(
                        alasan.toString(),
                        style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (cvUrl != null && cvUrl.toString().trim().isNotEmpty) ...[
                      Text('Dokumen Lampiran (CV / Portofolio)', style: BkuTheme.textSectionTitle),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final fullUrl = ApiGate.getImageUrl(cvUrl.toString());
                          if (fullUrl.isNotEmpty) {
                            final uri = Uri.parse(fullUrl);
                            try {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (_) {}
                          }
                        },
                        borderRadius: BkuTheme.r16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BkuTheme.primarySoft,
                            borderRadius: BkuTheme.r16,
                            border: Border.all(color: BkuTheme.primaryBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.description_rounded, color: BkuTheme.primary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Lihat Dokumen CV / Portofolio', style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                                    Text('Klik untuk membuka dokumen lampiran', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                                  ],
                                ),
                              ),
                              Icon(Icons.open_in_new_rounded, color: BkuTheme.primary, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (customAnswers.isNotEmpty) ...[
                      Text('Jawaban Kustom Pelamar', style: BkuTheme.textSectionTitle),
                      const SizedBox(height: 8),
                      ...customAnswers.entries.map((entry) {
                        final fieldId = entry.key;
                        final answer = entry.value;
                        final field = _formFields.firstWhere(
                          (f) => (f['id'] ?? f['ID']).toString() == fieldId,
                          orElse: () => <String, dynamic>{},
                        );
                        final label = field.isNotEmpty ? (field['label'] ?? 'Pertanyaan').toString() : 'Pertanyaan #$fieldId';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(color: BkuTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: BkuTheme.textCaption.copyWith(fontWeight: FontWeight.bold, color: BkuTheme.textMuted)),
                              const SizedBox(height: 2),
                              Text(answer?.toString() ?? '—', style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    if (statusStr == 'pending' && canManage) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: BkuButton(
                              variant: BkuButtonVariant.danger,
                              text: 'Tolak Berkas',
                              icon: Icons.cancel_rounded,
                              height: 44,
                              onPressed: () => _openRejectDialog(applicant),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BkuButton.success(
                              text: 'Terima Anggota',
                              icon: Icons.check_circle_rounded,
                              height: 44,
                              onPressed: () => _handleAccept(id, applicant),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, ormawaProv, child) {
        final allApplicants = ormawaProv.recruitmentApplicants;

        final totalCount = allApplicants.length;
        final pendingCount = allApplicants.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'pending').length;
        final acceptedCount = allApplicants.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'aktif').length;
        final rejectedCount = allApplicants.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'tidak_aktif').length;

        final filteredApplicants = allApplicants.where((a) {
          final m = a['Mahasiswa'] is Map
              ? a['Mahasiswa'] as Map<String, dynamic>
              : (a['mahasiswa'] is Map ? a['mahasiswa'] as Map<String, dynamic> : {});
          final name = (m['Nama'] ?? m['nama'] ?? a['Nama'] ?? a['name'] ?? '').toString().toLowerCase();
          final nim = (m['NIM'] ?? m['nim'] ?? a['NIM'] ?? a['nim'] ?? '').toString().toLowerCase();
          final divisi = (a['Divisi'] ?? a['divisi'] ?? '').toString().toLowerCase();
          final status = (a['Status'] ?? a['status'] ?? '').toString().toLowerCase();

          final matchQuery = _searchQuery.isEmpty || name.contains(_searchQuery) || nim.contains(_searchQuery) || divisi.contains(_searchQuery);
          final matchStatus = _filterStatus == 'semua' || status == _filterStatus;

          return matchQuery && matchStatus;
        }).toList();

        final oprecStatus = _computeOprecStatus();

        return Scaffold(
          backgroundColor: BkuTheme.scaffoldBg,
          body: RefreshIndicator(
            onRefresh: () => _loadAllData(true),
            color: BkuTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              slivers: [
                BkuAppBar(
                  title: 'Open Recruitment',
                  subtitle: 'Manajemen Pendaftaran & Seleksi Anggota',
                  variant: AppBarVariant.ormawa,
                  showBackButton: widget.showBackButton,
                  isExpandable: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: oprecStatus['bg'] as Color,
                            borderRadius: BkuTheme.r16,
                            border: Border.all(color: oprecStatus['border'] as Color),
                          ),
                          child: Row(
                            children: [
                              Icon(oprecStatus['icon'] as IconData, size: 20, color: oprecStatus['color'] as Color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      oprecStatus['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: oprecStatus['color'] as Color,
                                      ),
                                    ),
                                    Text(
                                      _openRecruitment
                                          ? 'Pendaftaran sedang dibuka untuk mahasiswa aktif.'
                                          : 'Pendaftaran calon anggota ormawa sedang ditutup.',
                                      style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (_activeTab != 'settings')
                                InkWell(
                                  onTap: () => setState(() => _activeTab = 'settings'),
                                  borderRadius: BkuTheme.r8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(color: oprecStatus['border'] as Color),
                                    ),
                                    child: Text('Ubah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: oprecStatus['color'] as Color)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BkuTheme.r16,
                            border: Border.all(color: BkuTheme.border),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentTab(id: 'pendaftar', label: 'Pendaftar', icon: Icons.people_alt_rounded, count: totalCount),
                              _buildSegmentTab(id: 'form', label: 'Form Builder', icon: Icons.dynamic_form_rounded, count: _formFields.length),
                              _buildSegmentTab(id: 'settings', label: 'Pengaturan', icon: Icons.tune_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                if (_isLoading && allApplicants.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
                      child: BkuShimmerList(itemCount: 3, itemHeight: 90),
                    ),
                  )
                else if (_activeTab == 'pendaftar') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Total Pendaftar',
                                  value: '$totalCount',
                                  badgeText: 'Semua',
                                  icon: Icons.people_outline_rounded,
                                  badgeColor: BkuTheme.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Menunggu Review',
                                  value: '$pendingCount',
                                  badgeText: 'Pending',
                                  icon: Icons.hourglass_empty_rounded,
                                  badgeColor: BkuTheme.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Diterima (Aktif)',
                                  value: '$acceptedCount',
                                  badgeText: 'Anggota',
                                  icon: Icons.check_circle_outline_rounded,
                                  badgeColor: BkuTheme.emerald,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Ditolak',
                                  value: '$rejectedCount',
                                  badgeText: 'Gugur',
                                  icon: Icons.cancel_outlined,
                                  badgeColor: BkuTheme.rose,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          OrmawaSearchBar(
                            controller: _searchController,
                            hintText: 'Cari nama, NIM, atau divisi...',
                            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          _buildApplicantToolbar(filteredApplicants, ormawaProv.hasPermission('manage_recruitment')),
                          const SizedBox(height: AppSpacing.md),

                          OrmawaFilterTabs(
                            tabs: [
                              OrmawaTabItem(key: 'semua', label: 'Semua', count: totalCount),
                              OrmawaTabItem(key: 'pending', label: 'Menunggu', count: pendingCount),
                              OrmawaTabItem(key: 'aktif', label: 'Diterima', count: acceptedCount),
                              OrmawaTabItem(key: 'tidak_aktif', label: 'Ditolak', count: rejectedCount),
                            ],
                            activeKey: _filterStatus,
                            onTabChanged: (val) => setState(() => _filterStatus = val),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  if (filteredApplicants.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 20),
                        child: BkuEmptyState(
                          title: 'Tidak Ada Pendaftar',
                          message: _searchQuery.isNotEmpty || _filterStatus != 'semua'
                              ? 'Tidak ada pelamar yang sesuai dengan pencarian atau filter aktif.'
                              : 'Belum ada mahasiswa yang mendaftar pada rekrutmen ini.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final a = filteredApplicants[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildApplicantItemCard(a, ormawaProv.hasPermission('manage_recruitment')),
                            );
                          },
                          childCount: filteredApplicants.length,
                        ),
                      ),
                    ),
                ] else if (_activeTab == 'form') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _buildFormBuilderContent(),
                    ),
                  ),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _buildPengaturanContent(),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s120)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentTab({
    required String id,
    required String label,
    required IconData icon,
    int? count,
  }) {
    final isActive = _activeTab == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = id),
        borderRadius: BkuTheme.r12,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? BkuTheme.primary : Colors.transparent,
            borderRadius: BkuTheme.r12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? Colors.white : BkuTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : BkuTheme.textMuted,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? BkuTheme.primary : BkuTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantToolbar(List<Map<String, dynamic>> applicants, bool canManage) {
    final hasSelection = _selectedIds.isNotEmpty;
    final isAllSelected = applicants.isNotEmpty && _selectedIds.length == applicants.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (canManage && applicants.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isAllSelected) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds.addAll(applicants.map((a) => (a['ID'] ?? a['id']).toString()));
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAllSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAllSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 17,
                        color: isAllSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pilih Semua (${applicants.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            InkWell(
              onTap: _actionLoading ? null : _handleExportCsv,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_actionLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                      )
                    else
                      const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFF334155)),
                    const SizedBox(width: 6),
                    const Text(
                      'Export CSV',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (hasSelection && canManage) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.checklist_rounded, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedIds.length} Terpilih',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _openBulkActionDialog('accept'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Terima',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _openBulkActionDialog('reject'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Tolak',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => setState(() => _selectedIds.clear()),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApplicantItemCard(Map<String, dynamic> a, bool canManage) {
    final m = a['Mahasiswa'] is Map
        ? a['Mahasiswa'] as Map<String, dynamic>
        : (a['mahasiswa'] is Map ? a['mahasiswa'] as Map<String, dynamic> : {});
    final name = m['Nama'] ?? m['nama'] ?? a['Nama'] ?? a['name'] ?? '—';
    final nim = m['NIM'] ?? m['nim'] ?? a['NIM'] ?? a['nim'] ?? '—';
    final rawProdi = (m['ProgramStudi'] is Map
            ? (m['ProgramStudi']['Nama'] ?? m['ProgramStudi']['nama'])
            : (m['Prodi'] is Map
                ? (m['Prodi']['Nama'] ?? m['Prodi']['nama'])
                : (m['Prodi'] ?? m['prodi'] ?? a['prodi'])))
        ?.toString();
    final prodiText = (rawProdi != null && rawProdi.trim().isNotEmpty && rawProdi != 'null') ? rawProdi.trim() : '—';
    final ipkNum = _extractIpk(a, m);
    final statusStr = (a['Status'] ?? a['status'] ?? 'pending').toString().toLowerCase();

    final rawDivisi = a['Divisi'] ?? a['divisi'] ?? a['divisi_pilihan_satu'] ?? a['DivisiPilihanSatu'] ?? a['divisi1'];
    final divisi = (rawDivisi != null && rawDivisi.toString().trim().isNotEmpty && rawDivisi.toString() != 'null')
        ? rawDivisi.toString().trim()
        : '—';

    final id = (a['ID'] ?? a['id']).toString();
    final isSelected = _selectedIds.contains(id);

    return BkuCard(
      onTap: () => _showReviewModal(a),
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (canManage) ...[
                Checkbox(
                  value: isSelected,
                  activeColor: BkuTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedIds.add(id);
                      } else {
                        _selectedIds.remove(id);
                      }
                    });
                  },
                ),
                const SizedBox(width: 4),
              ],
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r10,
                ),
                alignment: Alignment.center,
                child: Text(
                  (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString(),
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$nim • $prodiText',
                      style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BkuStatusBadge(
                status: statusStr == 'aktif'
                    ? BkuStatus.success
                    : statusStr == 'pending'
                        ? BkuStatus.warning
                        : BkuStatus.error,
                customText: statusStr == 'aktif'
                    ? 'Diterima'
                    : statusStr == 'pending'
                        ? 'Menunggu'
                        : 'Ditolak',
                showIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: BkuTheme.r10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.hub_outlined, size: 14, color: BkuTheme.textMuted),
                    const SizedBox(width: 5),
                    Text('Divisi: $divisi', style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: BkuTheme.amber),
                    const SizedBox(width: 3),
                    Text(
                      'IPK ${ipkNum.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BkuTheme.amber,
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

  Widget _buildFormBuilderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BkuCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Formulir Pendaftaran Kustom', style: BkuTheme.textSectionTitle),
                  BkuButton.outline(
                    text: '+ Tambah Field',
                    height: 32,
                    fullWidth: false,
                    onPressed: () => _showAddFieldSheet(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Atur pertanyaan khusus yang wajib diisi calon anggota saat mendaftar.',
                style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_formFields.isEmpty)
          BkuEmptyState(
            title: 'Belum Ada Field Formulir',
            message: 'Tambahkan pertanyaan tambahan untuk formulir ormawa.',
            buttonText: '+ Tambah Field Baru',
            onButtonPressed: _showAddFieldSheet,
          )
        else
          ..._formFields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BkuCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pertanyaan ${index + 1}',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _removeFormField(index),
                          borderRadius: BkuTheme.r8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: BkuTheme.roseSoft,
                              borderRadius: BkuTheme.r8,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: BkuTheme.rose, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    BkuTextField(
                      label: 'Pertanyaan *',
                      hint: 'Tuliskan pertanyaan...',
                      initialValue: field['label']?.toString() ?? '',
                      onChanged: (val) => field['label'] = val,
                    ),
                    const SizedBox(height: 8),

                    BkuDropdown<String>(
                      label: 'Tipe Input',
                      value: _mapDbTypeToDisplay(field['type'] ?? 'text'),
                      items: _fieldTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => field['type'] = _mapDisplayToDbType(val));
                        }
                      },
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Switch(
                          value: field['required'] ?? false,
                          onChanged: (val) => setState(() => field['required'] = val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: BkuTheme.primary,
                          inactiveThumbColor: BkuTheme.textPlaceholder,
                          inactiveTrackColor: BkuTheme.borderSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text('Wajib diisi (Required)', style: BkuTheme.textCaption.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 14),
        BkuButton.primary(
          text: 'Simpan Formulir Kustom',
          isLoading: _settingsLoading,
          onPressed: _settingsLoading ? null : _saveFormFields,
          icon: Icons.save_rounded,
          height: 46,
        ),
      ],
    );
  }

  Widget _buildPengaturanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BkuCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Status Pendaftaran', style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        BkuStatusBadge(
                          status: _openRecruitment ? BkuStatus.success : BkuStatus.neutral,
                          customText: _openRecruitment ? 'Aktif' : 'Nonaktif',
                          showIcon: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _openRecruitment ? 'Form pendaftaran dapat diakses mahasiswa.' : 'Pendaftaran saat ini sedang ditutup.',
                      style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _openRecruitment,
                onChanged: (val) => setState(() => _openRecruitment = val),
                activeThumbColor: Colors.white,
                activeTrackColor: BkuTheme.emerald,
                inactiveThumbColor: BkuTheme.textPlaceholder,
                inactiveTrackColor: BkuTheme.borderSubtle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Text('Periode Pendaftaran', style: BkuTheme.textSectionTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RecruitmentDateField(
                label: 'Tanggal Buka',
                date: _recruitmentStart,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RecruitmentDateField(
                label: 'Tanggal Tutup',
                date: _recruitmentEnd,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        BkuCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BkuTextField(
                label: 'Standar IPK Minimal (Opsional)',
                hint: 'e.g. 2.75',
                controller: _minIpkController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.star_rounded, size: 16, color: BkuTheme.amber),
              ),
              const SizedBox(height: 10),
              BkuTextField(
                label: 'Persyaratan Khusus Pendaftaran',
                hint: 'Tuliskan syarat pendaftaran (pisahkan per baris)...',
                controller: _requirementsController,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        BkuButton.primary(
          text: 'Simpan Pengaturan Rekrutmen',
          isLoading: _settingsLoading,
          onPressed: _settingsLoading ? null : _saveSettings,
          icon: Icons.save_rounded,
          height: 46,
        ),
      ],
    );
  }

  String _mapDbTypeToDisplay(String dbType) {
    switch (dbType.toLowerCase()) {
      case 'text':
        return 'Teks Singkat';
      case 'paragraph':
        return 'Paragraf';
      case 'select':
        return 'Dropdown';
      case 'checkbox':
        return 'Pilihan Ganda';
      case 'file':
        return 'Upload File';
      default:
        return 'Teks Singkat';
    }
  }

  String _mapDisplayToDbType(String display) {
    switch (display) {
      case 'Teks Singkat':
        return 'text';
      case 'Paragraf':
        return 'paragraph';
      case 'Dropdown':
        return 'select';
      case 'Pilihan Ganda':
        return 'checkbox';
      case 'Upload File':
        return 'file';
      default:
        return 'text';
    }
  }

  void _showAddFieldSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Jenis Input', style: BkuTheme.textSectionTitle),
            const SizedBox(height: 12),
            ..._fieldTypes.map((type) {
              return ListTile(
                title: Text(type, style: BkuTheme.textBodyRegular.copyWith(fontWeight: FontWeight.w600)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BkuTheme.primarySoft,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Icon(_getIconForFieldType(type), size: 18, color: BkuTheme.primary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _addFormField(_mapDisplayToDbType(type));
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFieldType(String type) {
    switch (type) {
      case 'Teks Singkat':
        return Icons.short_text_rounded;
      case 'Paragraf':
        return Icons.notes_rounded;
      case 'Dropdown':
        return Icons.arrow_drop_down_circle_outlined;
      case 'Pilihan Ganda':
        return Icons.check_box_outlined;
      case 'Upload File':
        return Icons.upload_file_rounded;
      default:
        return Icons.text_fields_rounded;
    }
  }
}