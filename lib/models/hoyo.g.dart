// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hoyo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HoyoAdapter extends TypeAdapter<Hoyo> {
  @override
  final int typeId = 3;

  @override
  Hoyo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hoyo(
      numeroHoyo: fields[0] as int,
      par: fields[1] as int,
      handicap: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Hoyo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.numeroHoyo)
      ..writeByte(1)
      ..write(obj.par)
      ..writeByte(2)
      ..write(obj.handicap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoyoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
