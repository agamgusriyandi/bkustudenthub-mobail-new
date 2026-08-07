import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class MentorSessionAttendanceScreen extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;

  const MentorSessionAttendanceScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<MentorSessionAttendanceScreen> createState() => _MentorSessionAttendanceScreenState();
}

class _MentorSessionAttendanceScreenState extends State<MentorSessionAttendanceScreen> {
  List<SessionAttendanceData> _attendances = [];
  bool _isLoading = true;
  bool _isSaving = false;
  
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedFaculty = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<MentorKencanaProvider>();
    final data = await provider.fetchSessionAttendanceList(widget.sessionId);
    if (mounted) {
      setState(() {
        _attendances = data;
        _isLoading = false;
      });
    }
  }

  void _savePresensi() async {
    setState(() => _isSaving = true);
    final provider = context.read<MentorKencanaProvider>();
    final bool hasValidatedBefore = _attendances.any((e) => e.status == 'Hadir' || e.status == 'Izin' || e.status == 'Sakit' || e.status == 'Alpha');
    
    final List<Map<String, dynamic>> payload = _attendances.map((e) {
      String mappedStatus = 'absent';
      if (e.status == 'Hadir') {
        mappedStatus = 'present';
      } else if (e.status == 'Izin' || e.status == 'Sakit') {
        mappedStatus = 'permission';
      }
      return {
        'student_id': e.id,
        'status': mappedStatus,
      };
    }).toList();

    final success = await provider.submitBulkSessionAttendance(widget.sessionId, payload);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        if (hasValidatedBefore) {
          AppSnackbar.showSuccess(context, 'Anda sudah berhasil memvalidasi & memperbarui presensi sesi ini!');
        } else {
          AppSnackbar.showSuccess(context, 'Anda sudah berhasil melakukan presensi!');
        }
        context.pop();
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan presensi');
      }
    }
  }

  void _updateStatus(int studentId, String status) {
    setState(() {
      final idx = _attendances.indexWhere((e) => e.id == studentId);
      if (idx != -1) {
        final old = _attendances[idx];
        _attendances[idx] = SessionAttendanceData(
          id: old.id,
          name: old.name,
          nim: old.nim,
          programStudi: old.programStudi,
          faculty: old.faculty,
          status: status,
          originalStatus: old.originalStatus,
          reason: old.reason,
          attachmentUrl: old.attachmentUrl,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidated = _attendances.any((e) => e.status == 'Hadir' || e.status == 'Izin' || e.status == 'Sakit' || e.status == 'Alpha');

    final filtered = _attendances.where((e) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!e.name.toLowerCase().contains(q) && !e.nim.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedStatus != 'all') {
        if (e.status.toLowerCase() != _selectedStatus.toLowerCase()) return false;
      }
      if (_selectedFaculty != 'all') {
        if (e.faculty.toLowerCase() != _selectedFaculty.toLowerCase()) return false;
      }
      return true;
    }).toList();

    final uniqueFaculties = _attendances.map((e) => e.faculty).where((e) => e.isNotEmpty).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: _isLoading
          ? const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
          : CustomScrollView(
              slivers: [
                BkuAppBar(
                  title: 'Validasi Kehadiran Sesi',
                  info: 'Sesi: ${widget.sessionTitle}',
                  variant: AppBarVariant.student,
                  showBackButton: true,
                  isExpandable: false,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/mentor-kencana/attendance');
                    }
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daftar Hadir Mahasiswa',
                                          style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral900),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tandai kehadiran (Hadir, Izin, atau Alpha) lalu klik Simpan.',
                                          style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 32,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            showDialog(context: context, builder: (_) => SessionQrModal(sessionId: widget.sessionId));
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                                            side: const BorderSide(color: AppColors.neutral300),
                                          ),
                                          child: const Text('QR Presensi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.neutral900)),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: _savePresensi,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2563EB),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                                            elevation: 0,
                                          ),
                                          child: _isSaving 
                                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                            : Text(hasValidated ? 'Simpan Perubahan' : 'Simpan Presensi', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (hasValidated) ...[
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha(20),
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(color: AppColors.success.withAlpha(50)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Presensi Sesi Ini Sudah Divalidasi (Sudah Absen)',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manajemen Data', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Menampilkan daftar data yang terdaftar dalam sistem.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: AppRadius.radiusXl,
                                border: Border.all(color: AppColors.neutral300),
                              ),
                              child: Text(
                                'TOTAL DATA ${filtered.length}',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral900,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Filters
                        TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Cari NIM atau nama mahasiswa...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                                ),
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('Semua Status', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                  DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                                  DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                                  DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                                  DropdownMenuItem(value: 'Alpha', child: Text('Alpha')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedStatus = val);
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedFaculty,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                                ),
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(value: 'all', child: Text('Semua Fakultas', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                  ...uniqueFaculties.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedFaculty = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada data yang cocok', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final mentee = filtered[index];
                        return BkuCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      mentee.name,
                                      style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (mentee.originalStatus == 'permission_requested')
                                    GestureDetector(
                                      onTap: () => _showPermissionModal(context, mentee),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: context.appColors.warning.withAlpha(20),
                                          borderRadius: AppRadius.radiusSm,
                                          border: Border.all(color: context.appColors.warning.withAlpha(50)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility_rounded, size: 12, color: context.appColors.warning),
                                            const SizedBox(width: 4),
                                            Text('Lihat Izin', style: AppTextStyles.labelSm.copyWith(color: context.appColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NIM: ${mentee.nim} • ${mentee.programStudi} • ${mentee.faculty}',
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.appColors.surface,
                                  borderRadius: AppRadius.radiusLg,
                                  border: Border.all(color: context.appColors.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    _buildSegmentedButton('Hadir', mentee.id, mentee.status, context.appColors.success, matchStatus: ['Hadir', 'hadir', 'present', 'attended']),
                                    const SizedBox(width: 4),
                                    _buildSegmentedButton('Izin / Sakit', mentee.id, mentee.status, context.appColors.warning, matchStatus: ['Izin', 'Sakit', 'izin', 'sakit', 'permission']),
                                    const SizedBox(width: 4),
                                    _buildSegmentedButton('Alpha', mentee.id, mentee.status, context.appColors.error, matchStatus: ['Alpha', 'alpha', 'absent']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showPermissionModal(BuildContext context, SessionAttendanceData mentee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: context.appColors.primary),
            const SizedBox(width: 8),
            Text('Detail Izin', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alasan:', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(mentee.reason.isNotEmpty ? mentee.reason : '-', style: AppTextStyles.labelSm),
            const SizedBox(height: 16),
            if (mentee.attachmentUrl.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: context.appColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 16, color: context.appColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mentee.attachmentUrl,
                        style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: TextStyle(color: context.appColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton(String label, int studentId, String currentStatus, Color activeColor, {List<String>? matchStatus}) {
    final isActive = matchStatus != null 
        ? matchStatus.map((e)=>e.toLowerCase()).contains(currentStatus.toLowerCase()) 
        : currentStatus.toLowerCase() == label.toLowerCase();
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          String newStatus = label;
          if (label == 'Izin / Sakit') newStatus = 'Izin'; // default to Izin if they tap the grouped one, usually UI handles it specifically but this is fine
          _updateStatus(studentId, newStatus);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: AppRadius.radiusMd,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.neutral600,
            ),
          ),
        ),
      ),
    );
  }
}

class SessionQrModal extends StatefulWidget {
  final int sessionId;
  const SessionQrModal({super.key, required this.sessionId});

  @override
  State<SessionQrModal> createState() => _SessionQrModalState();
}

class _SessionQrModalState extends State<SessionQrModal> {
  late Timer _timer;
  int _countdown = 45;
  String _qrData = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _fetchToken();
        }
      });
    });
  }

  Future<void> _fetchToken() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final token = await context.read<MentorKencanaProvider>().fetchSessionQrToken(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _qrData = token ?? 'kencana-presensi-${widget.sessionId}-${DateTime.now().millisecondsSinceEpoch}';
      _countdown = 45;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      backgroundColor: context.appColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('QR Code Presensi Sesi', style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Otomatis diperbarui dalam $_countdown detik', style: AppTextStyles.labelSm.copyWith(color: context.appColors.error, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral200, // Neutral soft background instead of stark white
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: context.appColors.outline.withAlpha(50)),
              ),
              child: _isLoading && _qrData.isEmpty
                  ? const SizedBox(
                      width: 200.0,
                      height: 200.0,
                      child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
                    )
                  : QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.neutral900,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.neutral900,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: BkuButton(
                text: 'Tutup',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
