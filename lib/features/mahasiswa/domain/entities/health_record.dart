import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HealthRecord {
  final String id;
  final double height;
  final double weight;
  final String bloodPressure;
  final int heartRate;
  final double temperature;
  final DateTime date;
  final String bloodType;
  final String notes;
  final int? gulaDarah;

  HealthRecord({
    required this.id,
    required this.height,
    required this.weight,
    required this.bloodPressure,
    required this.heartRate,
    required this.temperature,
    required this.date,
    this.bloodType = '-',
    this.notes = '',
    this.gulaDarah,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiStatus {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get bmiColor {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
