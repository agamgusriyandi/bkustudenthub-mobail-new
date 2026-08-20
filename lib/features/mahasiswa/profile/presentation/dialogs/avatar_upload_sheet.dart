import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

class AvatarUploadSheet extends StatefulWidget {
  const AvatarUploadSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AvatarUploadSheet(),
    );
  }

  @override
  State<AvatarUploadSheet> createState() => _AvatarUploadSheetState();
}

class _AvatarUploadSheetState extends State<AvatarUploadSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _selectedFile = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() => _isUploading = true);

    try {
      final provider = context.read<ProfileProvider>();
      await provider.uploadAvatar(_selectedFile!.path);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Foto profil berhasil diperbarui'),
              ],
            ),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah foto: $e'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Perbarui Foto Profil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih foto terbaikmu dengan format JPG atau PNG',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (_selectedFile != null) ...[
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BkuTheme.primary, width: 3),
                  image: DecorationImage(
                    image: FileImage(File(_selectedFile!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading ? null : () => setState(() => _selectedFile = null),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ganti File', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BkuTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Simpan Foto', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.camera),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_camera_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Kamera',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Ambil foto langsung', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library_rounded, color: Color(0xFFD97706), size: 24),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Galeri',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Pilih dari file HP', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
