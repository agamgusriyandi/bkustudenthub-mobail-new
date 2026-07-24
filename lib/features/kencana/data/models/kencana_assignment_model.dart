class KencanaAssignmentModel {
  final int id;

  KencanaAssignmentModel({required this.id});

  factory KencanaAssignmentModel.fromJson(Map<String, dynamic> json) {
    return KencanaAssignmentModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
