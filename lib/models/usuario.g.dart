// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 5;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      idUsuario: fields[0] as int,
      matricula: fields[1] as String,
      password: fields[2] as String,
      correo: fields[3] as String,
      nombre: fields[4] as String,
      clubs: (fields[5] as List).cast<Club>(),
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idUsuario)
      ..writeByte(1)
      ..write(obj.matricula)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.correo)
      ..writeByte(4)
      ..write(obj.nombre)
      ..writeByte(5)
      ..write(obj.clubs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
