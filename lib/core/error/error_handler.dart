import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is DioException) {
      if (error.error is String) {
        return error.error as String;
      }

      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map) {
          // Parse Laravel validation errors
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            return errors.values
                .map((v) {
                  if (v is List) return v.join('\n');
                  return v.toString();
                })
                .join('\n');
          }

          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['error'] != null) {
            return data['error'].toString();
          }
        }

        switch (error.response?.statusCode) {
          case 400:
            return 'Permintaan tidak valid. Silakan periksa kembali data yang Anda masukkan.';
          case 401:
            return 'Anda belum masuk. Silakan login terlebih dahulu.';
          case 403:
            return 'Anda tidak memiliki izin untuk mengakses ini.';
          case 404:
            return 'Data tidak ditemukan (404).';
          case 422:
            return 'Validasi gagal. Periksa kembali input Anda.';
          case 500:
          case 502:
          case 503:
            return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi terputus (Timeout). Periksa internet Anda.';
        case DioExceptionType.connectionError:
          return 'Gagal terhubung ke server. Pastikan internet Anda aktif.';
        default:
          return 'Terjadi kesalahan jaringan.';
      }
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'Terjadi kesalahan yang tidak terduga.';
  }
}
