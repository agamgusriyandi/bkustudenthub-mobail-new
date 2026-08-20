import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_finance.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/create_keuangan_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/ormawa_keuangan_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/ormawa_mutasi_screen.dart';

class OrmawaFinanceScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaFinanceScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaFinanceScreen> createState() => _OrmawaFinanceScreenState();
}

class _OrmawaFinanceScreenState extends State<OrmawaFinanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeSubTab = 'buku_kas';
  String _filterTipe = 'all';
  String _filterSumber = 'all';
  bool _isRefreshing = false;
  bool _isSavingBank = false;
  bool _isSubmittingIuran = false;
  bool _isPayingIuran = false;

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankNumberController = TextEditingController();
  final TextEditingController _bankOwnerController = TextEditingController();

  final TextEditingController _iuranJudulController = TextEditingController();
  final TextEditingController _iuranNominalController = TextEditingController();
  final TextEditingController _iuranTenggatController = TextEditingController();
  final TextEditingController _iuranDeskripsiController = TextEditingController();

  File? _selectedProofFile;
  String? _selectedProofName;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bankNameController.dispose();
    _bankNumberController.dispose();
    _bankOwnerController.dispose();
    _iuranJudulController.dispose();
    _iuranNominalController.dispose();
    _iuranTenggatController.dispose();
    _iuranDeskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      final provider = context.read<OrmawaProvider>();
      await Future.wait([
        provider.getFinance(),
        provider.fetchBudgetStatus(),
        provider.fetchBankAccount(),
        provider.fetchIurans(),
        provider.fetchMyInvoices(),
      ]);

      final bank = provider.bankAccount;
      _bankNameController.text = bank['nama_bank'] ?? '';
      _bankNumberController.text = bank['no_rekening'] ?? '';
      _bankOwnerController.text = bank['nama_rekening'] ?? '';
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _formatRp(double n) {
    final fmt = NumberFormat('#,###', 'id_ID').format(n.toInt());
    return 'Rp $fmt';
  }

  String _formatDateIndo(dynamic date) {
    if (date == null) return '—';
    if (date is DateTime) {
      return DateFormat('d MMM yyyy', 'id').format(date);
    }
    final str = date.toString().trim();
    if (str.isEmpty || str == '—') return '—';
    try {
      final dt = DateTime.parse(str);
      return DateFormat('d MMM yyyy', 'id').format(dt);
    } catch (_) {
      if (str.contains('T')) return str.split('T').first;
      return str;
    }
  }

  String _getProofUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final clean = path.startsWith('/') ? path : '/$path';
    return '${ApiGate.baseUrl.replaceAll('/api', '')}$clean';
  }

  bool _isPemasukan(OrmawaFinance t) {
    final tp = t.type.toLowerCase();
    return tp == 'pemasukan' || tp == 'masuk';
  }

  bool _isPengeluaran(OrmawaFinance t) {
    final tp = t.type.toLowerCase();
    return tp == 'pengeluaran' || tp == 'keluar';
  }

  void _showReportDialog(BuildContext context, OrmawaProvider provider, double saldo, double totalIn, double totalOut) async {
    final reportNumber = await provider.generateReportNumber();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BkuTheme.r24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: BkuTheme.emeraldSoft,
                      borderRadius: BkuTheme.r12,
                      border: Border.all(color: BkuTheme.emeraldBorder),
                    ),
                    child: const Icon(Icons.description_rounded, color: BkuTheme.emerald, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Keuangan Kas',
                          style: BkuTheme.textSectionTitle.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Ringkasan resmi buku kas organisasi',
                          style: BkuTheme.textCaption.copyWith(
                            fontSize: 10.5,
                            color: BkuTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BkuTheme.r8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: BkuTheme.borderSubtle,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: BkuTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r16,
                  border: Border.all(color: BkuTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nomor Dokumen Resmi',
                          style: BkuTheme.textBadge.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: BkuTheme.textMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BkuTheme.emeraldSoft,
                            borderRadius: BkuTheme.r8,
                          ),
                          child: Text(
                            'Resmi',
                            style: BkuTheme.textBadge.copyWith(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: BkuTheme.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reportNumber,
                      style: BkuTheme.textCardTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Divider(height: 16, color: BkuTheme.border),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 14, color: BkuTheme.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.orgName.isNotEmpty ? provider.orgName : 'Organisasi Mahasiswa',
                            style: BkuTheme.textCardTitle.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: BkuTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Tanggal Cetak: ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.now())}',
                          style: BkuTheme.textCaption.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: BkuTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r16,
                  border: Border.all(color: BkuTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, size: 14, color: BkuTheme.textHeading),
                            const SizedBox(width: 6),
                            Text(
                              'Saldo Kas Mandiri',
                              style: BkuTheme.textCardTitle.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatRp(saldo),
                          style: BkuTheme.textCardTitle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: BkuTheme.emerald,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: BkuTheme.emeraldSoft,
                              borderRadius: BkuTheme.r10,
                              border: Border.all(color: BkuTheme.emeraldBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pemasukan',
                                  style: BkuTheme.textBadge.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: BkuTheme.emerald,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRp(totalIn),
                                  style: BkuTheme.textCardTitle.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: BkuTheme.emerald,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: BkuTheme.roseSoft,
                              borderRadius: BkuTheme.r10,
                              border: Border.all(color: BkuTheme.roseBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengeluaran',
                                  style: BkuTheme.textBadge.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: BkuTheme.rose,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRp(totalOut),
                                  style: BkuTheme.textCardTitle.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: BkuTheme.rose,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: BkuButton.outline(
                      onPressed: () => Navigator.pop(ctx),
                      text: 'Tutup',
                      height: 42,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BkuButton.primary(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: 'LAPORAN KAS ORMAWA\nNo: $reportNumber\nOrganisasi: ${provider.orgName}\nSaldo: ${_formatRp(saldo)}\nTotal Masuk: ${_formatRp(totalIn)}\nTotal Keluar: ${_formatRp(totalOut)}',
                        ));
                        Navigator.pop(ctx);
                        AppSnackbar.showSuccess(context, 'Ringkasan laporan kas berhasil disalin!');
                      },
                      icon: Icons.copy_rounded,
                      text: 'Salin Laporan',
                      height: 42,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateIuranDialog(BuildContext context) {
    _iuranJudulController.clear();
    _iuranNominalController.clear();
    _iuranTenggatController.clear();
    _iuranDeskripsiController.clear();

    BkuBottomSheet.show(
      context: context,
      title: 'Terbitkan Tagihan Iuran',
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kirimkan tagihan iuran kas ke seluruh anggota aktif organisasi.',
                style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 14),

              BkuTextField(
                controller: _iuranJudulController,
                label: 'Judul Tagihan *',
                hint: 'Contoh: Iuran Kas Bulan Mei 2026',
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: BkuTextField(
                      controller: _iuranNominalController,
                      label: 'Nominal (Rp) *',
                      hint: '20000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenggat Waktu',
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: modalCtx,
                              initialDate: DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: BkuTheme.primary,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: BkuTheme.textHeading,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: BkuTheme.primary,
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                _iuranTenggatController.text = DateFormat('yyyy-MM-dd').format(picked);
                              });
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: BkuTheme.cardSurface,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _iuranTenggatController.text.isNotEmpty ? _iuranTenggatController.text : 'Pilih Tanggal',
                              style: BkuTheme.textBodyRegular.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _iuranTenggatController.text.isNotEmpty ? BkuTheme.textHeading : BkuTheme.textPlaceholder,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              BkuTextField(
                controller: _iuranDeskripsiController,
                label: 'Deskripsi Singkat',
                hint: 'Keterangan peruntukan dana iuran...',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              BkuButton.primary(
                isLoading: _isSubmittingIuran,
                icon: Icons.check_circle_outline_rounded,
                text: 'Terbitkan Tagihan Iuran',
                height: 46,
                onPressed: _isSubmittingIuran
                    ? null
                    : () async {
                        if (_iuranJudulController.text.trim().isEmpty || _iuranNominalController.text.trim().isEmpty) {
                          AppSnackbar.showWarning(context, 'Judul dan nominal wajib diisi');
                          return;
                        }
                        setModalState(() => _isSubmittingIuran = true);
                        try {
                          final nominal = double.tryParse(_iuranNominalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                          await context.read<OrmawaProvider>().createIuran({
                            'judul': _iuranJudulController.text.trim(),
                            'nominal': nominal,
                            'tenggat': _iuranTenggatController.text.trim(),
                            'deskripsi': _iuranDeskripsiController.text.trim(),
                          });
                          if (context.mounted) {
                            Navigator.pop(modalCtx);
                            AppSnackbar.showSuccess(context, 'Tagihan iuran berhasil diterbitkan!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, 'Gagal menerbitkan tagihan: $e');
                          }
                        } finally {
                          setModalState(() => _isSubmittingIuran = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProofImageModal(BuildContext context, String proofPath) {
    final fullUrl = _getProofUrl(proofPath);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BkuTheme.r20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bukti Pembayaran',
                    style: BkuTheme.textSectionTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              color: BkuTheme.textHeading,
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Gagal memuat gambar bukti transfer', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BkuButton.outline(
                onPressed: () => Navigator.pop(ctx),
                text: 'Tutup',
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyModal(BuildContext context, Map<String, dynamic> member, String iuranId) {
    String verifyStatus = 'lunas';
    final notesController = TextEditingController(text: member['Catatan'] ?? member['catatan'] ?? '');
    bool isVerifying = false;
    final proof = member['bukti_transfer'] ?? member['BuktiTransfer'];
    final detailId = (member['ID'] ?? member['id'] ?? '').toString();

    BkuBottomSheet.show(
      context: context,
      title: 'Verifikasi Pembayaran',
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mahasiswa: ${member['nama'] ?? member['Nama'] ?? 'Anggota'} (${member['nim'] ?? member['NIM'] ?? '—'})',
                style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 14),

              if (proof != null && proof.toString().isNotEmpty) ...[
                InkWell(
                  onTap: () => _showProofImageModal(context, proof.toString()),
                  borderRadius: BkuTheme.r12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BkuTheme.indigoSoft,
                      borderRadius: BkuTheme.r12,
                      border: Border.all(color: BkuTheme.indigoBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image_rounded, color: BkuTheme.indigo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lihat Foto Bukti Transfer',
                            style: BkuTheme.textCardTitle.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: BkuTheme.indigo,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: BkuTheme.indigo, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.amberSoft,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.amberBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: BkuTheme.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Belum ada foto bukti transfer. Anda dapat verifikasi manual jika bayar tunai.',
                          style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.amber),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Text('Status Verifikasi', style: BkuTheme.textCardTitle.copyWith(fontSize: 11)),
              const SizedBox(height: 5),
              BkuDropdown<String>(
                value: verifyStatus,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'lunas', child: Text('Setujui Pembayaran (Lunas)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BkuTheme.emerald))),
                  DropdownMenuItem(value: 'ditolak', child: Text('Tolak Bukti Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BkuTheme.rose))),
                  DropdownMenuItem(value: 'pending', child: Text('Tetap Menunggu Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BkuTheme.amber))),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => verifyStatus = val);
                },
              ),
              const SizedBox(height: 12),

              BkuTextField(
                controller: notesController,
                label: 'Catatan Pengurus',
                hint: 'Catatan untuk anggota (opsional)...',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              BkuButton.primary(
                isLoading: isVerifying,
                icon: Icons.check_circle_outline_rounded,
                text: 'Simpan Verifikasi',
                height: 46,
                onPressed: isVerifying
                    ? null
                    : () async {
                        setModalState(() => isVerifying = true);
                        try {
                          await context.read<OrmawaProvider>().verifyIuranPayment(
                            detailId,
                            {
                              'status': verifyStatus,
                              'catatan': notesController.text.trim(),
                            },
                            iuranId,
                          );
                          if (context.mounted) {
                            Navigator.pop(modalCtx);
                            AppSnackbar.showSuccess(context, 'Verifikasi pembayaran berhasil disimpan!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, 'Gagal memverifikasi: $e');
                          }
                        } finally {
                          setModalState(() => isVerifying = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIuranMembersModal(BuildContext context, Map<String, dynamic> iuran) {
    final iuranId = (iuran['ID'] ?? iuran['id'] ?? '').toString();
    final provider = context.read<OrmawaProvider>();
    provider.fetchIuranMembers(iuranId);
    if (provider.members.isEmpty) {
      provider.refreshData();
    }

    BkuBottomSheet.show(
      context: context,
      title: iuran['Judul'] ?? iuran['judul'] ?? 'Daftar Tagihan Anggota',
      child: Consumer<OrmawaProvider>(
        builder: (_, prov, __) {
          final members = prov.iuranMembers;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nominal: ${_formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble())} • Tenggat: ${_formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat'])}',
                  style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: members.isEmpty
                      ? const Center(
                          child: BkuEmptyState(
                            icon: Icons.receipt_long_rounded,
                            title: 'Belum Ada Anggota',
                            message: 'Belum ada data anggota pada tagihan ini.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: members.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (itemCtx, idx) {
                            final m = members[idx];
                            final st = (m['Status'] ?? m['status'] ?? 'belum_bayar').toString().toLowerCase();
                            final isLunas = st == 'lunas';
                            final isPending = st == 'pending';
                            final isDitolak = st == 'ditolak';

                            final mId = (m['mahasiswa_id'] ?? m['MahasiswaID'] ?? m['id'] ?? '').toString();
                            final matchedMember = prov.members.cast<OrmawaMember?>().firstWhere(
                              (mem) => mem != null && (mem.mahasiswaId == mId || mem.id == mId),
                              orElse: () => null,
                            );

                            String memberName = (m['nama'] ?? m['Nama'] ?? m['Mahasiswa']?['Nama'] ?? m['Mahasiswa']?['nama'] ?? m['Mahasiswa']?['Pengguna']?['NamaLengkap'] ?? m['mahasiswa']?['Nama'] ?? m['mahasiswa']?['nama'] ?? m['Anggota']?['Mahasiswa']?['Nama'] ?? m['User']?['Name'] ?? m['user']?['name'] ?? '').toString().trim();
                            if (memberName.isEmpty || memberName.toLowerCase() == 'mahasiswa') {
                              if (matchedMember != null && matchedMember.name.isNotEmpty) {
                                memberName = matchedMember.name;
                              } else if (memberName.isEmpty) {
                                memberName = 'Mahasiswa';
                              }
                            }

                            String memberNim = (m['nim'] ?? m['NIM'] ?? m['Mahasiswa']?['NIM'] ?? m['Mahasiswa']?['nim'] ?? m['mahasiswa']?['NIM'] ?? m['mahasiswa']?['nim'] ?? m['Anggota']?['Mahasiswa']?['NIM'] ?? '').toString().trim();
                            if (memberNim.isEmpty || memberNim == '—' || memberNim == '-') {
                              if (matchedMember != null && matchedMember.nim.isNotEmpty && matchedMember.nim != '—' && matchedMember.nim != '-') {
                                memberNim = matchedMember.nim;
                              } else if (memberNim.isEmpty) {
                                memberNim = '—';
                              }
                            }

                            final proof = m['bukti_transfer'] ?? m['BuktiTransfer'];
                            final payDate = m['tanggal_bayar'] ?? m['TanggalBayar'];

                            return BkuCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              borderRadius: 14,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          memberName,
                                          style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'NIM: $memberNim',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontFamily: 'monospace'),
                                        ),
                                        if (isLunas && payDate != null) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time_rounded, size: 10, color: BkuTheme.emerald),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Dibayar: ${_formatDateIndo(payDate)}',
                                                style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.emerald, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (proof != null && proof.toString().isNotEmpty) ...[
                                    InkWell(
                                      onTap: () => _showProofImageModal(context, proof.toString()),
                                      borderRadius: BkuTheme.r8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.indigoSoft,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.indigoBorder),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.image_rounded, size: 12, color: BkuTheme.indigo),
                                            SizedBox(width: 3),
                                            Text('Bukti', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: BkuTheme.indigo)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLunas ? BkuTheme.emeraldSoft : (isPending ? BkuTheme.amberSoft : (isDitolak ? BkuTheme.roseSoft : BkuTheme.borderSubtle)),
                                      borderRadius: BkuTheme.r8,
                                    ),
                                    child: Text(
                                      isLunas ? 'Lunas' : (isPending ? 'Review' : (isDitolak ? 'Ditolak' : 'Belum')),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: isLunas ? BkuTheme.emerald : (isPending ? BkuTheme.amber : (isDitolak ? BkuTheme.rose : BkuTheme.textMuted)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  BkuButton.primary(
                                    text: isLunas ? 'Detail' : 'Verifikasi',
                                    height: 30,
                                    fontSize: 9.5,
                                    fullWidth: false,
                                    customRadius: BkuTheme.r8,
                                    onPressed: () => _showVerifyModal(context, m, iuranId),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPayKasModal(BuildContext context, Map<String, dynamic> iuran) {
    final iuranId = (iuran['ID'] ?? iuran['id'] ?? '').toString();
    final provider = context.read<OrmawaProvider>();
    final bank = provider.bankAccount;
    final myInv = provider.myInvoices.firstWhere(
      (inv) => (inv['IuranID'] ?? inv['iuran_id'] ?? inv['Iuran']?['ID'] ?? '').toString() == iuranId,
      orElse: () => <String, dynamic>{},
    );
    final detailId = (myInv['ID'] ?? myInv['id'] ?? iuranId).toString();

    setState(() {
      _selectedProofFile = null;
      _selectedProofName = null;
    });

    BkuBottomSheet.show(
      context: context,
      title: 'Bayar Iuran: ${iuran['Judul'] ?? iuran['judul'] ?? 'Kas Anggota'}',
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selesaikan pembayaran tagihan kas ormawa Anda.',
                style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 14),

              BkuCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Besaran Tagihan:',
                          style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: BkuTheme.textMuted),
                        ),
                        Text(
                          _formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble()),
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tenggat Pembayaran:',
                          style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                        ),
                        Text(
                          _formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat']),
                          style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textHeading),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TUJUAN TRANSFER (${bank['nama_bank'] ?? 'Bank'})',
                          style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.indigo),
                        ),
                        if (bank['no_rekening'] != null && bank['no_rekening'].toString().isNotEmpty)
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: bank['no_rekening'].toString()));
                              AppSnackbar.showSuccess(context, 'Nomor rekening disalin!');
                            },
                            child: const Text('Salin No. Rek', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: BkuTheme.indigo, decoration: TextDecoration.underline)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bank['no_rekening'] ?? '— Belum diatur bendahara —',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: BkuTheme.indigo, fontFamily: 'monospace'),
                    ),
                    Text(
                      'a.n. ${bank['nama_rekening'] ?? '—'}',
                      style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.indigo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text('Unggah Foto Bukti Transfer *', style: BkuTheme.textCardTitle.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setModalState(() {
                      _selectedProofFile = File(picked.path);
                      _selectedProofName = picked.name;
                    });
                  }
                },
                borderRadius: BkuTheme.r12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: BkuTheme.cardSurface,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedProofFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                        color: _selectedProofFile != null ? BkuTheme.emerald : BkuTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _selectedProofName ?? 'Pilih Foto Bukti Transfer (JPG/PNG)',
                          style: BkuTheme.textCardTitle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _selectedProofFile != null ? BkuTheme.emerald : BkuTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              BkuButton.primary(
                isLoading: _isPayingIuran,
                icon: Icons.send_rounded,
                text: 'Kirim Bukti Pembayaran',
                height: 46,
                onPressed: _isPayingIuran
                    ? null
                    : () async {
                        if (_selectedProofFile == null) {
                          AppSnackbar.showWarning(context, 'Silakan pilih foto bukti transfer terlebih dahulu');
                          return;
                        }
                        setModalState(() => _isPayingIuran = true);
                        try {
                          final prov = context.read<OrmawaProvider>();
                          final fileUrl = await prov.uploadFile(_selectedProofFile!.path);
                          if (fileUrl == null || fileUrl.isEmpty) {
                            throw Exception('Gagal mengunggah file bukti transfer');
                          }
                          await prov.payMyIuran(detailId, fileUrl);
                          if (context.mounted) {
                            Navigator.pop(modalCtx);
                            AppSnackbar.showSuccess(context, 'Bukti pembayaran berhasil dikirim! Menunggu review pengurus.');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, 'Gagal memproses pembayaran: $e');
                          }
                        } finally {
                          setModalState(() => _isPayingIuran = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, OrmawaFinance t) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Transaksi Kas?',
      message: 'Hapus "${t.description}" (${_formatRp(t.nominal)})? Saldo kas akan disesuaikan kembali secara otomatis.',
      primaryButtonText: 'Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteFinance(t.id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Transaksi berhasil dihapus');
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus transaksi: $e');
          }
        }
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildSubTabItem({
    required String id,
    required String label,
    required IconData icon,
    required String count,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => setState(() => _activeSubTab = id),
      borderRadius: BkuTheme.r12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? BkuTheme.primary : BkuTheme.cardSurface,
          borderRadius: BkuTheme.r12,
          border: Border.all(color: isActive ? BkuTheme.primary : BkuTheme.border),
          boxShadow: isActive ? BkuTheme.cardShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: isActive ? Colors.white : BkuTheme.textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : BkuTheme.textHeading,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withAlpha(45) : BkuTheme.borderSubtle,
                borderRadius: BkuTheme.r8,
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : BkuTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowTrendWidget(Map<String, Map<String, double>> monthlyMap) {
    if (monthlyMap.isEmpty) return const SizedBox.shrink();

    final sortedEntries = monthlyMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final displayEntries = sortedEntries.length > 6
        ? sortedEntries.sublist(sortedEntries.length - 6)
        : sortedEntries;

    double maxVal = 1.0;
    for (var e in displayEntries) {
      final inVal = e.value['in'] ?? 0.0;
      final outVal = e.value['out'] ?? 0.0;
      if (inVal > maxVal) maxVal = inVal;
      if (outVal > maxVal) maxVal = outVal;
    }

    final latestEntry = displayEntries.last;
    final latestIn = latestEntry.value['in'] ?? 0.0;
    final latestOut = latestEntry.value['out'] ?? 0.0;
    final latestNet = latestIn - latestOut;
    final isSurplus = latestNet >= 0;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: BkuTheme.primarySoft,
                        borderRadius: BkuTheme.r10,
                      ),
                      child: Icon(Icons.insights_rounded, size: 16, color: BkuTheme.primary),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tren Arus Kas',
                            style: BkuTheme.textSectionTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Realisasi keuangan bulanan',
                            style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: BkuTheme.emerald, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  const Text('Masuk', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: BkuTheme.emerald)),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: BkuTheme.rose, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  const Text('Keluar', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: BkuTheme.rose)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14, bottom: 8, left: 8, right: 8),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: SizedBox(
              height: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: displayEntries.map((entry) {
                  final dt = DateFormat('yyyy-MM').parse(entry.key);
                  final monthLabel = DateFormat('MMM yy', 'id').format(dt);
                  final inVal = entry.value['in'] ?? 0.0;
                  final outVal = entry.value['out'] ?? 0.0;

                  final double inRatio = (inVal / maxVal).clamp(0.06, 1.0);
                  final double outRatio = (outVal / maxVal).clamp(0.06, 1.0);
                  final double inBarHeight = inVal > 0 ? (inRatio * 75) : 4;
                  final double outBarHeight = outVal > 0 ? (outRatio * 75) : 4;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 12,
                              height: inBarHeight,
                              decoration: BoxDecoration(
                                color: BkuTheme.emerald,
                                borderRadius: BkuTheme.r8,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 12,
                              height: outBarHeight,
                              decoration: BoxDecoration(
                                color: BkuTheme.rose,
                                borderRadius: BkuTheme.r8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthLabel,
                          style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.emeraldSoft,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.emeraldBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BkuTheme.emerald.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, size: 14, color: BkuTheme.emerald),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Masuk', style: BkuTheme.textBadge.copyWith(fontSize: 8.5, fontWeight: FontWeight.w800, color: BkuTheme.emerald)),
                            const SizedBox(height: 1),
                            Text(
                              _formatRp(latestIn),
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: BkuTheme.emerald, fontFamily: 'monospace'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.roseSoft,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.roseBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BkuTheme.rose.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, size: 14, color: BkuTheme.rose),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Keluar', style: BkuTheme.textBadge.copyWith(fontSize: 8.5, fontWeight: FontWeight.w800, color: BkuTheme.rose)),
                            const SizedBox(height: 1),
                            Text(
                              _formatRp(latestOut),
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: BkuTheme.rose, fontFamily: 'monospace'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSurplus ? BkuTheme.emeraldSoft : BkuTheme.roseSoft,
              borderRadius: BkuTheme.r10,
              border: Border.all(color: isSurplus ? BkuTheme.emeraldBorder : BkuTheme.roseBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSurplus ? Icons.check_circle_rounded : Icons.warning_rounded,
                      size: 14,
                      color: isSurplus ? BkuTheme.emerald : BkuTheme.rose,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSurplus ? 'Surplus Arus Kas Periode Ini' : 'Defisit Arus Kas Periode Ini',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSurplus ? BkuTheme.emerald : BkuTheme.rose,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${isSurplus ? '+' : ''}${_formatRp(latestNet)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSurplus ? BkuTheme.emerald : BkuTheme.rose,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final allTransactions = provider.financeList;
    final budgetStatus = provider.budgetStatus;
    final bank = provider.bankAccount;
    final iurans = provider.iurans;
    final myInvoices = provider.myInvoices;

    final canCreateFinance = provider.hasPermission('ormawa.finance.create') || provider.hasPermission('create_finance');
    final canDeleteFinance = provider.hasPermission('ormawa.finance.delete') || provider.hasPermission('delete_finance');
    final canManageFinance = provider.hasPermission('ormawa.finance.manage') || provider.hasPermission('ormawa.finance.update') || canCreateFinance;

    double totalIn = 0;
    double totalOut = 0;
    double campusIn = 0;
    double campusOut = 0;

    for (var t in allTransactions) {
      final isInc = _isPemasukan(t);
      final isCamp = t.sumber.toLowerCase() == 'kampus';

      if (isInc) {
        totalIn += t.nominal;
        if (isCamp) campusIn += t.nominal;
      } else {
        totalOut += t.nominal;
        if (isCamp) campusOut += t.nominal;
      }
    }

    final saldo = totalIn - totalOut;
    final campusSaldo = campusIn - campusOut;
    final paguRemaining = budgetStatus != null ? ((budgetStatus['remaining_budget'] ?? campusSaldo) as num).toDouble() : campusSaldo;
    final budgetLimit = budgetStatus != null ? ((budgetStatus['budget_limit'] ?? 0) as num).toDouble() : 0.0;
    final usedBudget = budgetStatus != null ? ((budgetStatus['used_budget'] ?? campusOut) as num).toDouble() : campusOut;

    final filteredTransactions = allTransactions.where((t) {
      final src = t.sumber.toLowerCase();
      if (_filterSumber != 'all' && src != _filterSumber.toLowerCase()) return false;

      final isInc = _isPemasukan(t);
      final isOut = _isPengeluaran(t);

      if (_filterTipe == 'pemasukan' && !isInc) return false;
      if (_filterTipe == 'pengeluaran' && !isOut) return false;

      final matchQuery = _searchQuery.isEmpty ||
          t.description.toLowerCase().contains(_searchQuery) ||
          t.category.toLowerCase().contains(_searchQuery);

      return matchQuery;
    }).toList();

    final myInvoicesMap = <String, Map<String, dynamic>>{};
    for (var inv in myInvoices) {
      final id = (inv['IuranID'] ?? inv['iuran_id'] ?? inv['Iuran']?['ID'] ?? '').toString();
      if (id.isNotEmpty) myInvoicesMap[id] = inv;
    }

    final Map<String, Map<String, double>> monthlyMap = {};
    for (var t in allTransactions) {
      final key = DateFormat('yyyy-MM').format(t.date);
      monthlyMap.putIfAbsent(key, () => {'in': 0.0, 'out': 0.0});
      if (_isPemasukan(t)) {
        monthlyMap[key]!['in'] = (monthlyMap[key]!['in'] ?? 0.0) + t.nominal;
      } else {
        monthlyMap[key]!['out'] = (monthlyMap[key]!['out'] ?? 0.0) + t.nominal;
      }
    }

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: BkuTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            BkuAppBar(
              title: 'Pagu & Keuangan',
              subtitle: 'Buku Kas & Saldo Operasional',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BkuTheme.r8,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'Buku Kas Terintegrasi',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                        ),
                        InkWell(
                          onTap: _loadAllData,
                          borderRadius: BkuTheme.r8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: BkuTheme.cardSurface,
                              borderRadius: BkuTheme.r8,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isRefreshing
                                    ? const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                                    : const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF0F172A)),
                                const SizedBox(width: 4),
                                const Text('Segarkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrmawaMutasiScreen())),
                            borderRadius: BkuTheme.r10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: BkuTheme.cardSurface,
                                borderRadius: BkuTheme.r10,
                                border: Border.all(color: BkuTheme.border),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_rounded, size: 14, color: BkuTheme.textHeading),
                                  SizedBox(width: 4),
                                  Text('Mutasi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: BkuTheme.textHeading)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showReportDialog(context, provider, saldo, totalIn, totalOut),
                            borderRadius: BkuTheme.r10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: BkuTheme.cardSurface,
                                borderRadius: BkuTheme.r10,
                                border: Border.all(color: BkuTheme.border),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_rounded, size: 14, color: BkuTheme.emerald),
                                  SizedBox(width: 4),
                                  Text('Unduh PDF', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: BkuTheme.emerald)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (canCreateFinance) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateKeuanganScreen())).then((_) => _loadAllData()),
                              borderRadius: BkuTheme.r10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: BkuTheme.primary,
                                  borderRadius: BkuTheme.r10,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 15, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text('Catat Kas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Saldo Kas Mandiri',
                            value: _formatRp(saldo),
                            badgeText: 'Kas Internal',
                            subtitle: 'Netto arus kas organisasi',
                            icon: Icons.account_balance_wallet_rounded,
                            badgeColor: BkuTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Pemasukan Kas',
                            value: _formatRp(totalIn),
                            badgeText: 'Arus Masuk',
                            subtitle: 'Iuran, donasi & dana masuk',
                            icon: Icons.trending_up_rounded,
                            badgeColor: BkuTheme.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Pengeluaran Kas',
                            value: _formatRp(totalOut),
                            badgeText: 'Arus Keluar',
                            subtitle: 'Kas kecil & operasional',
                            icon: Icons.trending_down_rounded,
                            badgeColor: BkuTheme.rose,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Sisa Pagu Kampus',
                            value: _formatRp(paguRemaining),
                            badgeText: budgetLimit > 0 ? 'Pagu: ${_formatRp(budgetLimit)}' : 'Alokasi Kampus',
                            subtitle: usedBudget > 0 ? 'Terpakai: ${_formatRp(usedBudget)}' : 'Dana hibah program kerja',
                            icon: Icons.assured_workload_rounded,
                            badgeColor: BkuTheme.sky,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSubTabItem(
                            id: 'buku_kas',
                            label: 'Buku Kas',
                            icon: Icons.account_balance_wallet_rounded,
                            count: '${allTransactions.length}',
                            isActive: _activeSubTab == 'buku_kas',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildSubTabItem(
                            id: 'iuran',
                            label: canManageFinance ? 'Iuran Kas' : 'Tagihan',
                            icon: Icons.receipt_long_rounded,
                            count: '${iurans.length}',
                            isActive: _activeSubTab == 'iuran',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildSubTabItem(
                            id: 'rekening',
                            label: 'Rekening',
                            icon: Icons.credit_card_rounded,
                            count: (bank['no_rekening'] != null && bank['no_rekening'].toString().isNotEmpty) ? 'Aktif' : 'Atur',
                            isActive: _activeSubTab == 'rekening',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_activeSubTab == 'buku_kas') ...[
                      if (monthlyMap.isNotEmpty) ...[
                        _buildCashFlowTrendWidget(monthlyMap),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: BkuDropdown<String>(
                              value: _filterTipe,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('Semua Tipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.emerald))),
                                DropdownMenuItem(value: 'pengeluaran', child: Text('Pengeluaran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.rose))),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _filterTipe = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BkuDropdown<String>(
                              value: _filterSumber,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('Semua Sumber', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'organisasi', child: Text('Kas Mandiri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.indigo))),
                                DropdownMenuItem(value: 'kampus', child: Text('Pagu Kampus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.sky))),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _filterSumber = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      BkuTextField(
                        controller: _searchController,
                        hint: 'Cari keterangan transaksi kas...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: BkuTheme.textMuted),
                      ),
                      const SizedBox(height: 12),

                      if (filteredTransactions.isEmpty)
                        BkuEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum Ada Transaksi',
                          message: _searchController.text.isNotEmpty || _filterTipe != 'all' || _filterSumber != 'all'
                              ? 'Tidak ada catatan transaksi kas yang cocok dengan kriteria filter pencarian aktif.'
                              : 'Belum ada catatan pembukuan transaksi kas masuk atau keluar.',
                          buttonText: _searchController.text.isNotEmpty || _filterTipe != 'all' || _filterSumber != 'all'
                              ? 'Reset Filter & Cari Ulang'
                              : null,
                          onButtonPressed: () {
                            setState(() {
                              _searchController.clear();
                              _filterTipe = 'all';
                              _filterSumber = 'all';
                            });
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, idx) {
                            final t = filteredTransactions[idx];
                            final isInc = _isPemasukan(t);
                            final isCamp = t.sumber.toLowerCase() == 'kampus';

                            return BkuCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              borderRadius: 16,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrmawaKeuanganDetailScreen(transaksi: t))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isCamp ? BkuTheme.indigoSoft : BkuTheme.borderSubtle,
                                              borderRadius: BkuTheme.r8,
                                              border: Border.all(color: isCamp ? BkuTheme.indigoBorder : BkuTheme.border),
                                            ),
                                            child: Text(
                                              isCamp ? 'Pagu Kampus' : 'Kas Mandiri',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                                color: isCamp ? BkuTheme.indigo : BkuTheme.textBody,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isInc ? BkuTheme.emeraldSoft : BkuTheme.roseSoft,
                                              borderRadius: BkuTheme.r8,
                                              border: Border.all(color: isInc ? BkuTheme.emerald.withAlpha(100) : BkuTheme.rose.withAlpha(100)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(isInc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 10, color: isInc ? BkuTheme.emerald : BkuTheme.rose),
                                                const SizedBox(width: 2),
                                                Text(
                                                  isInc ? 'Masuk' : 'Keluar',
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w900,
                                                    color: isInc ? BkuTheme.emerald : BkuTheme.rose,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _formatDateIndo(t.date),
                                        style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t.description.isNotEmpty ? t.description : 'Transaksi Kas',
                                              style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w900, height: 1.25),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Kategori: ${t.category.isNotEmpty ? t.category : 'Kas Operasional'}',
                                              style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textPlaceholder),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${isInc ? '+' : '-'}${_formatRp(t.nominal)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                          color: isInc ? BkuTheme.emerald : BkuTheme.rose,
                                        ),
                                      ),
                                      if (canDeleteFinance) ...[
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () => _showDeleteConfirmDialog(context, t),
                                          borderRadius: BkuTheme.r8,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(color: BkuTheme.roseSoft, borderRadius: BkuTheme.r8),
                                            child: const Icon(Icons.delete_outline_rounded, size: 14, color: BkuTheme.rose),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],

                    if (_activeSubTab == 'iuran') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  canManageFinance ? 'Tagihan Iuran Kas Anggota' : 'Tagihan Iuran Kas Saya',
                                  style: BkuTheme.textSectionTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  canManageFinance ? 'Terbitkan tagihan dan pantau status pembayaran' : 'Daftar tagihan kas ormawa Anda',
                                  style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (canCreateFinance) ...[
                            const SizedBox(width: 8),
                            BkuButton.primary(
                              onPressed: () => _showCreateIuranDialog(context),
                              icon: Icons.add_rounded,
                              text: 'Terbitkan Tagihan',
                              height: 34,
                              fontSize: 10.5,
                              fullWidth: false,
                              customRadius: BkuTheme.r8,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (iurans.isEmpty)
                        const BkuEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum Ada Tagihan Iuran',
                          message: 'Belum ada tagihan iuran kas yang diterbitkan oleh bendahara.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: iurans.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final iuran = iurans[idx];
                            final iuranId = (iuran['ID'] ?? iuran['id'] ?? '').toString();
                            final myInv = myInvoicesMap[iuranId];
                            final myStatus = (myInv?['Status'] ?? myInv?['status'] ?? 'belum_bayar').toString().toLowerCase();
                            final isMyLunas = myStatus == 'lunas';
                            final isMyPending = myStatus == 'pending';
                            final isMyDitolak = myStatus == 'ditolak';
                            final myProof = myInv?['BuktiTransfer'] ?? myInv?['bukti_transfer'];

                            return BkuCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              borderRadius: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          iuran['Judul'] ?? iuran['judul'] ?? 'Iuran Kas',
                                          style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w900),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(color: BkuTheme.emeraldSoft, borderRadius: BkuTheme.r8),
                                        child: const Text('Aktif', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: BkuTheme.emerald)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: BkuTheme.borderSubtle, borderRadius: BkuTheme.r10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Besaran Tagihan', style: BkuTheme.textBadge.copyWith(fontSize: 8.5, fontWeight: FontWeight.w800, color: BkuTheme.textPlaceholder)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble()),
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    iuran['Deskripsi'] ?? iuran['deskripsi'] ?? 'Iuran rutin kas bulanan anggota organisasi.',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 12, color: BkuTheme.textPlaceholder),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Tenggat: ${_formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat'])}',
                                                style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (canManageFinance)
                                        BkuButton.outline(
                                          text: 'Pantau Pembayaran',
                                          height: 32,
                                          fontSize: 10.5,
                                          fullWidth: false,
                                          customRadius: BkuTheme.r8,
                                          onPressed: () => _showIuranMembersModal(context, iuran),
                                        )
                                      else if (isMyLunas)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: BkuTheme.emeraldSoft, borderRadius: BkuTheme.r8),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.check_circle_rounded, size: 12, color: BkuTheme.emerald),
                                              SizedBox(width: 3),
                                              Text('Sudah Lunas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: BkuTheme.emerald)),
                                            ],
                                          ),
                                        )
                                      else if (isMyPending)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: BkuTheme.amberSoft, borderRadius: BkuTheme.r8),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.hourglass_top_rounded, size: 11, color: BkuTheme.amber),
                                                  SizedBox(width: 3),
                                                  Text('Menunggu Review', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.amber)),
                                                ],
                                              ),
                                            ),
                                            if (myProof != null && myProof.toString().isNotEmpty) ...[
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () => _showProofImageModal(context, myProof.toString()),
                                                borderRadius: BkuTheme.r8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(color: BkuTheme.borderSubtle, borderRadius: BkuTheme.r8),
                                                  child: const Icon(Icons.image_rounded, size: 13, color: BkuTheme.textBody),
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      else if (isMyDitolak)
                                        BkuButton.danger(
                                          text: 'Kirim Ulang',
                                          height: 32,
                                          fontSize: 10.5,
                                          icon: Icons.refresh_rounded,
                                          fullWidth: false,
                                          customRadius: BkuTheme.r8,
                                          onPressed: () => _showPayKasModal(context, iuran),
                                        )
                                      else
                                        BkuButton.success(
                                          text: 'Bayar Kas',
                                          height: 32,
                                          fontSize: 10.5,
                                          icon: Icons.payments_rounded,
                                          fullWidth: false,
                                          customRadius: BkuTheme.r8,
                                          onPressed: () => _showPayKasModal(context, iuran),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],

                    if (_activeSubTab == 'rekening') ...[
                      if (canManageFinance)
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengaturan Rekening Bank Resmi',
                                style: BkuTheme.textSectionTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Nomor rekening ini akan ditampilkan ke anggota untuk pembayaran iuran kas.',
                                style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                              ),
                              const SizedBox(height: 14),

                              BkuTextField(
                                controller: _bankNameController,
                                label: 'Nama Bank *',
                                hint: 'Contoh: Bank Mandiri / BCA / BNI',
                              ),
                              const SizedBox(height: 12),

                              BkuTextField(
                                controller: _bankNumberController,
                                label: 'Nomor Rekening *',
                                hint: 'Contoh: 1300012345678',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),

                              BkuTextField(
                                controller: _bankOwnerController,
                                label: 'Atas Nama Pemilik Rekening *',
                                hint: 'Contoh: Bendahara BEM BKU',
                              ),
                              const SizedBox(height: 16),

                              BkuButton.primary(
                                isLoading: _isSavingBank,
                                icon: Icons.check_circle_outline_rounded,
                                text: 'Simpan Rekening Bank',
                                height: 46,
                                onPressed: _isSavingBank
                                    ? null
                                    : () async {
                                        if (_bankNameController.text.trim().isEmpty || _bankNumberController.text.trim().isEmpty) {
                                          AppSnackbar.showWarning(context, 'Nama bank dan nomor rekening wajib diisi');
                                          return;
                                        }
                                        setState(() => _isSavingBank = true);
                                        try {
                                          await context.read<OrmawaProvider>().updateBankAccount({
                                            'nama_bank': _bankNameController.text.trim(),
                                            'no_rekening': _bankNumberController.text.trim(),
                                            'nama_rekening': _bankOwnerController.text.trim(),
                                          });
                                          if (context.mounted) {
                                            AppSnackbar.showSuccess(context, 'Rekening bank resmi berhasil diperbarui!');
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            AppSnackbar.showError(context, 'Gagal memperbarui rekening: $e');
                                          }
                                        } finally {
                                          if (mounted) setState(() => _isSavingBank = false);
                                        }
                                      },
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BkuTheme.r20,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withAlpha(40),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rekening Resmi Organisasi',
                                        style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.textPlaceholder, letterSpacing: 0.5),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.emerald.withAlpha(50),
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.emerald.withAlpha(100)),
                                        ),
                                        child: Text(
                                          bank['nama_bank'] != null && bank['nama_bank'].toString().isNotEmpty ? bank['nama_bank'].toString() : 'Bank Transfer',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nomor Rekening',
                                    style: BkuTheme.textBadge.copyWith(fontSize: 8.5, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bank['no_rekening'] ?? '— Belum Diatur Bendahara —',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'monospace', letterSpacing: 1.5),
                                        ),
                                      ),
                                      if (bank['no_rekening'] != null && bank['no_rekening'].toString().isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: bank['no_rekening'].toString()));
                                            AppSnackbar.showSuccess(context, 'Nomor rekening disalin!');
                                          },
                                          borderRadius: BkuTheme.r8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(20),
                                              borderRadius: BkuTheme.r8,
                                              border: Border.all(color: Colors.white.withAlpha(40)),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text('Salin', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: Color(0xFF334155), height: 1),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Atas Nama Pemilik:', style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textPlaceholder)),
                                      Text(bank['nama_rekening'] ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BkuTheme.amberSoft,
                                borderRadius: BkuTheme.r12,
                                border: Border.all(color: BkuTheme.amberBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 16, color: BkuTheme.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gunakan nomor rekening di atas untuk melakukan transfer pembayaran kas resmi organisasi.',
                                      style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.amber),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],

                    const SizedBox(height: AppSpacing.s140),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}