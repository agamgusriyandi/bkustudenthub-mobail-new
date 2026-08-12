import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/achievement.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';

import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';

class ReportAchievementScreen extends StatefulWidget {
  final Achievement? achievement;
  const ReportAchievementScreen({super.key, this.achievement});

  @override
  State<ReportAchievementScreen> createState() =>
      _ReportAchievementScreenState();
}

class _ReportAchievementScreenState extends State<ReportAchievementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Base Controllers
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedFilePath;
  String? _selectedFileName;

  // New Dynamic Dropdowns
  String _selectedTipe = 'Prestasi Mandiri';
  String _selectedKategori = 'RISNOV';
  String _selectedJenisRekognisi = 'SERKOM';
  String _selectedTingkat = 'NAS';
  String _selectedPeringkat = 'JUARA1';

  // New Dynamic Controllers
  final _danaDiajukanController = TextEditingController();

  // SIMKATMAWA Controllers
  final _cabangController = TextEditingController();
  final _urlPesertaController = TextEditingController();
  final _urlSertifikatController = TextEditingController();
  final _urlFotoUppController = TextEditingController();
  final _urlDokumenUndanganController = TextEditingController();
  final _jumlahUnitPesertaController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _anggotaMahasiswaController = TextEditingController();
  final _pembimbingDosenController = TextEditingController();

  String _selectedKelompokPrestasi = '';
  String _selectedBentuk = '';

  @override
  void initState() {
    super.initState();
    if (widget.achievement != null) {
      _titleController.text = widget.achievement!.title;
      _organizerController.text = widget.achievement!.organizer;
      _selectedDate = widget.achievement!.date;

      final tipe = widget.achievement!.tipe;
      if ([
        'Prestasi Mandiri',
        'Sertifikasi',
        'Rekognisi',
        'Pengajuan Dana',
      ].contains(tipe)) {
        _selectedTipe = tipe!;
      }

      final level = widget.achievement!.level;
      if (['KAB', 'PROV', 'NAS', 'INT'].contains(level)) {
        _selectedTingkat = level;
      }

      final rank = widget.achievement!.rank;
      if ([
        'JUARA1',
        'JUARA2',
        'JUARA3',
        'HARAPAN1',
        'HARAPAN2',
        'HARAPAN3',
        'APRESIASI',
        'PESERTA',
      ].contains(rank)) {
        _selectedPeringkat = rank;
      }

      final kat = widget.achievement!.kategori;
      if ([
        'RISNOV',
        'RISNOVSSH',
        'SENBUD',
        'OLAHRAGA',
        'MINAT',
      ].contains(kat)) {
        _selectedKategori = kat!;
      }

      final jR = widget.achievement!.jenisRekognisi;
      if ([
        'SERKOM',
        'JURIOR',
        'JURINOR',
        'KEYCONF',
        'KEYWORK',
        'PAMERAN',
        'KARYA',
        'BUKU',
        'PATEN',
        'PUB',
        'DUTA',
        'PTG',
        'PSB',
        'PKD',
      ].contains(jR)) {
        _selectedJenisRekognisi = jR!;
      }

      _danaDiajukanController.text = widget.achievement!.danaDiajukan ?? '';
      _cabangController.text = widget.achievement!.cabang ?? '';
      _urlPesertaController.text = widget.achievement!.urlPeserta ?? '';
      _urlFotoUppController.text = widget.achievement!.urlFotoUpp ?? '';
      _urlDokumenUndanganController.text =
          widget.achievement!.urlDokumenUndangan ?? '';
      _jumlahUnitPesertaController.text =
          widget.achievement!.jumlahUnitPeserta ?? '';

      final kel = widget.achievement!.kelompokPrestasi ?? '';
      if (['INDIVIDU', 'KELOMPOK'].contains(kel)) {
        _selectedKelompokPrestasi = kel;
      }

      final ben = widget.achievement!.bentuk ?? '';
      if (['LURING', 'DARING'].contains(ben)) {
        _selectedBentuk = ben;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _danaDiajukanController.dispose();
    _cabangController.dispose();
    _urlPesertaController.dispose();
    _urlSertifikatController.dispose();
    _urlFotoUppController.dispose();
    _urlDokumenUndanganController.dispose();
    _jumlahUnitPesertaController.dispose();
    _keteranganController.dispose();
    _anggotaMahasiswaController.dispose();
    _pembimbingDosenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: const BkuStaticAppBar(
        title: 'Sistem Mahasiswa',
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
              _buildInfoBanner(),
              const SizedBox(height: AppSpacing.xxl),

              _buildLabel('Tipe Pengajuan', required: true),
              _buildDropdown(
                'Tipe Pengajuan',
                [
                  'Prestasi Mandiri',
                  'Sertifikasi',
                  'Rekognisi',
                  'Pengajuan Dana',
                ],
                (val) => setState(() => _selectedTipe = val!),
                _selectedTipe,
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildLabel(
                _selectedTipe == 'Sertifikasi'
                    ? 'Nama Sertifikasi'
                    : _selectedTipe == 'Rekognisi'
                    ? 'Nama Rekognisi'
                    : 'Nama Lomba/Kompetisi',
                required: true,
              ),
              _buildTextField(
                _titleController,
                _selectedTipe == 'Sertifikasi'
                    ? 'Contoh: Sertifikasi BNSP'
                    : 'Contoh: Gemastik 2026',
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_selectedTipe == 'Prestasi Mandiri') ...[
                _buildLabel('Kategori', required: true),
                _buildDropdown(
                  'Kategori',
                  ['RISNOV', 'RISNOVSSH', 'SENBUD', 'OLAHRAGA', 'MINAT'],
                  (val) => setState(() => _selectedKategori = val!),
                  _selectedKategori,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (_selectedTipe == 'Rekognisi') ...[
                _buildLabel('Jenis Rekognisi', required: true),
                _buildDropdown(
                  'Jenis Rekognisi',
                  [
                    'SERKOM',
                    'JURIOR',
                    'JURINOR',
                    'KEYCONF',
                    'KEYWORK',
                    'PAMERAN',
                    'KARYA',
                    'BUKU',
                    'PATEN',
                    'PUB',
                    'DUTA',
                    'PTG',
                    'PSB',
                    'PKD',
                  ],
                  (val) => setState(() => _selectedJenisRekognisi = val!),
                  _selectedJenisRekognisi,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tingkat', required: true),
                        _buildDropdown(
                          'Tingkat',
                          ['KAB', 'PROV', 'NAS', 'INT'],
                          (val) => setState(() => _selectedTingkat = val!),
                          _selectedTingkat,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Penyelenggara', required: true),
                        _buildTextField(
                          _organizerController,
                          'Cth: Kemendikbud',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Pelaksanaan', required: true),
                        _buildDatePicker(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  if (_selectedTipe == 'Prestasi Mandiri')
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Peringkat Diraih', required: true),
                          _buildDropdown(
                            'Peringkat',
                            [
                              'JUARA1',
                              'JUARA2',
                              'JUARA3',
                              'HARAPAN1',
                              'HARAPAN2',
                              'HARAPAN3',
                              'APRESIASI',
                              'PESERTA',
                            ],
                            (val) => setState(() => _selectedPeringkat = val!),
                            _selectedPeringkat,
                          ),
                        ],
                      ),
                    )
                  else if (_selectedTipe == 'Pengajuan Dana')
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            'Dana yang Diajukan (Rp)',
                            required: true,
                          ),
                          _buildTextField(
                            _danaDiajukanController,
                            'Cth: 1500000',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // SIMKATMAWA Section
              _buildSimkatmawaSection(),
              const SizedBox(height: AppSpacing.xxl),

              _buildLabel(
                _selectedTipe == 'Pengajuan Dana'
                    ? 'Upload Proposal/Bukti Pendukung'
                    : 'Upload Sertifikat/Bukti',
                required: widget.achievement == null,
              ),
              _buildUploadSection(),
              const SizedBox(height: AppSpacing.s48),

              _buildSubmitButton(),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimkatmawaSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: context.appColors.outline.withAlpha(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                color: context.appColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Informasi Tambahan SIMKATMAWA',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '(Opsional) Lengkapi data ini untuk pelaporan ke kementerian.',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),

          _buildLabel('Cabang Lomba'),
          _buildTextField(_cabangController, 'Cth: Lomba Esai'),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Kepesertaan'),
                    _buildDropdown(
                      'Pilih',
                      ['', 'INDIVIDU', 'KELOMPOK'],
                      (val) => setState(() => _selectedKelompokPrestasi = val!),
                      _selectedKelompokPrestasi,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Bentuk Kompetisi'),
                    _buildDropdown(
                      'Pilih',
                      ['', 'LURING', 'DARING'],
                      (val) => setState(() => _selectedBentuk = val!),
                      _selectedBentuk,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('URL Kompetisi / Lomba'),
          _buildTextField(_urlPesertaController, 'https://...'),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('URL Foto UPP (Serah Terima)'),
          _buildTextField(_urlFotoUppController, 'https://...'),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('URL Dokumen Undangan'),
          _buildTextField(_urlDokumenUndanganController, 'https://...'),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('Jumlah PT Peserta (Atau Negara)'),
          _buildTextField(
            _jumlahUnitPesertaController,
            'Cth: 10',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('ID Mahasiswa Tim (Koma)'),
          _buildTextField(_anggotaMahasiswaController, 'Cth: 1, 2, 3'),
          const SizedBox(height: AppSpacing.lg),

          _buildLabel('ID/NIDN Dosen Pembimbing'),
          _buildTextField(_pembimbingDosenController, 'Cth: 5, 0012345678'),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.primary.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: context.appColors.primary.withAlpha(40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.appColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Pilih tipe pengajuan yang sesuai. Isi data selengkap mungkin agar validasi Admin lebih cepat.',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral800,
                height: 1.4,
              ),
            ),
          ),
        ],
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
            color: context.appColors.onSurface,
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return BkuTextField(
      controller: controller,
      keyboardType: keyboardType,
      hint: hint,
      validator: (val) {
        // If it's a required field conceptually, we can add validation here.
        // For simplicity, we just rely on the user filling out basic required ones.
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
    String currentValue,
  ) {
    return BkuDropdown<String>(
      value: items.contains(currentValue)
          ? currentValue
          : (items.isNotEmpty ? items.first : null),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.isEmpty ? 'Pilih' : value,
            style: AppTextStyles.labelMd.copyWith(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onChanged,
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
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: context.appColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
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
            color: context.appColors.outline.withAlpha(30),
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
              color: context.appColors.outline,
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
          color: hasFile ? context.appColors.successContainer : context.appColors.background,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: hasFile ? context.appColors.success : AppColors.neutral200,
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
        child: Column(
          children: [
            Container(
              padding: AppSpacing.padding14,
              decoration: BoxDecoration(
                color: hasFile ? context.appColors.successContainer : context.appColors.infoContainer,
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
              style: const TextStyle(
                color: AppColors.neutral600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FocusScope.of(context).unfocus();

    BkuBottomSheet.show(
      context: context,
      padding: EdgeInsets.zero,
      title: 'Pilih Sumber Dokumen',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              context.pop();
              _pickFromCamera();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.folder_rounded,
              color: AppColors.neutral600,
            ),
            title: Text(
              'Galeri / File (PDF)',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              context.pop();
              _pickFromGalleryOrFiles();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _selectedFilePath = image.path;
          _selectedFileName = image.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking camera: $e");
    }
  }

  Future<void> _pickFromGalleryOrFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        withReadStream: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Widget _buildSubmitButton() {
    final isEditing = widget.achievement != null;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: BkuButton(
        onPressed: () async {
          if (_titleController.text.isEmpty ||
              _organizerController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Harap isi semua field wajib (Nama dan Penyelenggara)',
                ),
              ),
            );
            return;
          }

          if (_formKey.currentState!.validate()) {
            final newAchievement = Achievement(
              id:
                  isEditing
                      ? widget.achievement!.id
                      : 'A${DateTime.now().millisecondsSinceEpoch}',
              title: _titleController.text,
              organizer: _organizerController.text,
              level: _selectedTingkat,
              rank: _selectedPeringkat,
              date: _selectedDate,
              status: isEditing ? widget.achievement!.status : 'Pending',
              isSynced: isEditing ? widget.achievement!.isSynced : false,
              certificateUrl:
                  isEditing ? widget.achievement!.certificateUrl : null,
              filePath: _selectedFilePath,
              kategori: _selectedKategori,
              tipe: _selectedTipe,
              danaDiajukan: _danaDiajukanController.text,
              cabang: _cabangController.text,
              jumlahUnitPeserta: _jumlahUnitPesertaController.text,
              kelompokPrestasi: _selectedKelompokPrestasi,
              bentuk: _selectedBentuk,
              urlPeserta: _urlPesertaController.text,
              urlFotoUpp: _urlFotoUppController.text,
              urlDokumenUndangan: _urlDokumenUndanganController.text,
              jenisRekognisi: _selectedJenisRekognisi,
            );

            try {
              BkuLoadingDialog.show(context);

              if (isEditing) {
                await context.read<AcademicProvider>().updateAchievement(
                  widget.achievement!.id,
                  newAchievement,
                );
              } else {
                await context.read<AcademicProvider>().addAchievement(
                  newAchievement,
                );
              }

              if (mounted) BkuLoadingDialog.hide(context);
              if (!mounted) return;
              _showSuccessDialog(isEditing);
            } catch (e) {
              if (mounted) BkuLoadingDialog.hide(context);
              if (!mounted) return;
              await BkuDialog.show(
                context: context,
                type: BkuDialogType.error,
                title: 'Gagal Mengirim Data',
                message: ErrorHandler.getMessage(e),
                primaryButtonText: 'Tutup',
                onPrimaryPressed: () => context.pop(),
              );
            }
          }
        },
        variant: BkuButtonVariant.success,
        text: isEditing ? 'Simpan Perubahan' : 'Kirim Laporan Prestasi',
      ),
    );
  }

  void _showSuccessDialog(bool isEditing) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.success,
      title: isEditing ? 'Perubahan Disimpan!' : 'Laporan Terkirim!',
      message:
          isEditing
              ? 'Perubahan data laporan prestasi kamu berhasil disimpan dan diperbarui di sistem.'
              : 'Laporan prestasi kamu telah masuk antrean validasi Admin. Kamu akan menerima notifikasi jika status berubah.',
      primaryButtonText: 'Kembali ke Portofolio',
      onPrimaryPressed: () {
        context.pop();
        context.pop();
      },
    );
  }
}
