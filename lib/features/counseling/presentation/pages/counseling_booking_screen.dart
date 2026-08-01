import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CounselingBookingScreen extends StatefulWidget {
  /// Jika diberikan, langsung load jadwal psikolog ini
  final String? psikologId;

  final String? rescheduleBookingId;

  const CounselingBookingScreen({
    super.key,
    this.psikologId,
    this.rescheduleBookingId,
  });

  @override
  State<CounselingBookingScreen> createState() =>
      _CounselingBookingScreenState();
}

class _CounselingBookingScreenState extends State<CounselingBookingScreen> {
  Map<String, dynamic>? _selectedSlot;
  final _complaintCtrl = TextEditingController();
  String? _attachmentPath;
  bool _isSubmitting = false;
  String _selectedMode = 'Tatap Muka';
  String _selectedKategori = 'Stres Akademik';

  static const List<String> _kategoriList = [
    'Stres Akademik',
    'Kecemasan',
    'Masalah Keluarga',
    'Karir & Masa Depan',
    'Hubungan Sosial',
    'Kesehatan Mental',
    'Lainnya',
  ]; // "Tatap Muka" atau "Online"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<StudentCounselingProvider>();
      if (widget.psikologId != null && widget.psikologId!.isNotEmpty) {
        p.loadPsychologistSchedules(widget.psikologId!);
      } else {
        p.loadAvailableSchedules();
      }
    });
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        final slots =
            widget.psikologId != null
                ? provider.psychologistSlots
                : provider.availableSchedules;
        final psikologDetail =
            widget.psikologId != null
                ? provider.psychologistDetail
                : <String, dynamic>{};

        return Scaffold(
          backgroundColor: context.appColors.surface,
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.psikologId != null && widget.psikologId!.isNotEmpty) {
                await provider.loadPsychologistSchedules(widget.psikologId!);
              } else {
                await provider.loadAvailableSchedules();
              }
            },
            color: context.watch<ThemeProvider>().primary,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: BkuStaticAppBar(
                    title: 'Booking Konseling',
                    variant: AppBarVariant.student,
                    showBackButton: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.rescheduleBookingId != null)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            margin: EdgeInsets.only(bottom: AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: context
                                  .watch<ThemeProvider>()
                                  .warning
                                  .withAlpha(20),
                              borderRadius: AppRadius.radiusLg,
                              border: Border.all(
                                color: context
                                    .watch<ThemeProvider>()
                                    .warning
                                    .withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: context.watch<ThemeProvider>().warning,
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Kamu sedang melakukan penjadwalan ulang (Reschedule) untuk sesi konseling.',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color:
                                          context
                                              .watch<ThemeProvider>()
                                              .warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (psikologDetail.isNotEmpty)
                          _buildPsychologistBrief(psikologDetail),
                        if (psikologDetail.isNotEmpty) SizedBox(height: AppSpacing.xxl),
                        _buildSectionHeader('Pilih Slot Jadwal'),
                        SizedBox(height: AppSpacing.sm),
                        // Info kuota
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          margin: EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.info.withAlpha(15),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Expanded(
                                child: Text(
                                  'Slot abu-abu = penuh atau sudah kamu booking. Tarik ke bawah untuk refresh.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.neutral700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        SizedBox(height: AppSpacing.lg),
                        _buildSlotList(slots),
                        SizedBox(height: AppSpacing.xl),
                        _buildSectionHeader('Topik / Kategori Konseling'),
                        SizedBox(height: AppSpacing.lg),
                        _buildKategoriSelector(),
                        SizedBox(height: AppSpacing.xl),
                        _buildSectionHeader('Mode Konseling'),
                        SizedBox(height: AppSpacing.lg),
                        _buildModeSelector(),
                        SizedBox(height: AppSpacing.xl),
                        _buildSectionHeader('Keluhan Singkat'),
                        SizedBox(height: AppSpacing.lg),
                        _buildComplaintField(),
                        SizedBox(height: AppSpacing.xl),
                        _buildAttachmentField(),
                        SizedBox(height: AppSpacing.xxl),
                        _buildConfirmButton(provider),
                        SizedBox(height: AppSpacing.s48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPsychologistBrief(Map<String, dynamic> p) {
    final name = p['name']?.toString() ?? '-';
    final spec = p['specialization']?.toString() ?? '-';

    final rawPhoto = () {
      final possibleKeys = [
        'foto_url',
        'photo_url',
        'photoUrl',
        'FotoURL',
        'foto',
        'Foto',
        'avatar_url',
        'avatar',
      ];
      for (final key in possibleKeys) {
        if (p[key] != null && p[key].toString().trim().isNotEmpty) {
          return p[key].toString().trim();
        }
      }
      final user = p['user'] ?? p['User'] ?? p['Pengguna'] ?? p['pengguna'];
      if (user is Map) {
        for (final key in possibleKeys) {
          if (user[key] != null && user[key].toString().trim().isNotEmpty) {
            return user[key].toString().trim();
          }
        }
      }
      return '';
    }();
    final photoUrl = rawPhoto.isNotEmpty ? ApiGate.getImageUrl(rawPhoto) : '';
    debugPrint('AVATAR_DEBUG booking_screen: $photoUrl');

    return BkuCard(
      backgroundColor: AppColors.neutral100,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.neutral200,
            child: ClipOval(
              child:
                  photoUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: 
                        photoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.neutral700,
                              size: 30,
                            ),
                        placeholder: (context, url) => Container(color: AppColors.neutral200),
                      )
                      : const Icon(
                        Icons.person_rounded,
                        color: AppColors.neutral700,
                        size: 30,
                      ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  spec,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.watch<ThemeProvider>().outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLg.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral900,
      ),
    );
  }

  Widget _buildSlotList(List<Map<String, dynamic>> slots) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;
    final outlineColor = themeProvider.outline;
    final infoColor = themeProvider.info;
    final errorColor = themeProvider.colorError;

    return Column(
      children:
          slots.map((slot) {
            final isSelected = _selectedSlot?['id'] == slot['id'];
            final hari =
                slot['hari']?.toString() ?? slot['day']?.toString() ?? '-';
            final start =
                slot['jam_mulai']?.toString() ??
                slot['start']?.toString() ??
                '-';
            final end =
                slot['jam_selesai']?.toString() ??
                slot['end']?.toString() ??
                '-';
            final lokasi =
                slot['lokasi']?.toString() ??
                slot['location']?.toString() ??
                '';
            final kategori =
                slot['kategori']?.toString() ??
                slot['category']?.toString() ??
                '';
            // Parse aman — Dio return num bukan int dari JSON
            final sisaKuotaRaw = slot['sisa_kuota'] ?? slot['quota'];
            final sisaKuota =
                sisaKuotaRaw != null ? (sisaKuotaRaw as num).toInt() : 1;
            final kuotaRaw = slot['kuota'] ?? slot['quota'];
            final kuota = kuotaRaw != null ? (kuotaRaw as num).toInt() : 1;
            final displayDate = slot['display_date']?.toString() ?? '';
            // Penuh = sisa kuota 0 (sudah ada booking sebanyak kuota)
            final isFull = sisaKuota <= 0;
            // Mahasiswa ini sendiri sudah booking slot ini
            final alreadyBooked = slot['already_booked'] == true;
            // Disabled = penuh ATAU sudah dibooking mahasiswa ini
            final isDisabled = isFull || alreadyBooked;

            // Psikolog info (untuk available schedules)
            final psikolog = slot['psychologist'] as Map<String, dynamic>?;
            final psikologName = psikolog?['name']?.toString() ?? '';

            return GestureDetector(
              onTap:
                  isDisabled
                      ? null
                      : () => setState(
                        () => _selectedSlot = isSelected ? null : slot,
                      ),
              child: BkuCard(
                backgroundColor: isSelected ? primaryColor : context.appColors.surface,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            isDisabled
                                ? AppColors.neutral200.withAlpha(20)
                                : isSelected
                                ? context.appColors.onPrimary.withAlpha(30)
                                : AppColors.neutral100,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        alreadyBooked
                            ? Icons.check_circle_outline_rounded
                            : isFull
                            ? Icons.block_rounded
                            : Icons.schedule_rounded,
                        color:
                            isDisabled
                                ? AppColors.neutral500
                                : isSelected
                                ? context.appColors.onPrimary
                                : AppColors.neutral700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$hari, $start - $end',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color:
                                   isDisabled
                                       ? AppColors.neutral500
                                       : isSelected
                                       ? context.appColors.onPrimary
                                       : AppColors.neutral900,
                            ),
                          ),
                          if (displayDate.isNotEmpty)
                            Text(
                              displayDate,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isDisabled
                                        ? AppColors.neutral500
                                      : isSelected
                                        ? context.appColors.onPrimary
                                      : outlineColor,
                              ),
                            ),
                            if (psikologName.isNotEmpty)
                              Text(
                                psikologName,
                                style: AppTextStyles.labelSm.copyWith(
                                  color:
                                      isDisabled
                                          ? AppColors.neutral500
                                        : isSelected
                                      ? context.appColors.onPrimary
                                        : primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (kategori.isNotEmpty)
                                _buildChip(
                                  kategori,
                                  isSelected
                                      ? context.appColors.onPrimary
                                      : AppColors.neutral700,
                                  isSelected,
                                  isDisabled,
                                ),
                              if (lokasi.isNotEmpty)
                                _buildChip(
                                  lokasi,
                                  isSelected ? context.appColors.onPrimary : context.appColors.info,
                                  isSelected,
                                  isDisabled,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (alreadyBooked)
                          _buildBadge('Sudah\nDibooking', infoColor)
                        else if (isFull)
                          _buildBadge('Penuh', errorColor)
                        else ...[
                          Text(
                            'Sisa $sisaKuota/$kuota',
                            style: AppTextStyles.labelSm.copyWith(
                              color: isSelected ? context.appColors.onPrimary : outlineColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildChip(
    String label,
    Color color,
    bool isSelected,
    bool isDisabled,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isDisabled
                ? AppColors.neutral500.withAlpha(15)
                : isSelected
                ? context.appColors.onPrimary.withAlpha(30)
                : color.withAlpha(15),
        borderRadius: AppRadius.radiusXs,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color:
            isDisabled
                ? AppColors.neutral500
                : isSelected
                ? context.appColors.onPrimary
                : color,
            fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSm.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildKategoriSelector() {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih kategori yang paling sesuai dengan keluhan Anda',
            style: AppTextStyles.labelMd.copyWith(
              color: context.watch<ThemeProvider>().outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _kategoriList.map((kategori) {
                  final isSelected = _selectedKategori == kategori;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedKategori = kategori),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.neutral900
                                : context.watch<ThemeProvider>().background,
                        borderRadius: AppRadius.radiusXl,
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.neutral900
                                  : context
                                      .watch<ThemeProvider>()
                                      .outlineVariant,
                        ),
                      ),
                      child: Text(
                        kategori,
                        style: AppTextStyles.labelMd.copyWith(
                          color:
                              isSelected
                                  ? context.appColors.onPrimary
                                  : context.watch<ThemeProvider>().onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = 'Tatap Muka'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _selectedMode == 'Tatap Muka' ? AppColors.success : context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                    color:
                      _selectedMode == 'Tatap Muka'
                          ? AppColors.success
                          : AppColors.neutral300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.neutral500,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tatap Muka',
                    style: TextStyle(
                      color:
                          _selectedMode == 'Tatap Muka'
                              ? context.appColors.onPrimary
                              : AppColors.neutral800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = 'Daring'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _selectedMode == 'Daring'
                        ? AppColors.success
                        : context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color:
                      _selectedMode == 'Daring'
                          ? AppColors.success
                          : AppColors.neutral300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.video_camera_front_rounded,
                    color: _selectedMode == 'Daring' ? context.appColors.onPrimary : AppColors.neutral500,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Daring',
                    style: TextStyle(
                      color:
                          _selectedMode == 'Daring'
                              ? context.appColors.onPrimary
                              : AppColors.neutral800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintField() {
    return TextField(
      controller: _complaintCtrl,
      maxLines: 4,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(
        hintText: 'Ceritakan keluhan atau topik yang ingin kamu diskusikan...',
        hintStyle: AppTextStyles.labelMd.copyWith(
          color: context.watch<ThemeProvider>().outline.withAlpha(100),
        ),
        filled: true,
        fillColor: context.watch<ThemeProvider>().background,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusXl,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(AppSpacing.xl),
      ),
    );
  }

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lampiran (Opsional)'),
        SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: _pickFile,
          borderRadius: AppRadius.radiusLg,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().background,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color:
                    _attachmentPath != null
                        ? context.watch<ThemeProvider>().primary
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _attachmentPath != null
                      ? Icons.check_circle_rounded
                      : Icons.attach_file_rounded,
                  color:
                      _attachmentPath != null
                          ? context.watch<ThemeProvider>().primary
                          : context.watch<ThemeProvider>().outline.withAlpha(
                            150,
                          ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _attachmentPath != null
                        ? _attachmentPath!.split('/').last
                        : 'Unggah file (PDF/Gambar)',
                    style: AppTextStyles.labelMd.copyWith(
                      color:
                          _attachmentPath != null
                              ? context.watch<ThemeProvider>().onSurface
                              : context
                                  .watch<ThemeProvider>()
                                  .outline
                                  .withAlpha(150),
                      fontWeight:
                          _attachmentPath != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_attachmentPath != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    onPressed: () => setState(() => _attachmentPath = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachmentPath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file: $e');
      }
    }
  }

  Widget _buildConfirmButton(StudentCounselingProvider provider) {
    return BkuButton(
      text:
          widget.rescheduleBookingId != null
              ? 'Konfirmasi Reschedule'
              : 'Lanjutkan Booking',
      onPressed: _selectedSlot == null ? null : () => _submit(provider),
      isLoading: _isSubmitting,
      height: 60,
      variant: BkuButtonVariant.success,
    );
  }

  Future<void> _submit(StudentCounselingProvider provider) async {
    if (_selectedSlot == null) return;
    setState(() => _isSubmitting = true);

    final slot = _selectedSlot!;

    dynamic rawPsikologId =
        slot['psikolog_id'] ??
        slot['psychologist_id'] ??
        slot['dosen_id'] ??
        slot['DosenID'] ??
        slot['PsikologID'] ??
        slot['psychologistId'] ??
        slot['PsychologistID'];

    if ((rawPsikologId == null || rawPsikologId == 0 || rawPsikologId == '0') &&
        slot['psychologist'] is Map) {
      final psych = slot['psychologist'] as Map<String, dynamic>;
      rawPsikologId =
          psych['id'] ??
          psych['ID'] ??
          psych['dosen_id'] ??
          psych['DosenID'] ??
          psych['psikolog_id'] ??
          psych['PsikologID'];
    }

    if ((rawPsikologId == null || rawPsikologId == 0 || rawPsikologId == '0') &&
        slot['psikolog'] is Map) {
      final psik = slot['psikolog'] as Map<String, dynamic>;
      rawPsikologId =
          psik['id'] ??
          psik['ID'] ??
          psik['dosen_id'] ??
          psik['DosenID'] ??
          psik['psikolog_id'] ??
          psik['PsikologID'];
    }

    if (rawPsikologId == null || rawPsikologId == 0 || rawPsikologId == '0') {
      rawPsikologId =
          widget.psikologId ??
          provider.psychologistDetail['id'] ??
          provider.psychologistDetail['ID'] ??
          provider.psychologistDetail['dosen_id'] ??
          provider.psychologistDetail['DosenID'];
    }

    final int psikologId = int.tryParse(rawPsikologId?.toString() ?? '') ?? 0;

    dynamic rawSlotId =
        slot['id'] ??
        slot['ID'] ??
        slot['slot_id'] ??
        slot['SlotID'] ??
        slot['slotId'];
    final int slotId = int.tryParse(rawSlotId?.toString() ?? '') ?? 0;

    final date =
        slot['tanggal']?.toString() ?? slot['next_date']?.toString() ?? '';
    final start =
        slot['jam_mulai']?.toString() ?? slot['start']?.toString() ?? '';
    final end =
        slot['jam_selesai']?.toString() ?? slot['end']?.toString() ?? '';

    final isReschedule = widget.rescheduleBookingId != null;

    if (!isReschedule) {
      final agreed = await _showInformedConsent();
      if (!agreed) {
        setState(() => _isSubmitting = false);
        return;
      }
    }

    bool success = false;

    if (isReschedule) {
      success = await provider.rescheduleBooking(
        bookingId: widget.rescheduleBookingId!,
        date: date,
        start: start,
        end: end,
      );
    } else {
      success = await provider.createBooking(
        psikologId: psikologId,
        slotId: slotId,
        date: date,
        start: start,
        end: end,
        topic: _selectedKategori,
        complaint: _complaintCtrl.text.trim(),
        mode: _selectedMode,
        attachmentPath: _attachmentPath,
      );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        final studentProvider = context.read<StudentProvider>();

        AppSnackbar.showSuccess(
          context,
          isReschedule
              ? 'Jadwal konseling berhasil diperbarui'
              : 'Pendaftaran konseling berhasil dikirim',
        );

        studentProvider.loadAllData();
        Navigator.pop(context);
      } else {
        AppSnackbar.showError(
          context,
          provider.bookingError ??
              (isReschedule
                  ? 'Gagal mereschedule booking'
                  : 'Gagal melakukan booking konseling'),
        );
      }
    }
  }

  Future<bool> _showInformedConsent() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _InformedConsentSheet(
            onAgree: () => Navigator.pop(ctx, true),
            onCancel: () => Navigator.pop(ctx, false),
          ),
    );
    return result ?? false;
  }
}

class _InformedConsentSheet extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onCancel;

  const _InformedConsentSheet({
    required onAgree,
    required onCancel,
  })  : onAgree = onAgree,
        onCancel = onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral500.withAlpha(60),
              borderRadius: AppRadius.radiusXs,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
                    padding: AppSpacing.paddingLg,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Informed Consent Digital',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.appColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Harap baca dan setujui lembar persetujuan layanan konseling di bawah ini sebelum melanjutkan pendaftaran.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildClauseItem(
                  context,
                  '1. Kerahasiaan Informasi',
                  'Semua informasi yang Anda bagikan selama sesi konseling bersifat rahasia dan dilindungi, kecuali jika terdapat indikasi yang membahayakan diri sendiri atau orang lain.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildClauseItem(
                  context,
                  '2. Keterbukaan & Kerjasama',
                  'Proses konseling berjalan efektif apabila Anda bersedia menyampaikan keluhan dengan jujur dan bekerja sama secara aktif dengan konselor/psikolog.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildClauseItem(
                  context,
                  '3. Penjadwalan & Kehadiran',
                  'Anda diharapkan hadir tepat waktu sesuai jadwal slot yang dipilih. Jika ingin melakukan pembatalan atau penjadwalan ulang, harap lakukan sebelum sesi dimulai.',
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl + AppSpacing.sm,
              top: AppSpacing.md,
            ),
            decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutral500.withAlpha(100))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.neutral500.withAlpha(50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: BkuButton(
                    text: 'Saya Setuju',
                    onPressed: onAgree,
                    height: 52,
                    variant: BkuButtonVariant.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClauseItem(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.background,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: context.appColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
