import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Icon(Icons.description_rounded, color: Color(0xFF059669), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Keuangan Kas',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Ringkasan resmi buku kas organisasi',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NOMOR DOKUMEN RESMI',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'RESMI',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reportNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.orgName.isNotEmpty ? provider.orgName : 'Organisasi Mahasiswa',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Tanggal Cetak: ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
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
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF0F172A)),
                            SizedBox(width: 6),
                            Text(
                              'Saldo Kas Mandiri',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatRp(saldo),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF059669),
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
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pemasukan',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRp(totalIn),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF047857),
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
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFE4E6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pengeluaran',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRp(totalOut),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE11D48),
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
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text: 'LAPORAN KAS ORMAWA\nNo: $reportNumber\nOrganisasi: ${provider.orgName}\nSaldo: ${_formatRp(saldo)}\nTotal Masuk: ${_formatRp(totalIn)}\nTotal Keluar: ${_formatRp(totalOut)}',
                        ));
                        Navigator.pop(ctx);
                        AppSnackbar.showSuccess(context, 'Ringkasan laporan kas berhasil disalin!');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: OrmawaTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: OrmawaTheme.primary.withAlpha(40),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Salin Laporan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Terbitkan Tagihan Iuran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    IconButton(
                      onPressed: () => Navigator.pop(modalCtx),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const Text('Kirimkan tagihan iuran kas ke seluruh anggota aktif organisasi.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                const Text('Judul Tagihan *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                const SizedBox(height: 5),
                TextField(
                  controller: _iuranJudulController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Iuran Kas Bulan Mei 2026',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nominal (Rp) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _iuranNominalController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '20000',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tenggat Waktu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
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
                                        primary: OrmawaTheme.primary,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: const Color(0xFF0F172A),
                                      ),
                                                                            textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: OrmawaTheme.primary,
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
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _iuranTenggatController.text.isNotEmpty ? _iuranTenggatController.text : 'Pilih Tanggal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _iuranTenggatController.text.isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
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

                const Text('Deskripsi Singkat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                const SizedBox(height: 5),
                TextField(
                  controller: _iuranDeskripsiController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Keterangan peruntukan dana iuran...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
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
                    icon: _isSubmittingIuran
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Terbitkan Tagihan Iuran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrmawaTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bukti Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
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
              color: const Color(0xFF0F172A),
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
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Verifikasi Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    IconButton(onPressed: () => Navigator.pop(modalCtx), icon: const Icon(Icons.close_rounded, size: 20)),
                  ],
                ),
                Text(
                  'Mahasiswa: ${member['nama'] ?? member['Nama'] ?? 'Anggota'} (${member['nim'] ?? member['NIM'] ?? '—'})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                if (proof != null && proof.toString().isNotEmpty) ...[
                  InkWell(
                    onTap: () => _showProofImageModal(context, proof.toString()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image_rounded, color: Color(0xFF4338CA), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Lihat Foto Bukti Transfer', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF4338CA))),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF4338CA), size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Belum ada foto bukti transfer. Anda dapat verifikasi manual jika bayar tunai.', style: TextStyle(fontSize: 10, color: Color(0xFF92400E))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Text('Status Verifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: verifyStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'lunas', child: Text('Setujui Pembayaran (Lunas)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                        DropdownMenuItem(value: 'ditolak', child: Text('Tolak Bukti Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)))),
                        DropdownMenuItem(value: 'pending', child: Text('Tetap Menunggu Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => verifyStatus = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Catatan Pengurus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                const SizedBox(height: 5),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Catatan untuk anggota (opsional)...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
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
                    icon: isVerifying
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Simpan Verifikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrmawaTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<OrmawaProvider>(
        builder: (_, prov, __) {
          final members = prov.iuranMembers;
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        iuran['Judul'] ?? iuran['judul'] ?? 'Daftar Tagihan Anggota',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, size: 20)),
                  ],
                ),
                Text(
                  'Nominal: ${_formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble())} • Tenggat: ${_formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat'])}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: members.isEmpty
                      ? const Center(child: Text('Belum ada data anggota pada tagihan ini.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))))
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

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(memberName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 2),
                                        Text('NIM: $memberNim', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'monospace')),
                                        if (isLunas && payDate != null) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF059669)),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Dibayar: ${_formatDateIndo(payDate)}',
                                                style: const TextStyle(fontSize: 9.5, color: Color(0xFF059669), fontWeight: FontWeight.w700),
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFC7D2FE)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.image_rounded, size: 12, color: Color(0xFF4338CA)),
                                            SizedBox(width: 3),
                                            Text('Bukti', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF4338CA))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLunas ? const Color(0xFFD1FAE5) : (isPending ? const Color(0xFFFEF3C7) : (isDitolak ? const Color(0xFFFFE4E6) : const Color(0xFFF1F5F9))),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isLunas ? 'LUNAS' : (isPending ? 'REVIEW' : (isDitolak ? 'DITOLAK' : 'BELUM')),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: isLunas ? const Color(0xFF047857) : (isPending ? const Color(0xFFB45309) : (isDitolak ? const Color(0xFFBE123C) : const Color(0xFF475569))),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _showVerifyModal(context, m, iuranId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isLunas ? const Color(0xFFE2E8F0) : OrmawaTheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isLunas ? 'Detail' : 'Verifikasi',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: isLunas ? const Color(0xFF334155) : Colors.white,
                                        ),
                                      ),
                                    ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Bayar Iuran: ${iuran['Judul'] ?? iuran['judul'] ?? 'Kas Anggota'}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(modalCtx), icon: const Icon(Icons.close_rounded, size: 20)),
                  ],
                ),
                const Text('Selesaikan pembayaran tagihan kas ormawa Anda.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Besaran Tagihan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                          Text(
                            _formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble()),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: OrmawaTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tenggat Pembayaran:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          Text(_formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat']), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TUJUAN TRANSFER (${bank['nama_bank'] ?? 'Bank'})', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF4338CA))),
                          if (bank['no_rekening'] != null && bank['no_rekening'].toString().isNotEmpty)
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: bank['no_rekening'].toString()));
                                AppSnackbar.showSuccess(context, 'Nomor rekening disalin!');
                              },
                              child: const Text('Salin No. Rek', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF4338CA), decoration: TextDecoration.underline)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(bank['no_rekening'] ?? '— Belum diatur bendahara —', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF312E81), fontFamily: 'monospace')),
                      Text('a.n. ${bank['nama_rekening'] ?? '—'}', style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Unggah Foto Bukti Transfer *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
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
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_selectedProofFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: _selectedProofFile != null ? const Color(0xFF047857) : const Color(0xFF64748B), size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _selectedProofName ?? 'Pilih Foto Bukti Transfer (JPG/PNG)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _selectedProofFile != null ? const Color(0xFF047857) : const Color(0xFF475569),
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

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
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
                    icon: _isPayingIuran
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Kirim Bukti Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrmawaTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, OrmawaFinance t) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hapus Transaksi Kas?',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Tindakan ini tidak dapat dibatalkan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.description,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRp(t.nominal),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFE11D48), fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin menghapus data mutasi kas ini? Saldo kas akan disesuaikan kembali secara otomatis.',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(ctx);
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withAlpha(40),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildSubTabItem({
    required String id,
    required String label,
    required IconData icon,
    required String count,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => setState(() => _activeSubTab = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? OrmawaTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? OrmawaTheme.primary : const Color(0xFFE2E8F0)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: OrmawaTheme.primary.withAlpha(45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: isActive ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : const Color(0xFF334155),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withAlpha(45) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
                        color: OrmawaTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.insights_rounded, size: 16, color: OrmawaTheme.primary),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tren Arus Kas',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Realisasi keuangan bulanan',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
                    decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  const Text('Masuk', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  const Text('Keluar', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFE11D48))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14, bottom: 8, left: 8, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF34D399), Color(0xFF059669)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 12,
                              height: outBarHeight,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthLabel,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
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
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL MASUK', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                            const SizedBox(height: 1),
                            Text(
                              _formatRp(latestIn),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF047857), fontFamily: 'monospace'),
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
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFFE11D48)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL KELUAR', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFFE11D48))),
                            const SizedBox(height: 1),
                            Text(
                              _formatRp(latestOut),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFBE123C), fontFamily: 'monospace'),
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
              color: isSurplus ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSurplus ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSurplus ? Icons.check_circle_rounded : Icons.warning_rounded,
                      size: 14,
                      color: isSurplus ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSurplus ? 'Surplus Arus Kas Periode Ini' : 'Defisit Arus Kas Periode Ini',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSurplus ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${isSurplus ? '+' : ''}${_formatRp(latestNet)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSurplus ? const Color(0xFF166534) : const Color(0xFF991B1B),
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
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: OrmawaTheme.primary,
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
                            color: OrmawaTheme.primary.withAlpha(18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: OrmawaTheme.primary.withAlpha(50)),
                          ),
                          child: Text(
                            'Buku Kas Terintegrasi',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primary),
                          ),
                        ),
                        InkWell(
                          onTap: _loadAllData,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isRefreshing
                                    ? SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: OrmawaTheme.primary))
                                    : Icon(Icons.refresh_rounded, size: 14, color: OrmawaTheme.primary),
                                const SizedBox(width: 4),
                                Text('Segarkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: OrmawaTheme.primary)),
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
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_rounded, size: 14, color: Color(0xFF334155)),
                                  SizedBox(width: 4),
                                  Text('Mutasi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showReportDialog(context, provider, saldo, totalIn, totalOut),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_rounded, size: 14, color: Color(0xFF047857)),
                                  SizedBox(width: 4),
                                  Text('Unduh PDF', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
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
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: OrmawaTheme.primary,
                                  borderRadius: BorderRadius.circular(10),
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
                            badgeColor: OrmawaTheme.primary,
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
                            badgeColor: const Color(0xFF059669),
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
                            badgeColor: const Color(0xFFE11D48),
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
                            badgeColor: const Color(0xFF0284C7),
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
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _filterTipe,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'all', child: Text('Semua Tipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                    DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)))),
                                    DropdownMenuItem(value: 'pengeluaran', child: Text('Pengeluaran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)))),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setState(() => _filterTipe = v);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _filterSumber,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'all', child: Text('Semua Sumber', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                    DropdownMenuItem(value: 'organisasi', child: Text('Kas Mandiri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)))),
                                    DropdownMenuItem(value: 'kampus', child: Text('Pagu Kampus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)))),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setState(() => _filterSumber = v);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      OrmawaSearchBar(
                        controller: _searchController,
                        hintText: 'Cari keterangan transaksi kas...',
                      ),
                      const SizedBox(height: 12),

                      if (filteredTransactions.isEmpty)
                        OrmawaEmptyCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum Ada Transaksi',
                          description: _searchController.text.isNotEmpty || _filterTipe != 'all' || _filterSumber != 'all'
                              ? 'Tidak ada catatan transaksi kas yang cocok dengan kriteria filter pencarian aktif.'
                              : 'Belum ada catatan pembukuan transaksi kas masuk atau keluar.',
                          actionLabel: _searchController.text.isNotEmpty || _filterTipe != 'all' || _filterSumber != 'all'
                              ? 'Reset Filter & Cari Ulang'
                              : null,
                          actionIcon: Icons.refresh_rounded,
                          onAction: () {
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

                            return InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrmawaKeuanganDetailScreen(transaksi: t))),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
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
                                                color: isCamp ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: isCamp ? const Color(0xFFC7D2FE) : const Color(0xFFCBD5E1)),
                                              ),
                                              child: Text(
                                                isCamp ? 'PAGU KAMPUS' : 'KAS MANDIRI',
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: isCamp ? const Color(0xFF4338CA) : const Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isInc ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(isInc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 10, color: isInc ? const Color(0xFF047857) : const Color(0xFFBE123C)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    isInc ? 'MASUK' : 'KELUAR',
                                                    style: TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w900,
                                                      color: isInc ? const Color(0xFF047857) : const Color(0xFFBE123C),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _formatDateIndo(t.date),
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.25),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Kategori: ${t.category.isNotEmpty ? t.category : 'Kas Operasional'}',
                                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
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
                                            color: isInc ? const Color(0xFF047857) : const Color(0xFFBE123C),
                                          ),
                                        ),
                                        if (canDeleteFinance) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => _showDeleteConfirmDialog(context, t),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(6)),
                                              child: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFBE123C)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
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
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  canManageFinance ? 'Terbitkan tagihan dan pantau status pembayaran' : 'Daftar tagihan kas ormawa Anda',
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          if (canCreateFinance) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showCreateIuranDialog(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: OrmawaTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text(
                                      'Terbitkan Tagihan',
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (iurans.isEmpty)
                        const OrmawaEmptyCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum Ada Tagihan Iuran',
                          description: 'Belum ada tagihan iuran kas yang diterbitkan oleh bendahara.',
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

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          iuran['Judul'] ?? iuran['judul'] ?? 'Iuran Kas',
                                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                                        child: const Text('AKTIF', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('BESARAN TAGIHAN', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatRp(((iuran['Nominal'] ?? iuran['nominal'] ?? 0) as num).toDouble()),
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: OrmawaTheme.primary, fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    iuran['Deskripsi'] ?? iuran['deskripsi'] ?? 'Iuran rutin kas bulanan anggota organisasi.',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                                            const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Tenggat: ${_formatDateIndo(iuran['Tenggat'] ?? iuran['tenggat'])}',
                                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (canManageFinance)
                                        InkWell(
                                          onTap: () => _showIuranMembersModal(context, iuran),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: OrmawaTheme.primary.withAlpha(20),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Pantau Pembayaran',
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primary),
                                            ),
                                          ),
                                        )
                                      else if (isMyLunas)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF047857)),
                                              SizedBox(width: 3),
                                              Text('Sudah Lunas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                                            ],
                                          ),
                                        )
                                      else if (isMyPending)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.hourglass_top_rounded, size: 11, color: Color(0xFFB45309)),
                                                  SizedBox(width: 3),
                                                  Text('Menunggu Review', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                                                ],
                                              ),
                                            ),
                                            if (myProof != null && myProof.toString().isNotEmpty) ...[
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () => _showProofImageModal(context, myProof.toString()),
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                                  child: const Icon(Icons.image_rounded, size: 13, color: Color(0xFF334155)),
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      else if (isMyDitolak)
                                        InkWell(
                                          onTap: () => _showPayKasModal(context, iuran),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE11D48),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.refresh_rounded, size: 12, color: Colors.white),
                                                SizedBox(width: 3),
                                                Text('Kirim Ulang', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        InkWell(
                                          onTap: () => _showPayKasModal(context, iuran),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF047857),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.payments_rounded, size: 12, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text('Bayar Kas', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
                                              ],
                                            ),
                                          ),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pengaturan Rekening Bank Resmi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                              const Text('Nomor rekening ini akan ditampilkan ke anggota untuk pembayaran iuran kas.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              const SizedBox(height: 14),

                              const Text('Nama Bank *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _bankNameController,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: Bank Mandiri / BCA / BNI',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              const Text('Nomor Rekening *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _bankNumberController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 1300012345678',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 12),

                              const Text('Atas Nama Pemilik Rekening *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _bankOwnerController,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: Bendahara BEM BKU',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
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
                                  icon: _isSavingBank
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                                  label: const Text('Simpan Rekening Bank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: OrmawaTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
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
                                borderRadius: BorderRadius.circular(20),
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
                                      const Text('REKENING RESMI ORGANISASI', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF047857).withAlpha(50),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFF10B981).withAlpha(100)),
                                        ),
                                        child: Text(
                                          bank['nama_bank'] != null && bank['nama_bank'].toString().isNotEmpty ? bank['nama_bank'].toString().toUpperCase() : 'BANK TRANSFER',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('NOMOR REKENING', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
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
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(20),
                                              borderRadius: BorderRadius.circular(8),
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
                                      const Text('Atas Nama Pemilik:', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
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
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gunakan nomor rekening di atas untuk melakukan transfer pembayaran kas resmi organisasi.',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
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