import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Shared helper for consistent error handling across the app
///
/// Usage:
/// ```dart
/// // Parse error for display
/// String message = ErrorHelper.getMessage(error);
///
/// // Show snackbar with error
/// ErrorHelper.showSnackBar(context, error);
/// ```
class ErrorHelper {
  ErrorHelper._();

  /// Extract user-friendly error message from various error types
  static String getMessage(
    dynamic error, {
    String fallback = 'Terjadi kesalahan',
  }) {
    if (error == null) return fallback;

    // DioException
    if (error is DioException) {
      return _parseDioError(error);
    }

    // Standard Exception
    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception: " prefix if present
      if (message.startsWith('Exception: ')) {
        return message.substring(10);
      }
      return message;
    }

    // String error
    if (error is String) {
      return error.isEmpty ? fallback : error;
    }

    return fallback;
  }

  /// Parse DioException to user-friendly message
  static String _parseDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Periksa koneksi internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespons. Coba lagi.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat tidak valid.';
      case DioExceptionType.badResponse:
        return _parseHttpStatus(
          error.response?.statusCode,
          error.response?.data,
        );
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      case DioExceptionType.unknown:
        return error.message ?? 'Terjadi kesalahan tidak diketahui.';
    }
  }

  /// Parse HTTP status code to user-friendly message
  static String _parseHttpStatus(int? statusCode, dynamic data) {
    // Try to extract message from response body
    if (data is Map<String, dynamic>) {
      // Check common error message fields
      final message =
          data['message'] ?? data['error'] ?? data['errors'] ?? data['detail'];
      if (message != null) {
        if (message is List) {
          return message.join(', ');
        }
        return message.toString();
      }
    }

    // Fallback to status code
    switch (statusCode) {
      case 400:
        return 'Data tidak valid.';
      case 401:
        return 'Sesi telah berakhir. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Validasi gagal. Periksa input Anda.';
      case 429:
        return 'Terlalu banyak permintaan. Coba beberapa saat lagi.';
      case 500:
        return 'Server sedang gangguan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan (code: $statusCode)';
    }
  }

  /// Show error snackbar with consistent styling
  static void showSnackBar(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final message = customMessage ?? getMessage(error);
    AppSnackbar.showError(context, message);
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    AppSnackbar.showSuccess(context, message);
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    AppSnackbar.showWarning(context, message);
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout;
    }
    return false;
  }

  /// Check if error is an auth error (401/403)
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 ||
          error.response?.statusCode == 403;
    }
    return false;
  }

  /// Check if error is a server error (5xx)
  static bool isServerError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode != null && statusCode >= 500 && statusCode < 600;
    }
    return false;
  }
}
