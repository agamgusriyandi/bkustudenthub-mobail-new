import 'package:flutter/material.dart';

class Mission {
  final String? id;
  final String? title;
  final String? desc;
  final IconData? icon;
  final Color? color;
  final String? stage;
  final String? type;
  final String? content;
  final String? fileUrl;
  final String? linkUrl;
  int score;
  bool isCompleted;

  Mission({
    this.id,
    this.title,
    this.desc,
    this.icon,
    this.color,
    this.stage,
    this.type,
    this.content,
    this.fileUrl,
    this.linkUrl,
    this.score = 0,
    this.isCompleted = false,
  });
}
