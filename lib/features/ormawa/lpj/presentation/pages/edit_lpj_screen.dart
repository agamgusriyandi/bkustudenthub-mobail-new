import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_lpj.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';

class EditLpjScreen extends StatefulWidget {
  final dynamic lpj;
  const EditLpjScreen({super.key, required this.lpj});

  @override
  State<EditLpjScreen> createState() => _EditLpjScreenState();
}

class _EditLpjScreenState extends State<EditLpjScreen> {
  final _judulController = TextEditingController();
  final _jenisController = TextEditingController(text: 'LPJ');
  final _periodeController = TextEditingController(text: '2024/2025');
  final _paguController = TextEditingController();
  final _realisasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kendalaController = TextEditingController();
  final _driveUrlController = TextEditingController();

  String? _selectedProposalId;
  String? _uploadedFileUrl;
  String? _uploadedFileName;
  int? _uploadedFileSize;
  bool _isUploading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final l = widget.lpj;
    final judul = l is OrmawaLPJ ? l.judul : (l['judul'] ?? l['Judul'] ?? l['title'] ?? '').toString();
    final pagu = l is OrmawaLPJ ? l.totalAnggaran : ((l['totalAnggaran'] ?? l['TotalAnggaran'] ?? l['TotalPagu'] ?? 0.0) as num).toDouble();
    final realisasi = l is OrmawaLPJ ? l.realisasiAnggaran : ((l['realisasiAnggaran'] ?? l['RealisasiAnggaran'] ?? 0.0) as num).toDouble();
    final catatan = l is OrmawaLPJ ? l.catatan : (l['catatan'] ?? l['Catatan'] ?? '').toString();
    final String? fileUrl = l is OrmawaLPJ ? l.fileUrl : (l['fileUrl'] ?? l['FileUrl'] ?? l['FileURL'])?.toString();
    final proposalId = l is OrmawaLPJ ? l.proposalId : (l['proposalId'] ?? l['ProposalID'] ?? l['proposal_id'])?.toString();

    _judulController.text = judul;
    _paguController.text = pagu > 0 ? NumberFormat('#,###', 'id_ID').format(pagu.toInt()) : '';
    _realisasiController.text = realisasi > 0 ? NumberFormat('#,###', 'id_ID').format(realisasi.toInt()) : '';
    _deskripsiController.text = catatan;
    _selectedProposalId = proposalId;

    if (fileUrl != null && fileUrl.isNotEmpty) {
      if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
        if (fileUrl.contains('drive.google.com')) {
          _driveUrlController.text = fileUrl;
        } else {
          _uploadedFileUrl = fileUrl;
          _uploadedFileName = fileUrl.split('/').last;
        }
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _jenisController.dispose();
    _periodeController.dispose();
    _paguController.dispose();
    _realisasiController.dispose();
    _deskripsiController.dispose();
    _kendalaController.dispose();
    _driveUrlController.dispose();
    super.dispose();
  }

  String _formatRp(double val) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _onProposalChanged(String? propId, List<OrmawaProposal> proposals) {
    setState(() {
      _selectedProposalId = propId;
      if (propId != null) {
        final selected = proposals.firstWhere(
          (p) => p.id.toString() == propId,
          orElse: () => proposals.first,
        );
        final budget = selected.budget;
        _paguController.text = NumberFormat('#,###', 'id_ID').format(budget.toInt());
      }
    });
  }

