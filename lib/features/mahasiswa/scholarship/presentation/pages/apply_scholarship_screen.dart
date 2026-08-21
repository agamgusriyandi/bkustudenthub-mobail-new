import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_application_detail_screen.dart';

class ApplyScholarshipScreen extends StatefulWidget {
  final Scholarship scholarship;

  const ApplyScholarshipScreen({super.key, required this.scholarship});

  @override
  State<ApplyScholarshipScreen> createState() => _ApplyScholarshipScreenState();
}

class _ApplyScholarshipScreenState extends State<ApplyScholarshipScreen> {
  int _currentStep = 1;

  final _motivasiController = TextEditingController();
  bool _isAgreed = false;

  String? _ktmKtpPath;
  String? _ktmKtpName;
  String? _transkripPath;
  String? _transkripName;
  String? _sertifikatPath;
  String? _sertifikatName;

  final Map<String, String> _rubrikAnswers = {};
  final Map<String, dynamic> _customAnswers = {};
  final Map<String, TextEditingController> _customTextControllers = {};
  final Map<String, String> _customFilePaths = {};
  final Map<String, String> _customFileNames = {};

  List<dynamic> _customFields = [];
  List<dynamic> _rubrikComponents = [];

  @override
  void initState() {
    super.initState();
    _parseSchemas();
  }

