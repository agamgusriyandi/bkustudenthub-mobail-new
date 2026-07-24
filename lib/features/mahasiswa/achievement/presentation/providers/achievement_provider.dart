import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String level; // 'Nasional', 'Internasional', 'Provinsi'
  final String date;
  final String status; // 'Valid', 'Pending', 'Ditolak'
  final IconData icon;

  Achievement({
    required this.id,
    required this.title,
    required this.level,
    required this.date,
    required this.status,
    required this.icon,
  });
}

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      title: 'Juara 1 Lomba Karya Tulis Ilmiah Farmasi',
      level: 'Nasional',
      date: '12 Aug 2024',
      status: 'Valid',
      icon: Icons.emoji_events_rounded,
    ),
    Achievement(
      id: '2',
      title: 'Peserta Terbaik LDK Mahasiswa',
      level: 'Universitas',
      date: '20 Jul 2024',
      status: 'Valid',
      icon: Icons.stars_rounded,
    ),
    Achievement(
      id: '3',
      title: 'Finalis Olimpiade Farmakologi',
      level: 'Provinsi',
      date: '05 Sep 2024',
      status: 'Pending',
      icon: Icons.workspace_premium_rounded,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  int get totalValid => _achievements.where((a) => a.status == 'Valid').length;
  int get totalPending =>
      _achievements.where((a) => a.status == 'Pending').length;
  int get totalCount => _achievements.length;

  void addAchievement(Achievement achievement) {
    _achievements.add(achievement);
    notifyListeners();
  }
}
