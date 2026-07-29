import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared helper for counseling-related status colors and labels
///
/// Usage:
/// ```dart
/// Color color = CounselingStatusHelper.getStatusColor(status, context);
/// String label = CounselingStatusHelper.getStatusLabel(status);
/// ```
class CounselingStatusHelper {
  CounselingStatusHelper._();

  /// Get color for booking status
  static Color getBookingStatusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final warning = AppColors.warning;
    final success = AppColors.success;
    final error = AppColors.error;
    final grey = AppColors.neutral500;

    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return warning;
      case 'dikonfirmasi':
      case 'confirmed':
        return primary;
      case 'selesai':
      case 'completed':
        return success;
      case 'ditolak':
      case 'cancelled':
      case 'canceled':
        return error;
      default:
        return grey;
    }
  }

  /// Get color for referral status
  static Color getReferralStatusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final warning = AppColors.warning;
    final success = AppColors.success;
    final error = AppColors.error;
    final grey = AppColors.neutral500;

    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'sent':
        return primary;
      case 'received':
        return success;
      case 'rejected':
        return error;
      default:
        return grey;
    }
  }

  /// Get display label for booking status
  static String getBookingStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return 'Menunggu';
      case 'dikonfirmasi':
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'ditolak':
      case 'cancelled':
      case 'canceled':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Get display label for referral status
  static String getReferralStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'sent':
        return 'Sudah Dikirim';
      case 'received':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Get icon for booking status
  static IconData getBookingStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return Icons.schedule;
      case 'dikonfirmasi':
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'selesai':
      case 'completed':
        return Icons.task_alt;
      case 'ditolak':
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Check if booking is actionable (can be confirmed/rejected)
  static bool isBookingActionable(String status) {
    return status.toLowerCase() == 'menunggu' ||
        status.toLowerCase() == 'pending';
  }

  /// Check if referral can be sent
  static bool canSendReferral(String status) {
    return status.toLowerCase() == 'pending';
  }

  /// Check if referral can be marked as received
  static bool canConfirmReceived(String status) {
    return status.toLowerCase() == 'sent';
  }
}
