import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sesi Anda telah berakhir, silakan login kembali.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Data yang dikirimkan tidak valid.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal menyimpan/mengambil data dari penyimpanan lokal.']);
}
