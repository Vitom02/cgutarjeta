import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'score.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 7)
class TarjetaScores extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<int> scores1;

  @HiveField(2)
  final List<int> scores2;

  TarjetaScores({
    String? id,
    List<int>? scores1,
    List<int>? scores2,
  })  : id = id ?? _uuid.v4(),
        scores1 = scores1 ?? List.filled(18, 0),
        scores2 = scores2 ?? List.filled(18, 0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scores1': scores1,
      'scores2': scores2,
    };
  }

  factory TarjetaScores.fromJson(Map<String, dynamic> json) {
    return TarjetaScores(
      id: json['id'] as String?,
      scores1: json['scores1'] != null ? List<int>.from(json['scores1']) : null,
      scores2: json['scores2'] != null ? List<int>.from(json['scores2']) : null,
    );
  }
}

