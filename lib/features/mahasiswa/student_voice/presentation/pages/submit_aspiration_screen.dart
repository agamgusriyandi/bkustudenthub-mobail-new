import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';

import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';

class SubmitAspirationScreen extends StatefulWidget {
  const SubmitAspirationScreen({super.key});

  @override
  State<SubmitAspirationScreen> createState() => _SubmitAspirationScreenState();
}

class _SubmitAspirationScreenState extends State<SubmitAspirationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Fasilitas';
  String _selectedTujuan = 'Fakultas';
  bool _isAnonim = false;
  final bool _isSubmitting = false;
  String? _attachmentPath;
  String? _attachmentName;
  bool _isAnonimEnabled = true;


  @override
  void initState() {
    super.initState();
    _fetchSystemSettings();
  }

  Future<void> _fetchSystemSettings() async {
    try {
      final response = await ApiClient().client.get('/public/system-settings');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['settings'] != null) {
          final isEnabled = data['settings']['anonymous_aspirasi_enabled'] == 'true';
          if (mounted) {
            setState(() {
              _isAnonimEnabled = isEnabled;

              if (!isEnabled) {
                _isAnonim = false;
              }
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch system settings: $e');
    }
    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const BkuStaticAppBar(
        title: 'Sampaikan Aspirasi',
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
              _buildLabel('Tujuan Aspirasi'),
              _buildTujuanSelector(),
              const SizedBox(height: 20),
              _buildSectionTitle('Pilih Kategori'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 32),
              _buildSectionTitle('Apa yang ingin kamu sampaikan?'),
              const SizedBox(height: 12),
              _buildLabel('Judul Aspirasi'),
              _buildTextField(
                _titleController,
                'Contoh: Kerusakan Kursi di Kantin',
              ),
              const SizedBox(height: 20),
              _buildLabel('Detail Aspirasi'),
              _buildTextArea(
                _descController,
                'Ceritakan lebih detail mengenai saran atau keluhanmu...',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Lampirkan Bukti (Opsional)'),
              const SizedBox(height: 12),
              _buildUploadSection(),
              const SizedBox(height: 20),
              if (_isAnonimEnabled) _buildAnonimSwitch(),

              const SizedBox(height: 48),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTujuanSelector() {
    return BkuCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTujuan,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Theme.of(context).colorScheme.outline,
          ),
          items:
              [
                'Fakultas',
                'Universitas',
                'Program Studi (Prodi)',
                'Organisasi Mahasiswa (Ormawa)',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTextStyles.labelMd),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedTujuan = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAnonimSwitch() {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.neutral600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kirim Anonim',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Identitasmu akan disembunyikan',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isAnonim,
            onChanged: (val) {
              setState(() {
                _isAnonim = val;
              });
            },
            activeThumbColor: AppColors.neutral800,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLg.copyWith(fontSize: 18));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      'Akademik',
      'Fasilitas',
      'Kemahasiswaan',
      'Saran & Ide',
      'Lainnya',
    ];
    return Wrap(
      spacing: 8,
      children:
          categories.map((cat) {
            bool isSelected = _selectedCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              selectedColor: AppColors.neutral100,
              labelStyle: AppTextStyles.labelSm.copyWith(
                color:
                    isSelected
                        ? AppColors.neutral800
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMd,
                side: BorderSide(
                  color:
                      isSelected ? AppColors.neutral800 : AppColors.neutral200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return BkuTextField(
      controller: controller,
      style: AppTextStyles.labelMd,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.neutral50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Mohon isi judul' : null,
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint) {
    return BkuTextField(
      controller: controller,
      maxLines: 6,
      style: AppTextStyles.labelMd,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.neutral50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
      ),
      validator:
          (val) =>
              val == null || val.isEmpty ? 'Mohon isi detail aspirasi' : null,
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: AppColors.neutral200,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.outline.withAlpha(50),
          ),
          const SizedBox(height: 12),
          Text(
            'Klik untuk unggah Foto atau Dokumen',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Maksimal 10MB',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline.withAlpha(50),
              fontSize: 10,
            ),
          ),
          if (_attachmentName != null) ...[
            const SizedBox(height: 12),
            Text(
              'File terpilih: $_attachmentName',
              style: AppTextStyles.labelSm.copyWith(),
            ),
          ],
          const SizedBox(height: 16),
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
                _attachmentName == null ? 'Pilih File' : 'Ganti File',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BkuButton(
      onPressed: _isSubmitting ? null : () => _submitForm(),
      text: 'Kirim Aspirasi',
      isLoading: _isSubmitting,
      icon: Icons.send_rounded,
      variant: BkuButtonVariant.primary,
    );
  }

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachmentPath = pickedFile.path;
                      _attachmentName = pickedFile.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachmentPath = pickedFile.path;
                      _attachmentName = pickedFile.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_rounded),
                title: const Text('File Explorer'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    FilePickerResult? result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null) {
                      setState(() {
                        _attachmentPath = result.files.single.path;
                        _attachmentName = result.files.single.name;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      AppSnackbar.showError(context, 'Gagal memilih file');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    BkuLoadingDialog.show(context);

    try {
      final newAsp = Aspiration(
        id: 'ASP${DateTime.now().millisecondsSinceEpoch}',
        category: _selectedCategory,
        title: _titleController.text,
        description: _descController.text,
        date: DateTime.now(),
        status: 'Pending',
        attachmentPath: _attachmentPath,
        tujuan: _selectedTujuan,
        isAnonim: _isAnonim,
      );
      await context.read<StudentProvider>().addAspiration(newAsp);
      if (!mounted) return;
      BkuLoadingDialog.hide(context); // Hide loading first
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      BkuLoadingDialog.hide(context); // Hide loading first
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => CustomDialog(
            title: 'Berhasil',
            content: 'Aspirasi Anda berhasil dikirimkan.',
            isSuccess: true,
            cancelText: '',
            confirmText: 'Kembali',
            onCancel: () {},
            onConfirm: () {
              Navigator.pop(dialogContext); // Close success dialog
              Navigator.pop(context); // Go back
            },
          ),
    );
  }
}
