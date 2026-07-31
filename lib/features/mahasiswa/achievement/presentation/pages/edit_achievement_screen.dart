import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';

import 'package:bkuhub_mobile/features/mahasiswa/achievement/data/models/achievement_form_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/providers/achievement_form_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class EditAchievementScreen extends StatefulWidget {
  final int achievementId;
  final String namaPrestasi;
  final String tingkat;
  final DateTime tanggal;
  final String deskripsi;
  const EditAchievementScreen({
    super.key,
    required this.achievementId,
    required this.namaPrestasi,
    required this.tingkat,
    required this.tanggal,
    required this.deskripsi,
  });

  @override
  State<EditAchievementScreen> createState() => _EditAchievementScreenState();
}

class _EditAchievementScreenState extends State<EditAchievementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late DateTime _selectedDate;
  late String _selectedTingkat;
  String? _selectedFilePath;
  String? _selectedFileName;

  final _tingkatOptions = ['Lokal', 'Provinsi', 'Nasional', 'Internasional'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaPrestasi);
    _deskripsiController = TextEditingController(text: widget.deskripsi);
    _selectedDate = widget.tanggal;
    _selectedTingkat = _tingkatOptions.contains(widget.tingkat) ? widget.tingkat : 'Lokal';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchievementFormProvider>();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: const BkuStaticAppBar(
        title: 'Edit Prestasi',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Prestasi', required: true),
              BkuTextField(
                controller: _namaController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama prestasi wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Contoh: Juara 1 Lomba Karya Tulis Ilmiah',
                  hintStyle: AppTextStyles.labelMd.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: context.appColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withAlpha(30),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withAlpha(30),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildLabel('Tingkat', required: true),
              _buildDropdown(
                _tingkatOptions,
                (val) => setState(() => _selectedTingkat = val!),
                _selectedTingkat,
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildLabel('Tanggal Pelaksanaan', required: true),
              _buildDatePicker(),
              const SizedBox(height: AppSpacing.xl),

              _buildLabel('Deskripsi', required: true),
              BkuTextField(
                controller: _deskripsiController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Deskripsikan prestasi Anda...',
                  hintStyle: AppTextStyles.labelMd.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: context.appColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withAlpha(30),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withAlpha(30),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildLabel('Sertifikat (Opsional)'),
              _buildUploadSection(),
              const SizedBox(height: AppSpacing.s48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: BkuButton(
                  onPressed: provider.isLoading ? null : _submit,
                  isLoading: provider.isLoading,
                  text: 'Simpan Perubahan',
                  variant: BkuButtonVariant.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    Function(String?) onChanged,
    String currentValue,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(30),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(currentValue) ? currentValue : items.first,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.outline,
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppTextStyles.labelMd.copyWith(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() => _selectedDate = picked);
        }
      },
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: AppTextStyles.labelMd,
            ),
            Icon(
              Icons.calendar_today_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    final bool hasFile = _selectedFileName != null;
    return InkWell(
      onTap: _pickFile,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFF0FDF4) : context.appColors.background,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: hasFile ? const Color(0xFF86EFAC) : AppColors.neutral200,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: AppSpacing.padding14,
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? Icons.task_rounded : Icons.cloud_upload_rounded,
                size: 28,
                color: hasFile ? context.appColors.success : context.appColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _selectedFileName ?? 'Klik untuk Upload File',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasFile ? context.appColors.success : context.appColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasFile ? 'Klik untuk mengganti file' : 'Maks 5MB (PDF, JPG, PNG)',
              style: const TextStyle(color: AppColors.neutral600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
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
                  style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.neutral600),
                title: Text('Kamera', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedFilePath = image.path;
                      _selectedFileName = image.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_rounded, color: AppColors.neutral600),
                title: Text('Galeri / File (PDF)', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );
                  if (result != null && result.files.single.path != null) {
                    setState(() {
                      _selectedFilePath = result.files.single.path;
                      _selectedFileName = result.files.single.name;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final form = AchievementFormModel(
      namaPrestasi: _namaController.text.trim(),
      tingkat: _selectedTingkat,
      tanggal: _selectedDate,
      deskripsi: _deskripsiController.text.trim(),
    );

    context.read<AchievementFormProvider>().updateAchievement(
      widget.achievementId,
      form,
      filePath: _selectedFilePath,
    );
  }
}
