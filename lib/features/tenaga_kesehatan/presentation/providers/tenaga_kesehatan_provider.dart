import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/repositories/tenaga_kesehatan_repository_impl.dart';

class TenagaKesehatanProvider extends ChangeNotifier {
  final TenagaKesehatanRepository tenagaKesehatanRepository;

  TenagaKesehatanProvider({required this.tenagaKesehatanRepository});
}
