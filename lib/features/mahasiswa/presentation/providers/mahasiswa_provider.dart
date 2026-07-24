import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/data/repositories/mahasiswa_repository_impl.dart';

class MahasiswaProvider extends ChangeNotifier {
  final MahasiswaRepository mahasiswaRepository;

  MahasiswaProvider({required this.mahasiswaRepository});
}
