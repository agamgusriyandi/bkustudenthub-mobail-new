class KencanaGroupMemberModel {
  final int id;

  KencanaGroupMemberModel({required this.id});

  factory KencanaGroupMemberModel.fromJson(Map<String, dynamic> json) {
    return KencanaGroupMemberModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
