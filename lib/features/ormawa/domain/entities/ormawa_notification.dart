class OrmawaNotification {
  final String id;
  final String ormawaId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  OrmawaNotification({
    required this.id,
    required this.ormawaId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}