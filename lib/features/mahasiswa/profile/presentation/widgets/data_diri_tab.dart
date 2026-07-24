import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

class DataDiriTabWidget extends StatefulWidget {
  final StudentProvider student;
  const DataDiriTabWidget({super.key, required this.student});

  @override
  State<DataDiriTabWidget> createState() => _DataDiriTabWidgetState();
}

class _DataDiriTabWidgetState extends State<DataDiriTabWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Map<String, dynamic> _formData;

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

  void _initFormData() {
    final raw = widget.student.rawProfileData;
    final m = raw['mahasiswa'] ?? raw;
    _formData = {
      'nik': m['nik']?.toString() ?? '',
      'nisn': m['nisn']?.toString() ?? '',
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
          '',
      'nama_ibu_kandung':
          m['nama_ibu_kandung']?.toString() ??
          m['NamaIbuKandung']?.toString() ??
          '',
      'nama_ayah': m['nama_ayah']?.toString() ?? m['NamaAyah']?.toString() ?? '',
    };
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
      await widget.student.updateProfile(backendPayload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Profil berhasil diperbarui',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
    final controller = TextEditingController(text: _formData[key]?.toString() ?? '');

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
                  color: Color(0xFF334155),
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
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
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 19,
                      color: const Color(0xFF64748B),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF334155),
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
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
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  sectionIcon,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...fields,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildSectionCard(
            'Data Pribadi Mahasiswa',
            Icons.person_rounded,
            const Color(0xFF3B82F6),
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
            const Color(0xFF0D9488),
            [
              _buildField('Email Personal', 'email_personal', prefixIcon: Icons.mail_outline_rounded),
              _buildField('Nomor HP/WA', 'phone', required: true, prefixIcon: Icons.phone_android_rounded),
              _buildField('Alamat Domisili', 'address', prefixIcon: Icons.home_outlined),
            ],
          ),
          _buildSectionCard(
            'Keluarga',
            Icons.family_restroom_rounded,
            const Color(0xFFE11D48),
            [
              _buildField('Nama Ibu Kandung', 'nama_ibu_kandung', required: true, prefixIcon: Icons.woman_rounded),
              _buildField('Nama Ayah', 'nama_ayah', prefixIcon: Icons.man_rounded),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withAlpha(40),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        SizedBox(width: 8),
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
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
