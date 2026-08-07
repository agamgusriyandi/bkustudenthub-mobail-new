import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

class MentorMaterialsScreen extends StatefulWidget {
  const MentorMaterialsScreen({super.key});

  @override
  State<MentorMaterialsScreen> createState() => _MentorMaterialsScreenState();
}

class _MentorMaterialsScreenState extends State<MentorMaterialsScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedSifat = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchSessionMaterialsList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final baseUrl = ApiGate.baseUrl.replaceAll('/api', '');
    final finalUrl = url.startsWith('http') ? url : '$baseUrl$url';
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (mounted) AppSnackbar.showError(context, 'Tidak dapat membuka URL lampiran');
    }
  }

  void _showManageMaterialsModal(BuildContext context, SessionMaterialData session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final provider = context.watch<MentorKencanaProvider>();
        final currentSession = provider.sessionMaterials.firstWhere(
          (s) => s.id == session.id,
          orElse: () => session,
        );
        final materialsList = currentSession.materials;

        return Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Materi: ${currentSession.title}',
                          style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kelola semua materi bacaan, video, atau file presentasi untuk sesi ini.',
                          style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Top Header Box
              BkuCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Icon(Icons.inventory_2_outlined, color: context.appColors.onSurface, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Daftar Materi Sesi', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
                            Text('${materialsList.length} materi terdaftar', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddMaterialModal(context, currentSession),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Tambah Materi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Items List
              if (materialsList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('Belum ada materi terdaftar', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: materialsList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final mat = materialsList[index];
                  return BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: const Icon(Icons.attach_file_rounded, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mat.title, style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                    mat.fileUrl.isNotEmpty ? mat.fileUrl.split('/').last : 'File Dokumentasi',
                                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Text('FILE', style: AppTextStyles.labelSm.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Komponen: ${mat.component}', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                            Row(
                              children: [
                                if (mat.fileUrl.isNotEmpty)
                                  InkWell(
                                    onTap: () => _openFile(mat.fileUrl),
                                    borderRadius: AppRadius.radiusSm,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: context.appColors.primary.withAlpha(15),
                                        borderRadius: AppRadius.radiusSm,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.open_in_new_rounded, size: 12, color: context.appColors.primary),
                                          const SizedBox(width: 2),
                                          Text('Buka File', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.appColors.primary)),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _showEditMaterialModal(context, session, mat),
                                  borderRadius: AppRadius.radiusSm,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral200,
                                      borderRadius: AppRadius.radiusSm,
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit_rounded, size: 12, color: AppColors.neutral700),
                                        SizedBox(width: 2),
                                        Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.neutral700)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _showDeleteMaterialModal(context, session, mat),
                                  borderRadius: AppRadius.radiusSm,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withAlpha(15),
                                      borderRadius: AppRadius.radiusSm,
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 12, color: AppColors.error),
                                        SizedBox(width: 2),
                                        Text('Hapus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
    },
  );
}

  void _showAddMaterialModal(BuildContext context, SessionMaterialData session) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    String jenisMateri = 'Teks';
    String component = 'cognitive';
    bool isMandatory = true;
    String? fileName;
    PlatformFile? selectedFile;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Materi Baru', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Isi form sesuai jenis materi. Teks dan link bisa digabung dengan file jika diperlukan.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('JUDUL MATERI *', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Panduan Orientasi Mahasiswa',
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('JENIS MATERI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: jenisMateri,
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Teks', child: Text('Teks', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'File', child: Text('File', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Video', child: Text('Video', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Link', child: Text('Link', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => jenisMateri = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KOMPONEN NILAI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: component,
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'cognitive', child: Text('Kognitif', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'psychomotor', child: Text('Psikomotor', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'affective', child: Text('Afektif', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => component = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: context.appColors.onSurface,
                  value: isMandatory,
                  onChanged: (val) => setModalState(() => isMandatory = val ?? true),
                  title: Text('Materi wajib dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.appColors.onSurface)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 8),
                Text('DESKRIPSI / TEKS MATERI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan teks penjelasan jika perlu...',
                    hintStyle: AppTextStyles.labelSm.copyWith(fontSize: 12, color: context.appColors.outline),
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 12),
                Text('TAUTAN (URL EKSTERNAL) (opsional)', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: urlController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'https://... (opsional)',
                    hintStyle: AppTextStyles.labelSm.copyWith(fontSize: 12, color: context.appColors.outline),
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text('UPLOAD FILE DOKUMEN / VIDEO', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: AppColors.neutral300, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.pickFiles();
                          if (result != null && result.files.isNotEmpty) {
                            setModalState(() {
                              selectedFile = result.files.single;
                              fileName = result.files.single.name;
                            });
                          }
                        },
                        icon: const Icon(Icons.upload_file_rounded, size: 14),
                        label: const Text('Pilih File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.onSurface,
                          side: const BorderSide(color: AppColors.neutral300),
                          backgroundColor: context.appColors.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName ?? 'No file chosen',
                          style: TextStyle(fontSize: 11, color: fileName != null ? AppColors.neutral900 : context.appColors.outline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutral600,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Kembali', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.onSurface,
                        foregroundColor: context.appColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        elevation: 0,
                      ),
                      onPressed: isUploading ? null : () async {
                        if (titleController.text.trim().isEmpty) return;
                        final provider = context.read<MentorKencanaProvider>();
                        
                        String finalFileUrl = urlController.text.trim();
                        if (selectedFile != null) {
                          setModalState(() => isUploading = true);
                          final uploadedUrl = await provider.uploadMaterialFile(selectedFile!);
                          setModalState(() => isUploading = false);
                          if (uploadedUrl != null) {
                            finalFileUrl = uploadedUrl;
                          } else {
                            if (context.mounted) AppSnackbar.showError(context, 'Gagal mengupload file');
                            return;
                          }
                        }
                        
                        final success = await provider.createMaterial({
                          'session_id': session.id,
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                          'file_url': finalFileUrl,
                          'component': component,
                          'is_mandatory': isMandatory,
                        });
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          AppSnackbar.showSuccess(context, 'Materi berhasil disimpan');
                          provider.fetchSessionMaterialsList();
                        } else {
                          AppSnackbar.showError(context, 'Gagal menyimpan materi');
                        }
                      },
                      child: isUploading 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Materi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMaterialModal(BuildContext context, SessionMaterialData session, SessionMaterialItem mat) {
    final titleController = TextEditingController(text: mat.title);
    final descController = TextEditingController(text: 'Deskripsi materi');
    final urlController = TextEditingController(text: mat.fileUrl.startsWith('http') ? mat.fileUrl : '');
    String jenisMateri = mat.fileUrl.endsWith('.pdf') ? 'File' : 'Teks';
    String component = ['cognitive', 'psychomotor', 'affective'].contains(mat.component) ? mat.component : 'cognitive';
    bool isMandatory = true;
    String fileName = mat.fileUrl.isNotEmpty ? mat.fileUrl.split('/').last : 'Belum ada file terpilih';
    PlatformFile? selectedFile;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Materi', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Isi form sesuai jenis materi. Teks dan link bisa digabung dengan file jika diperlukan.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('JUDUL MATERI *', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('JENIS MATERI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: jenisMateri,
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            ),
                            style: const TextStyle(fontSize: 11, color: AppColors.neutral900),
                            items: const [
                              DropdownMenuItem(value: 'Teks', child: Text('Teks', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'File', child: Text('File', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'Video', child: Text('Video', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'Link', child: Text('Link', style: TextStyle(fontSize: 11))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => jenisMateri = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KOMPONEN NILAI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: component,
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            ),
                            style: const TextStyle(fontSize: 11, color: AppColors.neutral900),
                            items: const [
                              DropdownMenuItem(value: 'cognitive', child: Text('Kognitif', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'psychomotor', child: Text('Psikomotor', style: TextStyle(fontSize: 11))),
                              DropdownMenuItem(value: 'affective', child: Text('Afektif', style: TextStyle(fontSize: 11))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => component = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: context.appColors.onSurface,
                  value: isMandatory,
                  onChanged: (val) => setModalState(() => isMandatory = val ?? true),
                  title: Text('Materi wajib dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.appColors.onSurface)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 6),
                Text('DESKRIPSI / TEKS MATERI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintStyle: AppTextStyles.labelSm.copyWith(fontSize: 12, color: context.appColors.outline),
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text('TAUTAN (URL EKSTERNAL) (opsional)', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://... (opsional)',
                    hintStyle: AppTextStyles.labelSm.copyWith(fontSize: 12, color: context.appColors.outline),
                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text('UPLOAD FILE DOKUMEN / VIDEO', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: AppColors.neutral300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.pickFiles();
                              if (result != null && result.files.isNotEmpty) {
                                setModalState(() {
                                  selectedFile = result.files.single;
                                  fileName = result.files.single.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file_rounded, size: 14),
                            label: const Text('Pilih File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.appColors.onSurface,
                              side: const BorderSide(color: AppColors.neutral300),
                              backgroundColor: context.appColors.surface,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFile != null ? selectedFile!.name : (fileName.isNotEmpty ? fileName : 'Tidak ada file'),
                              style: TextStyle(
                                fontSize: 11,
                                color: (selectedFile != null || fileName.isNotEmpty) ? AppColors.neutral900 : context.appColors.outline,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (fileName.isNotEmpty && selectedFile == null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, size: 13, color: AppColors.neutral600),
                            const SizedBox(width: 4),
                            Text(
                              'File Tersimpan saat ini',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.neutral600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutral600,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.onSurface,
                        foregroundColor: context.appColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        elevation: 0,
                      ),
                      onPressed: isUploading ? null : () async {
                        if (titleController.text.trim().isEmpty) return;
                        final provider = context.read<MentorKencanaProvider>();
                        
                        String finalFileUrl = urlController.text.trim();
                        if (selectedFile != null) {
                          setModalState(() => isUploading = true);
                          final uploadedUrl = await provider.uploadMaterialFile(selectedFile!);
                          setModalState(() => isUploading = false);
                          if (uploadedUrl != null) {
                            finalFileUrl = uploadedUrl;
                          } else {
                            if (context.mounted) AppSnackbar.showError(context, 'Gagal mengupload file');
                            return;
                          }
                        } else if (finalFileUrl.isEmpty) {
                          finalFileUrl = mat.fileUrl; // keep the old one if no new file/url is provided
                        }
                        
                        final success = await provider.updateMaterial(mat.id, {
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                          'file_url': finalFileUrl,
                          'component': component,
                          'is_mandatory': isMandatory,
                        });
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          AppSnackbar.showSuccess(context, 'Materi berhasil diupdate');
                          provider.fetchSessionMaterialsList();
                        } else {
                          AppSnackbar.showError(context, 'Gagal mengupdate materi');
                        }
                      },
                      child: isUploading 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Update Materi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteMaterialModal(BuildContext context, SessionMaterialData session, SessionMaterialItem mat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: const Text('Hapus Materi'),
        content: Text('Apakah Anda yakin ingin menghapus materi "${mat.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.appColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              final provider = context.read<MentorKencanaProvider>();
              final success = await provider.deleteMaterial(mat.id);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              if (success) {
                AppSnackbar.showSuccess(context, 'Materi berhasil dihapus');
                provider.fetchSessionMaterialsList();
              } else {
                AppSnackbar.showError(context, 'Gagal menghapus materi');
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManageQuizzesModal(BuildContext context, SessionMaterialData session) {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final maxAttemptsController = TextEditingController(text: '1');
    String statusKuis = 'published';
    String komponenNilai = 'cognitive';
    String currentView = 'list';
    double pgRatio = 50.0;
    int? editingQuizId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = context.watch<MentorKencanaProvider>();
          final currentSession = provider.sessionMaterials.firstWhere(
            (s) => s.id == session.id,
            orElse: () => session,
          );
          final quizList = currentSession.quizzes;

          return Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.xl,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentView == 'list' ? 'Kelola Kuis: ${session.title}' : (editingQuizId != null ? 'Edit Kuis' : 'Tambah Kuis Baru'), style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                            Text(currentView == 'list' ? 'Daftar kuis evaluasi dan koreksi essay.' : 'Isi form untuk menyimpan kuis.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (currentView == 'list') ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          editingQuizId = null;
                          titleController.clear();
                          setModalState(() => currentView = 'form');
                        },
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Tambah Kuis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.onSurface,
                          foregroundColor: context.appColors.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (quizList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('Belum ada kuis untuk sesi ini', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quizList.length,
                        itemBuilder: (context, idx) {
                          final q = quizList[idx];
                          return BkuCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.help_outline_rounded, size: 20, color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        q.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        q.status,
                                        style: const TextStyle(color: Color(0xFF166534), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStatBox('DURASI', '30 Menit'),
                                    const SizedBox(width: 6),
                                    _buildStatBox('MAX COBA', '1x Coba'),
                                    const SizedBox(width: 6),
                                    _buildStatBox('NILAI LULUS', '60'),
                                    const SizedBox(width: 6),
                                    _buildStatBox('KOMPONEN', q.component),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _showQuizQuestionsModal(context, q);
                                      },
                                      icon: const Icon(Icons.edit_note_rounded, size: 14),
                                      label: const Text('Kelola Soal →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        editingQuizId = q.id;
                                        titleController.text = q.title;
                                        statusKuis = q.status.isNotEmpty ? q.status : 'published';
                                        komponenNilai = q.component.isNotEmpty ? q.component : 'cognitive';
                                        setModalState(() {
                                          currentView = 'form';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 12, color: Color(0xFF334155)),
                                            SizedBox(width: 4),
                                            Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
                                            title: const Text('Hapus Kuis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            content: Text('Apakah Anda yakin ingin menghapus kuis "${q.title}"?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: context.appColors.error, foregroundColor: Colors.white),
                                                onPressed: () async {
                                                  Navigator.pop(dCtx);
                                                  final success = await provider.deleteQuiz(q.id);
                                                  if (!context.mounted) return;
                                                  if (success) {
                                                    await provider.fetchSessionMaterialsList();
                                                    if (!context.mounted) return;
                                                    AppSnackbar.showSuccess(context, 'Kuis berhasil dihapus');
                                                  } else {
                                                    AppSnackbar.showError(context, 'Gagal menghapus kuis');
                                                  }
                                                },
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 12, color: Color(0xFFEF4444)),
                                            SizedBox(width: 4),
                                            Text('Hapus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
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
                  ] else ...[
                    // Form View
                    Text('Judul Kuis *', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: 'Misal: Kuis Evaluasi Sesi 1', border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Durasi (Menit)', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Maksimal Percobaan', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: maxAttemptsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status Kuis', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: statusKuis,
                                isExpanded: true,
                                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'published', child: Text('Diterbitkan (Aktif)', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'draft', child: Text('Draft', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) { if (val != null) setModalState(() => statusKuis = val); },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Komponen Nilai', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: komponenNilai,
                                isExpanded: true,
                                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'cognitive', child: Text('Kognitif', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'psychomotor', child: Text('Psikomotor', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'affective', child: Text('Afektif', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) { if (val != null) setModalState(() => komponenNilai = val); },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: AppRadius.radiusMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Rasio Bobot Nilai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text('PG: ${pgRatio.toInt()}% | Esai: ${(100 - pgRatio).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                          Slider(
                            value: pgRatio,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: (val) => setModalState(() => pgRatio = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => setModalState(() => currentView = 'list'), child: const Text('Kembali')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.onSurface,
                            foregroundColor: context.appColors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) return;
                            final provider = context.read<MentorKencanaProvider>();
                            final payload = {
                              'session_id': session.id,
                              'title': titleController.text.trim(),
                              'duration_minutes': int.tryParse(durationController.text) ?? 30,
                              'max_attempts': int.tryParse(maxAttemptsController.text) ?? 1,
                              'status': statusKuis,
                              'component': komponenNilai,
                              'pg_percentage': pgRatio.toInt(),
                              'is_required': true,
                            };
                            final bool success;
                            if (editingQuizId != null) {
                              success = await provider.updateQuiz(editingQuizId!, payload);
                            } else {
                              success = await provider.createQuiz(payload);
                            }
                            if (!context.mounted) return;
                            if (success) {
                              await provider.fetchSessionMaterialsList();
                              if (!context.mounted) return;
                              setModalState(() {
                                editingQuizId = null;
                                currentView = 'list';
                              });
                              AppSnackbar.showSuccess(context, editingQuizId != null ? 'Kuis berhasil diperbarui' : 'Kuis berhasil dibuat');
                            } else {
                              AppSnackbar.showError(context, editingQuizId != null ? 'Gagal memperbarui kuis' : 'Gagal membuat kuis');
                            }
                          },
                          child: Text(editingQuizId != null ? 'Update Kuis' : 'Simpan Kuis', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }  final Map<int, List<Map<String, dynamic>>> _quizQuestionsCache = {};

  Future<void> _showQuizQuestionsModal(BuildContext context, SessionMaterialItem quiz) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
    );
    final provider = context.read<MentorKencanaProvider>();
    final questions = await provider.fetchQuizQuestions(quiz.id);
    if (!context.mounted) return;
    Navigator.pop(context); // close loading
    _quizQuestionsCache[quiz.id] = questions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final questionsList = _quizQuestionsCache[quiz.id]!;

          return Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz.title, style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                            const Text('Kuis ini berisi pertanyaan evaluasi.', style: TextStyle(fontSize: 11, color: AppColors.neutral600)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daftar Pertanyaan (${questionsList.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddQuestionDialog(
                            context,
                            quizId: quiz.id,
                            onSave: (newQuestionData) async {
                              final provider = context.read<MentorKencanaProvider>();
                              final createdQuestion = await provider.createQuizQuestion({
                                'quiz_id': quiz.id,
                                ...newQuestionData,
                              });
                              if (createdQuestion != null) {
                                setModalState(() {
                                  questionsList.add(createdQuestion);
                                });
                                if (!context.mounted) return;
                                AppSnackbar.showSuccess(context, 'Soal berhasil disimpan');
                              } else {
                                if (!context.mounted) return;
                                AppSnackbar.showError(context, 'Gagal menyimpan soal');
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Tambah Soal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (questionsList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text('Belum ada pertanyaan untuk kuis ini', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questionsList.length,
                      itemBuilder: (context, idx) {
                        final item = questionsList[idx];
                        final opts = (item['options'] as List<dynamic>?) ?? [];
                        return BkuCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE2E8F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text('Bobot: ${item['weight'] ?? item['score'] ?? item['bobot'] ?? 25}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () => _showAddQuestionDialog(
                                      context,
                                      quizId: quiz.id,
                                      initialQuestion: item['question_text'] ?? item['question'] ?? item['pertanyaan'],
                                      initialAnswer: opts.isNotEmpty ? opts.first['option_text'] ?? opts.first['text'] : '',
                                      onSave: (updatedData) async {
                                        final provider = context.read<MentorKencanaProvider>();
                                        if (item['id'] != null) {
                                          await provider.updateQuizQuestion(item['id'], updatedData);
                                        }
                                        setModalState(() {
                                          questionsList[idx] = {...item, ...updatedData};
                                        });
                                        if (!context.mounted) return;
                                        AppSnackbar.showSuccess(context, 'Soal berhasil diperbarui');
                                      },
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Edit', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () async {
                                      final provider = context.read<MentorKencanaProvider>();
                                      if (item['id'] != null) {
                                        await provider.deleteQuizQuestion(item['id']);
                                      }
                                      setModalState(() {
                                        questionsList.removeAt(idx);
                                      });
                                      if (!context.mounted) return;
                                      AppSnackbar.showSuccess(context, 'Soal berhasil dihapus');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Hapus', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['question_text'] ?? item['question'] ?? item['pertanyaan'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              if (opts.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Column(
                                  children: [
                                    for (int i = 0; i < opts.length; i += 2)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildQuestionOptionCard(
                                                opts[i]['label'] ?? String.fromCharCode(65 + i),
                                                opts[i]['text'] ?? opts[i]['option_text'] ?? '',
                                                isCorrect: opts[i]['is_correct'] == true || opts[i]['is_correct'] == 1,
                                              ),
                                            ),
                                            if (i + 1 < opts.length) ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: _buildQuestionOptionCard(
                                                  opts[i + 1]['label'] ?? String.fromCharCode(65 + i + 1),
                                                  opts[i + 1]['text'] ?? opts[i + 1]['option_text'] ?? '',
                                                  isCorrect: opts[i + 1]['is_correct'] == true || opts[i + 1]['is_correct'] == 1,
                                                ),
                                              ),
                                            ] else
                                              const Spacer(),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionOptionCard(String label, String text, {required bool isCorrect}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isCorrect ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                color: isCorrect ? const Color(0xFF166534) : const Color(0xFF334155),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_rounded, size: 14, color: Color(0xFF166534)),
          ],
        ],
      ),
    );
  }

  void _showAddQuestionDialog(
    BuildContext context, {
    int? quizId,
    String? initialQuestion,
    String? initialAnswer,
    required Function(Map<String, dynamic>) onSave,
  }) {
    final questionCtrl = TextEditingController(text: initialQuestion ?? '');
    String tipeSoal = 'Pilihan Ganda';
    int selectedCorrectOption = 0;
    final optionACtrl = TextEditingController(text: initialAnswer ?? 'Opsi A');
    final optionBCtrl = TextEditingController(text: 'Opsi B');
    final optionCCtrl = TextEditingController(text: 'Opsi C');
    final optionDCtrl = TextEditingController(text: 'Opsi D');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(initialQuestion != null ? 'Edit Soal' : 'Buat Soal Baru', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, size: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Teks Pertanyaan *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                TextField(
                  controller: questionCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Masukkan pertanyaan di sini...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Tipe Soal *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: tipeSoal,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pilihan Ganda', child: Text('Pilihan Ganda', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'Esai', child: Text('Esai / Teks Pendek', style: TextStyle(fontSize: 11))),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => tipeSoal = val);
                  },
                ),
                const SizedBox(height: 14),
                if (tipeSoal == 'Pilihan Ganda') ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('OPSI JAWABAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF64748B))),
                            InkWell(
                              onTap: () => AppSnackbar.showWarning(context, 'Pilihan ganda menggunakan 4 opsi (A, B, C, D)'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('4 Opsi (A - D)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildOptionInputRow(0, selectedCorrectOption, optionACtrl, (idx) => setDialogState(() => selectedCorrectOption = idx)),
                        const SizedBox(height: 6),
                        _buildOptionInputRow(1, selectedCorrectOption, optionBCtrl, (idx) => setDialogState(() => selectedCorrectOption = idx)),
                        const SizedBox(height: 6),
                        _buildOptionInputRow(2, selectedCorrectOption, optionCCtrl, (idx) => setDialogState(() => selectedCorrectOption = idx)),
                        const SizedBox(height: 6),
                        _buildOptionInputRow(3, selectedCorrectOption, optionDCtrl, (idx) => setDialogState(() => selectedCorrectOption = idx)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.onSurface,
                foregroundColor: context.appColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                elevation: 0,
              ),
              onPressed: () {
                if (questionCtrl.text.trim().isEmpty) return;
                final newQuestionData = {
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'quiz_id': quizId,
                  'question': questionCtrl.text.trim(),
                  'pertanyaan': questionCtrl.text.trim(),
                  'question_text': questionCtrl.text.trim(),
                  'question_type': tipeSoal == 'Pilihan Ganda' ? 'multiple_choice' : 'essay',
                  'type': tipeSoal,
                  'weight': 25,
                  'score': 25,
                  'bobot': 25,
                  'options': tipeSoal == 'Pilihan Ganda'
                      ? [
                          {
                            'label': 'A',
                            'text': optionACtrl.text.trim(),
                            'option_text': optionACtrl.text.trim(),
                            'is_correct': selectedCorrectOption == 0,
                            'is_answer': selectedCorrectOption == 0 ? 1 : 0,
                          },
                          {
                            'label': 'B',
                            'text': optionBCtrl.text.trim(),
                            'option_text': optionBCtrl.text.trim(),
                            'is_correct': selectedCorrectOption == 1,
                            'is_answer': selectedCorrectOption == 1 ? 1 : 0,
                          },
                          {
                            'label': 'C',
                            'text': optionCCtrl.text.trim(),
                            'option_text': optionCCtrl.text.trim(),
                            'is_correct': selectedCorrectOption == 2,
                            'is_answer': selectedCorrectOption == 2 ? 1 : 0,
                          },
                          {
                            'label': 'D',
                            'text': optionDCtrl.text.trim(),
                            'option_text': optionDCtrl.text.trim(),
                            'is_correct': selectedCorrectOption == 3,
                            'is_answer': selectedCorrectOption == 3 ? 1 : 0,
                          },
                        ]
                      : [],
                };
                Navigator.pop(ctx);
                onSave(newQuestionData);
              },
              child: const Text('Simpan Soal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionInputRow(int index, int selectedIndex, TextEditingController ctrl, Function(int) onSelect) {
    final isSelected = index == selectedIndex;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1.0),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
                border: Border.all(color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF94A3B8), width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => ctrl.clear(),
          ),
        ],
      ),
    );
  }

  void _showManageTasksModal(BuildContext context, SessionMaterialData session) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String tipePengumpulan = 'Teks Online';
    String status = 'published';
    String komponenNilai = 'cognitive';
    String currentView = 'list';
    bool isMandatory = true;
    int? editingTaskId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = context.watch<MentorKencanaProvider>();
          final currentSession = provider.sessionMaterials.firstWhere(
            (s) => s.id == session.id,
            orElse: () => session,
          );
          final taskList = currentSession.assignments;

          return Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.xl,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentView == 'list' ? 'Kelola Tugas: ${session.title}' : (editingTaskId != null ? 'Edit Tugas' : 'Tambah Tugas Baru'), style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(currentView == 'list' ? 'Kelola daftar tugas untuk sesi ini.' : 'Tentukan detail dan batas waktu pengumpulan tugas.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                          ),
                          child: const Icon(Icons.close, size: 14, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (currentView == 'list') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.assignment_outlined, size: 20, color: Color(0xFF1E3A8A)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daftar Tugas Sesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text('${taskList.length} tugas terdaftar', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              editingTaskId = null;
                              titleController.clear();
                              descController.clear();
                              setModalState(() => currentView = 'form');
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Tambah Tugas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (taskList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('Belum ada tugas untuk sesi ini', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskList.length,
                        itemBuilder: (context, idx) {
                          final t = taskList[idx];
                          final formattedDueDate = t.dueDate.isNotEmpty ? t.dueDate : '6 Agt 2026, 21:00 WIB';
                          final formattedStartDate = t.startDate.isNotEmpty ? t.startDate : '6 Agt 2026, 15:00 WIB';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.assignment_outlined, size: 18, color: Color(0xFF1E40AF)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              t.title,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF7ED),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFFFEDD5)),
                                            ),
                                            child: const Text(
                                              'WAJIB',
                                              style: TextStyle(color: Color(0xFFEA580C), fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'DITERBITKAN',
                                        style: TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF8F5),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFF1F5F9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('TIPE PENGUMPULAN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                            const SizedBox(height: 2),
                                            Text(t.submissionType.isNotEmpty ? t.submissionType : 'LINK URL', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF8F5),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFF1F5F9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('TENGGAT WAKTU', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                            const SizedBox(height: 2),
                                            Text(formattedDueDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF8F5),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFF1F5F9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('KOMPONEN NILAI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                            const SizedBox(height: 2),
                                            Text(t.component.isNotEmpty ? t.component : 'Psikomotor', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text('Mulai: $formattedStartDate', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        editingTaskId = t.id;
                                        titleController.text = t.title;
                                        status = t.status.isNotEmpty ? t.status : 'published';
                                        komponenNilai = t.component.isNotEmpty ? t.component : 'cognitive';
                                        setModalState(() {
                                          currentView = 'form';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 12, color: Color(0xFF1D4ED8)),
                                            SizedBox(width: 4),
                                            Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
                                            title: const Text('Hapus Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            content: Text('Apakah Anda yakin ingin menghapus tugas "${t.title}"?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: context.appColors.error, foregroundColor: Colors.white),
                                                onPressed: () async {
                                                  Navigator.pop(dCtx);
                                                  final success = await provider.deleteAssignment(t.id);
                                                  if (!context.mounted) return;
                                                  if (success) {
                                                    await provider.fetchSessionMaterialsList();
                                                    if (!context.mounted) return;
                                                    AppSnackbar.showSuccess(context, 'Tugas berhasil dihapus');
                                                  } else {
                                                    AppSnackbar.showError(context, 'Gagal menghapus tugas');
                                                  }
                                                },
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 12, color: Color(0xFFDC2626)),
                                            SizedBox(width: 4),
                                            Text('Hapus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
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
                  ] else ...[
                    // Form View
                    Text('JUDUL TUGAS *', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: 'Contoh: Tugas Essay Kepemimpinan', border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                    const SizedBox(height: 12),
                    Text('INSTRUKSI / DESKRIPSI TUGAS', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: 'Jelaskan apa yang harus dilakukan peserta...', border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.all(10)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TIPE PENGUMPULAN', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: tipePengumpulan,
                                isExpanded: true,
                                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'Teks Online', child: Text('Teks Online', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'File Upload', child: Text('File Upload', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) { if (val != null) setModalState(() => tipePengumpulan = val); },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: isMandatory,
                            onChanged: (val) => setModalState(() => isMandatory = val ?? true),
                            title: const Text('Tugas Wajib Diselesaikan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('STATUS', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: status,
                                isExpanded: true,
                                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'published', child: Text('Diterbitkan', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'draft', child: Text('Draft', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) { if (val != null) setModalState(() => status = val); },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KOMPONEN NILAI', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: komponenNilai,
                                isExpanded: true,
                                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: AppRadius.radiusMd), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'cognitive', child: Text('Kognitif', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'psychomotor', child: Text('Psikomotor', style: TextStyle(fontSize: 11))),
                                  DropdownMenuItem(value: 'affective', child: Text('Afektif', style: TextStyle(fontSize: 11))),
                                ],
                                onChanged: (val) { if (val != null) setModalState(() => komponenNilai = val); },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => setModalState(() => currentView = 'list'), child: const Text('Kembali')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.onSurface,
                            foregroundColor: context.appColors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) return;
                            final provider = context.read<MentorKencanaProvider>();
                            final payload = {
                              'session_id': session.id,
                              'title': titleController.text.trim(),
                              'instruction': descController.text.trim(),
                              'status': status,
                              'component': komponenNilai,
                              'is_mandatory': isMandatory,
                            };
                            final bool success;
                            if (editingTaskId != null) {
                              success = await provider.updateAssignment(editingTaskId!, payload);
                            } else {
                              success = await provider.createAssignment(payload);
                            }
                            if (!context.mounted) return;
                            if (success) {
                              await provider.fetchSessionMaterialsList();
                              if (!context.mounted) return;
                              setModalState(() {
                                editingTaskId = null;
                                currentView = 'list';
                              });
                              AppSnackbar.showSuccess(context, editingTaskId != null ? 'Tugas berhasil diperbarui' : 'Tugas berhasil disimpan');
                            } else {
                              AppSnackbar.showError(context, editingTaskId != null ? 'Gagal memperbarui tugas' : 'Gagal membuat tugas');
                            }
                          },
                          child: Text(editingTaskId != null ? 'Update Tugas' : 'Simpan Tugas', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showActionMenu(BuildContext context, SessionMaterialData session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kelola Sesi: ${session.title}', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.menu_book_rounded, color: context.appColors.onSurface),
              title: const Text('Kelola Materi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                _showManageMaterialsModal(context, session);
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline_rounded, color: context.appColors.onSurface),
              title: const Text('Kelola Kuis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                _showManageQuizzesModal(context, session);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined, color: context.appColors.onSurface),
              title: const Text('Kelola Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                _showManageTasksModal(context, session);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final sessions = provider.sessionMaterials;

    final filtered = sessions.where((s) {
      if (_searchQuery.isNotEmpty) {
        if (!s.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      }
      if (_selectedStatus != 'all') {
        if (s.status.toLowerCase() != _selectedStatus.toLowerCase()) return false;
      }
      if (_selectedSifat != 'all') {
        final req = _selectedSifat == 'true';
        if (s.isRequired != req) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchSessionMaterialsList(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Kelola Materi & Tugas',
              info: 'Kelola modul pembelajaran, tugas, dan kuis evaluasi per sesi bimbingan Kencana.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/mentor-kencana');
                }
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sesi & Konten Pembelajaran', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih sesi untuk mengelola materi bacaan, kuis evaluasi, dan tugas mahasiswa.',
                      style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Controls Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manajemen Data', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                              Text('Menampilkan daftar data yang terdaftar dalam sistem.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neutral200.withAlpha(150),
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Text(
                            'TOTAL DATA ${filtered.length}',
                            style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Search & Filters
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari sesi bimbingan...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            ),
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                              DropdownMenuItem(value: 'active', child: Text('Aktif')),
                              DropdownMenuItem(value: 'locked', child: Text('Terkunci')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSifat,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            ),
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Semua Sifat')),
                              DropdownMenuItem(value: 'true', child: Text('Wajib')),
                              DropdownMenuItem(value: 'false', child: Text('Opsional')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSifat = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (provider.isLoading && sessions.isEmpty)
              const SliverFillRemaining(child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()))
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text('Ruang sesi masih kosong', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = filtered[index];
                    final isPra = item.stageType == 'pra_kencana';
                    final isFaculty = item.stageType.contains('fakultas') || item.stageType == 'faculty';
                    final stageLabel = isPra ? 'PRA-KENCANA' : (isFaculty ? 'KENCANA FAKULTAS' : 'KENCANA UNIVERSITAS');

                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: AppRadius.radiusSm,
                                  border: Border.all(color: AppColors.neutral300),
                                ),
                                child: Text(
                                  stageLabel,
                                  style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurface, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.isRequired ? AppColors.info.withAlpha(20) : AppColors.neutral200,
                                      borderRadius: AppRadius.radiusSm,
                                    ),
                                    child: Text(
                                      item.isRequired ? 'WAJIB' : 'OPSIONAL',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: item.isRequired ? AppColors.info : AppColors.neutral700,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.status == 'active' ? AppColors.success.withAlpha(20) : AppColors.neutral200,
                                      borderRadius: AppRadius.radiusSm,
                                    ),
                                    child: Text(
                                      item.status,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: item.status == 'active' ? AppColors.success : AppColors.neutral700,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item.title, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(item.description, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                          ],
                          const SizedBox(height: AppSpacing.md),

                          // Badges Row for attached content
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showManageMaterialsModal(context, item),
                                child: _buildContentBadge('${item.materials.length} Materi', AppColors.info, Icons.menu_book_rounded),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _showManageQuizzesModal(context, item),
                                child: _buildContentBadge('${item.quizzes.length} Kuis', AppColors.warning, Icons.help_outline_rounded),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _showManageTasksModal(context, item),
                                child: _buildContentBadge('${item.assignments.length} Tugas', AppColors.secondary, Icons.assignment_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (item.startDate.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    'Timeline: ${item.startDate.split("T").first}',
                                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _showActionMenu(context, item),
                                icon: const Icon(Icons.settings_outlined, size: 12),
                                label: const Text('Kelola', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }, childCount: filtered.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBadge(String label, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurface, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
