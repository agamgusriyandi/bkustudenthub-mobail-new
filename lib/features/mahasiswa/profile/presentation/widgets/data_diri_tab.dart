import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class DataDiriTabWidget extends StatefulWidget {
  const DataDiriTabWidget({super.key});

  @override
  State<DataDiriTabWidget> createState() => _DataDiriTabWidgetState();
}

class _DataDiriTabWidgetState extends State<DataDiriTabWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Map<String, dynamic> _formData;
  final Map<String, TextEditingController> _controllers = {};


  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initFormData();
  }

  String _cleanDateString(String? val) {
    if (val == null || val.isEmpty || val.contains('0001-01-01')) return '';
    try {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) {
        return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
      }
    } catch (_) {}
    if (val.contains('T')) {
      return val.split('T')[0];
    }
    if (val.contains(' ')) {
      return val.split(' ')[0];
    }
    return val;
  }

  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.watch<ProfileProvider>();
    if (!_hasLoadedData && profile.rawProfileData.isNotEmpty) {
      _initFormData();
      _hasLoadedData = true;
    }
  }

  void _initFormData() {
    final profile = context.read<ProfileProvider>();
    final raw = profile.rawProfileData;
    final m = raw['mahasiswa'] ?? raw;
    _formData = {
      'nik': m['nik']?.toString() ?? m['NIK']?.toString() ?? '',
      'nisn': m['nisn']?.toString() ?? m['NISN']?.toString() ?? '',
      'birth_place':
          m['tempat_lahir']?.toString() ?? m['TempatLahir']?.toString() ?? '',
      'birth_date': _cleanDateString(
        m['tanggal_lahir']?.toString() ?? m['TanggalLahir']?.toString(),
      ),
      'gender':
          m['jenis_kelamin']?.toString() ?? m['JenisKelamin']?.toString() ?? '',
      'religion': m['agama']?.toString() ?? m['Agama']?.toString() ?? '',
      'email_personal':
          m['email_personal']?.toString() ??
          m['EmailPersonal']?.toString() ??
          '',
      'phone': m['no_hp']?.toString() ?? m['NoHP']?.toString() ?? '',
      'address':
          m['alamat_domisili']?.toString() ??
          m['AlamatDomisili']?.toString() ??
          m['Alamat']?.toString() ??
          '',
      'nama_ibu_kandung':
          m['nama_ibu_kandung']?.toString() ??
          m['NamaIbuKandung']?.toString() ??
          '',
      'nama_ayah': m['nama_ayah']?.toString() ?? m['NamaAyah']?.toString() ?? '',
    };
    
    // Update controllers
    _formData.forEach((key, value) {
      if (!_controllers.containsKey(key)) {
        _controllers[key] = TextEditingController(text: value?.toString() ?? '');
      } else {
        // Only update if it's different to preserve cursor position during typing
        if (_controllers[key]!.text != value?.toString()) {
          _controllers[key]!.text = value?.toString() ?? '';
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final backendPayload = {
      'nik': _formData['nik'] ?? '',
      'nisn': _formData['nisn'] ?? '',
      'tempat_lahir': _formData['birth_place'] ?? _formData['tempat_lahir'] ?? '',
      'tanggal_lahir': _formData['birth_date'] ?? _formData['tanggal_lahir'] ?? '',
      'jenis_kelamin': _formData['gender'] ?? _formData['jenis_kelamin'] ?? '',
      'agama': _formData['religion'] ?? _formData['agama'] ?? '',
      'email_personal': _formData['email_personal'] ?? '',
      'no_hp': _formData['phone'] ?? _formData['no_hp'] ?? '',
      'alamat_domisili': _formData['address'] ?? _formData['alamat_domisili'] ?? '',
      'nama_ibu_kandung': _formData['nama_ibu_kandung'] ?? '',
      'nama_ayah': _formData['nama_ayah'] ?? '',
    };

    setState(() => _isLoading = true);
    try {
      final profile = context.read<ProfileProvider>();
      await profile.updateProfile(backendPayload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: context.appColors.surface, size: 20),
                SizedBox(width: AppSpacing.s10),
                Text(
                  'Profil berhasil diperbarui',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: context.appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMd,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: context.appColors.surface, size: 20),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMd,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField(
    String label,
    String key, {
    bool required = false,
    IconData? prefixIcon,
    bool isDate = false,
  }) {
    final controller = _controllers[key] ??= TextEditingController(text: _formData[key]?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              if (required)
    Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          TextFormField(
            controller: controller,
            readOnly: isDate,
            onTap: isDate
                ? () async {
                    DateTime initial = DateTime.tryParse(controller.text) ?? DateTime(2004, 1, 1);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      final formatted = DateFormat('yyyy-MM-dd').format(picked);
                      setState(() {
                        controller.text = formatted;
                        _formData[key] = formatted;
                      });
                    }
                  }
                : null,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 19,
                      color: AppColors.neutral600,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide(
                  color: context.appColors.secondaryContainer,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide(color: context.appColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide(color: context.appColors.error, width: 1.8),
              ),
            ),
            onSaved: (val) => _formData[key] = val,
            validator: (val) {
              if (required && (val == null || val.trim().isEmpty)) {
                return 'Field ini wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData sectionIcon,
    Color accentColor,
    List<Widget> fields,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s18),
      padding: AppSpacing.padding18,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.br22,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(18),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  sectionIcon,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s18),
          ...fields,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    
    // Show loading spinner if data hasn't loaded yet
    if (profile.isLoading && !_hasLoadedData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neutral900),
      );
    }
    
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildSectionCard(
            'Data Pribadi Mahasiswa',
            Icons.person_rounded,
            context.appColors.info,
            [
              _buildField('NIK', 'nik', required: true, prefixIcon: Icons.badge_outlined),
              _buildField('NISN', 'nisn', prefixIcon: Icons.subtitles_outlined),
              _buildField('Tempat Lahir', 'birth_place', required: true, prefixIcon: Icons.location_city_rounded),
              _buildField(
                'Tanggal Lahir (YYYY-MM-DD)',
                'birth_date',
                required: true,
                prefixIcon: Icons.calendar_today_rounded,
                isDate: true,
              ),
              _buildField('Jenis Kelamin (L/P)', 'gender', required: true, prefixIcon: Icons.wc_rounded),
              _buildField('Agama', 'religion', required: true, prefixIcon: Icons.auto_awesome_rounded),
            ],
          ),
          _buildSectionCard(
            'Kontak & Domisili',
            Icons.contact_phone_rounded,
            context.appColors.info,
            [
              _buildField('Email Personal', 'email_personal', prefixIcon: Icons.mail_outline_rounded),
              _buildField('Nomor HP/WA', 'phone', required: true, prefixIcon: Icons.phone_android_rounded),
              _buildField('Alamat Domisili', 'address', prefixIcon: Icons.home_outlined),
            ],
          ),
          _buildSectionCard(
            'Keluarga',
            Icons.family_restroom_rounded,
            context.appColors.error,
            [
              _buildField('Nama Ibu Kandung', 'nama_ibu_kandung', required: true, prefixIcon: Icons.woman_rounded),
              _buildField('Nama Ayah', 'nama_ayah', prefixIcon: Icons.man_rounded),
            ],
          ),
    SizedBox(height: AppSpacing.sm),
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusLg,
              color: context.appColors.primary,
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: context.appColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusLg,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: context.appColors.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.s120),
        ],
      ),
    );
  }
}