  Future<void> _pickAndUploadFile() async {
    final provider = context.read<OrmawaProvider>();
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final size = await file.length();

        if (size > 10 * 1024 * 1024) {
          if (mounted) {
            AppSnackbar.showWarning(context, 'Ukuran berkas melebihi batas maksimal 10 MB');
          }
          return;
        }

        setState(() => _isUploading = true);
        final url = await provider.uploadFile(file.path);

        if (mounted) {
          setState(() {
            _isUploading = false;
            if (url != null && url.isNotEmpty) {
              _uploadedFileUrl = url;
              _uploadedFileName = result.files.single.name;
              _uploadedFileSize = size;
              AppSnackbar.showSuccess(context, 'Berkas LPJ berhasil diunggah');
            } else {
              AppSnackbar.showError(context, 'Gagal mengunggah berkas LPJ');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        AppSnackbar.showError(context, 'Terjadi kesalahan saat memilih berkas: $e');
      }
    }
  }

  void _handleSubmit() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Judul LPJ wajib diisi');
      return;
    }

    final finalFileUrl = _uploadedFileUrl ?? _driveUrlController.text.trim();
    final rawPagu = _paguController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final rawRealisasi = _realisasiController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final paguNum = double.tryParse(rawPagu) ?? 0.0;
    final realisasiNum = double.tryParse(rawRealisasi) ?? 0.0;

    final extraNotes = <String>[];
    if (_kendalaController.text.trim().isNotEmpty) {
      extraNotes.add('[Kendala & Evaluasi]: ${_kendalaController.text.trim()}');
    }
    if (_uploadedFileUrl != null && _driveUrlController.text.trim().isNotEmpty) {
      extraNotes.add('[Tautan Drive Cadangan]: ${_driveUrlController.text.trim()}');
    }

    final fullCatatan = extraNotes.isNotEmpty
        ? '${_deskripsiController.text.trim().isNotEmpty ? "${_deskripsiController.text.trim()}\n\n" : ""}${extraNotes.join("\n\n")}'
        : _deskripsiController.text.trim();

    final data = <String, dynamic>{
      'Judul': _judulController.text.trim(),
      'ProposalID': _selectedProposalId != null ? (int.tryParse(_selectedProposalId!) ?? _selectedProposalId) : null,
      'TotalPagu': paguNum,
      'TotalAnggaran': paguNum,
      'TotalRealisasi': realisasiNum,
      'RealisasiAnggaran': realisasiNum,
      'TotalPengeluaran': realisasiNum,
      'Kendala': _kendalaController.text.trim(),
      'FileUrl': finalFileUrl,
      'FileURL': finalFileUrl,
      'Catatan': fullCatatan,
      'Deskripsi': _deskripsiController.text.trim(),
      'Status': 'diajukan',
    };

    final lpjId = widget.lpj is OrmawaLPJ ? widget.lpj.id : (widget.lpj['id'] ?? widget.lpj['ID']).toString();

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      await context.read<OrmawaProvider>().updateLPJ(lpjId, data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Perubahan LPJ berhasil disimpan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal memperbarui LPJ: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final proposals = provider.proposals;

    final rawPagu = _paguController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final rawRealisasi = _realisasiController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final paguNum = double.tryParse(rawPagu) ?? 0.0;
    final realisasiNum = double.tryParse(rawRealisasi) ?? 0.0;
    final selisih = paguNum - realisasiNum;
    final absorptionPct = paguNum > 0 ? ((realisasiNum / paguNum) * 100).toStringAsFixed(1) : '0.0';

    final l = widget.lpj;
    final status = (l is OrmawaLPJ ? l.status : (l['status'] ?? l['Status'] ?? 'draft')).toString().toLowerCase();
    final isRevisi = status == 'revisi';
    final reviewerNote = (l is OrmawaLPJ ? l.catatan : (l['catatan'] ?? l['Catatan'] ?? '')).toString();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const BkuAppBar(
            title: 'Edit Berkas LPJ',
            subtitle: 'Pembaruan Laporan Pertanggungjawaban',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRevisi && reviewerNote.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: BkuTheme.amberSoft,
                        borderRadius: BkuTheme.r16,
                        border: Border.all(color: BkuTheme.amberBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: BkuTheme.amber, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Catatan Revisi dari Reviewer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: BkuTheme.amber,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  reviewerNote,
                                  style: const TextStyle(fontSize: 11.5, color: BkuTheme.amber, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Pagu Anggaran',
                          value: _formatRp(paguNum),
                          badgeText: _selectedProposalId != null ? 'Terkait' : 'Pagu',
                          icon: Icons.account_balance_wallet_rounded,
                          badgeColor: BkuTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Total Realisasi',
                          value: _formatRp(realisasiNum),
                          badgeText: 'Pengeluaran',
                          icon: Icons.payments_rounded,
                          badgeColor: BkuTheme.sky,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: selisih >= 0 ? 'Sisa Saldo Efisiensi' : 'Defisit Anggaran',
                          value: _formatRp(selisih.abs()),
                          badgeText: selisih >= 0 ? 'Hemat' : 'Over',
                          icon: selisih >= 0 ? Icons.savings_rounded : Icons.trending_down_rounded,
                          badgeColor: selisih >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Persentase Serapan',
                          value: '$absorptionPct%',
                          badgeText: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? 'Optimal' : 'Over',
                          icon: Icons.check_circle_rounded,
                          badgeColor: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? BkuTheme.purple : BkuTheme.rose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.primarySoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.corporate_fare_rounded, color: BkuTheme.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Informasi Usulan Terkait', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Pilih proposal kegiatan yang telah disetujui sebelumnya.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        BkuDropdown<String>(
                          label: 'Proposal Kegiatan yang Telah Disetujui',
                          value: _selectedProposalId,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('— Pilih Proposal Terkait —'),
                            ),
                            ...proposals.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id.toString(),
                                child: Text(
                                  '[#PROP-${p.id}] ${p.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) => _onProposalChanged(val, proposals),
                        ),
                        const SizedBox(height: 12),

                        BkuTextField(
                          label: 'Judul Laporan Pertanggungjawaban (LPJ) *',
                          hint: 'e.g. LPJ - Latihan Keterampilan Manajemen Mahasiswa',
                          controller: _judulController,
                          prefixIcon: Icon(Icons.description_rounded, size: 16, color: BkuTheme.primary),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: BkuTextField(
                                label: 'Jenis Laporan',
                                controller: _jenisController,
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BkuTextField(
                                label: 'Periode Kepengurusan',
                                controller: _periodeController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.emeraldSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.calculate_rounded, color: BkuTheme.emerald, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rincian Anggaran & Realisasi', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Perbandingan alokasi dana pagu usulan dan serapan aktual.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        BkuTextField(
                          label: 'PAGU ANGGARAN DISETUJUI (RP) *',
                          hint: 'e.g. 10.000.000',
                          controller: _paguController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: BkuTheme.emerald),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        BkuTextField(
                          label: 'TOTAL REALISASI PENGELUARAN (RP) *',
                          hint: 'e.g. 9.500.000',
                          controller: _realisasiController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.payments_rounded, size: 16, color: BkuTheme.emerald),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selisih >= 0 ? BkuTheme.emeraldSoft : BkuTheme.roseSoft,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(color: selisih >= 0 ? BkuTheme.emeraldBorder : BkuTheme.roseBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selisih >= 0 ? 'Sisa Saldo Efisiensi (Hemat)' : 'Defisit Anggaran (Over)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: selisih >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${selisih >= 0 ? '+' : '-'}${_formatRp(selisih.abs())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: selisih >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BkuTheme.r8,
                                  border: Border.all(color: selisih >= 0 ? BkuTheme.emeraldBorder : BkuTheme.roseBorder),
                                ),
                                child: Text(
                                  'Serapan $absorptionPct%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: selisih >= 0 ? BkuTheme.emerald : BkuTheme.rose,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.purpleSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.folder_zip_rounded, color: BkuTheme.purple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dokumen & Berkas Pendukung', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Unggah naskah LPJ resmi (PDF/Word/Zip) atau cantumkan Google Drive.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BkuTheme.borderSubtle,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(color: BkuTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _uploadedFileUrl != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                                    color: _uploadedFileUrl != null ? BkuTheme.emerald : BkuTheme.textPlaceholder,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _uploadedFileName ?? 'Unggah Berkas Dokumen LPJ (PDF / DOCX / ZIP)',
                                          style: BkuTheme.textCardTitle.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _uploadedFileName != null ? BkuTheme.textHeading : BkuTheme.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _uploadedFileSize != null
                                              ? '${(_uploadedFileSize! / (1024 * 1024)).toStringAsFixed(2)} MB • Berkas Terpilih'
                                              : 'Maksimal ukuran berkas 10 MB',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BkuButton.outline(
                                    text: _uploadedFileUrl != null ? 'Ganti' : 'Pilih File',
                                    height: 32,
                                    isLoading: _isUploading,
                                    onPressed: _isUploading ? null : _pickAndUploadFile,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        BkuTextField(
                          label: 'Tautan Google Drive (Opsional / Cadangan)',
                          hint: 'https://drive.google.com/...',
                          controller: _driveUrlController,
                          prefixIcon: Icon(Icons.link_rounded, size: 16, color: BkuTheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.amberSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.note_alt_rounded, color: BkuTheme.amber, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Evaluasi, Kendala & Catatan', style: BkuTheme.textSectionTitle),
                                  Text(
                                    'Uraikan ringkasan pencapaian dan kendala pelaksanaan.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        BkuTextField(
                          label: 'Deskripsi Hasil / Ringkasan Kegiatan',
                          hint: 'Tuliskan gambaran umum ketercapaian kegiatan...',
                          controller: _deskripsiController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),

                        BkuTextField(
                          label: 'Kendala, Evaluasi & Rekomendasi',
                          hint: 'Uraikan kendala operasional yang dihadapi...',
                          controller: _kendalaController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: BkuButton.primary(
                      text: 'Simpan Perubahan LPJ',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: Icons.save_rounded,
                      height: 48,
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
}