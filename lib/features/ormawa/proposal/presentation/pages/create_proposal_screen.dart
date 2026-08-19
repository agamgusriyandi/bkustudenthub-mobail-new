import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

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

  DateTime _selectedDate = DateTime.now();
  PlatformFile? _selectedFile;

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

  void _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Nama kegiatan tidak boleh kosong');
      return;
    }

    BkuLoadingDialog.show(context);

    final provider = Provider.of<OrmawaProvider>(context, listen: false);
    final isEdit = widget.initialProposal != null;

    String? uploadedUrl = isEdit ? widget.initialProposal!.fileUrl : null;
    if (_selectedFile != null && _selectedFile!.path != null) {
      try {
        uploadedUrl = await provider.uploadFile(_selectedFile!.path!);
      } catch (e) {
        if (mounted) {
          BkuLoadingDialog.hide(context);
          AppSnackbar.showError(context, 'Gagal mengunggah berkas proposal: $e');
        }
        return;
      }
    }

    final numBudget =
        double.tryParse(
          _budgetController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0.0;

    final proposal = OrmawaProposal(
      id: isEdit ? widget.initialProposal!.id : '',
      title: _nameController.text.trim(),
      code: isEdit ? widget.initialProposal!.code : '',
      status: isEdit ? widget.initialProposal!.status : 'pending',
      date: _selectedDate,
      budget: numBudget,
      bentukKegiatan: _bentukController.text.trim(),
      mitra: _mitraController.text.trim(),
      sasaranKegiatan: _sasaranController.text.trim(),
      indikatorKeberhasilan: _indikatorController.text.trim(),
      sumberDana: _sumberDanaController.text.trim(),
      latarBelakang: _latarBelakangController.text.trim(),
      landasanKegiatan: _landasanController.text.trim(),
      pjKegiatan: _pjKegiatanController.text.trim(),
      jadwalPelaksanaan: _jadwalController.text.trim(),
      tujuanKegiatan: _tujuanController.text.trim(),
      description: _deskripsiController.text.trim(),
      fileUrl: uploadedUrl,
    );

    try {
      if (isEdit) {
        await provider.updateProposal(proposal);
        if (mounted) {
          BkuLoadingDialog.hide(context);
          AppSnackbar.showSuccess(context, 'Proposal berhasil diperbarui');
          context.pop();
        }
      } else {
        await provider.addProposal(proposal);
        if (mounted) {
          BkuLoadingDialog.hide(context);
          AppSnackbar.showSuccess(context, 'Proposal berhasil diajukan');
          context.pop();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, ErrorHandler.getMessage(e));
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProposal != null;

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          BkuAppBar(
            title: isEdit ? 'EDIT PROPOSAL' : 'BUAT PROPOSAL BARU',
            subtitle: 'Pengajuan Kegiatan Ormawa',
            variant: AppBarVariant.ormawa,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
            expandedHeight: 125.0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Dasar',
                          style: OrmawaTheme.textSectionTitle,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Nama Kegiatan *',
                          hintText: 'Contoh: Seminar Nasional IT 2026',
                          prefixIcon: Icons.event_rounded,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pelaksanaan & Sasaran',
                          style: OrmawaTheme.textSectionTitle,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Kegiatan',
                              style: OrmawaTheme.textCaption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: OrmawaTheme.primaryDark,
                                          onPrimary: Colors.white,
                                          onSurface: OrmawaTheme.textHeading,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: OrmawaTheme.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: OrmawaTheme.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: OrmawaTheme.textCardTitle.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: OrmawaTheme.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Jadwal Pelaksanaan',
                          hintText: 'Contoh: Senin, 15 Juli 2026, 09.00 WIB',
                          prefixIcon: Icons.schedule_rounded,
                          controller: _jadwalController,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'PJ Kegiatan',
                          hintText: 'Contoh: Budi Santoso (Ketua Panitia)',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _pjKegiatanController,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'Mitra Kerja',
                          'Pilih mitra...',
                          Icons.handshake_outlined,
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
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'Sasaran Kegiatan',
                          'Pilih sasaran...',
                          Icons.groups_outlined,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Khusus & Analisis',
                          style: OrmawaTheme.textSectionTitle,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Latar Belakang Kegiatan',
                          hintText: 'Uraikan latar belakang penyelenggaraan...',
                          controller: _latarBelakangController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Tujuan Kegiatan',
                          hintText: 'Uraikan tujuan dan output kegiatan...',
                          controller: _tujuanController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Deskripsi Detail Kegiatan',
                          hintText: 'Uraikan konsep dan rangkaian acara...',
                          controller: _deskripsiController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'Indikator Keberhasilan',
                          'Pilih indikator...',
                          Icons.insights_rounded,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anggaran & Berkas Proposal',
                          style: OrmawaTheme.textSectionTitle,
                        ),
                        const SizedBox(height: 12),
                        OrmawaTextField(
                          label: 'Total Anggaran Biaya (Rp) *',
                          hintText: '0',
                          prefixIcon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                          controller: _budgetController,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'Sumber Dana',
                          'Pilih sumber...',
                          Icons.account_balance_wallet_outlined,
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
                        const SizedBox(height: 14),
                        _buildFileUploadBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OrmawaButton(
                      text: isEdit ? 'SIMPAN PERUBAHAN' : 'AJUKAN PROPOSAL KE FAKULTAS/UNIVERSITAS',
                      onPressed: _handleSubmit,
                      icon: isEdit ? Icons.save_rounded : Icons.send_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
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
              style: OrmawaTheme.textCaption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            BkuDropdown<String>(
              initialValue: currentValue,
              hint: hint,
              isExpanded: true,
              style: OrmawaTheme.textCardTitle.copyWith(fontSize: 13),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: OrmawaTheme.primary,
                  size: 18,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: OrmawaTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: OrmawaTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: OrmawaTheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: OrmawaTheme.textCardTitle.copyWith(fontSize: 13),
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
              const SizedBox(height: 8),
              OrmawaTextField(
                label: 'Keterangan $label Lainnya',
                hintText: 'Tuliskan $label lainnya...',
                controller: controller,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFileUploadBox() {
    final hasFile = _selectedFile != null ||
        (widget.initialProposal?.fileUrl != null &&
            widget.initialProposal!.fileUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Berkas Dokumen Proposal (Opsional)',
          style: OrmawaTheme.textCaption.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: hasFile ? OrmawaTheme.primarySoft : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasFile ? OrmawaTheme.primaryBorder : OrmawaTheme.border,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: OrmawaTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasFile ? Icons.description_rounded : Icons.cloud_upload_outlined,
                    color: OrmawaTheme.primaryDark,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedFile != null
                      ? _selectedFile!.name
                      : (widget.initialProposal?.fileUrl != null &&
                              widget.initialProposal!.fileUrl!.isNotEmpty
                          ? 'Dokumen sudah terunggah (Ketuk untuk ganti)'
                          : 'Ketuk untuk memilih file PDF / DOCX'),
                  style: OrmawaTheme.textCardTitle.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Format PDF/DOCX maksimal 10MB',
                  style: OrmawaTheme.textCaption,
                ),
              ],
            ),
          ),
        ),
      ],
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
