import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaRecruitmentScreen extends StatefulWidget {
  const OrmawaRecruitmentScreen({super.key});

  @override
  State<OrmawaRecruitmentScreen> createState() => _OrmawaRecruitmentScreenState();
}

class _OrmawaRecruitmentScreenState extends State<OrmawaRecruitmentScreen> with SingleTickerProviderStateMixin {
  String _activeTab = 'pendaftar';
  bool _isLoading = false;
  bool _isRefreshing = false;
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

  Future<void> _loadAllData([bool isRefresh = false]) async {
    if (!mounted) return;
    if (isRefresh) {
      setState(() => _isRefreshing = true);
    } else {
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
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Map<String, dynamic> _computeOprecStatus() {
    if (!_openRecruitment) {
      return {
        'label': 'Pendaftaran Ditutup',
        'color': const Color(0xFF64748B),
        'bg': const Color(0xFFF1F5F9),
        'border': const Color(0xFFCBD5E1),
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
          'color': const Color(0xFFD97706),
          'bg': const Color(0xFFFFFBEB),
          'border': const Color(0xFFFDE68A),
          'icon': Icons.schedule_rounded,
        };
      }
      if (today.isAfter(end)) {
        return {
          'label': 'Periode Berakhir',
          'color': const Color(0xFFE11D48),
          'bg': const Color(0xFFFFF1F2),
          'border': const Color(0xFFFECDD3),
          'icon': Icons.event_busy_rounded,
        };
      }
      final diffDays = end.difference(today).inDays;
      return {
        'label': 'Buka (Sisa $diffDays hari)',
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
        'icon': Icons.how_to_reg_rounded,
      };
    }

    return {
      'label': 'Pendaftaran Dibuka',
      'color': const Color(0xFF059669),
      'bg': const Color(0xFFECFDF5),
      'border': const Color(0xFFA7F3D0),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_rounded, color: Color(0xFFE11D48), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tolak Berkas Pelamar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tuliskan alasan penolakan berkas calon anggota ini untuk disampaikan secara transparan:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Contoh: IPK belum memenuhi standar / kuota divisi penuh...',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tolak Berkas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAccept ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAccept ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isAccept ? const Color(0xFF059669) : const Color(0xFFE11D48),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAccept ? 'Terima Massal' : 'Tolak Massal',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Text(
          isAccept
              ? 'Yakin ingin menerima $count pendaftar yang dipilih sebagai anggota resmi?'
              : 'Yakin ingin menolak $count berkas pendaftar yang dipilih?',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? const Color(0xFF059669) : const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isAccept ? 'Terima ($count)' : 'Tolak ($count)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            onPrimary: Colors.white,
            onSurface: Color(0xFF0F172A),
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_search_rounded, size: 20, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Berkas Pendaftar',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'KUALIFIKASI AKADEMIK & PILIHAN DIVISI',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFDBEAFE)),
                              ),
                              child: Center(
                                child: Text(
                                  (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusStr == 'aktif'
                                              ? const Color(0xFFECFDF5)
                                              : statusStr == 'pending'
                                                  ? const Color(0xFFFFFBEB)
                                                  : const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: statusStr == 'aktif'
                                                ? const Color(0xFFA7F3D0)
                                                : statusStr == 'pending'
                                                    ? const Color(0xFFFDE68A)
                                                    : const Color(0xFFFECDD3),
                                          ),
                                        ),
                                        child: Text(
                                          statusStr == 'aktif'
                                              ? 'DITERIMA'
                                              : statusStr == 'pending'
                                                  ? 'MENUNGGU REVIEW'
                                                  : 'DITOLAK',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: statusStr == 'aktif'
                                                ? const Color(0xFF047857)
                                                : statusStr == 'pending'
                                                    ? const Color(0xFFB45309)
                                                    : const Color(0xFFBE123C),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name.toString(),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        nim.toString(),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          prodi.toString(),
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('INDEKS PRESTASI (IPK)', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 3),
                                  Text(
                                    isMaba ? 'MABA' : (ipkVal != null ? double.tryParse(ipkVal.toString())?.toStringAsFixed(2) ?? '—' : '—'),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PILIHAN DIVISI 1', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 3),
                                  Text(
                                    divisi1.toString().toUpperCase(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PILIHAN DIVISI 2', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 3),
                                  Text(
                                    divisi2.toString(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TGL PENDAFTARAN', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                                  const SizedBox(height: 3),
                                  Text(
                                    applicant['CreatedAt'] != null && !applicant['CreatedAt'].toString().startsWith('0001')
                                        ? DateFormat('d MMM yyyy', 'id_ID').format(DateTime.tryParse(applicant['CreatedAt'].toString()) ?? DateTime.now())
                                        : '—',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (rejectionReason != null && rejectionReason.toString().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                                  SizedBox(width: 6),
                                  Text('Alasan Penolakan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFBE123C))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rejectionReason.toString(),
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF881337), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      const Text('MOTIVASI & ALASAN BERGABUNG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          alasan.toString(),
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), height: 1.45, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (customAnswers.isNotEmpty) ...[
                        const Text('JAWABAN FORMULIR KUSTOM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                        const SizedBox(height: 6),
                        ...customAnswers.entries.map((entry) {
                          final key = entry.key;
                          final val = entry.value;
                          final field = _formFields.firstWhere(
                            (f) => f['id'].toString() == key || f['label'].toString() == key,
                            orElse: () => {'label': 'Pertanyaan Tambahan', 'type': 'text'},
                          );
                          final label = field['label']?.toString().isNotEmpty == true ? field['label'].toString() : 'Pertanyaan Tambahan';
                          final isFile = (field['type']?.toString().toLowerCase() == 'file') || val.toString().startsWith('http') || val.toString().endsWith('.pdf');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                if (isFile)
                                  InkWell(
                                    onTap: () async {
                                      final uri = Uri.tryParse(val.toString());
                                      if (uri != null && await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF2563EB)),
                                        SizedBox(width: 4),
                                        Text('Buka File Lampiran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2563EB), decoration: TextDecoration.underline)),
                                      ],
                                    ),
                                  )
                                else
                                  Text(
                                    val.toString(),
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                      ],

                      if (cvUrl != null && cvUrl.toString().isNotEmpty) ...[
                        InkWell(
                          onTap: () async {
                            final uri = Uri.tryParse(cvUrl.toString());
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Curriculum Vitae / Portofolio', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                                      Text('Klik untuk meninjau berkas CV pelamar', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF2563EB)),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: Text('Pendaftar tidak mengunggah dokumen CV tambahan.', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (statusStr == 'pending')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _actionLoading ? null : () => _openRejectDialog(applicant),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Tolak Berkas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE11D48),
                            side: const BorderSide(color: Color(0xFFFECDD3)),
                            backgroundColor: const Color(0xFFFFF1F2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _actionLoading ? null : () => _handleAccept(id, applicant),
                          icon: _actionLoading
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Terima Anggota', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.userData?['user'] ?? auth.userData?['mahasiswa'] ?? auth.userData ?? {};
    final ormawaName = user['nama'] ?? user['Nama'] ?? 'ORMAWA';

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 11 ? 'Selamat Pagi' : hour < 15 ? 'Selamat Siang' : hour < 18 ? 'Selamat Sore' : 'Selamat Malam';

    final oprecStatus = _computeOprecStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          final acceptanceRate = totalCount > 0 ? ((acceptedCount / totalCount) * 100).round() : 0;

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

          return RefreshIndicator(
            onRefresh: () => _loadAllData(true),
            color: const Color(0xFF2563EB),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Open Recruitment',
                  subtitle: 'Pusat Rekrutmen & Seleksi Anggota',
                  expandedHeight: 120.0,
                  showBackButton: true,
                  isExpandable: false,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.how_to_reg_rounded, size: 20, color: Color(0xFF2563EB)),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$greeting,',
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            ormawaName.toString(),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: _isRefreshing ? null : () => _loadAllData(true),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: _isRefreshing
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))
                                          : const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF475569)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Kelola formulir pendaftaran dinamis, review berkas calon anggota, dan umumkan hasil seleksi secara terpadu.',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: oprecStatus['bg'] as Color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: oprecStatus['border'] as Color),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(oprecStatus['icon'] as IconData, size: 14, color: oprecStatus['color'] as Color),
                                    const SizedBox(width: 6),
                                    Text(
                                      oprecStatus['label'] as String,
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: oprecStatus['color'] as Color),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Total Pelamar',
                                value: '$totalCount',
                                subtitle: 'Pendaftar terdata',
                                icon: Icons.groups_rounded,
                                badgeColor: const Color(0xFF0284C7),
                                badgeText: 'Semua',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Menunggu Review',
                                value: '$pendingCount',
                                subtitle: 'Perlu diverifikasi',
                                icon: Icons.hourglass_top_rounded,
                                badgeColor: const Color(0xFFD97706),
                                badgeText: pendingCount > 0 ? '$pendingCount Baru' : 'Antrean',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Diterima',
                                value: '$acceptedCount',
                                subtitle: 'Resmi anggota',
                                icon: Icons.check_circle_rounded,
                                badgeColor: const Color(0xFF059669),
                                badgeText: totalCount > 0 ? '$acceptanceRate%' : 'Lolos',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Tidak Lolos',
                                value: '$rejectedCount',
                                subtitle: 'Belum sesuai',
                                icon: Icons.cancel_rounded,
                                badgeColor: const Color(0xFFE11D48),
                                badgeText: 'Gagal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentTab(
                                id: 'pendaftar',
                                label: 'Pendaftar',
                                icon: Icons.groups_rounded,
                                count: pendingCount > 0 ? pendingCount : null,
                              ),
                              _buildSegmentTab(
                                id: 'form',
                                label: 'Form Builder',
                                icon: Icons.dynamic_form_rounded,
                                count: _formFields.isNotEmpty ? _formFields.length : null,
                              ),
                              _buildSegmentTab(
                                id: 'pengaturan',
                                label: 'Pengaturan',
                                icon: Icons.tune_rounded,
                                hasDot: _openRecruitment,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
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
                else if (_activeTab == 'pendaftar')
                  _buildTabPendaftar(filteredApplicants, totalCount, pendingCount, acceptedCount, rejectedCount)
                else if (_activeTab == 'form')
                  _buildTabFormBuilder()
                else
                  _buildTabPengaturan(),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentTab({
    required String id,
    required String label,
    required IconData icon,
    int? count,
    bool hasDot = false,
  }) {
    final isActive = _activeTab == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
              if (hasDot && !isActive) ...[
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPendaftar(
    List<Map<String, dynamic>> applicants,
    int totalCount,
    int pendingCount,
    int acceptedCount,
    int rejectedCount,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Cari pendaftar berdasarkan nama atau NIM...',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('semua', 'Semua ($totalCount)'),
                  const SizedBox(width: 6),
                  _buildFilterChip('pending', 'Menunggu ($pendingCount)'),
                  const SizedBox(width: 6),
                  _buildFilterChip('aktif', 'Diterima ($acceptedCount)'),
                  const SizedBox(width: 6),
                  _buildFilterChip('tidak_aktif', 'Ditolak ($rejectedCount)'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_selectedIds.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedIds.length} Dipilih',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _openBulkActionDialog('accept'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Terima Semua', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _openBulkActionDialog('reject'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Tolak Semua', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (applicants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_outline_rounded, color: Color(0xFF94A3B8), size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text('Tidak Ada Pendaftar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Belum ada data pendaftar yang sesuai kriteria pencarian.', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)), textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: applicants.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final item = applicants[i];
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

                  return InkWell(
                    onTap: () => _showReviewModal(item),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            activeColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                (name.toString().isNotEmpty ? name.toString()[0] : 'P').toUpperCase(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name.toString(),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: status == 'aktif'
                                            ? const Color(0xFFECFDF5)
                                            : status == 'pending'
                                                ? const Color(0xFFFFFBEB)
                                                : const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status == 'aktif' ? 'Diterima' : status == 'pending' ? 'Menunggu' : 'Ditolak',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          color: status == 'aktif'
                                              ? const Color(0xFF047857)
                                              : status == 'pending'
                                                  ? const Color(0xFFB45309)
                                                  : const Color(0xFFBE123C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$nim • $prodi',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Divisi: $divisi',
                                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: isMaba ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isMaba ? 'MABA' : 'IPK: ${ipkVal != null ? double.tryParse(ipkVal.toString())?.toStringAsFixed(2) ?? '—' : '—'}',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                          color: isMaba ? const Color(0xFFB45309) : const Color(0xFF334155),
                                        ),
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
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filterStatus == key;
    return InkWell(
      onTap: () => setState(() => _filterStatus = key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTabFormBuilder() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TAMBAH PERTANYAAN KUSTOM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAddFieldChip('Teks', Icons.short_text_rounded, 'text'),
                        const SizedBox(width: 6),
                        _buildAddFieldChip('Paragraf', Icons.notes_rounded, 'paragraph'),
                        const SizedBox(width: 6),
                        _buildAddFieldChip('Pilihan', Icons.list_rounded, 'select'),
                        const SizedBox(width: 6),
                        _buildAddFieldChip('Upload', Icons.upload_file_rounded, 'file'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_formFields.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.dynamic_form_rounded, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text('Belum Ada Pertanyaan Tambahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Formulir saat ini hanya memuat biodata standar. Tambahkan pertanyaan kustom di atas.', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)), textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _formFields.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final field = _formFields[i];
                  final type = field['type']?.toString() ?? 'text';

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.help_outline_rounded, size: 12, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pertanyaan ${i + 1}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: i > 0 ? () => _moveFormField(i, -1) : null,
                                    icon: const Icon(Icons.arrow_upward_rounded, size: 14),
                                    color: i > 0 ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 14,
                                  ),
                                  Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                                  IconButton(
                                    onPressed: i < _formFields.length - 1 ? () => _moveFormField(i, 1) : null,
                                    icon: const Icon(Icons.arrow_downward_rounded, size: 14),
                                    color: i < _formFields.length - 1 ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 14,
                                  ),
                                  Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                                  IconButton(
                                    onPressed: () => _removeFormField(i),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFE11D48)),
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: TextEditingController(text: field['label']?.toString() ?? '')..selection = TextSelection.collapsed(offset: (field['label']?.toString() ?? '').length),
                          onChanged: (val) => field['label'] = val,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Tulis judul pertanyaan kustom...',
                            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: type,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    items: const [
                                      DropdownMenuItem(value: 'text', child: Text('Teks Pendek')),
                                      DropdownMenuItem(value: 'paragraph', child: Text('Paragraf / Uraian')),
                                      DropdownMenuItem(value: 'select', child: Text('Pilihan (Dropdown)')),
                                      DropdownMenuItem(value: 'file', child: Text('Unggah Berkas')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => field['type'] = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => setState(() => field['required'] = !(field['required'] == true)),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: field['required'] == true ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: field['required'] == true ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: field['required'] == true,
                                        onChanged: (val) => setState(() => field['required'] = val ?? false),
                                        activeColor: const Color(0xFF2563EB),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Wajib Diisi',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: field['required'] == true ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (type == 'select') ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: TextEditingController(text: field['options']?.toString() ?? '')..selection = TextSelection.collapsed(offset: (field['options']?.toString() ?? '').length),
                            onChanged: (val) => field['options'] = val,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Opsi pilihan (pisahkan koma): Divisi Acara, Humas, Logistik...',
                              hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _settingsLoading ? null : _saveFormFields,
                icon: _settingsLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 16),
                label: const Text('Simpan Perubahan Formulir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFieldChip(String label, IconData icon, String type) {
    return InkWell(
      onTap: () => _addFormField(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPengaturan() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Status Open Recruitment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _openRecruitment ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _openRecruitment ? 'AKTIF' : 'NONAKTIF',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: _openRecruitment ? const Color(0xFF047857) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Tampilkan pendaftaran di portal mahasiswa', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _openRecruitment,
                    onChanged: (val) => setState(() => _openRecruitment = val),
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF059669),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCBD5E1),
                    trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TGL BUKA', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF2563EB)),
                              const SizedBox(width: 6),
                              Text(
                                _recruitmentStart != null ? DateFormat('d MMM yyyy', 'id_ID').format(_recruitmentStart!) : 'Pilih Tanggal',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TGL TUTUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event_busy_rounded, size: 14, color: Color(0xFFE11D48)),
                              const SizedBox(width: 6),
                              Text(
                                _recruitmentEnd != null ? DateFormat('d MMM yyyy', 'id_ID').format(_recruitmentEnd!) : 'Pilih Tanggal',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BATAS IPK MINIMAL (0 - 4.00)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _minIpkController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: '0.00 (Tanpa Batas IPK)',
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.school_rounded, size: 16, color: Color(0xFFD97706)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PERSYARATAN & KETENTUAN KHUSUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _requirementsController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), height: 1.45, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan syarat administratif, komitmen, atau ketentuan khusus di sini...',
                      hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _settingsLoading ? null : _saveSettings,
                icon: _settingsLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 16),
                label: const Text('Simpan Pengaturan Pendaftaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
