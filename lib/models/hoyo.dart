import 'package:hive/hive.dart';

part 'hoyo.g.dart';

@HiveType(typeId: 3)
class Hoyo {
  @HiveField(0)
  final int numeroHoyo;

  @HiveField(1)
  final int par;

  @HiveField(2)
  final int? handicap;

  Hoyo({
    required this.numeroHoyo,
    required this.par,
    required this.handicap,
  });

  factory Hoyo.fromJson(Map<String, dynamic> json) {
    return Hoyo(
      numeroHoyo: json['numeroHoyo'] ?? 0,
      par: json['par'] ?? 0,
      handicap: json['handicap'] != null ? json['handicap'] as int? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroHoyo': numeroHoyo,
      'par': par,
      'handicap': handicap,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hoyo &&
          runtimeType == other.runtimeType &&
          numeroHoyo == other.numeroHoyo &&
          par == other.par &&
          handicap == other.handicap;

  @override
  int get hashCode => numeroHoyo.hashCode ^ par.hashCode ^ handicap.hashCode;
}

