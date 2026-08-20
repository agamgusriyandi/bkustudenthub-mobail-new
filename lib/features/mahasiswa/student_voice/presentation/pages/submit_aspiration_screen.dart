import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_voice_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
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
              FadeInAnimation(
                delay: 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tujuan Aspirasi'),
                    _buildTujuanSelector(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeInAnimation(
                delay: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Pilih Kategori'),
                    _buildCategorySelector(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeInAnimation(
                delay: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Judul Aspirasi'),
                    BkuTextField(
                      controller: _titleController,
                      style: BkuTheme.textBodyRegular,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Perbaikan AC Ruang Kuliah 302',
                        hintStyle: BkuTheme.textCaption.copyWith(color: BkuTheme.textPlaceholder),
                        filled: true,
                        fillColor: BkuTheme.cardSurface,
                        border: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: const BorderSide(color: BkuTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: const BorderSide(color: BkuTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: BorderSide(color: BkuTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Mohon masukkan judul aspirasi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeInAnimation(
                delay: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Detail Aspirasi'),
                    BkuTextField(
                      controller: _descController,
                      maxLines: 5,
                      style: BkuTheme.textBodyRegular,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan detail kendala, saran, atau masukan yang ingin disampaikan...',
                        hintStyle: BkuTheme.textCaption.copyWith(color: BkuTheme.textPlaceholder),
                        filled: true,
                        fillColor: BkuTheme.cardSurface,
                        border: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: const BorderSide(color: BkuTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: const BorderSide(color: BkuTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BkuTheme.r12,
                          borderSide: BorderSide(color: BkuTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Mohon masukkan detail aspirasi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeInAnimation(
                delay: 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Lampiran Bukti (Opsional)'),
                    _buildUploadSection(),
                  ],
                ),
              ),
              if (_isAnonimEnabled) ...[
                const SizedBox(height: AppSpacing.lg),
                FadeInAnimation(
                  delay: 0.3,
                  child: _buildAnonimSwitch(),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              FadeInAnimation(
                delay: 0.35,
                child: SizedBox(
                  width: double.infinity,
                  child: BkuButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    text: 'Kirim Aspirasi',
                    isLoading: _isSubmitting,
                    icon: Icons.send_rounded,
                    variant: BkuButtonVariant.primary,
                    height: 46,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: 2),
      child: Text(
        text,
        style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
      ),
    );
  }

  Widget _buildTujuanSelector() {
    return Container(
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r12,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DropdownButtonHideUnderline(
        child: BkuDropdown<String>(
          value: _selectedTujuan,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: BkuTheme.textMuted,
          ),
          items: [
            'Fakultas',
            'Universitas',
            'Program Studi (Prodi)',
            'Biro Kemahasiswaan / BAAK',
            'Sarana & Prasarana',
            'Organisasi Mahasiswa (Ormawa)',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: BkuTheme.textBodyRegular),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTujuan = newValue;
              });
            }
          },
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
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return InkWell(
          onTap: () => setState(() => _selectedCategory = cat),
          borderRadius: BkuTheme.rPill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
            decoration: BoxDecoration(
              color: isSelected ? BkuTheme.primary : BkuTheme.cardSurface,
              borderRadius: BkuTheme.rPill,
              border: Border.all(
                color: isSelected ? BkuTheme.primary : BkuTheme.border,
              ),
              boxShadow: isSelected ? BkuTheme.cardShadow : null,
            ),
            child: Text(
              cat,
              style: BkuTheme.textBadge.copyWith(
                color: isSelected ? Colors.white : BkuTheme.textHeading,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BkuTheme.indigoSoft,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.indigoBorder),
            ),
            child: const Icon(Icons.add_photo_alternate_rounded, color: BkuTheme.indigo, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Unggah Foto atau Dokumen Pendukung', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
          const SizedBox(height: 2),
          Text('Format PDF, JPG, PNG (Maksimal 10MB)', style: BkuTheme.textCaption.copyWith(fontSize: 10.5)),
          if (_attachmentName != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BkuTheme.emeraldSoft,
                borderRadius: BkuTheme.r8,
                border: Border.all(color: BkuTheme.emeraldBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file_rounded, size: 14, color: BkuTheme.emerald),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _attachmentName!,
                      style: BkuTheme.textBadge.copyWith(color: BkuTheme.emerald, fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickFile,
            borderRadius: BkuTheme.rPill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7.5),
              decoration: BoxDecoration(
                color: BkuTheme.primarySoft,
                borderRadius: BkuTheme.rPill,
                border: Border.all(color: BkuTheme.primaryBorder),
              ),
              child: Text(
                _attachmentName == null ? 'Pilih File' : 'Ganti File',
                style: BkuTheme.textBadge.copyWith(
                  color: BkuTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonimSwitch() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r10,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: BkuTheme.indigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kirim Sebagai Anonim',
                    style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
                  ),
                  Text(
                    'Identitas nama dan NIM tidak ditampilkan',
                    style: BkuTheme.textCaption.copyWith(fontSize: 10),
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
            activeThumbColor: BkuTheme.primary,
          ),
        ],
      ),
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
                leading: Icon(Icons.camera_alt_rounded, color: BkuTheme.primary),
                title: Text('Kamera', style: BkuTheme.textBodyRegular),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _attachmentPath = pickedFile.path;
                      _attachmentName = pickedFile.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: BkuTheme.primary),
                title: Text('Galeri Foto', style: BkuTheme.textBodyRegular),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _attachmentPath = pickedFile.path;
                      _attachmentName = pickedFile.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_rounded, color: BkuTheme.primary),
                title: Text('File Dokumen (PDF)', style: BkuTheme.textBodyRegular),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final result = await FilePicker.pickFiles(
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
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: DateTime.now(),
        status: 'Pending',
        attachmentPath: _attachmentPath,
        tujuan: _selectedTujuan,
        isAnonim: _isAnonim,
      );
      await context.read<StudentVoiceProvider>().addAspiration(newAsp);
      if (!mounted) return;
      BkuLoadingDialog.hide(context);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      BkuLoadingDialog.hide(context);
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    }
  }

  void _showSuccessDialog() {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.success,
      title: 'Aspirasi Terkirim',
      message: 'Aspirasi Anda berhasil dikirimkan ke pihak kampus dan akan segera ditindaklanjuti.',
      primaryButtonText: 'Kembali',
      onPrimaryPressed: () {
        Navigator.pop(context);
        context.pop();
      },
    );
  }
}