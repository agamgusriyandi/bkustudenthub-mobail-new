import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/bku_design/bku_loading_dialog.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:go_router/go_router.dart';

class CreateProposalScreen extends StatefulWidget {
  final OrmawaProposal? initialProposal;
  const CreateProposalScreen({super.key, this.initialProposal});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _bentukController = TextEditingController();
  final _mitraController = TextEditingController();
  final _sasaranController = TextEditingController();
  final _indikatorController = TextEditingController();
  final _sumberDanaController = TextEditingController();
  final _latarBelakangController = TextEditingController();

  final _landasanController = TextEditingController();
  final _pjKegiatanController = TextEditingController();
  final _jadwalController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProposal != null) {
      final p = widget.initialProposal!;
      _nameController.text = p.title;
      _budgetController.text = _formatNumber(p.budget.toInt().toString());
      _selectedDate = p.date;
      _bentukController.text = p.bentukKegiatan ?? '';
      _mitraController.text = p.mitra ?? '';
      _sasaranController.text = p.sasaranKegiatan ?? '';
      _indikatorController.text = p.indikatorKeberhasilan ?? '';
      _sumberDanaController.text = p.sumberDana ?? '';
      _latarBelakangController.text = p.latarBelakang ?? '';
      _landasanController.text = p.landasanKegiatan ?? '';
      _pjKegiatanController.text = p.pjKegiatan ?? '';
      _jadwalController.text = p.jadwalPelaksanaan ?? '';
      _tujuanController.text = p.tujuanKegiatan ?? '';
      _deskripsiController.text = p.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _bentukController.dispose();
    _mitraController.dispose();
    _sasaranController.dispose();
    _indikatorController.dispose();
    _sumberDanaController.dispose();
    _latarBelakangController.dispose();
    _landasanController.dispose();
    _pjKegiatanController.dispose();
    _jadwalController.dispose();
    _tujuanController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      AppSnackbar.showError(context, 'Nama kegiatan tidak boleh kosong');
      return;
    }

    BkuLoadingDialog.show(context);

    final provider = Provider.of<OrmawaProvider>(context, listen: false);
    final isEdit = widget.initialProposal != null;

    String? uploadedUrl = isEdit ? widget.initialProposal!.fileUrl : null;

    if (_selectedFile != null && _selectedFile!.path != null) {
      uploadedUrl = await provider.uploadFile(_selectedFile!.path!);
      if (uploadedUrl == null) {
        if (mounted) {
          AppSnackbar.showError(
            context,
            'Gagal mengunggah file. Silakan coba lagi.',
          );
          BkuLoadingDialog.hide(context);
        }
        return;
      }
    }

    final proposal = OrmawaProposal(
      id: isEdit ? widget.initialProposal!.id : '',
      ormawaId: isEdit ? widget.initialProposal!.ormawaId : provider.ormawaId,
      mahasiswaId:
          isEdit ? widget.initialProposal!.mahasiswaId : provider.mahasiswaId,
      fakultasId:
          isEdit ? widget.initialProposal!.fakultasId : provider.fakultasId,
      title: _nameController.text,
      code: isEdit ? widget.initialProposal!.code : '',
      status: isEdit ? widget.initialProposal!.status : 'diajukan',
      date: _selectedDate,
      budget: double.tryParse(_budgetController.text.replaceAll('.', '')) ?? 0,
      description: _deskripsiController.text,
      landasanKegiatan: _landasanController.text,
      bentukKegiatan: _bentukController.text,
      mitra: _mitraController.text,
      pjKegiatan: _pjKegiatanController.text,
      jadwalPelaksanaan: _jadwalController.text,
      sasaranKegiatan: _sasaranController.text,
      indikatorKeberhasilan: _indikatorController.text,
      sumberDana: _sumberDanaController.text,
      latarBelakang: _latarBelakangController.text,
      tujuanKegiatan: _tujuanController.text,
      fileUrl: uploadedUrl,
    );

    try {
      if (isEdit) {
        await provider.updateProposal(proposal);
      } else {
        await provider.addProposal(proposal);
      }

      if (mounted) {
        context.pop();
        AppSnackbar.showSuccess(
          context,
          isEdit
              ? 'Proposal berhasil diperbarui!'
              : 'Proposal berhasil diajukan ke Pihak Kampus!',
        );
      }
    } catch (e) {
      String errMsg = ErrorHandler.getMessage(e);
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map &&
            (data.containsKey('message') || data.containsKey('Message'))) {
          errMsg = (data['message'] ?? data['Message']).toString();
        }
      }
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan proposal: $errMsg');
      }
    } finally {
      if (mounted) BkuLoadingDialog.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title:
                widget.initialProposal != null
                    ? 'EDIT PROPOSAL'
                    : 'BUAT PROPOSAL BARU',
            variant: AppBarVariant.ormawa,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informasi Dasar'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Nama Kegiatan',
                    'Contoh: Seminar Nasional IT 2026',
                    Icons.event_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Landasan Kegiatan',
                    'Pilih landasan...',
                    Icons.foundation_rounded,
                    [
                      'Program Kerja Tahunan',
                      'Instruksi Universitas',
                      'Instruksi Fakultas',
                      'Delegasi Ormawa',
                      'Lainnya',
                    ],
                    _landasanController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Bentuk Kegiatan',
                    'Pilih bentuk...',
                    Icons.category_rounded,
                    [
                      'Kompetisi / Lomba',
                      'Seminar / Webinar',
                      'Pelatihan / Workshop',
                      'Pengabdian Masyarakat',
                      'Musyawarah / Rapat Kerja',
                      'Olahraga / Seni',
                      'Lainnya',
                    ],
                    _bentukController,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionTitle('Pelaksanaan'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Tanggal Kegiatan',
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    Icons.calendar_today_rounded,
                    isReadOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Mitra Kerja',
                    'Pilih mitra...',
                    Icons.handshake_rounded,
                    [
                      'Tidak Ada Mitra',
                      'Sponsor Swasta',
                      'Instansi Pemerintah',
                      'Ormawa Lain',
                      'Organisasi Eksternal Kampus',
                      'Lainnya',
                    ],
                    _mitraController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'PJ Kegiatan',
                    'Contoh: Budi Santoso (Ketua Panitia)...',
                    Icons.person_rounded,
                    controller: _pjKegiatanController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Jadwal Pelaksanaan',
                    'Contoh: Senin, 15 Juli 2026, 09.00...',
                    Icons.schedule_rounded,
                    controller: _jadwalController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Sasaran Kegiatan',
                    'Pilih sasaran...',
                    Icons.group_rounded,
                    [
                      'Seluruh Mahasiswa Universitas',
                      'Seluruh Mahasiswa Fakultas',
                      'Pengurus Ormawa Internal',
                      'Masyarakat Umum',
                      'Siswa SMA/SMK',
                      'Lainnya',
                    ],
                    _sasaranController,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionTitle('Detail Khusus'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Latar Belakang',
                    'Uraikan latar belakang...',
                    Icons.subject_rounded,
                    maxLines: 5,
                    controller: _latarBelakangController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Tujuan Kegiatan',
                    'Uraikan tujuan kegiatan...',
                    Icons.flag_rounded,
                    maxLines: 5,
                    controller: _tujuanController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Deskripsi Detail Kegiatan',
                    'Uraikan deskripsi kegiatan...',
                    Icons.description_rounded,
                    maxLines: 5,
                    controller: _deskripsiController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Indikator Keberhasilan',
                    'Pilih indikator...',
                    Icons.analytics_rounded,
                    [
                      'Target Peserta Terpenuhi',
                      'Publikasi Media Luas',
                      'Mendapatkan Profit / Keuntungan',
                      'Kerjasama Jangka Panjang',
                      'Meningkatkan Akreditasi',
                      'Lainnya',
                    ],
                    _indikatorController,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionTitle('Anggaran & Berkas'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'Total Anggaran',
                    '0',
                    Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                    controller: _budgetController,
                    isPrice: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDropdownField(
                    'Sumber Dana',
                    'Pilih sumber...',
                    Icons.account_balance_wallet_rounded,
                    [
                      'Dana Kemahasiswaan Universitas',
                      'Dana Kemahasiswaan Fakultas',
                      'Kas Organisasi',
                      'Sponsor / Mitra',
                      'Dana Swadaya Mahasiswa',
                      'Lainnya',
                    ],
                    _sumberDanaController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFileUploadBox(),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSubmitButton(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: context.appColors.primary,
            borderRadius: AppRadius.radiusXs,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    IconData icon,
    List<String> options,
    TextEditingController controller,
  ) {
    String? currentValue;
    if (options.contains(controller.text)) {
      currentValue = controller.text;
    } else if (controller.text.isNotEmpty) {
      currentValue = 'Lainnya';
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: currentValue,
              hint: Text(
                hint,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              isExpanded: true,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appColors.onSurface,              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: context.appColors.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.neutral100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusLg,
                  borderSide: const BorderSide(
                    color: AppColors.neutral300,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusLg,
                  borderSide: const BorderSide(
                    color: AppColors.neutral300,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusLg,
                  borderSide: BorderSide(
                    color: context.appColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              items:
                  options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentValue = newValue;
                    if (newValue != 'Lainnya') {
                      controller.text = newValue;
                    } else {
                      controller.text = '';
                    }
                  });
                }
              },
            ),
            if (currentValue == 'Lainnya') ...[
              const SizedBox(height: AppSpacing.md),
              BkuTextField(
                controller: controller,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan $label lainnya...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral500,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: const BorderSide(
                      color: AppColors.neutral300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: const BorderSide(
                      color: AppColors.neutral300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide(
                      color: context.appColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon, {
    bool isReadOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: BkuTextField(
            controller: controller,
            enabled: !isReadOnly && onTap == null,
            readOnly: isReadOnly || onTap != null,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onTap: onTap,
            inputFormatters:
                isPrice ? [ThousandsSeparatorInputFormatter()] : null,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: context.appColors.outline.withAlpha(100),
              ),
              prefixIcon: Icon(
                icon,
                color: context.appColors.primary,
                size: 20,
              ),
              prefixText: isPrice ? 'Rp ' : null,
              prefixStyle: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appColors.onSurface,              ),
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: const BorderSide(
                  color: AppColors.neutral300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: const BorderSide(
                  color: AppColors.neutral300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(
                  color: context.appColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Dokumen (Opsional)',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: context.appColors.primary.withAlpha(30),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: context.appColors.primary,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _selectedFile != null
                      ? _selectedFile!.name
                      : (widget.initialProposal?.fileUrl != null &&
                              widget.initialProposal!.fileUrl!.isNotEmpty
                          ? 'File sudah terunggah (Ketuk untuk ganti)'
                          : 'Ketuk untuk pilih file'),
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedFile == null &&
                    (widget.initialProposal?.fileUrl == null ||
                        widget.initialProposal!.fileUrl!.isEmpty))
                  Text(
                    'Maksimal ukuran file: 10MB (PDF/DOC)',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.outline,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BkuButton(
      text:
          widget.initialProposal != null
              ? 'SIMPAN PERUBAHAN'
              : 'AJUKAN PROPOSAL',
      onPressed: _handleSubmit,
      isLoading: _isSubmitting,
      height: 56,
    );
  }
}

String _formatNumber(String value) {
  String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < cleaned.length; i++) {
    if (i > 0 && (cleaned.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(cleaned[i]);
  }
  return buffer.toString();
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < cleanedText.length; i++) {
      if (i > 0 && (cleanedText.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanedText[i]);
    }

    final newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
