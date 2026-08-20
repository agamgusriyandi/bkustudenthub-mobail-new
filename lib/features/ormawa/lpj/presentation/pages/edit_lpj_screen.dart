import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
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
      backgroundColor: OrmawaTheme.scaffoldBg,
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
                  if (isRevisi) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status: Butuh Revisi LPJ',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  reviewerNote.isNotEmpty
                                      ? 'Catatan Reviewer: "$reviewerNote"'
                                      : 'Silakan perbaiki data realisasi anggaran atau lampiran berkas sesuai arahan reviewer, lalu ajukan kembali.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
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
                          badgeText: 'Pagu',
                          icon: Icons.account_balance_wallet_rounded,
                          badgeColor: OrmawaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Total Realisasi',
                          value: _formatRp(realisasiNum),
                          badgeText: 'Pengeluaran',
                          icon: Icons.payments_rounded,
                          badgeColor: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: selisih >= 0 ? 'Sisa Efisiensi' : 'Defisit Anggaran',
                          value: _formatRp(selisih.abs()),
                          badgeText: selisih >= 0 ? 'Hemat' : 'Over',
                          icon: selisih >= 0 ? Icons.savings_rounded : Icons.trending_down_rounded,
                          badgeColor: selisih >= 0 ? const Color(0xFF10B981) : const Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Tingkat Serapan',
                          value: '$absorptionPct%',
                          badgeText: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? 'Optimal' : 'Over',
                          icon: Icons.check_circle_rounded,
                          badgeColor: (double.tryParse(absorptionPct) ?? 0.0) <= 100.0 ? const Color(0xFF7C3AED) : const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF2563EB), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Informasi Proposal & Kegiatan', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Pilih proposal kegiatan yang telah selesai dilaksanakan.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TAUTKAN PROPOSAL TERKAIT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF334155),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedProposalId,
                                  isExpanded: true,
                                  hint: const Text(
                                    '-- Pilih Proposal Kegiatan --',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                  items: proposals.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p.id.toString(),
                                      child: Text(
                                        '${p.title} (${_formatRp(p.budget)})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => _onProposalChanged(val, proposals),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        OrmawaTextField(
                          label: 'NAMA / JUDUL LPJ *',
                          controller: _judulController,
                          hintText: 'Contoh: LPJ Kegiatan Latihan Kepemimpinan Mahasiswa 2025',
                          prefixIcon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OrmawaTextField(
                                label: 'JENIS DOKUMEN',
                                controller: _jenisController,
                                readOnly: true,
                                prefixIcon: Icons.description_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OrmawaTextField(
                                label: 'PERIODE KEPENGURUSAN',
                                controller: _periodeController,
                                hintText: '2024/2025',
                                prefixIcon: Icons.calendar_today_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Alokasi & Realisasi Anggaran', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Bandingkan pagu dana disetujui dengan pengeluaran riil.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OrmawaTextField(
                                label: 'PAGU DISETUJUI (RP)',
                                controller: _paguController,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.account_balance_rounded,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OrmawaTextField(
                                label: 'REALISASI TERPAKAI (RP) *',
                                controller: _realisasiController,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.payments_rounded,
                                prefixIconColor: const Color(0xFF16A34A),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (paguNum > 0)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selisih >= 0 ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selisih >= 0 ? const Color(0xFFBBF7D0) : const Color(0xFFFECDD3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: selisih >= 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    selisih >= 0 ? Icons.savings_rounded : Icons.trending_down_rounded,
                                    color: selisih >= 0 ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selisih >= 0 ? 'Efisiensi Anggaran Berhasil Tercatat' : 'Peringatan Defisit / Over Budget',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: selisih >= 0 ? const Color(0xFF14532D) : const Color(0xFF881337),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selisih >= 0
                                            ? 'Hemat ${_formatRp(selisih)} (${(100.0 - (double.tryParse(absorptionPct) ?? 0.0)).toStringAsFixed(1)}% dari pagu).'
                                            : 'Realisasi melebihi pagu sebesar ${_formatRp(selisih.abs())}.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: selisih >= 0 ? const Color(0xFF166534) : const Color(0xFF9F1239),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$absorptionPct%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: selisih >= 0 ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.fact_check_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Capaian, Evaluasi & Berkas Dokumen', style: OrmawaTheme.textSectionTitle),
                                  const Text(
                                    'Uraikan pencapaian acara dan unggah berkas dokumen LPJ.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        OrmawaTextField(
                          label: 'RINGKASAN HASIL KEGIATAN',
                          controller: _deskripsiController,
                          hintText: 'Jelaskan ringkasan jalannya kegiatan, output, dan hasil capaian acara...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),

                        OrmawaTextField(
                          label: 'KENDALA & SARAN REKOMENDASI',
                          controller: _kendalaController,
                          hintText: 'Uraikan kendala operasional yang dihadapi serta evaluasi perbaikan...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'DOKUMEN BERKAS UTAMA LPJ (PDF/DOCX)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (_uploadedFileUrl != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF16A34A), size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _uploadedFileName ?? 'Berkas Dokumen LPJ Terunggah',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_uploadedFileSize != null)
                                        Text(
                                          '${(_uploadedFileSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _uploadedFileUrl = null;
                                      _uploadedFileName = null;
                                      _uploadedFileSize = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 20),
                                  tooltip: 'Hapus Berkas',
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          BkuBounceButton(
                            onTap: _isUploading ? null : _pickAndUploadFile,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isUploading) ...[
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Mengunggah berkas...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ] else ...[
                                    Icon(Icons.cloud_upload_outlined, size: 32, color: OrmawaTheme.primary),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Pilih & Unggah Berkas Dokumen LPJ',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Format PDF, DOCX, ZIP (Maksimal 10 MB)',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        OrmawaTextField(
                          label: 'TAUTAN GOOGLE DRIVE CADANGAN / FOTO (OPSIONAL)',
                          controller: _driveUrlController,
                          hintText: 'https://drive.google.com/...',
                          prefixIcon: Icons.link_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  OrmawaButton(
                    text: 'Simpan Perubahan LPJ',
                    icon: Icons.save_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}