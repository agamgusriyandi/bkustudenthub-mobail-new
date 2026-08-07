import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:go_router/go_router.dart';

class DaftarOrmawaScreen extends StatefulWidget {
  final String ormawaId;
  final String namaOrmawa;

  const DaftarOrmawaScreen({
    super.key,
    required this.ormawaId,
    required this.namaOrmawa,
  });

  @override
  State<DaftarOrmawaScreen> createState() => _DaftarOrmawaScreenState();
}

class _DaftarOrmawaScreenState extends State<DaftarOrmawaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Default lampiran
  String? _lampiranPath;
  String? _lampiranName;

  // Divisions & Custom fields loaded from API
  List<Map<String, dynamic>> _divisions = [];
  String? _selectedDivisi;
  String? _selectedDivisi2;

  List<dynamic> _recruitmentFields = [];

  // Dynamic fields state mapping
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _filePaths = {};
  final Map<String, String?> _fileNames = {};
  final Map<String, bool> _checkboxValues = {};
  final Map<String, String?> _selectValues = {};

  @override
  void initState() {
    super.initState();
    _loadOrmawaDetails();
  }

  Future<void> _loadOrmawaDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provider = context.read<OrganizationProvider>();
      final divisionsList = await provider.getOrmawaDivisions(widget.ormawaId);
      final fieldsData = await provider.getRecruitmentFields(widget.ormawaId);

      if (mounted) {
        setState(() {
          _divisions = divisionsList;
          _recruitmentFields = fieldsData['data'] ?? [];

          // Initialize state maps for dynamic fields
          for (var field in _recruitmentFields) {
            final idStr = (field['id'] ?? field['ID']).toString();
            final type = field['type']?.toString().toLowerCase() ?? 'text';
            if (type == 'text' || type == 'paragraph') {
              _textControllers[idStr] = TextEditingController();
            } else if (type == 'checkbox') {
              _checkboxValues[idStr] = false;
            } else if (type == 'select') {
              _selectValues[idStr] = null;
            }
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final errMsg = e.toString().toLowerCase();
        if (errMsg.contains('tutup') ||
            errMsg.contains('closed') ||
            errMsg.contains('400')) {
          _errorMessage = 'Pendaftaran Ormawa ini sedang ditutup';
        } else {
          _errorMessage = 'Gagal memuat detail pendaftaran';
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _lampiranPath = result.files.single.path;
          _lampiranName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file');
      }
    }
  }

  Future<void> _pickDynamicFile(String fieldId) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _filePaths[fieldId] = result.files.single.path;
          _fileNames[fieldId] = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate dynamic required files
    if (_recruitmentFields.isNotEmpty) {
      for (var field in _recruitmentFields) {
        final idStr = (field['id'] ?? field['ID']).toString();
        final isRequired = field['required'] == true || field['required'] == 1;
        final type = field['type']?.toString().toLowerCase() ?? 'text';
        if (type == 'file' && isRequired) {
          if (_filePaths[idStr] == null || _filePaths[idStr]!.isEmpty) {
            AppSnackbar.showWarning(
              context,
              'File ${field['label'] ?? 'lampiran'} wajib diunggah',
            );
            return;
          }
        }
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final provider = context.read<OrganizationProvider>();
      String cvUrl = '';
      if (_lampiranPath != null && _lampiranPath!.isNotEmpty) {
        cvUrl = await provider.uploadRecruitmentFile(_lampiranPath!);
      }

      // Map dynamic fields
      final Map<String, String> customAnswers = {};
      if (_recruitmentFields.isNotEmpty) {
        for (var field in _recruitmentFields) {
          final idStr = (field['id'] ?? field['ID']).toString();
          final type = field['type']?.toString().toLowerCase() ?? 'text';

          if (type == 'text' || type == 'paragraph') {
            customAnswers[idStr] = _textControllers[idStr]?.text ?? '';
          } else if (type == 'checkbox') {
            customAnswers[idStr] =
                (_checkboxValues[idStr] ?? false) ? 'true' : 'false';
          } else if (type == 'select') {
            customAnswers[idStr] = _selectValues[idStr] ?? '';
          } else if (type == 'file') {
            final path = _filePaths[idStr];
            if (path != null && path.isNotEmpty) {
              final uploadedUrl = await provider.uploadRecruitmentFile(path);
              customAnswers[idStr] = uploadedUrl;
            } else {
              customAnswers[idStr] = '';
            }
          }
        }
      }

      await provider.daftarOrmawa(
        ormawaId: widget.ormawaId,
        alasan: _recruitmentFields.isEmpty ? _alasanController.text : '',
        cvUrl: cvUrl,
        divisi: _selectedDivisi,
        divisiPilihanDua: _selectedDivisi2,
        customAnswers: _recruitmentFields.isNotEmpty ? customAnswers : null,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => CustomDialog(
              title: 'Berhasil',
              content: 'Pendaftaran ke Ormawa berhasil diajukan.',
              isSuccess: true,
              cancelText: '',
              confirmText: 'Tutup',
              onCancel: () {},
              onConfirm: () {
                context.pop(); // Close dialog
                context.pop(); // Go back
              },
            ),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: BkuStaticAppBar(
        title: 'Daftar ${widget.namaOrmawa}',
        variant: AppBarVariant.clean,
        showBackButton: true,
      ),
      body:
          _isLoading
              ? const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: BkuShimmerList(itemCount: 5, itemHeight: 80),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: BkuButton(
                          onPressed: () => context.pop(),
                          text: 'Kembali',
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic divisions block
                      if (_divisions.isNotEmpty) ...[
                        Text(
                          'Pilih Divisi (Prioritas 1)',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDivisi,
                          decoration: InputDecoration(
                            fillColor: AppColors.neutral50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: const BorderSide(
                                color: AppColors.neutral600,
                                width: 1.5,
                              ),
                            ),
                          ),
                          hint: Text(
                            'Pilih divisi utama...',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                          items:
                              _divisions.map((div) {
                                final name =
                                    div['nama']?.toString() ?? 'Divisi';
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                );
                              }).toList(),
                          validator:
                              (val) =>
                                  val == null
                                      ? 'Divisi utama wajib dipilih'
                                      : null,
                          onChanged: (val) {
                            setState(() {
                              _selectedDivisi = val;
                              if (_selectedDivisi2 == val) {
                                _selectedDivisi2 = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Pilih Divisi (Prioritas 2 - Opsional)',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDivisi2,
                          decoration: InputDecoration(
                            fillColor: AppColors.neutral50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: const BorderSide(
                                color: AppColors.neutral600,
                                width: 1.5,
                              ),
                            ),
                          ),
                          hint: Text(
                            'Pilih divisi kedua...',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                          items:
                              _divisions
                                  .where(
                                    (div) =>
                                        div['nama']?.toString() !=
                                        _selectedDivisi,
                                  )
                                  .map((div) {
                                    final name =
                                        div['nama']?.toString() ?? 'Divisi';
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    );
                                  })
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDivisi2 = val;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Dynamic form fields / Default form fields
                      if (_recruitmentFields.isEmpty) ...[
                        Text(
                          'Mengapa Anda ingin bergabung dengan ${widget.namaOrmawa}?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BkuTextField(
                          controller: _alasanController,
                          maxLines: 5,
                          validator:
                              (value) =>
                                  value!.isEmpty ? 'Alasan wajib diisi' : null,
                          decoration: InputDecoration(
                            hintText: 'Tuliskan motivasi dan alasan Anda...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral400,
                            ),
                            filled: true,
                            fillColor: AppColors.neutral50,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: const BorderSide(
                                color: AppColors.neutral600,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Lampiran Pendukung (CV/Portofolio)',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withAlpha(50),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Maksimal 5MB (PDF/JPG/PNG)',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(50),
                                  fontSize: 10,
                                ),
                              ),
                              if (_lampiranName != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'File terpilih: $_lampiranName',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral800,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              InkWell(
                                onTap: _pickFile,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Text(
                                    _lampiranName == null
                                        ? 'Pilih File'
                                        : 'Ganti File',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.neutral800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ..._recruitmentFields.map((field) {
                          final label = field['label']?.toString() ?? 'Field';
                          final type =
                              field['type']?.toString().toLowerCase() ?? 'text';
                          final required = field['required'] as bool? ?? false;
                          final idStr = (field['id'] ?? field['ID']).toString();
                          final options = field['options']?.toString() ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    if (required)
                                      Text(
                                        ' *',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (type == 'text')
                                  BkuTextField(
                                    controller: _textControllers[idStr],
                                    validator:
                                        (val) =>
                                            required &&
                                                    (val == null || val.isEmpty)
                                                ? '$label wajib diisi'
                                                : null,
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan jawaban...',
                                      filled: true,
                                      fillColor: AppColors.neutral50,
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: const BorderSide(
                                          color: AppColors.neutral600,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (type == 'paragraph')
                                  BkuTextField(
                                    controller: _textControllers[idStr],
                                    maxLines: 4,
                                    validator:
                                        (val) =>
                                            required &&
                                                    (val == null || val.isEmpty)
                                                ? '$label wajib diisi'
                                                : null,
                                    decoration: InputDecoration(
                                      hintText: 'Tuliskan jawaban...',
                                      filled: true,
                                      fillColor: AppColors.neutral50,
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: const BorderSide(
                                          color: AppColors.neutral600,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (type == 'select')
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectValues[idStr],
                                    decoration: InputDecoration(
                                      fillColor: AppColors.neutral50,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.radiusLg,
                                        borderSide: const BorderSide(
                                          color: AppColors.neutral600,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    hint: Text(
                                      'Pilih opsi...',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                    items:
                                        options
                                            .split(',')
                                            .map((opt) => opt.trim())
                                            .where((opt) => opt.isNotEmpty)
                                            .map((opt) {
                                              return DropdownMenuItem<String>(
                                                value: opt,
                                                child: Text(opt),
                                              );
                                            })
                                            .toList(),
                                    validator:
                                        (val) =>
                                            required && val == null
                                                ? '$label wajib dipilih'
                                                : null,
                                    onChanged: (val) {
                                      setState(() {
                                        _selectValues[idStr] = val;
                                      });
                                    },
                                  )
                                else if (type == 'checkbox')
                                  CheckboxListTile(
                                    title: Text(
                                      'Ya, saya menyetujui / mengonfirmasi',
                                      style: AppTextStyles.bodyMd,
                                    ),
                                    value: _checkboxValues[idStr] ?? false,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    activeColor: AppColors.neutral800,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (val) {
                                      setState(() {
                                        _checkboxValues[idStr] = val ?? false;
                                      });
                                    },
                                  )
                                else if (type == 'file')
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.xl,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.appColors.surface,
                                      borderRadius: AppRadius.radiusXl,
                                      border: Border.all(
                                        color:
                                            Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.file_upload_outlined,
                                          size: 36,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline.withAlpha(50),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          'Maksimal 5MB (PDF/JPG/PNG)',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline.withAlpha(50),
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (_fileNames[idStr] != null) ...[
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            'File terpilih: ${_fileNames[idStr]}',
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color: AppColors.neutral800,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.md),
                                        InkWell(
                                          onTap: () => _pickDynamicFile(idStr),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.lg,
                                              vertical: AppSpacing.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.neutral100,
                                              borderRadius: AppRadius.radiusMd,
                                            ),
                                            child: Text(
                                              _fileNames[idStr] == null
                                                  ? 'Pilih File'
                                                  : 'Ganti File',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: AppColors.neutral800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: AppSpacing.xxxl),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,

                          child:
                              _isSubmitting
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.appColors.onPrimary,
                                    ),
                                  )
                                  : Text(
                                    'Kirim Pendaftaran',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.onPrimary,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
