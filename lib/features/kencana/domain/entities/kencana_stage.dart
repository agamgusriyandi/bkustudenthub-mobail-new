import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_period.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_session.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';

class KencanaStage extends Equatable {
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final String? endDate;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? id;
  final bool? isPublished;
  final String? name;
  final int? orderNumber;
  final KencanaPeriod? period;
  final int? periodId;
  final List<KencanaSession>? sessions;
  final String? startDate;
  final String? status;
  final String? type;
  final String? updatedAt;

  const KencanaStage({
    this.createdAt,
    this.createdBy,
    this.description,
    this.endDate,
    this.fakultas,
    this.fakultasId,
    this.id,
    this.isPublished,
    this.name,
    this.orderNumber,
    this.period,
    this.periodId,
    this.sessions,
    this.startDate,
    this.status,
    this.type,
    this.updatedAt,
  });

  factory KencanaStage.fromJson(Map<String, dynamic> json) {
    return KencanaStage(
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      endDate: json['end_date'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isPublished: json['is_published'],
      name: json['name'],
      orderNumber:
          json['order_number'] != null
              ? int.tryParse(json['order_number'].toString()) ??
                  json['order_number']
              : null,
      period:
          json['period'] != null
              ? KencanaPeriod.fromJson(json['period'])
              : null,
      periodId:
          json['period_id'] != null
              ? int.tryParse(json['period_id'].toString()) ?? json['period_id']
              : null,
      sessions:
          json['sessions'] != null
              ? (json['sessions'] as List)
                  .map((i) => KencanaSession.fromJson(i))
                  .toList()
              : null,
      startDate: json['start_date'],
      status: json['status'],
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'end_date': endDate,
      'fakultas': fakultas?.toJson(),
      'fakultas_id': fakultasId,
      'id': id,
      'is_published': isPublished,
      'name': name,
      'order_number': orderNumber,
      'period': period?.toJson(),
      'period_id': periodId,
      'sessions': sessions?.map((i) => i.toJson()).toList(),
      'start_date': startDate,
      'status': status,
      'type': type,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    createdBy,
    description,
    endDate,
    fakultas,
    fakultasId,
    id,
    isPublished,
    name,
    orderNumber,
    period,
    periodId,
    sessions,
    startDate,
    status,
    type,
    updatedAt,
  ];
}
