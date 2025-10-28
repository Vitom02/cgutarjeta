import 'dart:convert';
import 'package:hive/hive.dart';
import 'club.dart';

part 'usuario.g.dart';

Usuario usuarioFromJson(String str) => Usuario.fromMap(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

@HiveType(typeId: 5)
class Usuario {
  @HiveField(0)
  final int idUsuario;

  @HiveField(1)
  final String matricula;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String correo;

  @HiveField(4)
  final String nombre;

  @HiveField(5)
  final List<Club> clubs;

  Usuario({
    this.idUsuario = 0,
    this.matricula = '',
    this.password = '',
    this.correo = '',
    this.nombre = '',
    this.clubs = const [],
  });

  factory Usuario.fromMap(List<dynamic> json) => Usuario(
        idUsuario: json[0]["id_usuario"] ?? 0,
        matricula: json[0]["matricula"] ?? '',
        password: json[0]["password"] ?? '',
        correo: json[0]["correo"] ?? '',
        nombre: json[0]["nombre"] ?? '',
        clubs: json.map((x) => Club.fromJson(x)).toList(),
      );

  factory Usuario.vacio() => Usuario(
        idUsuario: 0,
        matricula: '',
        password: '',
        correo: '',
        nombre: '',
        clubs: [],
      );

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "matricula": matricula,
        "password": password,
        "correo": correo,
        "nombre": nombre,
        "clubs": List<dynamic>.from(clubs.map((x) => x.toJson())),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          runtimeType == other.runtimeType &&
          idUsuario == other.idUsuario);

  @override
  int get hashCode => idUsuario.hashCode;
}

