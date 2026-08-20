import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_date_field.dart';

class RecruitmentSettingsScreen extends StatefulWidget {
  const RecruitmentSettingsScreen({super.key});

  @override
  State<RecruitmentSettingsScreen> createState() => _RecruitmentSettingsScreenState();
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

  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentSettings();

    final settings = provider.recruitmentSettings;
    if (settings.isNotEmpty && mounted) {
      setState(() {
        _isOpenRecruitment = settings['open_recruitment'] ?? settings['isActive'] ?? false;
        final ipkRaw = settings['min_ipk'] ?? settings['minIpk'];
        _minIpk = double.tryParse(ipkRaw?.toString() ?? '2.5') ?? 2.5;
        _requirementsController.text =
            settings['recruitment_requirements'] ?? settings['requirements'] ?? '';

        final startRaw = settings['recruitment_start'] ?? settings['startDate'];
        if (startRaw != null) {
          _startDate = DateTime.tryParse(startRaw.toString());
        }

        final endRaw = settings['recruitment_end'] ?? settings['endDate'];
        if (endRaw != null) {
          _endDate = DateTime.tryParse(endRaw.toString());
        }
      });
    } else {
      _requirementsController.text =
          'Mahasiswa aktif\nMinimal IPK 2.50\nMengisi formulir pendaftaran';
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
                      ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        'open_recruitment': _isOpenRecruitment,
        'recruitment_requirements': _requirementsController.text.trim(),
        'min_ipk': _minIpk,
        'recruitment_start': _startDate != null
            ? DateTime.utc(
                _startDate!.year,
                _startDate!.month,
                _startDate!.day,
              ).toIso8601String()
            : null,
        'recruitment_end': _endDate != null
            ? DateTime.utc(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                23,
                59,
                59,
              ).toIso8601String()
            : null,
      };

      await context.read<OrmawaProvider>().updateRecruitmentSettings(payload);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengaturan Open Recruitment berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan pengaturan: $e');
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
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrmawaCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Status Open Recruitment',
                              style: OrmawaTheme.textCardTitle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OrmawaBadge(
                              text: _isOpenRecruitment ? 'AKTIF' : 'NONAKTIF',
                              variant: _isOpenRecruitment
                                  ? OrmawaBadgeVariant.success
                                  : OrmawaBadgeVariant.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isOpenRecruitment
                              ? 'Pendaftaran sedang terbuka untuk mahasiswa'
                              : 'Pendaftaran saat ini sedang ditutup',
                          style: OrmawaTheme.textCaption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOpenRecruitment,
                    onChanged: (value) => setState(() => _isOpenRecruitment = value),
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF16A34A),
                    inactiveThumbColor: const Color(0xFF94A3B8),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Periode Pendaftaran',
              style: OrmawaTheme.textSectionTitle,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Tanggal Buka',
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Tanggal Tutup',
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrmawaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: OrmawaTheme.statusWarningBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Standar IPK Minimal',
                            style: OrmawaTheme.textCardTitle,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrmawaTheme.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: OrmawaTheme.primaryBorder),
                        ),
                        child: Text(
                          _minIpk.toStringAsFixed(2),
                          style: OrmawaTheme.textBadge.copyWith(
                            color: OrmawaTheme.primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: OrmawaTheme.primary,
                      inactiveTrackColor: OrmawaTheme.primaryBorder,
                      thumbColor: OrmawaTheme.primaryDark,
                      overlayColor: OrmawaTheme.primarySoft,
                      trackHeight: 5,
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
            OrmawaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: OrmawaTheme.statusInfoBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFF0284C7),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Persyaratan Utama Pendaftaran',
                        style: OrmawaTheme.textCardTitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Persyaratan Khusus',
                    hintText: 'Tuliskan syarat pendaftaran (pisahkan per baris)...',
                    controller: _requirementsController,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OrmawaButton(
                text: 'SIMPAN PENGATURAN',
                onPressed: _isLoading ? null : _saveSettings,
                isLoading: _isLoading,
                icon: Icons.save_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.s100),
          ],
        ),
      ),
    );
  }
}