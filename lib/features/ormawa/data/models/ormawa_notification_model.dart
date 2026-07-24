import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notification.dart';

class OrmawaNotificationModel extends OrmawaNotification {
  OrmawaNotificationModel({
    required super.id,
    required super.ormawaId,
    required super.type,
    required super.title,
    required super.message,
    required super.isRead,
    required super.createdAt,
  });

  factory OrmawaNotificationModel.fromJson(Map<String, dynamic> json) {
    return OrmawaNotificationModel(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      ormawaId: (json['OrmawaID'] ?? json['ormawaId'] ?? '').toString(),
      type: json['Tipe'] ?? json['type'] ?? '',
      title: json['Judul'] ?? json['title'] ?? '',
      message: json['Pesan'] ?? json['message'] ?? '',
      isRead: json['IsRead'] ?? json['isRead'] ?? json['is_read'] ?? false,
      createdAt:
          DateTime.tryParse(
            json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'OrmawaID': int.tryParse(ormawaId),
      'Tipe': type,
      'Judul': title,
      'Pesan': message,
      'IsRead': isRead,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }
}