  void _parseSchemas() {
    if (widget.scholarship.customFieldsRaw != null) {
      if (widget.scholarship.customFieldsRaw is List) {
        _customFields = List<dynamic>.from(widget.scholarship.customFieldsRaw);
      } else if (widget.scholarship.customFieldsRaw is String) {
        try {
          final decoded = json.decode(widget.scholarship.customFieldsRaw);
          if (decoded is List) _customFields = decoded;
        } catch (_) {}
      }
    }

    if (widget.scholarship.rubrikSchemaRaw != null) {
      if (widget.scholarship.rubrikSchemaRaw is List) {
        _rubrikComponents = List<dynamic>.from(widget.scholarship.rubrikSchemaRaw);
      } else if (widget.scholarship.rubrikSchemaRaw is String) {
        try {
          final decoded = json.decode(widget.scholarship.rubrikSchemaRaw);
          if (decoded is List) _rubrikComponents = decoded;
        } catch (_) {}
      }
    }

    for (final field in _customFields) {
      if (field is Map) {
        final label = (field['label'] ?? field['name'] ?? '').toString();
        if (label.isNotEmpty) {
          _customTextControllers[label] = TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    _motivasiController.dispose();
    for (final c in _customTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _hasRubrik {
    final skema = (widget.scholarship.skema ?? '').toLowerCase();
    return _rubrikComponents.isNotEmpty ||
        ['excellence', 'impact', 'hope_grant', 'tahfidz'].contains(skema);
  }

  bool get _hasCustomFields => _customFields.isNotEmpty;

  int get _totalSteps {
    int count = 2;
    if (_hasRubrik) count++;
    if (_hasCustomFields) count++;
    count++;
    return count;
  }

  int? get _rubrikStepIndex => _hasRubrik ? 3 : null;
  int? get _customStepIndex => _hasCustomFields ? (_hasRubrik ? 4 : 3) : null;
  int get _confirmStepIndex => _totalSteps;

  List<Map<String, dynamic>> get _stagesList {
    final list = <Map<String, dynamic>>[
      {'index': 1, 'label': '1. MOTIVASI'},
      {'index': 2, 'label': '2. UPLOAD BERKAS'},
    ];
    if (_hasRubrik) {
      list.add({'index': list.length + 1, 'label': '${list.length + 1}. KRITERIA RUBRIK'});
    }
    if (_hasCustomFields) {
      list.add({'index': list.length + 1, 'label': '${list.length + 1}. SYARAT KHUSUS ADMIN'});
    }
    list.add({'index': list.length + 1, 'label': '${list.length + 1}. KONFIRMASI & KIRIM'});
    return list;
  }

  bool _isStepValid(int step) {
    if (step == 1) {
      return _motivasiController.text.trim().length >= 10;
    } else if (step == 2) {
      return _ktmKtpPath != null && _transkripPath != null;
    } else if (_rubrikStepIndex != null && step == _rubrikStepIndex) {
      return true;
    } else if (_customStepIndex != null && step == _customStepIndex) {
      for (final f in _customFields) {
        if (f is Map && (f['required'] == true || f['wajib'] == true)) {
          final label = (f['label'] ?? f['name'] ?? '').toString();
          final val = _customAnswers[label] ?? _customTextControllers[label]?.text.trim();
          if (val == null || val.toString().isEmpty) return false;
        }
      }
      return true;
    } else if (step == _confirmStepIndex) {
      return _isAgreed;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: BkuStaticAppBar(
        title: 'Formulir Pendaftaran Beasiswa',
        subtitle: widget.scholarship.title,
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStageHeader(),
            const SizedBox(height: AppSpacing.lg),

            if (_currentStep == 1) ...[
              _buildStep1Motivasi(),
            ] else if (_currentStep == 2) ...[
              _buildStep2Berkas(),
            ] else if (_rubrikStepIndex != null && _currentStep == _rubrikStepIndex) ...[
              _buildStep3Rubrik(),
            ] else if (_customStepIndex != null && _currentStep == _customStepIndex) ...[
              _buildStep4CustomFields(),
            ] else if (_currentStep == _confirmStepIndex) ...[
              _buildStepConfirm(),
            ],
            const SizedBox(height: AppSpacing.s48),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStageHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text(
                          'Formulir Pendaftaran Beasiswa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'Draft Otomatis Tersimpan',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Lengkapi langkah berikut untuk mengajukan pendaftaran resmi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Langkah $_currentStep dari $_totalSteps',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _stagesList.map((stage) {
                final isDone = stage['index'] < _currentStep;
                final isCurrent = stage['index'] == _currentStep;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF0F172A)
                          : (isDone ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF0F172A)
                            : (isDone ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      stage['label'],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: isCurrent
                            ? Colors.white
                            : (isDone ? const Color(0xFF059669) : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Motivasi() {
    return _buildCardWrapper(
      stepNumber: '1',
      title: 'Motivasi & Rencana Studi',
      subtitle: 'Tuliskan alasan mengapa Anda layak menerima beasiswa ini dan bagaimana beasiswa ini mendukung masa depan studi Anda.',
      children: [
        _buildLabel('Esai Motivasi / Rencana Studi', required: true),
        TextField(
          controller: _motivasiController,
          maxLines: 7,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Jelaskan latar belakang, prestasi yang pernah diraih, serta rencana penggunaan beasiswa untuk mendukung kegiatan akademik Anda...',
            hintStyle: BkuTheme.textCardSubtitle.copyWith(fontSize: 12, color: BkuTheme.textPlaceholder),
            filled: true,
            fillColor: BkuTheme.scaffoldBg,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BkuTheme.border),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_motivasiController.text.trim().length} karakter (Minimal 10 karakter)',
            style: BkuTheme.textCaption.copyWith(
              fontSize: 10.5,
              color: _motivasiController.text.trim().length >= 10 ? BkuTheme.emerald : BkuTheme.rose,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Berkas() {
    return _buildCardWrapper(
      stepNumber: '2',
      title: 'Upload Dokumen Persyaratan Wajib',
      subtitle: 'Unggah berkas resmi dalam format PDF, JPG, atau PNG (Maksimal 5MB per berkas).',
      children: [
        _buildLabel('KTM & KTP Mahasiswa', required: true),
        _buildUploadTile(
          fileName: _ktmKtpName,
          hint: 'Pilih Berkas KTM / KTP',
          onTap: () => _pickDocument(type: 'ktm_ktp'),
        ),
        const SizedBox(height: AppSpacing.md),

        _buildLabel('Transkrip Nilai Terakhir (SIAKAD)', required: true),
        _buildUploadTile(
          fileName: _transkripName,
          hint: 'Pilih Berkas Transkrip Nilai',
          onTap: () => _pickDocument(type: 'transkrip'),
        ),
        const SizedBox(height: AppSpacing.md),

        _buildLabel('Sertifikat Prestasi / SK Rekomendasi (Opsional)'),
        _buildUploadTile(
          fileName: _sertifikatName,
          hint: 'Pilih Berkas Sertifikat Prestasi (Opsional)',
          onTap: () => _pickDocument(type: 'sertifikat'),
        ),
      ],
    );
  }

  Widget _buildStep3Rubrik() {
    final skema = (widget.scholarship.skema ?? '').toLowerCase();

    return _buildCardWrapper(
      stepNumber: '3',
      title: 'Kriteria Rubrik SPMI',
      subtitle: 'Isi indikator capaian sesuai kriteria penjaminan mutu beasiswa.',
      badgeColor: BkuTheme.amber,
      badgeBg: BkuTheme.amberSoft,
      children: [
        if (skema == 'excellence') ...[
          _buildLabel('Tingkat Prestasi Tertinggi', required: true),
          _buildDropdown(
            items: const ['INT', 'NAS', 'PROV', 'KAB'],
            itemLabels: const {
              'INT': 'Internasional',
              'NAS': 'Nasional',
              'PROV': 'Provinsi',
              'KAB': 'Kabupaten / Kota',
            },
            value: _rubrikAnswers['tingkat_prestasi'] ?? 'NAS',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['tingkat_prestasi'] = val);
            },
          ),
        ] else if (skema == 'impact') ...[
          _buildLabel('Level Kepemimpinan Organisasi', required: true),
          _buildDropdown(
            items: const ['UNIVERSITAS', 'FAKULTAS', 'HIMA', 'EKSTERNAL'],
            itemLabels: const {
              'UNIVERSITAS': 'Tingkat Universitas (BEM/DPM-U)',
              'FAKULTAS': 'Tingkat Fakultas (BEM/DPM-F)',
              'HIMA': 'Himpunan Mahasiswa Jurusan (HIMA/UKM)',
              'EKSTERNAL': 'Organisasi Luar Kampus',
            },
            value: _rubrikAnswers['level_organisasi'] ?? 'UNIVERSITAS',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['level_organisasi'] = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLabel('Jabatan Kepengurusan', required: true),
          _buildDropdown(
            items: const ['KETUA', 'BPH', 'KADIV', 'ANGGOTA'],
            itemLabels: const {
              'KETUA': 'Ketua Umum / Wakil Ketua',
              'BPH': 'Sekretaris / Bendahara Umum',
              'KADIV': 'Kepala Divisi / Departemen',
              'ANGGOTA': 'Anggota Aktif',
            },
            value: _rubrikAnswers['jabatan_ormawa'] ?? 'KETUA',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['jabatan_ormawa'] = val);
            },
          ),
        ] else if (skema == 'hope_grant') ...[
          _buildLabel('Rentang Penghasilan Orang Tua (Gabungan)', required: true),
          _buildDropdown(
            items: const ['DIBAWAH_1JT', '1JT_2JT', '2JT_3JT', 'DIATAS_3JT'],
            itemLabels: const {
              'DIBAWAH_1JT': '< Rp 1.000.000 / bulan',
              '1JT_2JT': 'Rp 1.000.000 - Rp 2.000.000 / bulan',
              '2JT_3JT': 'Rp 2.000.000 - Rp 3.000.000 / bulan',
              'DIATAS_3JT': '> Rp 3.000.000 / bulan',
            },
            value: _rubrikAnswers['penghasilan_ortu'] ?? 'DIBAWAH_1JT',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['penghasilan_ortu'] = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLabel('Daya Listrik Rumah Tinggal', required: true),
          _buildDropdown(
            items: const ['450VA', '900VA', '1300VA', 'DIATAS_1300VA'],
            itemLabels: const {
              '450VA': '450 VA (Bersubsidi)',
              '900VA': '900 VA',
              '1300VA': '1.300 VA',
              'DIATAS_1300VA': '> 1.300 VA',
            },
            value: _rubrikAnswers['daya_listrik'] ?? '450VA',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['daya_listrik'] = val);
            },
          ),
        ] else if (skema == 'tahfidz') ...[
          _buildLabel('Jumlah Hafalan Al-Qur’an (Juz)', required: true),
          _buildDropdown(
            items: const ['30JUZ', '20JUZ', '10JUZ', '5JUZ', '3JUZ'],
            itemLabels: const {
              '30JUZ': '30 Juz (Mutqin)',
              '20JUZ': '20 - 29 Juz',
              '10JUZ': '10 - 19 Juz',
              '5JUZ': '5 - 9 Juz',
              '3JUZ': '1 - 4 Juz',
            },
            value: _rubrikAnswers['jumlah_juz'] ?? '5JUZ',
            onChanged: (val) {
              if (val != null) setState(() => _rubrikAnswers['jumlah_juz'] = val);
            },
          ),
        ] else ...[
          Text(
            'Kriteria rubrik telah disesuaikan secara otomatis oleh sistem evaluasi.',
            style: BkuTheme.textCardSubtitle.copyWith(fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildStep4CustomFields() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, size: 18, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text(
                'PERSYARATAN & ISIAN KHUSUS ADMIN',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._customFields.map((field) {
            if (field is! Map) return const SizedBox.shrink();
            final label = (field['label'] ?? field['name'] ?? 'Pertanyaan').toString();
            final isReq = field['required'] == true || field['wajib'] == true;
            final type = (field['type'] ?? 'text').toString().toLowerCase();

            final bool isFileField = type == 'file' ||
                type == 'upload' ||
                type == 'document' ||
                label.toLowerCase().contains('cv') ||
                label.toLowerCase().contains('berkas') ||
                label.toLowerCase().contains('dokumen') ||
                label.toLowerCase().contains('file') ||
                label.toLowerCase().contains('portofolio') ||
                label.toLowerCase().contains('surat') ||
                label.toLowerCase().contains('sertifikat') ||
                label.toLowerCase().contains('sktm') ||
                label.toLowerCase().contains('ktp') ||
                label.toLowerCase().contains('kk') ||
                label.toLowerCase().contains('sk');

            final String? uploadedFile = _customFileNames[label] ??
                (_customAnswers[label] is String && (_customAnswers[label] as String).isNotEmpty
                    ? (_customAnswers[label] as String).split('/').last
                    : null);
            final bool hasFile = uploadedFile != null && uploadedFile.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(label, required: isReq),
                    const SizedBox(height: 6),
                    if (isFileField) ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickCustomFile(label),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: hasFile ? const Color(0xFFECFDF5) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: hasFile ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      hasFile ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                                      size: 16,
                                      color: hasFile ? const Color(0xFF059669) : const Color(0xFF475569),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        hasFile ? uploadedFile : 'Upload Berkas...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: hasFile ? const Color(0xFF065F46) : const Color(0xFF334155),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (hasFile) ...[
                            const SizedBox(width: 8),
                            const Text(
                              'Terunggah',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _customFileNames.remove(label);
                                  _customFilePaths.remove(label);
                                  _customAnswers.remove(label);
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (type == 'dropdown' || type == 'select') ...[
                      _buildDropdown(
                        items: (field['options'] as List?)?.map((e) => e.toString()).toList() ?? ['Ya', 'Tidak'],
                        itemLabels: {for (var o in (field['options'] as List? ?? ['Ya', 'Tidak'])) o.toString(): o.toString()},
                        value: _customAnswers[label] ?? ((field['options'] as List?)?.first.toString() ?? 'Ya'),
                        onChanged: (val) {
                          if (val != null) setState(() => _customAnswers[label] = val);
                        },
                      ),
                    ] else ...[
                      BkuTextField(
                        controller: _customTextControllers[label],
                        hint: 'Jawaban Anda...',
                        keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
                        onChanged: (val) => _customAnswers[label] = val,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepConfirm() {
    final profile = context.watch<ProfileProvider>();

    return _buildCardWrapper(
      stepNumber: '$_confirmStepIndex',
      title: 'Konfirmasi & Pernyataan Keabsahan',
      subtitle: 'Periksa kembali kelengkapan formulir sebelum mengirimkan permohonan beasiswa.',
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: BkuTheme.scaffoldBg,
            borderRadius: BkuTheme.r16,
            border: Border.all(color: BkuTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Program Beasiswa', widget.scholarship.title),
              const Divider(height: 16, color: BkuTheme.borderSubtle),
              _buildReviewRow('Nama Mahasiswa', profile.name.isNotEmpty ? profile.name : 'Mahasiswa BKU'),
              const Divider(height: 16, color: BkuTheme.borderSubtle),
              _buildReviewRow('KTM & KTP', _ktmKtpName ?? 'Terlampir'),
              const Divider(height: 16, color: BkuTheme.borderSubtle),
              _buildReviewRow('Transkrip Nilai', _transkripName ?? 'Terlampir'),
              if (_sertifikatName != null) ...[
                const Divider(height: 16, color: BkuTheme.borderSubtle),
                _buildReviewRow('Sertifikat Prestasi', _sertifikatName!),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BkuTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _isAgreed,
                activeColor: BkuTheme.primary,
                onChanged: (val) => setState(() => _isAgreed = val ?? false),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAgreed = !_isAgreed),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Saya menyatakan bahwa data dan berkas yang saya lampirkan adalah benar dan dapat dipertanggungjawabkan keabsahannya.',
                      style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, height: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardWrapper({
    required String stepNumber,
    required String title,
    required String subtitle,
    required List<Widget> children,
    Color? badgeColor,
    Color? badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeBg ?? const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      color: badgeColor ?? const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: BkuTheme.textCardSubtitle.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: BkuTheme.borderSubtle),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: RichText(
        text: TextSpan(
          text: text,
          style: BkuTheme.textCardSubtitle.copyWith(
            fontWeight: FontWeight.w700,
            color: BkuTheme.textHeading,
            fontSize: 12,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: BkuTheme.rose, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required Map<String, String> itemLabels,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return BkuDropdown<String>(
      value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
      items: items.map((val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(
            itemLabels[val] ?? val,
            style: BkuTheme.textBodyRegular.copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildUploadTile({
    required String? fileName,
    required String hint,
    required VoidCallback onTap,
  }) {
    final bool hasFile = fileName != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BkuTheme.r16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
          borderRadius: BkuTheme.r16,
          border: Border.all(
            color: hasFile ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                size: 22,
                color: hasFile ? const Color(0xFF059669) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? hint,
                    style: BkuTheme.textCardTitle.copyWith(
                      fontSize: 12.5,
                      color: hasFile ? const Color(0xFF065F46) : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? 'Ketuk untuk mengganti berkas' : 'PDF, JPG, PNG (Maks. 5MB)',
                    style: BkuTheme.textCaption.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDocument({required String type}) async {
    FocusScope.of(context).unfocus();

    BkuBottomSheet.show(
      context: context,
      padding: EdgeInsets.zero,
      title: 'Pilih Sumber Berkas',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF475569)),
            title: Text('Ambil Foto Kamera', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              _pickCamera(type);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_rounded, color: Color(0xFF475569)),
            title: Text('Pilih Berkas / PDF / Gambar', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              _pickFile(type);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _pickCamera(String type) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (type == 'ktm_ktp') {
            _ktmKtpPath = image.path;
            _ktmKtpName = image.name;
          } else if (type == 'transkrip') {
            _transkripPath = image.path;
            _transkripName = image.name;
          } else if (type == 'sertifikat') {
            _sertifikatPath = image.path;
            _sertifikatName = image.name;
          }
        });
      }
    } catch (e) {
      log('Error picking camera: $e');
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (type == 'ktm_ktp') {
            _ktmKtpPath = result.files.single.path;
            _ktmKtpName = result.files.single.name;
          } else if (type == 'transkrip') {
            _transkripPath = result.files.single.path;
            _transkripName = result.files.single.name;
          } else if (type == 'sertifikat') {
            _sertifikatPath = result.files.single.path;
            _sertifikatName = result.files.single.name;
          }
        });
      }
    } catch (e) {
      log('Error picking file: $e');
    }
  }

  Future<void> _pickCustomFile(String label) async {
    FocusScope.of(context).unfocus();
    BkuBottomSheet.show(
      context: context,
      padding: EdgeInsets.zero,
      title: 'Pilih Berkas $label',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF475569)),
            title: Text('Ambil Foto Kamera', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
            onTap: () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                _uploadCustomPickedFile(label, image.path, image.name);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_rounded, color: Color(0xFF475569)),
            title: Text('Pilih Berkas / PDF / Gambar', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              );
              if (result != null && result.files.single.path != null) {
                _uploadCustomPickedFile(label, result.files.single.path!, result.files.single.name);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _uploadCustomPickedFile(String label, String path, String name) async {
    setState(() {
      _customFilePaths[label] = path;
      _customFileNames[label] = name;
      _customAnswers[label] = path;
    });

    try {
      final fileUrl = await context.read<ScholarshipProvider>().uploadCustomFile(path);
      if (mounted) {
        setState(() {
          _customAnswers[label] = fileUrl;
        });
      }
    } catch (_) {
      // Keep local path
    }
  }

  Widget _buildBottomNav() {
    final isValid = _isStepValid(_currentStep);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 1) ...[
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {
                          if (_currentStep < _confirmStepIndex) {
                            setState(() => _currentStep++);
                          } else {
                            _handleSubmit();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BkuTheme.primary,
                    disabledBackgroundColor: BkuTheme.primary.withAlpha(90),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == _confirmStepIndex ? 'Kirim Pendaftaran Beasiswa' : 'Langkah Berikutnya',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    try {
      BkuLoadingDialog.show(context);

      String? customAnswersJson;
      if (_customAnswers.isNotEmpty) {
        customAnswersJson = json.encode(_customAnswers);
      }

      String? rubrikAnswersJson;
      if (_rubrikAnswers.isNotEmpty) {
        rubrikAnswersJson = json.encode(_rubrikAnswers);
      }

      final scholarshipProvider = context.read<ScholarshipProvider>();
      await scholarshipProvider.applyForScholarship(
        widget.scholarship.id,
        _motivasiController.text.trim(),
        ktmKtpPath: _ktmKtpPath,
        transkripPath: _transkripPath,
        sertifikatPath: _sertifikatPath,
        customAnswers: customAnswersJson,
        rubrikAnswers: rubrikAnswersJson,
      );

      await scholarshipProvider.loadScholarships();

      if (mounted) BkuLoadingDialog.hide(context);
      if (!mounted) return;

      await BkuDialog.show(
        context: context,
        type: BkuDialogType.success,
        title: 'Pendaftaran Berhasil Dikirim',
        message: 'Pengajuan beasiswa Anda berhasil dikirim dan sedang dalam tahap peninjauan berkas oleh admin.',
        primaryButtonText: 'Lihat Progress Pengajuan',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ScholarshipApplicationDetailScreen(
                scholarship: widget.scholarship.copyWith(
                  status: 'Applied',
                  applicationStatus: 'Menunggu Verifikasi Berkas',
                  tanggalPengajuan: DateTime.now().toString().split(' ').first,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) BkuLoadingDialog.hide(context);
      if (!mounted) return;

      await BkuDialog.show(
        context: context,
        type: BkuDialogType.error,
        title: 'Gagal Mengirim Pendaftaran',
        message: ErrorHandler.getMessage(e),
        primaryButtonText: 'Tutup',
        onPrimaryPressed: () => context.pop(),
      );
    }
  }
}
