import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

Future<void> pickAvatar(BuildContext context) async {
  final provider = context.read<ProfileProvider>();
  final primaryColor = context.appColors.primary;
  final result = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1000,
    maxHeight: 1000,
    imageQuality: 85,
  );
  if (result != null) {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: primaryColor,
            // ignore: use_build_context_synchronously
            toolbarWidgetColor: context.appColors.surface,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Potong Foto',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        await provider.uploadAvatar(croppedFile.path);
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => CustomDialog(
                  title: 'Berhasil',
                  content: 'Foto profil berhasil diperbarui',
                  isSuccess: true,
                  cancelText: '',
                  confirmText: 'Tutup',
                  confirmColor: context.appColors.success,
                  onCancel: () {},
                  onConfirm: () => Navigator.pop(ctx),
                ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => CustomDialog(
                title: 'Gagal',
                content: ErrorHandler.getMessage(e),
                cancelText: '',
                confirmText: 'Tutup',
                isDestructive: true,
                onCancel: () {},
                onConfirm: () => Navigator.pop(ctx),
              ),
        );
      }
    }
  }
}

Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral500,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

String formatBirthPlaceDate(String val) {
  if (val.isEmpty ||
      val.trim() == ',' ||
      val.contains('0001-01-01') ||
      val.contains('0001-01-01T00:00:00Z')) {
    return 'Belum diisi';
  }
  try {
    final parts = val.split(',');
    if (parts.length > 1) {
      final tempat = parts[0].trim();
      final tanggalStr = parts[1].trim();
      if (tanggalStr.contains('0001-01-01')) {
        return tempat.isEmpty ? 'Belum diisi' : tempat;
      }
      final parsedDate = DateTime.tryParse(tanggalStr);
      if (parsedDate != null) {
        final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate.toLocal());
        return '$tempat, $formattedDate';
      }
    } else {
      final parsedDate = DateTime.tryParse(val);
      if (parsedDate != null) {
        return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate.toLocal());
      }
    }
  } catch (_) {}
  return val;
}

String getActiveOrganizationRole(OrganizationProvider organization) {
  final activeOrgs =
      organization.organizationHistory.where((org) {
        final status = org.statusVerifikasi.toLowerCase();
        return status == 'aktif' ||
            status == 'disetujui' ||
            status == 'validated';
      }).toList();
  if (activeOrgs.isNotEmpty) {
    final org = activeOrgs.first;
    return '${org.jabatan} - ${org.namaOrganisasi}';
  }
  return 'Mahasiswa Aktif';
}
