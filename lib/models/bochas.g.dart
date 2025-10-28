// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bochas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BochaAdapter extends TypeAdapter<Bocha> {
  @override
  final int typeId = 4;

  @override
  Bocha read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bocha(
      idBocha: fields[0] as int,
      color: fields[1] as String,
      sexo: fields[2] as String,
      hoyos: (fields[3] as List).cast<Hoyo>(),
    );
  }

  @override
  void write(BinaryWriter writer, Bocha obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idBocha)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.sexo)
      ..writeByte(3)
      ..write(obj.hoyos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BochaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
