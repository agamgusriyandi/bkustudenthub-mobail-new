import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/widgets/tk_patient_card.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_booking_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TkPatientListScreen extends StatefulWidget {
  final bool showBackButton;

  const TkPatientListScreen({super.key, this.showBackButton = true});

  @override
  State<TkPatientListScreen> createState() => _TkPatientListScreenState();
}

class _TkPatientListScreenState extends State<TkPatientListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedFakultas = 'Semua Fakultas';
  String _selectedProdi = 'Semua Prodi';
  String _selectedGender = 'Semua Gender';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkPatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportPdf(List<Patient> patients) async {
    AppSnackbar.showSuccess(context, 'Menyiapkan PDF...');
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(AppSpacing.xxl),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Daftar Mahasiswa (Pasien)',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: AppSpacing.s20),
            pw.TableHelper.fromTextArray(
              headers: [
                'NIM',
                'Nama',
                'Fakultas',
                'Program Studi',
                'Gender',
                'Kontak',
              ],
              data:
                  patients
                      .map(
                        (p) => [
                          p.nim,
                          p.nama,
                          p.fakultas,
                          p.prodi,
                          p.jenisKelamin,
                          p.noHP ?? '-',
                        ],
                      )
                      .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2), // NIM
                1: const pw.FlexColumnWidth(2.5), // Nama
                2: const pw.FlexColumnWidth(2.0), // Fakultas
                3: const pw.FlexColumnWidth(2.5), // Prodi
                4: const pw.FlexColumnWidth(1.2), // Gender
                5: const pw.FlexColumnWidth(1.8), // Kontak
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'daftar_mahasiswa.pdf');
  }

  void _showManualBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const ManualBookingSheet();
      },
    );
  }

  Future<void> _handleOfflineForm() async {
    final provider = context.read<TkHealthProvider>();
    final url = await provider.getOfflineFormPdfUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        if (mounted) {
          AppSnackbar.showError(
            context,
            'Tidak dapat memuat PDF formulir offline',
          );
        }
      }
    }
  }

  Future<void> _exportExcel(List<Patient> patients) async {
    AppSnackbar.showSuccess(context, 'Menyiapkan Excel (CSV)');
    List<List<dynamic>> rows = [];
    rows.add(['NIM', 'Nama', 'Fakultas', 'Program Studi', 'Gender', 'Kontak']);

    for (var p in patients) {
      rows.add([
        p.nim,
        p.nama,
        p.fakultas,
        p.prodi,
        p.jenisKelamin,
        p.noHP ?? '-',
      ]);
    }

    String csv = rows
        .map(
          (row) => row
              .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
              .join(','),
        )
        .join('\n');
    final bytes = Uint8List.fromList(csv.codeUnits);

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'daftar_mahasiswa.csv';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: 'daftar_mahasiswa.csv');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Daftar Pasien',
        showBackButton: widget.showBackButton,
        onBack: () {
          final mainState =
              context.findAncestorStateOfType<TkMainScreenState>();
          if (mainState != null) {
            mainState.setSelectedIndex(0);
          } else if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/tenagakes?tab=0');
          }
        },
        variant: AppBarVariant.nakes,
      ),
      body: Consumer<TkPatientProvider>(
        builder: (context, provider, child) {
          // Extract unique filters from loaded patients
          final fakultasList = [
            'Semua Fakultas',
            ...provider.patients
                .map((e) => e.fakultas.trim())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
          ];

          final prodiList = [
            'Semua Prodi',
            ...provider.patients
                .map((e) => e.prodi.trim())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
          ];

          final genderList = ['Semua Gender', 'Laki-laki', 'Perempuan'];

          // Calculate filtered patients
          List<Patient> filteredPatients = provider.patients;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            filteredPatients = filteredPatients.where((p) {
              return p.nama.toLowerCase().contains(query) ||
                  p.nim.toLowerCase().contains(query);
            }).toList();
          }
          if (_selectedFakultas != 'Semua Fakultas') {
            final fSel = _selectedFakultas.trim().toLowerCase();
            filteredPatients = filteredPatients
                .where((p) => p.fakultas.trim().toLowerCase() == fSel)
                .toList();
          }
          if (_selectedProdi != 'Semua Prodi') {
            final pSel = _selectedProdi.trim().toLowerCase();
            filteredPatients = filteredPatients
                .where((p) => p.prodi.trim().toLowerCase() == pSel)
                .toList();
          }
          if (_selectedGender != 'Semua Gender') {
            final gSel = _selectedGender.trim().toLowerCase();
            filteredPatients = filteredPatients.where((p) {
              final jk = p.jenisKelamin.trim().toLowerCase();
              if (gSel.contains('laki')) {
                return jk.contains('laki') || jk == 'l' || jk.startsWith('l');
              } else if (gSel.contains('perempuan')) {
                return jk.contains('perempuan') || jk == 'p' || jk.startsWith('p');
              }
              return true;
            }).toList();
          }

          return Column(
            children: [
              // Filters Section
              Container(
                color: AppColors.surface,
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: Row(
                      children: [
                        Container(
                          padding: AppSpacing.padding6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Text(
                          'Saring & Cari Mahasiswa',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.neutral800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pencarian',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Ketik NIM atau Nama...',
                              filled: true,
                              fillColor: AppColors.neutral50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusLg,
                                borderSide: BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusLg,
                                borderSide: BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusLg,
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.neutral500,
                              ),
                              suffixIcon:
                                  _searchQuery.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                      : null,
                            ),
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Filters row
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterSelector(
                                  label: 'Fakultas',
                                  value: _selectedFakultas,
                                  items: fakultasList,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedFakultas = val!;
                                      _selectedProdi =
                                          'Semua Prodi';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildFilterSelector(
                                  label: 'Program Studi',
                                  value: _selectedProdi,
                                  items: prodiList,
                                  onChanged:
                                      (val) =>
                                          setState(() => _selectedProdi = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildFilterSelector(
                            label: 'Jenis Kelamin',
                            value: _selectedGender,
                            items: genderList,
                            onChanged:
                                (val) => setState(() => _selectedGender = val!),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactActionButton(
                                  onPressed: () => _exportExcel(filteredPatients),
                                  text: 'Export Excel',
                                  icon: Icons.table_chart_rounded,
                                  bgColor: const Color(0xFFF0FDF4),
                                  fgColor: const Color(0xFF16A34A),
                                  border: const BorderSide(color: Color(0xFF86EFAC)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildCompactActionButton(
                                  onPressed: () => _exportPdf(filteredPatients),
                                  text: 'Export PDF',
                                  icon: Icons.picture_as_pdf_rounded,
                                  bgColor: const Color(0xFFFEF2F2),
                                  fgColor: const Color(0xFFDC2626),
                                  border: const BorderSide(color: Color(0xFFFCA5A5)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactActionButton(
                                  onPressed: _handleOfflineForm,
                                  text: 'Form Offline',
                                  icon: Icons.description_rounded,
                                  bgColor: const Color(0xFFF8FAFC),
                                  fgColor: const Color(0xFF334155),
                                  border: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildCompactActionButton(
                                  onPressed: _showManualBookingSheet,
                                  text: 'Registrasi Manual',
                                  icon: Icons.person_add_rounded,
                                  bgColor: const Color(0xFF16A34A),
                                  fgColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Patient List
              Expanded(
                child:
                    provider.isLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 90),
                        )
                        : _buildPatientList(provider, filteredPatients),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSelector({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final bool isSelected = !value.startsWith('Semua');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () {
            _showSelectionBottomSheet(
              title: label,
              items: items,
              selectedValue: value,
              onSelected: onChanged,
            );
          },
          borderRadius: AppRadius.radiusLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: isSelected ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionBottomSheet({
    required String title,
    required List<String> items,
    required String selectedValue,
    required void Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Pilih $title',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == selectedValue;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(
                          item,
                          style: AppTextStyles.bodyMd.copyWith(
                            color:
                                isSelected
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF1E293B),
                            fontWeight:
                                isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                )
                                : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientList(TkPatientProvider provider, List<Patient> patients) {
    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Mahasiswa tidak ditemukan',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPatients(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          100,
        ),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TkPatientCard(
              patient: patient,
              onTap: () => _navigateToPatientDetail(patient),
            ),
          );
        },
      ),
    );
  }

  void _navigateToPatientDetail(Patient patient) {
    context.read<TkPatientProvider>().selectPatient(patient);
    context.push('/tk/patient/${patient.id}');
  }

  Widget _buildCompactActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    BorderSide? border,
  }) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
            side: border ?? BorderSide.none,
          ),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
