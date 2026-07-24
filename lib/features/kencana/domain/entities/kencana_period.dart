import 'package:equatable/equatable.dart';

class KencanaPeriod extends Equatable {
  final double? affectiveWeight;
  final String? bannerUrl;
  final double? cognitiveWeight;
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final String? endDate;
  final String? guidebookUrl;
  final int? id;
  final String? introVideoUrl;
  final String? name;
  final double? passingGrade;
  final String? pmbPeriodeId;
  final double? psychomotorWeight;
  final double? remedialGrade;
  final String? startDate;
  final String? status;
  final String? theme;
  final String? universityPhaseStatus;
  final String? updatedAt;
  final int? year;

  const KencanaPeriod({
    this.affectiveWeight,
    this.bannerUrl,
    this.cognitiveWeight,
    this.createdAt,
    this.createdBy,
    this.description,
    this.endDate,
    this.guidebookUrl,
    this.id,
    this.introVideoUrl,
    this.name,
    this.passingGrade,
    this.pmbPeriodeId,
    this.psychomotorWeight,
    this.remedialGrade,
    this.startDate,
    this.status,
    this.theme,
    this.universityPhaseStatus,
    this.updatedAt,
    this.year,
  });

  factory KencanaPeriod.fromJson(Map<String, dynamic> json) {
    return KencanaPeriod(
      affectiveWeight: json['affective_weight'],
      bannerUrl: json['banner_url'],
      cognitiveWeight: json['cognitive_weight'],
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      endDate: json['end_date'],
      guidebookUrl: json['guidebook_url'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      introVideoUrl: json['intro_video_url'],
      name: json['name'],
      passingGrade: json['passing_grade'],
      pmbPeriodeId: json['pmb_periode_id'],
      psychomotorWeight: json['psychomotor_weight'],
      remedialGrade: json['remedial_grade'],
      startDate: json['start_date'],
      status: json['status'],
      theme: json['theme'],
      universityPhaseStatus: json['university_phase_status'],
      updatedAt: json['updated_at'],
      year:
          json['year'] != null
              ? int.tryParse(json['year'].toString()) ?? json['year']
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'affective_weight': affectiveWeight,
      'banner_url': bannerUrl,
      'cognitive_weight': cognitiveWeight,
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'end_date': endDate,
      'guidebook_url': guidebookUrl,
      'id': id,
      'intro_video_url': introVideoUrl,
      'name': name,
      'passing_grade': passingGrade,
      'pmb_periode_id': pmbPeriodeId,
      'psychomotor_weight': psychomotorWeight,
      'remedial_grade': remedialGrade,
      'start_date': startDate,
      'status': status,
      'theme': theme,
      'university_phase_status': universityPhaseStatus,
      'updated_at': updatedAt,
      'year': year,
    };
  }

  @override
  List<Object?> get props => [
    affectiveWeight,
    bannerUrl,
    cognitiveWeight,
    createdAt,
    createdBy,
    description,
    endDate,
    guidebookUrl,
    id,
    introVideoUrl,
    name,
    passingGrade,
    pmbPeriodeId,
    psychomotorWeight,
    remedialGrade,
    startDate,
    status,
    theme,
    universityPhaseStatus,
    updatedAt,
    year,
  ];
}
