import 'package:flutter/material.dart';

class Scholarship {
  final String id;
  final String title;
  final String provider;
  final String deadline;
  final String amount;
  final String category; // 'Internal', 'Eksternal'
  final bool isApplied;

  Scholarship({
    required this.id,
    required this.title,
    required this.provider,
    required this.deadline,
    required this.amount,
    required this.category,
    this.isApplied = false,
  });
}

class ScholarshipProvider extends ChangeNotifier {
  String _selectedCategory = 'Internal';
  String get selectedCategory => _selectedCategory;

  final List<Scholarship> _allScholarships = [
    Scholarship(
      id: '1',
      title: 'Beasiswa Berprestasi BKU',
      provider: 'Yayasan Bhakti Kencana',
      deadline: '20 Okt 2024',
      amount: 'Full Tuition Fee',
      category: 'Internal',
    ),
    Scholarship(
      id: '2',
      title: 'Beasiswa Tahfidz Quran',
      provider: 'Kemahasiswaan BKU',
      deadline: '15 Nov 2024',
      amount: 'Rp 5.000.000 / Sem',
      category: 'Internal',
    ),
    Scholarship(
      id: '3',
      title: 'Beasiswa Bank Indonesia',
      provider: 'Bank Indonesia',
      deadline: '30 Sep 2024',
      amount: 'Rp 1.000.000 / Bln',
      category: 'Eksternal',
    ),
    Scholarship(
      id: '4',
      title: 'Djarum Beasiswa Plus',
      provider: 'Djarum Foundation',
      deadline: '05 Okt 2024',
      amount: 'Rp 750.000 / Bln',
      category: 'Eksternal',
    ),
  ];

  List<Scholarship> get filteredScholarships {
    return _allScholarships
        .where((s) => s.category == _selectedCategory)
        .toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
