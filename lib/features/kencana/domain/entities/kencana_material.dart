import 'package:equatable/equatable.dart';

class KencanaMaterial extends Equatable {
  final String? content;
  final String? createdAt;
  final int? fakultasId;
  final String? fileUrl;
  final int? id;
  final bool? isRequired;
  final String? linkUrl;
  final int? orderNumber;
  final String? originalFileName;
  final int? sessionId;
  final String? title;
  final String? type;
  final String? updatedAt;

  const KencanaMaterial({
    this.content,
    this.createdAt,
    this.fakultasId,
    this.fileUrl,
    this.id,
    this.isRequired,
    this.linkUrl,
    this.orderNumber,
    this.originalFileName,
    this.sessionId,
    this.title,
    this.type,
    this.updatedAt,
  });

  factory KencanaMaterial.fromJson(Map<String, dynamic> json) {
    return KencanaMaterial(
      content: json['content'],
      createdAt: json['created_at'],
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      fileUrl: json['file_url'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isRequired: json['is_required'],
      linkUrl: json['link_url'],
      orderNumber:
          json['order_number'] != null
              ? int.tryParse(json['order_number'].toString()) ??
                  json['order_number']
              : null,
      originalFileName: json['original_file_name'],
      sessionId:
          json['session_id'] != null
              ? int.tryParse(json['session_id'].toString()) ??
                  json['session_id']
              : null,
      title: json['title'],
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'created_at': createdAt,
      'fakultas_id': fakultasId,
      'file_url': fileUrl,
      'id': id,
      'is_required': isRequired,
      'link_url': linkUrl,
      'order_number': orderNumber,
      'original_file_name': originalFileName,
      'session_id': sessionId,
      'title': title,
      'type': type,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    content,
    createdAt,
    fakultasId,
    fileUrl,
    id,
    isRequired,
    linkUrl,
    orderNumber,
    originalFileName,
    sessionId,
    title,
    type,
    updatedAt,
  ];
}
