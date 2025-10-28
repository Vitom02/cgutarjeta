import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'bochas.dart';
import 'score.dart';

part 'tarjeta.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 6)
class Tarjeta {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombreTorneo;

  @HiveField(2)
  final String matricula;

  @HiveField(3)
  final String matriculaCompanion;

  @HiveField(4)
  final String nombreJugador;

  @HiveField(5)
  final Bocha? bochaSeleccionada1;

  @HiveField(6)
  final Bocha? bochaSeleccionada2;

  @HiveField(7)
  final TarjetaScores? tarjetaScores;

  Tarjeta({
    String? id,
    required this.nombreTorneo,
    required this.matricula,
    required this.matriculaCompanion,
    required this.nombreJugador,
    this.bochaSeleccionada1,
    this.bochaSeleccionada2,
    this.tarjetaScores,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreTorneo': nombreTorneo,
      'matricula': matricula,
      'matriculaCompanion': matriculaCompanion,
      'nombreJugador': nombreJugador,
      'bochaSeleccionada1': bochaSeleccionada1?.toJson(),
      'bochaSeleccionada2': bochaSeleccionada2?.toJson(),
      'tarjetaScores': tarjetaScores?.toJson(),
    };
  }

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'] as String?,
      nombreTorneo: json['nombreTorneo'] ?? '',
      matricula: json['matricula'] ?? '',
      matriculaCompanion: json['matriculaCompanion'] ?? '',
      nombreJugador: json['nombreJugador'] ?? '',
      bochaSeleccionada1: json['bochaSeleccionada1'] != null
          ? Bocha.fromJson(json['bochaSeleccionada1'])
          : null,
      bochaSeleccionada2: json['bochaSeleccionada2'] != null
          ? Bocha.fromJson(json['bochaSeleccionada2'])
          : null,
      tarjetaScores: json['tarjetaScores'] != null
          ? TarjetaScores.fromJson(json['tarjetaScores'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tarjeta &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}

