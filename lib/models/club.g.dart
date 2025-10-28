// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubAdapter extends TypeAdapter<Club> {
  @override
  final int typeId = 11;

  @override
  Club read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Club(
      codigo: fields[0] as String,
      club: fields[1] as String,
      url: fields[2] as String,
      imagen: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Club obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.codigo)
      ..writeByte(1)
      ..write(obj.club)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.imagen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
