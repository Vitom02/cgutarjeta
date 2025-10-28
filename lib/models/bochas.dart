import 'package:hive/hive.dart';
import 'hoyo.dart';

part 'bochas.g.dart';

@HiveType(typeId: 4)
class Bocha {
  @HiveField(0)
  final int idBocha;

  @HiveField(1)
  final String color;

  @HiveField(2)
  final String sexo;

  @HiveField(3)
  final List<Hoyo> hoyos;

  Bocha({
    required this.idBocha,
    required this.color,
    required this.sexo,
    required this.hoyos,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bocha &&
          runtimeType == other.runtimeType &&
          idBocha == other.idBocha);

  @override
  int get hashCode => idBocha.hashCode;

  factory Bocha.fromJson(Map<String, dynamic> json) {
    var hoyosJson = json['hoyos'] as List<dynamic>? ?? [];
    List<Hoyo> hoyosList = hoyosJson.map((hoyo) => Hoyo.fromJson(hoyo)).toList();

    return Bocha(
      idBocha: json['idBocha'],
      sexo: json['sexo'],
      color: json['color'],
      hoyos: hoyosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBocha': idBocha,
      'color': color,
      'sexo': sexo,
      'hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
    };
  }
}

