import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/widgets/rejection_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ApplyScholarshipScreen extends StatefulWidget {
  final Scholarship scholarship;

  const ApplyScholarshipScreen({super.key, required this.scholarship});

  @override
  State<ApplyScholarshipScreen> createState() => _ApplyScholarshipScreenState();
}

class _ApplyScholarshipScreenState extends State<ApplyScholarshipScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _ipkController;
  final _reasonController = TextEditingController();
  bool _isAgreed = false;

  List<dynamic> _customFields = [];
  final Map<String, dynamic> _customAnswers = {};
  final Map<String, String> _rubrikAnswers = {};
  final Map<String, String?> _customFiles = {};
  final Map<String, TextEditingController> _customTextControllers = {};
  bool _isPicking = false;

  String? _ktmKtpPath;
  String? _sertifikatPath;
  String? _transkripPath;

  Future<void> _pickFile(String type) async {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.xl,
                ),
                child: Text(
                  'Pilih Sumber Dokumen',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.neutral600,
                ),
                title: Text(
                  'Kamera',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _processPick(type, 'camera');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.neutral600,
                ),
                title: Text(
                  'Galeri',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _processPick(type, 'gallery');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.folder_rounded,
                  color: AppColors.neutral600,
                ),
                title: Text(
                  'File Manager',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _processPick(type, 'file');
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPick(String type, String source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      String? pickedPath;
      if (source == 'camera' || source == 'gallery') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80,
        );
        pickedPath = image?.path;
      } else {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        );
        pickedPath = result?.files.single.path;
      }

      if (pickedPath != null && mounted) {
        setState(() {
          if (type == 'ktm_ktp') {
            _ktmKtpPath = pickedPath;
          } else if (type == 'sertifikat') {
            _sertifikatPath = pickedPath;
          } else if (type == 'transkrip') {
            _transkripPath = pickedPath;
          } else {
            _customFiles[type] = pickedPath;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final student = context.read<StudentProvider>();
      final prefs = await SharedPreferences.getInstance();
      final appliedList = prefs.getStringList('applied_scholarships') ?? [];

      final appliedToThis =
          widget.scholarship.status == 'Applied' ||
          widget.scholarship.applicationStatus != null ||
          appliedList.contains(widget.scholarship.id);

      final hasOtherActiveApplied = student.scholarships.any((s) {
        if (s.id == widget.scholarship.id) return false;
        if (s.status.toLowerCase() == 'applied' ||
            s.applicationStatus != null ||
            appliedList.contains(s.id)) {
          String appStatus = (s.applicationStatus ?? '').toLowerCase();
          String mainStatus = s.status.toLowerCase();
          bool isFinished =
              appStatus.contains('ditolak') ||
              appStatus.contains('diterima') ||
              appStatus.contains('lulus') ||
              mainStatus.contains('ditolak') ||
              mainStatus.contains('diterima');
          return !isFinished;
        }
        return false;
      });

      if (appliedToThis || hasOtherActiveApplied) {
        Scholarship activeScholarship = widget.scholarship;
        if (hasOtherActiveApplied && !appliedToThis) {
          final match = student.scholarships.where((s) {
            if (s.id == widget.scholarship.id) return false;
            if (s.status.toLowerCase() == 'applied' ||
                s.applicationStatus != null ||
                (appliedList.isNotEmpty && s.id == appliedList.first)) {
              String appStatus = (s.applicationStatus ?? '').toLowerCase();
              String mainStatus = s.status.toLowerCase();
              bool isFinished =
                  appStatus.contains('ditolak') ||
                  appStatus.contains('diterima') ||
                  appStatus.contains('lulus') ||
                  mainStatus.contains('ditolak') ||
                  mainStatus.contains('diterima');
              return !isFinished;
            }
            return false;
          });
          if (match.isNotEmpty) {
            activeScholarship = match.first;
          }
        }

        if (!mounted) return;
        Navigator.pop(context);
        showRejectionBottomSheet(context, activeScholarship);
      }
    });

    final student = context.read<StudentProvider>();
    _nameController = TextEditingController(text: student.name);
    _nimController = TextEditingController(text: student.nim);
    _ipkController = TextEditingController(
      text: student.ipk.toStringAsFixed(2),
    );

    // Parse custom fields
    if (widget.scholarship.customFieldsRaw != null) {
      try {
        final raw = widget.scholarship.customFieldsRaw;
        if (raw is String) {
          _customFields = jsonDecode(raw);
        } else if (raw is List) {
          _customFields = raw;
        }
      } catch (e) {
        debugPrint('Error parsing custom_fields: ');
      }
    }

    // Initialize controllers for custom text fields
    for (var field in _customFields) {
      final type = (field['type'] ?? 'text').toString().toLowerCase();
      if (type == 'text' || type == 'paragraph' || type == 'textarea') {
        _customTextControllers[field['label']] = TextEditingController();
      }
    }

    // Prefill custom answers if editing
    if (widget.scholarship.status == 'Applied' &&
        widget.scholarship.customAnswersRaw != null) {
      try {
        final rawAns = widget.scholarship.customAnswersRaw;
        final Map<String, dynamic> parsedAns =
            rawAns is String ? jsonDecode(rawAns) : rawAns;
        _customAnswers.addAll(parsedAns);

        // Pre-fill controllers
        for (var field in _customFields) {
          final label = field['label'];
          final type = (field['type'] ?? 'text').toString().toLowerCase();
          if ((type == 'text' || type == 'paragraph' || type == 'textarea') &&
              _customAnswers[label] != null) {
            _customTextControllers[label]?.text =
                _customAnswers[label].toString();
          } else if ((type == 'file' || type == 'upload') &&
              _customAnswers[label] != null) {
            _customFiles[label] = _customAnswers[label].toString();
          }
        }
      } catch (e) {
        debugPrint('Error parsing custom_answers: ');
      }
    }

    // Jika statusnya sudah Applied, kita isi datanya dari database
    if (widget.scholarship.status == 'Applied') {
      _reasonController.text = widget.scholarship.motivasi ?? '';
      _isAgreed = true;
      _ktmKtpPath = widget.scholarship.ktmKtpUrl;
      _sertifikatPath = widget.scholarship.sertifikatUrl;
      _transkripPath = widget.scholarship.transkripUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _ipkController.dispose();
    _reasonController.dispose();
    for (var c in _customTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> _getRubrikQuestions() {
    final skema = widget.scholarship.skema?.toLowerCase() ?? '';
    if (skema == 'excellence') {
      return [
        {
          'id': 'ipk_score',
          'question': 'Berapa IPK Anda saat ini?',
          'options': [
            {'label': '>= 3.75', 'value': '3.75 - 4.00'},
            {'label': '3.50 - 3.74', 'value': '3.50 - 3.74'},
            {'label': '3.25 - 3.49', 'value': '3.25 - 3.49'},
            {'label': '< 3.25', 'value': '< 3.25'},
          ],
        },
        {
          'id': 'achievement_level',
          'question': 'Tingkat prestasi tertinggi yang pernah Anda raih?',
          'options': [
            {'label': 'Internasional (Juara 1-3)', 'value': 'internasional'},
            {'label': 'Nasional (Juara 1-3)', 'value': 'nasional'},
            {'label': 'Provinsi / Wilayah (Juara 1-3)', 'value': 'provinsi'},
            {
              'label': 'Kabupaten / Kota / Kampus (Juara 1-3)',
              'value': 'kabupaten_kota_kampus',
            },
            {'label': 'Tidak Ada', 'value': 'tidak_ada'},
          ],
        },
        {
          'id': 'english_proficiency',
          'question': 'Sertifikat kemampuan bahasa Inggris (TOEFL / IELTS)?',
          'options': [
            {'label': 'Ada (TOEFL >= 500 / IELTS >= 6.0)', 'value': 'tinggi'},
            {'label': 'Ada (TOEFL < 500 / IELTS < 6.0)', 'value': 'sedang'},
            {'label': 'Tidak Ada', 'value': 'tidak_ada'},
          ],
        },
      ];
    } else if (skema == 'impact') {
      return [
        {
          'id': 'org_experience',
          'question': 'Pengalaman kepemimpinan/organisasi Anda?',
          'options': [
            {
              'label': 'Ketua Umum / BPH Utama (BEM/HIMA/UKM)',
              'value': 'ketua_bph',
            },
            {
              'label': 'Koordinator Divisi / Staff Ahli',
              'value': 'koordinator_staff',
            },
            {
              'label': 'Anggota Aktif / Kepanitiaan',
              'value': 'anggota_panitia',
            },
            {'label': 'Tidak Ada', 'value': 'tidak_ada'},
          ],
        },
        {
          'id': 'social_impact',
          'question':
              'Keterlibatan dalam kegiatan sosial / pengabdian masyarakat?',
          'options': [
            {
              'label': 'Sering / Rutin (Memiliki proyek sosial sendiri)',
              'value': 'rutin_mandiri',
            },
            {
              'label': 'Aktif sebagai volunteer / relawan',
              'value': 'aktif_volunteer',
            },
            {'label': 'Jarang / Hanya sesekali', 'value': 'jarang'},
            {'label': 'Tidak Pernah', 'value': 'tidak_pernah'},
          ],
        },
      ];
    } else if (skema == 'hope_grant') {
      return [
        {
          'id': 'parent_income',
          'question': 'Berapa total pendapatan gabungan orang tua per bulan?',
          'options': [
            {'label': '<= Rp 1.500.000', 'value': 'rendah'},
            {'label': 'Rp 1.500.001 - Rp 3.000.000', 'value': 'sedang_rendah'},
            {'label': 'Rp 3.000.001 - Rp 5.000.000', 'value': 'sedang'},
            {'label': '> Rp 5.000.000', 'value': 'tinggi'},
          ],
        },
        {
          'id': 'dependents_count',
          'question': 'Jumlah anak yang menjadi tanggungan orang tua?',
          'options': [
            {'label': '> 4 anak', 'value': 'banyak'},
            {'label': '2 - 4 anak', 'value': 'sedang'},
            {'label': '1 anak', 'value': 'sedikit'},
          ],
        },
        {
          'id': 'housing_status',
          'question': 'Bagaimana status kepemilikan tempat tinggal keluarga?',
          'options': [
            {
              'label': 'Sewa / Mengontrak / Menumpang',
              'value': 'sewa_menumpang',
            },
            {
              'label': 'Milik Sendiri (Sederhana / Non-permanen)',
              'value': 'milik_sederhana',
            },
            {'label': 'Milik Sendiri (Permanen)', 'value': 'milik_permanen'},
          ],
        },
      ];
    } else if (skema == 'tahfidz') {
      return [
        {
          'id': 'juz_memorized',
          'question':
              'Berapa juz hafalan Al-Qur\'an Anda yang mutqin (lancar)?',
          'options': [
            {'label': '30 Juz (Lengkap)', 'value': '30_juz'},
            {'label': '20 - 29 Juz', 'value': '20_29_juz'},
            {'label': '10 - 19 Juz', 'value': '10_19_juz'},
            {'label': '5 - 9 Juz', 'value': '5_9_juz'},
            {'label': '< 5 Juz', 'value': 'kurang_5_juz'},
          ],
        },
        {
          'id': 'sanad_ownership',
          'question': 'Apakah Anda memiliki sertifikat / sanad hafalan?',
          'options': [
            {
              'label': 'Memiliki Sanad bersambung ke Rasulullah SAW',
              'value': 'memiliki_sanad',
            },
            {
              'label': 'Memiliki Syahadah / Sertifikat Resmi Lembaga',
              'value': 'memiliki_sertifikat',
            },
            {
              'label': 'Tidak Memiliki Sertifikat Resmi',
              'value': 'tidak_memiliki',
            },
          ],
        },
      ];
    }
    return [];
  }

  Widget _buildRubrikPenilaianSection() {
    final questions = _getRubrikQuestions();
    if (questions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        FadeInAnimation(
          delay: 0.85,
          child: _buildSectionTitle('Rubrik Penilaian Skema'),
        ),
        const SizedBox(height: AppSpacing.md),
        ...questions.map((q) {
          final id = q['id'] as String;
          final questionText = q['question'] as String;
          final options = q['options'] as List<Map<String, String>>;

          if (_rubrikAnswers[id] == null && options.isNotEmpty) {
            _rubrikAnswers[id] = options.first['value']!;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.onSurface.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...options.map((opt) {
                  return InkWell(
                    onTap:
                        widget.scholarship.status == 'Applied'
                            ? null
                            : () {
                              setState(() {
                                _rubrikAnswers[id] = opt['value']!;
                              });
                            },
                    borderRadius: AppRadius.radiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.md,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _rubrikAnswers[id] == opt['value']
                                ? AppColors.neutral100
                                : Colors.transparent,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(
                          color:
                              _rubrikAnswers[id] == opt['value']
                                  ? AppColors.neutral800
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _rubrikAnswers[id] == opt['value']
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color:
                                _rubrikAnswers[id] == opt['value']
                                    ? AppColors.neutral800
                                    : context.appColors.outline,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              opt['label']!,
                              style: AppTextStyles.bodyMd.copyWith(
                                color:
                                    _rubrikAnswers[id] == opt['value']
                                        ? AppColors.neutral800
                                        : AppColors.neutral800,
                                fontWeight:
                                    _rubrikAnswers[id] == opt['value']
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so the screen rebuilds when scholarship status changes
    context.watch<StudentProvider>();
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: const BkuStaticAppBar(
        title: 'Form Pendaftaran',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInAnimation(delay: 0.1, child: _buildScholarshipInfo()),
            const SizedBox(height: AppSpacing.s20),

            // DATA AKADEMIK CARD
            FadeInAnimation(
              delay: 0.2,
              child: _buildFormCard(
                children: [
                  _buildSectionTitle('Data Akademik'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Nama Lengkap',
                    _nameController,
                    'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'NIM',
                          _nimController,
                          'Masukkan NIM',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildTextField(
                          'IPK Terakhir',
                          _ipkController,
                          'Contoh: 3.85',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // MOTIVASI & ALASAN CARD
            FadeInAnimation(
              delay: 0.3,
              child: _buildFormCard(
                children: [
                  _buildSectionTitle('Motivasi & Alasan'),
                  const SizedBox(height: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTextArea(
                        'Motivasi & Alasan',
                        _reasonController,
                        'Jelaskan mengapa kamu layak menerima beasiswa ini...',
                        autovalidateMode: AutovalidateMode.always,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Mohon isi alasan kamu';
                          }
                          if (val.trim().length < 150) {
                            return 'Alasan minimal 150 karakter (saat ini ${val.trim().length} karakter)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _reasonController,
                        builder: (context, value, child) {
                          final count = value.text.length;
                          final color =
                              count < 150
                                  ? context.appColors.error
                                  : context.appColors.info;
                          return Text(
                            '$count/150 karakter minimal',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // DOKUMEN PENDUKUNG CARD
            FadeInAnimation(
              delay: 0.4,
              child: _buildFormCard(
                children: [
                  _buildSectionTitle('Dokumen Pendukung'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildUploadItem(
                    'KTM & KTP${widget.scholarship.fileKtm == 'wajib' ? ' *' : ' (Opsional)'}',
                    Icons.badge_rounded,
                    _ktmKtpPath,
                    'ktm_ktp',
                  ),
                  _buildUploadItem(
                    'Sertifikat Pendukung${widget.scholarship.fileSertifikat == 'wajib' ? ' *' : ' (Opsional)'}',
                    Icons.emoji_events_rounded,
                    _sertifikatPath,
                    'sertifikat',
                  ),
                  _buildUploadItem(
                    'Transkrip Nilai${widget.scholarship.fileTranskrip == 'wajib' ? ' *' : ' (Opsional)'}',
                    Icons.description_rounded,
                    _transkripPath,
                    'transkrip',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildRubrikPenilaianSection(),

            if (_customFields.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              FadeInAnimation(
                delay: 0.5,
                child: _buildFormCard(
                  children: [
                    _buildSectionTitle('Form Persyaratan Tambahan'),
                    const SizedBox(height: AppSpacing.lg),
                    ..._customFields.asMap().entries.map((entry) {
                      var field = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: _buildCustomFieldItem(field),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.s20),
            FadeInAnimation(delay: 0.6, child: _buildAgreementCheckbox()),

            const SizedBox(height: AppSpacing.s20),
            FadeInAnimation(delay: 0.7, child: _buildSubmitButton()),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildScholarshipInfo() {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.padding10,
            decoration: BoxDecoration(
              color: context.appColors.infoContainer,
              borderRadius: AppRadius.radiusMd,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.scholarship.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  widget.scholarship.provider,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFieldItem(Map<String, dynamic> field) {
    String label = field['label'] ?? '';
    String type = (field['type'] ?? 'text').toString().toLowerCase();

    Widget inputWidget;
    if (type == 'text' || type == 'paragraph' || type == 'textarea') {
      if (type == 'paragraph' || type == 'textarea') {
        inputWidget = _buildTextArea(
          label,
          _customTextControllers[label]!,
          'Jelaskan $label secara detail...',
          onChanged: (val) {
            _customAnswers[label] = val;
          },
        );
      } else {
        inputWidget = _buildTextField(
          label,
          _customTextControllers[label]!,
          'Masukkan $label',
          onChanged: (val) {
            _customAnswers[label] = val;
          },
        );
      }
    } else if (type == 'select' ||
        type == 'dropdown' ||
        type == 'checkbox' ||
        type == 'radio') {
      List<String> options = [];
      if (field['options'] != null) {
        if (field['options'] is List) {
          options =
              (field['options'] as List).map((e) => e.toString()).toList();
        } else {
          options =
              field['options']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
        }
      }
      inputWidget = BkuCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _customAnswers[label],
            hint: Text(
              'Pilih $label',
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: context.appColors.outline,
            ),
            items:
                options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTextStyles.labelMd),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                _customAnswers[label] = newValue;
              });
            },
          ),
        ),
      );
    } else if (type == 'file' || type == 'upload') {
      final isRequired =
          field['required'] == true ||
          field['required'] == 'true' ||
          field['required'] == 1 ||
          field['required'] == '1';
      inputWidget = _buildUploadItem(
        isRequired ? '$label *' : label,
        Icons.upload_file_rounded,
        _customFiles[label],
        label, // pass label as type
      );
    } else {
      // Default to text field if unknown type
      if (_customTextControllers[label] == null) {
        _customTextControllers[label] = TextEditingController(
          text: _customAnswers[label]?.toString() ?? '',
        );
      }
      inputWidget = _buildTextField(
        label,
        _customTextControllers[label]!,
        'Masukkan $label',
        onChanged: (val) {
          _customAnswers[label] = val;
        },
      );
    }

    if (type == 'text' ||
        type == 'paragraph' ||
        type == 'textarea' ||
        (type != 'select' &&
            type != 'dropdown' &&
            type != 'checkbox' &&
            type != 'radio' &&
            type != 'file' &&
            type != 'upload')) {
      return inputWidget; // BkuTextField handles its own label
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildLabel(label), inputWidget],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.br2,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: context.appColors.outline,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return BkuTextField(
      label: label,
      controller: controller,
      hint: hint,
      maxLines: maxLines,
      validator:
          (val) => val == null || val.isEmpty ? 'Data ini wajib diisi' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildTextArea(
    String label,
    TextEditingController controller,
    String hint, {
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
  }) {
    return BkuTextField(
      label: label,
      controller: controller,
      hint: hint,
      maxLines: 5,
      autovalidateMode: autovalidateMode,
      validator:
          validator ??
          ((val) => val == null || val.isEmpty ? 'Data ini wajib diisi' : null),
      onChanged: onChanged,
    );
  }

  void _viewDocument(String label, String filePath) {
    final isNetwork = filePath.startsWith('/uploads');
    final cleanPath =
        isNetwork
            ? '${ApiGate.baseUrl.replaceAll('/api', '')}$filePath'
            : filePath;
    final ext = filePath.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child:
                        isImage
                            ? ClipRRect(
                              borderRadius: AppRadius.radiusLg,
                              child:
                                  isNetwork
                                      ? CachedNetworkImage(imageUrl: 
                                        cleanPath,
                                        fit: BoxFit.contain,
                                        errorWidget:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  AppSpacing.xl,
                                                ),
                                                child: Text(
                                                  'Gagal memuat gambar dari server',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        placeholder: (context, url) => Container(color: AppColors.neutral200),
                                      )
                                      : Image.file(
                                        File(cleanPath),
                                        fit: BoxFit.contain,
                                      ),
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 80,
                                  color: AppColors.neutral800,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  filePath.split('/').last,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Dokumen PDF tidak dapat ditampilkan langsung. Ketuk "Ganti Dokumen" jika ingin mengubah berkas.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        context.appColors.outline,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
    );
  }

  void _showActionSheet(String label, dynamic typeOrOnTap, String filePath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.xl,
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.neutral600,
                ),
                title: Text(
                  'Lihat Dokumen',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewDocument(label, filePath);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cached_rounded,
                  color: AppColors.neutral800,
                ),
                title: Text(
                  'Ganti Dokumen',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (typeOrOnTap is String) {
                    _pickFile(typeOrOnTap);
                  } else if (typeOrOnTap is Function) {
                    typeOrOnTap();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.neutral800,
                ),
                title: Text(
                  'Hapus Dokumen',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (typeOrOnTap is String) {
                    setState(() {
                      if (typeOrOnTap == 'ktm_ktp') {
                        _ktmKtpPath = null;
                      } else if (typeOrOnTap == 'sertifikat') {
                        _sertifikatPath = null;
                      } else if (typeOrOnTap == 'transkrip') {
                        _transkripPath = null;
                      }
                    });
                  } else {
                    setState(() {
                      _customFiles[label] = null;
                      _customAnswers.remove(label);
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadItem(
    String label,
    IconData icon,
    String? filePath,
    dynamic typeOrOnTap,
  ) {
    final fileName = filePath?.replaceAll('\\', '/').split('/').last;
    final ext = filePath != null ? filePath.split('.').last.toLowerCase() : '';
    final isImage = filePath != null && ['jpg', 'jpeg', 'png'].contains(ext);
    final isNetwork = filePath != null && filePath.startsWith('/uploads');
    final cleanPath =
        filePath != null && isNetwork
            ? '${ApiGate.baseUrl.replaceAll('/api', '')}$filePath'
            : filePath;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.br14,
        border: Border.all(
          color: filePath != null ? AppColors.primary : AppColors.neutral200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (filePath != null) {
              _showActionSheet(label, typeOrOnTap, filePath);
            } else {
              if (typeOrOnTap is String) {
                _pickFile(typeOrOnTap);
              } else if (typeOrOnTap is Function) {
                typeOrOnTap();
              }
            }
          },
          borderRadius: AppRadius.br14,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        filePath != null
                            ? context.appColors.infoContainer
                            : AppColors.neutral100,
                    borderRadius: AppRadius.br10,
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.br10,
                    child:
                        filePath != null
                            ? (isImage
                                ? (isNetwork
                                    ? CachedNetworkImage(imageUrl: 
                                      cleanPath!,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(
                                                Icons.broken_image_rounded,
                                                color: AppColors.neutral500,
                                              ),
                                      placeholder: (context, url) => Container(color: AppColors.neutral200),
                                    )
                                    : Image.file(
                                      File(cleanPath!),
                                      fit: BoxFit.cover,
                                    ))
                                : const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ))
                            : Icon(
                              icon,
                              color: AppColors.neutral500,
                              size: 22,
                            ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        fileName ?? 'PDF / JPG (Maks. 5MB)',
                        style: TextStyle(
                          color:
                              fileName != null
                                  ? AppColors.neutral600
                                  : AppColors.neutral400,
                          fontSize: 11,
                          fontWeight:
                              fileName != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (filePath != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.successContainer,
                      borderRadius: AppRadius.br6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: context.appColors.info,
                          size: 12,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Selesai',
                          style: TextStyle(
                            color: context.appColors.info,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s6),
                ],
                Icon(
                  filePath != null
                      ? Icons.more_vert_rounded
                      : Icons.cloud_upload_outlined,
                  color:
                      filePath != null
                          ? AppColors.neutral500
                          : AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.br14,
        border: Border.all(color: AppColors.neutral200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _isAgreed = !_isAgreed),
        borderRadius: AppRadius.br10,
        child: Row(
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (val) => setState(() => _isAgreed = val ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXs,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Saya menyatakan bahwa semua data yang saya lampirkan adalah benar.',
                style: TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: !_isAgreed ? null : () => _submitForm(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.neutral200,
          foregroundColor: context.appColors.onPrimary,
          disabledForegroundColor: AppColors.neutral400,
          elevation: 0,
          shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
          ),
        ),
        child: Text(
          widget.scholarship.status == 'Applied'
              ? 'Simpan Perubahan'
              : 'Kirim Pendaftaran',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    AppSnackbar.showSuccess(context, message);
  }

  Future<void> _submitForm() async {
    // Validasi berkas wajib berdasarkan pengaturan beasiswa
    if (widget.scholarship.fileKtm == 'wajib' && _ktmKtpPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('KTM & KTP wajib diunggah!'),
          backgroundColor: AppColors.neutral800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (widget.scholarship.fileTranskrip == 'wajib' && _transkripPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transkrip Nilai wajib diunggah!'),
          backgroundColor: AppColors.neutral800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (widget.scholarship.fileSertifikat == 'wajib' &&
        _sertifikatPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sertifikat Pendukung wajib diunggah!'),
          backgroundColor: AppColors.neutral800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi field custom
    for (var field in _customFields) {
      final label = field['label'];
      final type = (field['type'] ?? 'text').toString().toLowerCase();
      if (type == 'select' ||
          type == 'dropdown' ||
          type == 'checkbox' ||
          type == 'radio') {
        if (_customAnswers[label] == null ||
            _customAnswers[label].toString().isEmpty) {
          _showErrorSnackBar('Opsi untuk $label wajib dipilih!');
          return;
        }
      } else if (type == 'file' || type == 'upload') {
        if (_customFiles[label] == null && _customAnswers[label] == null) {
          _showErrorSnackBar('Dokumen $label wajib diunggah!');
          return;
        }
      }
    }

    if (_formKey.currentState!.validate()) {
      BkuLoadingDialog.show(context);

      try {
        // Upload custom files first if any
        for (var entry in _customFiles.entries) {
          final label = entry.key;
          final path = entry.value;
          if (path != null &&
              path.isNotEmpty &&
              !path.startsWith('/uploads') &&
              !path.startsWith('http')) {
            final uploadedUrl = await context
                .read<StudentProvider>()
                .uploadCustomFile(path);
            _customAnswers[label] = uploadedUrl;
          }
        }

        // Make sure all text controller values are in _customAnswers
        for (var entry in _customTextControllers.entries) {
          _customAnswers[entry.key] = entry.value.text;
        }

        if (!mounted) return;
        await context.read<StudentProvider>().applyForScholarship(
          widget.scholarship.id,
          _reasonController.text,
          ktmKtpPath: _ktmKtpPath,
          sertifikatPath: _sertifikatPath,
          transkripPath: _transkripPath,
          customAnswers:
              _customAnswers.isNotEmpty ? jsonEncode(_customAnswers) : null,
          rubrikAnswers:
              _rubrikAnswers.isNotEmpty ? jsonEncode(_rubrikAnswers) : null,
        );

        // Tutup loading overlay
        if (mounted) BkuLoadingDialog.hide(context);

        // Tampilkan dialog sukses
        _showSuccessDialog();
      } catch (e) {
        // Tutup loading overlay
        if (mounted) BkuLoadingDialog.hide(context);

        // Tampilkan pesan error
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => CustomDialog(
                  title: 'Gagal Mengirim Data',
                  content: ErrorHandler.getMessage(e),
                  cancelText: '',
                  confirmText: 'Tutup',
                  onConfirm: () => Navigator.pop(context),
                  onCancel: () {},
                ),
          );
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isEdit = widget.scholarship.status == 'Applied';
        return CustomDialog(
          title: isEdit ? 'Perubahan Disimpan!' : 'Pendaftaran Terkirim!',
          content:
              isEdit
                  ? 'Data pendaftaran kamu telah berhasil diperbarui.'
                  : 'Aplikasi beasiswa kamu telah masuk tahap Seleksi Berkas. Pantau terus statusnya di menu Beasiswa.',
          cancelText: '', // Hide cancel button
          confirmText: 'Tutup',
          onCancel: () {},
          onConfirm: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
