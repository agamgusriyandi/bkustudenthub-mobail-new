import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, context.appColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, context.appColors.error);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, context.appColors.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, context.appColors.primary);
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: context.appColors.onPrimary)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
      ),
    );
  }
}
