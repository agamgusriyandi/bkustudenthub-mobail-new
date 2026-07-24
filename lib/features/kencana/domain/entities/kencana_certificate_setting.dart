import 'package:equatable/equatable.dart';

class KencanaCertificateSetting extends Equatable {
  final String? createdAt;
  final String? direkturName;
  final String? direkturNik;
  final String? endDate;
  final int? id;
  final String? issueDate;
  final String? leftLogoUrl;
  final String? logoUrl;
  final String? presmaName;
  final String? presmaNpm;
  final String? referenceNumber;
  final String? rektorName;
  final String? rektorNik;
  final String? rightLogoUrl;
  final String? startDate;
  final String? theme;
  final String? updatedAt;

  const KencanaCertificateSetting({
    this.createdAt,
    this.direkturName,
    this.direkturNik,
    this.endDate,
    this.id,
    this.issueDate,
    this.leftLogoUrl,
    this.logoUrl,
    this.presmaName,
    this.presmaNpm,
    this.referenceNumber,
    this.rektorName,
    this.rektorNik,
    this.rightLogoUrl,
    this.startDate,
    this.theme,
    this.updatedAt,
  });

  factory KencanaCertificateSetting.fromJson(Map<String, dynamic> json) {
    return KencanaCertificateSetting(
      createdAt: json['created_at'],
      direkturName: json['direktur_name'],
      direkturNik: json['direktur_nik'],
      endDate: json['end_date'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      issueDate: json['issue_date'],
      leftLogoUrl: json['left_logo_url'],
      logoUrl: json['logo_url'],
      presmaName: json['presma_name'],
      presmaNpm: json['presma_npm'],
      referenceNumber: json['reference_number'],
      rektorName: json['rektor_name'],
      rektorNik: json['rektor_nik'],
      rightLogoUrl: json['right_logo_url'],
      startDate: json['start_date'],
      theme: json['theme'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'direktur_name': direkturName,
      'direktur_nik': direkturNik,
      'end_date': endDate,
      'id': id,
      'issue_date': issueDate,
      'left_logo_url': leftLogoUrl,
      'logo_url': logoUrl,
      'presma_name': presmaName,
      'presma_npm': presmaNpm,
      'reference_number': referenceNumber,
      'rektor_name': rektorName,
      'rektor_nik': rektorNik,
      'right_logo_url': rightLogoUrl,
      'start_date': startDate,
      'theme': theme,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    direkturName,
    direkturNik,
    endDate,
    id,
    issueDate,
    leftLogoUrl,
    logoUrl,
    presmaName,
    presmaNpm,
    referenceNumber,
    rektorName,
    rektorNik,
    rightLogoUrl,
    startDate,
    theme,
    updatedAt,
  ];
}
