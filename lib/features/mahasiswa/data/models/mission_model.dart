import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  MissionModel({
    super.id,
    super.title,
    super.desc,
    super.icon,
    super.color,
    super.stage,
    super.type,
    super.score,
    super.isCompleted,
  });

  // Note: Serialization for IconData and Color would typically use code points and hex strings.
  // For now, providing basic structure.
}
